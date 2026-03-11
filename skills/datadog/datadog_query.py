#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["requests"]
# ///
"""Query the Datadog API from the command line.

Usage:
    uv run datadog_query.py <command> [subcommand] [options]

Commands:
    validate                         Validate API credentials
    metrics query  --query Q --from T --to T   Query timeseries points
    metrics list   --from T                    List active metrics
    metrics search --filter F                  Search metrics (V2)
    logs search    --query Q [--from T --to T] Search logs
    events list    [--query Q --from T --to T] List events
    monitors list  [--name N --tags T]         List monitors
    monitors search --query Q                  Search monitors
    monitors get   --id ID                     Get a specific monitor
    dashboards list                            List dashboards
    dashboards get --id ID                     Get a specific dashboard
    hosts list     [--filter F]                Search hosts
    incidents list                             List incidents
    incidents search --query Q                 Search incidents
    slos list      [--query Q --tags T]        List SLOs
    slos get       --id ID                     Get a specific SLO
    slos history   --id ID --from T --to T     Get SLO history
    traces search  [--query Q --from T --to T] Search APM spans (300 req/hr)
    traces aggregate [--query Q --group-by G]  Aggregate spans into buckets
    synthetics list                            List synthetic tests
    downtimes list                             List downtimes

Environment variables:
    DD_API_KEY   (required) Datadog API key
    DD_APP_KEY   (required) Datadog Application key
    DD_SITE      (optional) Datadog site, default: datadoghq.com

Time format:
    Epoch seconds (e.g. 1700000000) or ISO 8601 (e.g. 2024-01-15T10:00:00Z).
    Relative times: "1h" (1 hour ago), "30m" (30 min ago), "7d" (7 days ago).
"""

import argparse
import json
import os
import re
import sys
import time
from datetime import datetime, timezone

import requests

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

def get_config():
    api_key = os.environ.get("DD_API_KEY", "")
    app_key = os.environ.get("DD_APP_KEY", "")
    site = os.environ.get("DD_SITE", "datadoghq.com")
    if not api_key:
        die("DD_API_KEY environment variable is not set")
    if not app_key:
        die("DD_APP_KEY environment variable is not set")
    return {
        "api_key": api_key,
        "app_key": app_key,
        "base_url": f"https://api.{site}",
    }


def headers(cfg):
    return {
        "DD-API-KEY": cfg["api_key"],
        "DD-APPLICATION-KEY": cfg["app_key"],
        "Content-Type": "application/json",
    }

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def die(msg):
    print(f"Error: {msg}", file=sys.stderr)
    sys.exit(1)


def parse_time(value):
    """Parse a time string into epoch seconds.

    Accepts:
      - epoch seconds (int or string of digits)
      - ISO 8601 datetime string
      - relative shorthand: 30m, 1h, 6h, 1d, 7d, 30d
    """
    if value is None:
        return None
    value = str(value).strip()

    # "now"
    if value.lower() == "now":
        return int(time.time())

    # Epoch seconds
    if re.fullmatch(r"\d+", value):
        return int(value)

    # Relative time
    m = re.fullmatch(r"(\d+)([mhdw])", value)
    if m:
        amount, unit = int(m.group(1)), m.group(2)
        multipliers = {"m": 60, "h": 3600, "d": 86400, "w": 604800}
        return int(time.time()) - amount * multipliers[unit]

    # ISO 8601
    for fmt in ("%Y-%m-%dT%H:%M:%SZ", "%Y-%m-%dT%H:%M:%S%z", "%Y-%m-%d"):
        try:
            dt = datetime.strptime(value, fmt)
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            return int(dt.timestamp())
        except ValueError:
            continue

    die(f"Cannot parse time: {value!r}  (use epoch, ISO 8601, or relative like 1h/30m/7d)")


