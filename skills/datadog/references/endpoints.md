# Datadog API Endpoint Reference

Full catalog of endpoints supported by the `datadog_query.py` script.

## Authentication

All requests use two headers:
- `DD-API-KEY`: Organization API key
- `DD-APPLICATION-KEY`: User application key

Base URL: `https://api.{DD_SITE}` (default: `https://api.datadoghq.com`)

## V1 Endpoints

### Metrics

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/query` | Query timeseries points |
| GET | `/api/v1/metrics` | List active metrics |
| GET | `/api/v1/metrics/{metric_name}` | Get metric metadata |

**Query timeseries** (`/api/v1/query`):
- `from` (required): Epoch seconds start
- `to` (required): Epoch seconds end
- `query` (required): Metric query string (e.g. `avg:system.cpu.user{host:web01}`)

**List active metrics** (`/api/v1/metrics`):
- `from` (required): Epoch seconds — list metrics active since this time
- `host`: Filter by hostname
- `tag_filter`: Filter by tag prefix

### Monitors

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/monitor` | List all monitors |
| GET | `/api/v1/monitor/search` | Search monitors |
| GET | `/api/v1/monitor/{id}` | Get a specific monitor |

**List monitors** (`/api/v1/monitor`):
- `group_states`: Comma-separated states to filter (alert, warn, no data, ok)
- `name`: Filter by name substring
- `tags`: Filter by tags (comma-separated)
- `page_size`: Max 1000

**Search monitors** (`/api/v1/monitor/search`):
- `query`: Search string (e.g. `type:metric status:alert tag:env:prod`)
- `per_page`: Results per page (default 30)
- `page`: Page number
- `sort`: Sort field

### Dashboards

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/dashboard` | List all dashboards |
| GET | `/api/v1/dashboard/{id}` | Get a specific dashboard |

**List dashboards**: `count` (default 100), `start` (offset).

### Events (V1)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/events` | List events (max 1000) |
| GET | `/api/v1/events/{id}` | Get a specific event |

Parameters: `start` (epoch, required), `end` (epoch, required), `priority`, `sources`, `tags`, `page`.

### Hosts

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/hosts` | Search hosts (max 1000/page) |
| GET | `/api/v1/hosts/totals` | Total active host count |

Parameters: `filter`, `sort_field` (apps, cpu, iowait, load, name), `sort_dir`, `start`, `count`, `from`.

### SLOs

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/slo` | List SLOs |
| GET | `/api/v1/slo/{id}` | Get a specific SLO |
| GET | `/api/v1/slo/{id}/history` | Get SLO history |

**List SLOs**: `ids`, `query`, `tags_query`, `metrics_query`, `limit` (default 1000), `offset`.
**SLO history**: `from_ts` (epoch, required), `to_ts` (epoch, required).

### Synthetics

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/synthetics/tests` | List all tests |
| GET | `/api/v1/synthetics/tests/{id}` | Get a specific test |
| GET | `/api/v1/synthetics/tests/{id}/results` | Get test results |

### Downtimes

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/downtime` | List all downtimes |
| GET | `/api/v1/downtime/{id}` | Get a specific downtime |

Parameters: `current_only` (boolean).

### Other V1

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/validate` | Validate API key |
| GET | `/api/v1/tags/hosts` | Get host tags |
| GET | `/api/v1/notebooks` | List notebooks |

## V2 Endpoints

### Metrics (V2)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v2/metrics` | List metrics with tag configs |
| GET | `/api/v2/metrics/{name}/all-tags` | All tags for a metric |
| GET | `/api/v2/metrics/{name}/volumes` | Metric volumes |
| POST | `/api/v2/query/scalar` | Query scalar values |
| POST | `/api/v2/query/timeseries` | Query timeseries (V2) |

### Logs (V2)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v2/logs/events` | Search logs (GET) |
| POST | `/api/v2/logs/events/search` | Search logs (POST) |
| POST | `/api/v2/logs/analytics/aggregate` | Aggregate logs |

**Search logs** (POST body):
```json
{
  "filter": {
    "query": "@http.status_code:>=400",
    "from": "2024-01-01T00:00:00Z",
    "to": "2024-01-02T00:00:00Z",
    "indexes": ["main"]
  },
  "sort": "timestamp",
  "page": { "cursor": "...", "limit": 50 }
}
```

Pagination: cursor-based via `meta.page.after`.

### Events (V2)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v2/events` | List events |
| POST | `/api/v2/events/search` | Search events |
| GET | `/api/v2/events/{id}` | Get a specific event |

Parameters: `filter[query]`, `filter[from]`, `filter[to]`, `sort`, `page[cursor]`, `page[limit]`.

### Incidents

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v2/incidents` | List incidents |
| GET | `/api/v2/incidents/search` | Search incidents |
| GET | `/api/v2/incidents/{id}` | Get a specific incident |

Parameters: `include`, `page[size]`, `page[offset]`, `query`, `sort`.

### APM Traces / Spans

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v2/spans/events` | List spans (300 req/hr) |
| POST | `/api/v2/spans/events/search` | Search spans |
| POST | `/api/v2/spans/analytics/aggregate` | Aggregate spans |

**Search spans** (POST body): Same pattern as logs search — `filter.query`, `filter.from`, `filter.to`, cursor pagination.

**Aggregate spans** (POST body):
```json
{
  "filter": { "query": "service:api", "from": "...", "to": "..." },
  "compute": [{ "aggregation": "count" }],
  "group_by": [{ "facet": "resource_name", "limit": 10, "sort": { "aggregation": "count", "order": "desc" } }]
}
```

Aggregation types: `count`, `avg`, `sum`, `min`, `max`, `pc75`, `pc90`, `pc95`, `pc99`.

Rate limit: 300 requests/hour for span search endpoints.

### Additional V2 Endpoints (not in script, can be added)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v2/security_monitoring/signals` | Security signals |
| GET | `/api/v2/rum/events` | RUM events |
| GET | `/api/v2/audit/events` | Audit log events |
| GET | `/api/v2/processes` | Processes |
| GET | `/api/v2/containers` | Containers |
| GET | `/api/v2/ci/pipelines/events` | CI pipeline events |
| GET | `/api/v2/usage/hourly_usage` | Usage data |
| GET | `/api/v2/services/definitions` | Service catalog |

## Rate Limiting

Response headers on every request:
- `X-RateLimit-Limit`: Allowed requests in period
- `X-RateLimit-Period`: Reset period (seconds)
- `X-RateLimit-Remaining`: Remaining requests
- `X-RateLimit-Reset`: Seconds until reset

HTTP 429 returned when exceeded. The script warns when remaining < 5.

## Pagination Patterns

**Cursor-based (V2)**: Use `page[cursor]` from `meta.page.after` in response.
**Offset-based (V1)**: Use `start`/`count` or `page`/`per_page` depending on endpoint.
