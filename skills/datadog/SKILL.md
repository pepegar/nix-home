---
name: datadog
description: Query the Datadog API to get metrics, logs, events, monitors, dashboards, incidents, SLOs, hosts, traces, and more. Use whenever the user mentions Datadog, or asks about monitoring, alerting, observability, or production health — even indirectly. Trigger on questions like "is anything alerting?", "check production health", "what's the error rate?", "are there active incidents?", "how's the SLO doing?", "show me recent errors", "what hosts are running?", "check uptime", or any request involving metrics, logs, traces, monitors, dashboards, or SLOs that could be answered from Datadog.
user-invocable: true
argument-hint: "monitors list --group-states alert,warn"
---

# Datadog Skill

Query the Datadog API using a self-contained Python CLI script.

## Setup

Requires these environment variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `DD_API_KEY` | Yes | Datadog API key |
| `DD_APP_KEY` | Yes | Datadog Application key |
| `DD_SITE` | No | Datadog site (default: `datadoghq.com`) |

Valid sites: `datadoghq.com` (US1), `us3.datadoghq.com`, `us5.datadoghq.com`, `datadoghq.eu` (EU), `ap1.datadoghq.com`, `ap2.datadoghq.com`, `ddog-gov.com` (FedRAMP).

## Script

The CLI script is `datadog_query.py` in the same directory as this file. Run it with `uv run`:

```bash
uv run /path/to/datadog_query.py <command> [subcommand] [options]
```

**Important**: Resolve the actual path to the script before running. It lives next to this SKILL.md file. Use `readlink -f` or equivalent to resolve symlinks.

## Quick Reference

| Task | Command |
|------|---------|
| Validate credentials | `uv run $SCRIPT validate` |
| Query a metric | `uv run $SCRIPT metrics query -q "avg:system.cpu.user{*}" --from 1h --to now` |
| List active metrics | `uv run $SCRIPT metrics list --from 1h` |
| Search logs | `uv run $SCRIPT logs search -q "service:web status:error" --from 1h` |
| List events | `uv run $SCRIPT events list --from 1d` |
| List all monitors | `uv run $SCRIPT monitors list` |
| Alerting monitors | `uv run $SCRIPT monitors list --group-states alert,warn` |
| Search monitors | `uv run $SCRIPT monitors search -q "type:metric status:alert"` |
| Get a monitor | `uv run $SCRIPT monitors get --id 12345` |
| List dashboards | `uv run $SCRIPT dashboards list` |
| Get a dashboard | `uv run $SCRIPT dashboards get --id abc-def-ghi` |
| List hosts | `uv run $SCRIPT hosts list --filter web` |
| List incidents | `uv run $SCRIPT incidents list` |
| Search incidents | `uv run $SCRIPT incidents search -q "state:active"` |
| List SLOs | `uv run $SCRIPT slos list` |
| Get SLO details | `uv run $SCRIPT slos get --id abc123` |
| SLO history | `uv run $SCRIPT slos history --id abc123 --from 30d --to now` |
| Search APM traces | `uv run $SCRIPT traces search -q "service:web @duration:>1s" --from 1h` |
| Aggregate traces | `uv run $SCRIPT traces aggregate -q "service:web" --group-by resource_name --from 1h` |
| List synthetic tests | `uv run $SCRIPT synthetics list` |
| List downtimes | `uv run $SCRIPT downtimes list --current-only` |

Where `$SCRIPT` is the resolved path to `datadog_query.py`.

## Time Format

The `--from` and `--to` flags accept:
- **Relative**: `30m`, `1h`, `6h`, `1d`, `7d`, `4w` (ago from now)
- **Epoch seconds**: `1700000000`
- **ISO 8601**: `2024-01-15T10:00:00Z` or `2024-01-15`
- **"now"**: Use current epoch (just omit `--to` for "now")

## Instructions

1. Resolve the absolute path to `datadog_query.py` next to this SKILL.md (resolve symlinks).
2. Run the appropriate command via `uv run <resolved_path>/datadog_query.py ...`.
3. Output is JSON. Pipe through `jq` for filtering when needed.
4. If `$ARGUMENTS` is provided, pass it directly as command arguments.
5. For large result sets, use `--limit` and pagination flags.
6. When output is large, summarize key fields for the user. Useful `jq` patterns:
   - Monitors: `| jq '[.[] | {id, name, overall_state, tags}]'`
   - Dashboards: `| jq '.dashboards[:10] | [.[] | {id, title, url}]'`
   - Hosts: `| jq '.host_list[:10] | [.[] | {name, up, apps}]'`
   - Logs: `| jq '[.data[] | {timestamp: .attributes.timestamp, status: .attributes.status, service: .attributes.service, message: .attributes.attributes.message}]'`
   - Traces: `| jq '[.data[] | {trace_id: .attributes.attributes.trace_id, service: .attributes.service.name, resource: .attributes.resource.name, duration: .attributes.duration}]'`

## Common Workflows

### Check what's alerting

```bash
uv run $SCRIPT monitors list --group-states alert,warn
# Or search for specific monitor types
uv run $SCRIPT monitors search -q "status:alert tag:team:backend"
```

### Investigate recent errors

```bash
# Search error logs from the last hour
uv run $SCRIPT logs search -q "status:error" --from 1h --limit 100

# Check related events
uv run $SCRIPT events list --query "sources:alerting" --from 1h
```

### Review SLO health

```bash
# List all SLOs
uv run $SCRIPT slos list

# Get 30-day history for a specific SLO
uv run $SCRIPT slos history --id <slo_id> --from 30d --to now
```

### Investigate slow traces

```bash
# Search for slow spans (>1s) in a service
uv run $SCRIPT traces search -q "service:api @duration:>1000000000" --from 1h

# Aggregate latency by endpoint
uv run $SCRIPT traces aggregate -q "service:api" --aggregation pc95 --group-by resource_name --from 1h

# Find errors in traces
uv run $SCRIPT traces search -q "service:api status:error" --from 1h
```

Note: APM span search is rate limited to 300 requests/hour.

### Query infrastructure metrics

```bash
# CPU usage across all hosts
uv run $SCRIPT metrics query -q "avg:system.cpu.user{*} by {host}" --from 1h

# Disk usage for specific hosts
uv run $SCRIPT metrics query -q "avg:system.disk.in_use{host:web01}" --from 6h
```

## Detailed References

Read these files for advanced usage:

- `references/endpoints.md` — Full endpoint catalog with parameters
- `references/metrics.md` — Metric query syntax and functions
- `references/logs.md` — Log search query syntax
- `references/monitors.md` — Monitor search query patterns