def parse_time_iso(value):
    """Parse a time string into ISO 8601 format (for V2 endpoints)."""
    epoch = parse_time(value)
    if epoch is None:
        return None
    return datetime.fromtimestamp(epoch, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def do_get(cfg, path, params=None):
    url = f"{cfg['base_url']}{path}"
    resp = requests.get(url, headers=headers(cfg), params=params)
    check_rate_limit(resp)
    if not resp.ok:
        die(f"HTTP {resp.status_code}: {resp.text}")
    return resp.json()


def do_post(cfg, path, body):
    url = f"{cfg['base_url']}{path}"
    resp = requests.post(url, headers=headers(cfg), json=body)
    check_rate_limit(resp)
    if not resp.ok:
        die(f"HTTP {resp.status_code}: {resp.text}")
    return resp.json()


def check_rate_limit(resp):
    remaining = resp.headers.get("X-RateLimit-Remaining")
    if remaining is not None and int(remaining) < 5:
        reset = resp.headers.get("X-RateLimit-Reset", "?")
        print(f"Warning: rate limit low ({remaining} remaining, resets in {reset}s)", file=sys.stderr)


def output(data):
    print(json.dumps(data, indent=2))


def paginate_cursor(cfg, path, body, max_pages=1, page_limit=50):
    """Generic cursor-based pagination for V2 POST search endpoints."""
    results = []
    body.setdefault("page", {})
    body["page"]["limit"] = page_limit
    for _ in range(max_pages):
        data = do_post(cfg, path, body)
        results.append(data)
        cursor = (data.get("meta", {}).get("page", {}).get("after")
                  or data.get("meta", {}).get("pagination", {}).get("next_cursor"))
        if not cursor:
            break
        body["page"]["cursor"] = cursor
    if len(results) == 1:
        return results[0]
    # Merge data arrays
    merged = results[0]
    key = "data" if "data" in merged else None
    if key:
        for r in results[1:]:
            merged[key].extend(r.get(key, []))
    return merged

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

# -- validate ---------------------------------------------------------------

def cmd_validate(cfg, args):
    data = do_get(cfg, "/api/v1/validate")
    output(data)


# -- metrics ----------------------------------------------------------------

def cmd_metrics_query(cfg, args):
    t_from = parse_time(args.time_from) or int(time.time()) - 3600
    t_to = parse_time(args.time_to) or int(time.time())
    data = do_get(cfg, "/api/v1/query", {
        "from": t_from,
        "to": t_to,
        "query": args.query,
    })
    output(data)


def cmd_metrics_list(cfg, args):
    t_from = parse_time(args.time_from) or int(time.time()) - 3600
    params = {"from": t_from}
    if args.host:
        params["host"] = args.host
    if args.tag_filter:
        params["tag_filter"] = args.tag_filter
    data = do_get(cfg, "/api/v1/metrics", params)
    output(data)


def cmd_metrics_search(cfg, args):
    params = {}
    if args.filter:
        params["filter[configured]"] = "true"
        params["filter[tags_configured]"] = args.filter
    data = do_get(cfg, "/api/v2/metrics", params)
    output(data)


# -- logs -------------------------------------------------------------------

def cmd_logs_search(cfg, args):
    body = {
        "filter": {
            "query": args.query or "*",
        },
        "sort": "-timestamp",
        "page": {"limit": args.limit or 50},
    }
    if args.time_from:
        body["filter"]["from"] = parse_time_iso(args.time_from)
    if args.time_to:
        body["filter"]["to"] = parse_time_iso(args.time_to)
    if args.indexes:
        body["filter"]["indexes"] = args.indexes.split(",")
    data = paginate_cursor(cfg, "/api/v2/logs/events/search", body,
                           max_pages=args.max_pages, page_limit=args.limit or 50)
    output(data)


# -- events -----------------------------------------------------------------

def cmd_events_list(cfg, args):
    params = {}
    if args.query:
        params["filter[query]"] = args.query
    if args.time_from:
        params["filter[from]"] = parse_time_iso(args.time_from)
    if args.time_to:
        params["filter[to]"] = parse_time_iso(args.time_to)
    if args.limit:
        params["page[limit]"] = args.limit
    data = do_get(cfg, "/api/v2/events", params)
    output(data)


# -- monitors ---------------------------------------------------------------

def cmd_monitors_list(cfg, args):
    params = {}
    if args.name:
        params["name"] = args.name
    if args.tags:
        params["tags"] = args.tags
    if args.group_states:
        params["group_states"] = args.group_states
    if args.page_size:
        params["page_size"] = args.page_size
    data = do_get(cfg, "/api/v1/monitor", params)
    output(data)


def cmd_monitors_search(cfg, args):
    params = {"query": args.query}
    if args.per_page:
        params["per_page"] = args.per_page
    if args.page:
        params["page"] = args.page
    if args.sort:
        params["sort"] = args.sort
    data = do_get(cfg, "/api/v1/monitor/search", params)
    output(data)


def cmd_monitors_get(cfg, args):
    data = do_get(cfg, f"/api/v1/monitor/{args.id}")
    output(data)


# -- dashboards -------------------------------------------------------------

def cmd_dashboards_list(cfg, args):
    params = {}
    if args.count:
        params["count"] = args.count
    if args.start:
        params["start"] = args.start
    data = do_get(cfg, "/api/v1/dashboard", params)
    output(data)


def cmd_dashboards_get(cfg, args):
    data = do_get(cfg, f"/api/v1/dashboard/{args.id}")
    output(data)


# -- hosts ------------------------------------------------------------------

def cmd_hosts_list(cfg, args):
    params = {}
    if args.filter:
        params["filter"] = args.filter
    if args.count:
        params["count"] = args.count
    if args.sort_field:
        params["sort_field"] = args.sort_field
    if args.sort_dir:
        params["sort_dir"] = args.sort_dir
    data = do_get(cfg, "/api/v1/hosts", params)
    output(data)


# -- incidents --------------------------------------------------------------

def cmd_incidents_list(cfg, args):
    params = {}
    if args.page_size:
        params["page[size]"] = args.page_size
    if args.page_offset:
        params["page[offset]"] = args.page_offset
    data = do_get(cfg, "/api/v2/incidents", params)
    output(data)


def cmd_incidents_search(cfg, args):
    params = {
        "query": args.query,
    }
    if args.sort:
        params["sort"] = args.sort
    if args.page_size:
        params["page[size]"] = args.page_size
    if args.page_offset:
        params["page[offset]"] = args.page_offset
    data = do_get(cfg, "/api/v2/incidents/search", params)
    output(data)


# -- slos -------------------------------------------------------------------

def cmd_slos_list(cfg, args):
    params = {}
    if args.query:
        params["query"] = args.query
    if args.tags:
        params["tags_query"] = args.tags
    if args.limit:
        params["limit"] = args.limit
    if args.offset:
        params["offset"] = args.offset
    data = do_get(cfg, "/api/v1/slo", params)
    output(data)


def cmd_slos_get(cfg, args):
    data = do_get(cfg, f"/api/v1/slo/{args.id}")
    output(data)


def cmd_slos_history(cfg, args):
    t_from = parse_time(args.time_from)
    t_to = parse_time(args.time_to)
    if t_from is None or t_to is None:
        die("--from and --to are required for SLO history")
    params = {"from_ts": t_from, "to_ts": t_to}
    data = do_get(cfg, f"/api/v1/slo/{args.id}/history", params)
    output(data)


# -- synthetics -------------------------------------------------------------

def cmd_synthetics_list(cfg, args):
    data = do_get(cfg, "/api/v1/synthetics/tests")
    output(data)


# -- traces (APM) ----------------------------------------------------------

def cmd_traces_search(cfg, args):
    body = {
        "data": {
            "type": "search_request",
            "attributes": {
                "filter": {
                    "query": args.query or "*",
                },
                "sort": "-timestamp",
                "page": {"limit": args.limit or 50},
            },
        },
    }
    attrs = body["data"]["attributes"]
    if args.time_from:
        attrs["filter"]["from"] = parse_time_iso(args.time_from)
    if args.time_to:
        attrs["filter"]["to"] = parse_time_iso(args.time_to)
    data = do_post(cfg, "/api/v2/spans/events/search", body)
    # Handle pagination manually since body structure differs
    results = [data]
    pages_fetched = 1
    while pages_fetched < args.max_pages:
        cursor = data.get("meta", {}).get("page", {}).get("after")
        if not cursor:
            break
        attrs["page"]["cursor"] = cursor
        data = do_post(cfg, "/api/v2/spans/events/search", body)
        results.append(data)
        pages_fetched += 1
    if len(results) == 1:
        output(results[0])
    else:
        merged = results[0]
        for r in results[1:]:
            merged.get("data", []).extend(r.get("data", []))
        output(merged)


def cmd_traces_aggregate(cfg, args):
    body = {
        "data": {
            "type": "aggregate_request",
            "attributes": {
                "filter": {
                    "query": args.query or "*",
                },
                "compute": [
                    {"aggregation": args.aggregation or "count", "type": "total"},
                ],
            },
        },
    }
    attrs = body["data"]["attributes"]
    if args.time_from:
        attrs["filter"]["from"] = parse_time_iso(args.time_from)
    if args.time_to:
        attrs["filter"]["to"] = parse_time_iso(args.time_to)
    if args.group_by:
        attrs["group_by"] = [{"facet": g, "limit": 10, "sort": {"aggregation": args.aggregation or "count", "order": "desc"}} for g in args.group_by.split(",")]
    data = do_post(cfg, "/api/v2/spans/analytics/aggregate", body)
    output(data)


# -- downtimes --------------------------------------------------------------

def cmd_downtimes_list(cfg, args):
    params = {}
    if args.current_only:
        params["current_only"] = "true"
    data = do_get(cfg, "/api/v1/downtime", params)
    output(data)


# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

def build_parser():
    p = argparse.ArgumentParser(
        description="Query the Datadog API",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    sub = p.add_subparsers(dest="command", help="Top-level command")

    # validate
    sub.add_parser("validate", help="Validate API credentials")

    # metrics
    metrics = sub.add_parser("metrics", help="Metrics operations")
    msub = metrics.add_subparsers(dest="subcommand")

    mq = msub.add_parser("query", help="Query timeseries points")
    mq.add_argument("--query", "-q", required=True, help="Metric query (e.g. avg:system.cpu.user{*})")
    mq.add_argument("--from", dest="time_from", help="Start time (default: 1h ago)")
    mq.add_argument("--to", dest="time_to", help="End time (default: now)")

    ml = msub.add_parser("list", help="List active metrics")
    ml.add_argument("--from", dest="time_from", help="List metrics active since (default: 1h ago)")
    ml.add_argument("--host", help="Filter by host")
    ml.add_argument("--tag-filter", help="Filter by tag")

    ms = msub.add_parser("search", help="Search metrics (V2)")
    ms.add_argument("--filter", "-f", help="Tag filter")

    # logs
    logs = sub.add_parser("logs", help="Logs operations")
    lsub = logs.add_subparsers(dest="subcommand")

    ls = lsub.add_parser("search", help="Search logs")
    ls.add_argument("--query", "-q", default="*", help="Log search query (default: *)")
    ls.add_argument("--from", dest="time_from", help="Start time")
    ls.add_argument("--to", dest="time_to", help="End time")
    ls.add_argument("--limit", type=int, default=50, help="Results per page (max 1000)")
    ls.add_argument("--indexes", help="Comma-separated index names")
    ls.add_argument("--max-pages", type=int, default=1, help="Max pages to fetch (default: 1)")

    # events
    events = sub.add_parser("events", help="Events operations")
    esub = events.add_subparsers(dest="subcommand")

    el = esub.add_parser("list", help="List events")
    el.add_argument("--query", "-q", help="Event search query")
    el.add_argument("--from", dest="time_from", help="Start time")
    el.add_argument("--to", dest="time_to", help="End time")
    el.add_argument("--limit", type=int, help="Max results")

    # monitors
    monitors = sub.add_parser("monitors", help="Monitor operations")
    mosub = monitors.add_subparsers(dest="subcommand")

    mol = mosub.add_parser("list", help="List monitors")
    mol.add_argument("--name", help="Filter by name")
    mol.add_argument("--tags", help="Filter by tags (comma-separated)")
    mol.add_argument("--group-states", help="Filter by group states (e.g. alert,warn)")
    mol.add_argument("--page-size", type=int, help="Results per page (max 1000)")

    mos = mosub.add_parser("search", help="Search monitors")
    mos.add_argument("--query", "-q", required=True, help="Search query (e.g. type:metric status:alert)")
    mos.add_argument("--per-page", type=int, help="Results per page")
    mos.add_argument("--page", type=int, help="Page number")
    mos.add_argument("--sort", help="Sort field")

    mog = mosub.add_parser("get", help="Get a specific monitor")
    mog.add_argument("--id", required=True, help="Monitor ID")

    # dashboards
    dashboards = sub.add_parser("dashboards", help="Dashboard operations")
    dsub = dashboards.add_subparsers(dest="subcommand")

    dl = dsub.add_parser("list", help="List dashboards")
    dl.add_argument("--count", type=int, help="Number of dashboards (default 100)")
    dl.add_argument("--start", type=int, help="Offset")

    dg = dsub.add_parser("get", help="Get a specific dashboard")
    dg.add_argument("--id", required=True, help="Dashboard ID")

    # hosts
    hosts = sub.add_parser("hosts", help="Host operations")
    hsub = hosts.add_subparsers(dest="subcommand")

    hl = hsub.add_parser("list", help="Search hosts")
    hl.add_argument("--filter", "-f", help="Filter string for hostnames")
    hl.add_argument("--count", type=int, help="Max hosts to return")
    hl.add_argument("--sort-field", help="Sort field (e.g. apps, cpu, name)")
    hl.add_argument("--sort-dir", help="Sort direction (asc or desc)")

    # incidents
    incidents = sub.add_parser("incidents", help="Incident operations")
    isub = incidents.add_subparsers(dest="subcommand")

    il = isub.add_parser("list", help="List incidents")
    il.add_argument("--page-size", type=int, help="Results per page")
    il.add_argument("--page-offset", type=int, help="Page offset")

    ise = isub.add_parser("search", help="Search incidents")
    ise.add_argument("--query", "-q", required=True, help="Search query")
    ise.add_argument("--sort", help="Sort field")
    ise.add_argument("--page-size", type=int, help="Results per page")
    ise.add_argument("--page-offset", type=int, help="Page offset")

    # slos
    slos = sub.add_parser("slos", help="SLO operations")
    ssub = slos.add_subparsers(dest="subcommand")

    sl = ssub.add_parser("list", help="List SLOs")
    sl.add_argument("--query", "-q", help="Search query")
    sl.add_argument("--tags", help="Tag query")
    sl.add_argument("--limit", type=int, help="Max results")
    sl.add_argument("--offset", type=int, help="Offset")

    sg = ssub.add_parser("get", help="Get a specific SLO")
    sg.add_argument("--id", required=True, help="SLO ID")

    sh = ssub.add_parser("history", help="Get SLO history")
    sh.add_argument("--id", required=True, help="SLO ID")
    sh.add_argument("--from", dest="time_from", required=True, help="Start time")
    sh.add_argument("--to", dest="time_to", required=True, help="End time")

    # traces
    traces = sub.add_parser("traces", help="APM trace/span operations (rate limited: 300 req/hr)")
    trsub = traces.add_subparsers(dest="subcommand")

    trs = trsub.add_parser("search", help="Search spans")
    trs.add_argument("--query", "-q", default="*", help="Span search query (default: *)")
    trs.add_argument("--from", dest="time_from", help="Start time")
    trs.add_argument("--to", dest="time_to", help="End time")
    trs.add_argument("--limit", type=int, default=50, help="Results per page (max 1000)")
    trs.add_argument("--max-pages", type=int, default=1, help="Max pages to fetch (default: 1)")

    tra = trsub.add_parser("aggregate", help="Aggregate spans into buckets")
    tra.add_argument("--query", "-q", default="*", help="Span search query (default: *)")
    tra.add_argument("--from", dest="time_from", help="Start time")
    tra.add_argument("--to", dest="time_to", help="End time")
    tra.add_argument("--aggregation", default="count", help="Aggregation type (count, avg, sum, min, max, pc75, pc90, pc95, pc99)")
    tra.add_argument("--group-by", help="Comma-separated facets to group by (e.g. resource_name,service)")

    # synthetics
    synthetics = sub.add_parser("synthetics", help="Synthetics operations")
    sysub = synthetics.add_subparsers(dest="subcommand")
    sysub.add_parser("list", help="List synthetic tests")

    # downtimes
    downtimes = sub.add_parser("downtimes", help="Downtime operations")
    dtsub = downtimes.add_subparsers(dest="subcommand")
    dtl = dtsub.add_parser("list", help="List downtimes")
    dtl.add_argument("--current-only", action="store_true", help="Only show active downtimes")

    return p


# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

DISPATCH = {
    ("validate", None): cmd_validate,
    ("metrics", "query"): cmd_metrics_query,
    ("metrics", "list"): cmd_metrics_list,
    ("metrics", "search"): cmd_metrics_search,
    ("logs", "search"): cmd_logs_search,
    ("events", "list"): cmd_events_list,
    ("monitors", "list"): cmd_monitors_list,
    ("monitors", "search"): cmd_monitors_search,
    ("monitors", "get"): cmd_monitors_get,
    ("dashboards", "list"): cmd_dashboards_list,
    ("dashboards", "get"): cmd_dashboards_get,
    ("hosts", "list"): cmd_hosts_list,
    ("incidents", "list"): cmd_incidents_list,
    ("incidents", "search"): cmd_incidents_search,
    ("slos", "list"): cmd_slos_list,
    ("slos", "get"): cmd_slos_get,
    ("slos", "history"): cmd_slos_history,
    ("traces", "search"): cmd_traces_search,
    ("traces", "aggregate"): cmd_traces_aggregate,
    ("synthetics", "list"): cmd_synthetics_list,
    ("downtimes", "list"): cmd_downtimes_list,
}


def main():
    parser = build_parser()
    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    cfg = get_config()
    key = (args.command, getattr(args, "subcommand", None))
    handler = DISPATCH.get(key)

    if handler is None:
        # Maybe subcommand is missing
        if args.command in ("validate",):
            handler = DISPATCH[(args.command, None)]
        else:
            die(f"Unknown command: {args.command} {getattr(args, 'subcommand', '')}")

    handler(cfg, args)


if __name__ == "__main__":
    main()
