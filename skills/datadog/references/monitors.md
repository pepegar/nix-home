# Datadog Monitor Search Query Syntax

Reference for monitor search queries used with `monitors search --query`.

## Search Syntax

Monitor search uses a structured query format with key:value pairs.

```
# By type
type:metric
type:log
type:apm
type:synthetics
type:composite
type:slo

# By status
status:alert
status:warn
status:ok
status:"no data"

# By tag
tag:env:production
tag:team:backend
tag:service:web

# By name (substring match)
title:cpu
title:"disk space"

# Combine filters
type:metric status:alert tag:env:prod
```

## Monitor Types

| Type | Description |
|------|-------------|
| `metric` | Metric threshold/change monitors |
| `query alert` | Metric query alert |
| `service check` | Service check monitors |
| `event alert` | Event monitors |
| `log alert` | Log-based monitors |
| `process alert` | Process monitors |
| `synthetics alert` | Synthetic test monitors |
| `composite` | Composite monitors |
| `slo alert` | SLO alert monitors |
| `rum alert` | RUM monitors |
| `ci-pipelines alert` | CI pipeline monitors |
| `error-tracking alert` | Error tracking monitors |
| `audit alert` | Audit log monitors |

## Monitor Statuses

| Status | Description |
|--------|-------------|
| `Alert` | Monitor is in alert state |
| `Warn` | Monitor is in warning state |
| `OK` | Monitor is healthy |
| `No Data` | Monitor has no data |
| `Skipped` | Monitor evaluation was skipped |
| `Ignored` | Monitor is muted/ignored |

## Common Queries

```
# All alerting monitors
status:alert

# Alerting metric monitors in production
type:metric status:alert tag:env:prod

# Monitors with no data
status:"no data"

# Warning or alerting monitors
status:alert OR status:warn

# Monitors for a specific team
tag:team:backend

# Log monitors that are alerting
type:log status:alert

# SLO breach alerts
type:slo status:alert

# Search by monitor name
title:"API latency"
title:disk

# Muted monitors
muted:true

# Monitors created by a specific user
creator.email:user@example.com
```

## Sorting

Use `--sort` with `monitors search`:

| Sort value | Description |
|------------|-------------|
| `name,asc` | Name ascending |
| `name,desc` | Name descending |
| `status,asc` | Status ascending |
| `status,desc` | Status descending |
| `tags,asc` | Tags ascending |
| `tags,desc` | Tags descending |

## Group States

Use `--group-states` with `monitors list` to filter by evaluation group state:

```bash
# Only show monitors with groups in alert or warn
uv run datadog_query.py monitors list --group-states alert,warn

# Include no-data groups
uv run datadog_query.py monitors list --group-states alert,warn,"no data"
```

## Monitor Response Fields

Key fields in monitor JSON responses:

| Field | Description |
|-------|-------------|
| `id` | Monitor ID |
| `name` | Monitor name |
| `type` | Monitor type |
| `query` | Monitor query definition |
| `message` | Notification message |
| `tags` | Monitor tags |
| `overall_state` | Current state (Alert, Warn, OK, No Data) |
| `options` | Thresholds, notify settings, etc. |
| `creator` | Who created the monitor |
| `created` | Creation timestamp |
| `modified` | Last modified timestamp |
