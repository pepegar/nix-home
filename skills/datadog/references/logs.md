# Datadog Log Search Query Syntax

Reference for log search queries used with `logs search --query`.

## Basic Syntax

Log search uses Datadog's query language, similar to Lucene.

```
# Free text search
error

# Field match
service:web

# Status
status:error
status:warn
status:info

# Multiple terms (AND is implicit)
service:web status:error

# OR
service:web OR service:api

# NOT
-service:web
NOT status:info

# Grouping
(service:web OR service:api) AND status:error
```

## Attribute Queries

Use `@` prefix for custom attributes (facets):

```
# HTTP status code
@http.status_code:500
@http.status_code:>=400
@http.status_code:[400 TO 499]

# Response time
@duration:>1000000000

# URL path
@http.url_details.path:/api/users

# Custom attribute
@user.email:john@example.com

# Exists check
@http.status_code:*
-@error.message:*
```

## Wildcards

```
# Prefix wildcard
service:web*

# Suffix wildcard
*error

# Contains
host:*web*

# Single character
status:?rror
```

## Numeric Ranges

```
# Greater than
@http.status_code:>499

# Greater or equal
@http.status_code:>=400

# Less than
@duration:<1000000

# Range (inclusive)
@http.status_code:[400 TO 599]

# Range (exclusive)
@http.status_code:{400 TO 599}
```

## Tags

```
# Environment
env:production
env:staging

# Service
service:web-api
service:payment-service

# Host
host:web-01

# Version
version:2.1.0

# Custom tag
team:backend
```

## Reserved Attributes

| Attribute | Description | Example |
|-----------|-------------|---------|
| `status` | Log level | `status:error` |
| `service` | Service name | `service:web` |
| `source` | Log source | `source:nginx` |
| `host` | Hostname | `host:web-01` |
| `trace_id` | APM trace ID | `trace_id:abc123` |
| `message` | Log message | `message:timeout` |
| `timestamp` | Log timestamp | (use --from/--to instead) |

## Common Patterns

```
# All errors in production
service:* env:production status:error

# 5xx errors from nginx
source:nginx @http.status_code:>=500

# Slow requests (>5s)
@duration:>5000000000

# Errors from a specific service in the last hour
service:payment-service status:error

# Logs containing exception traces
error OR exception OR traceback

# Specific user activity
@usr.id:12345

# Database slow queries
source:postgresql @duration:>1000
```

## Log Indexes

Use `--indexes` to search specific indexes:

```bash
uv run datadog_query.py logs search -q "status:error" --indexes "main,security"
```

Default: searches all indexes.

## Pagination

Log search uses cursor-based pagination. Use `--max-pages` to fetch multiple pages:

```bash
# Fetch up to 5 pages of 100 results each
uv run datadog_query.py logs search -q "status:error" --limit 100 --max-pages 5
```
