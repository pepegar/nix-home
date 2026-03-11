# Datadog Metric Query Syntax

Reference for the `query` parameter used in `/api/v1/query`.

## Basic Format

```
<aggregator>:<metric_name>{<scope>}
```

- **Aggregator**: `avg`, `sum`, `min`, `max`, `count`
- **Metric name**: Dot-separated (e.g. `system.cpu.user`, `aws.ec2.cpuutilization`)
- **Scope**: Tag filters in braces (e.g. `{host:web01}`, `{env:prod,service:api}`)

## Examples

```
# Average CPU across all hosts
avg:system.cpu.user{*}

# CPU for a specific host
avg:system.cpu.user{host:web-01}

# Sum of requests by service
sum:http.requests{env:prod} by {service}

# Max memory usage in production
max:system.mem.used{env:prod} by {host}

# Disk usage for specific role
avg:system.disk.in_use{role:webserver} by {host,device}
```

## Scope Filters

```
# Wildcard - all hosts
{*}

# Single tag
{host:web-01}

# Multiple tags (AND)
{env:prod,service:api}

# Negation
{!env:staging}

# Wildcard in tag values
{host:web-*}
```

## Group By

Add `by {tag1,tag2}` after the scope to group results:

```
avg:system.cpu.user{env:prod} by {host}
sum:http.requests{*} by {service,status_code}
```

## Arithmetic

Combine metrics with arithmetic:

```
# Ratio
( sum:http.5xx{*} / sum:http.requests{*} ) * 100

# Difference
avg:system.mem.total{*} - avg:system.mem.free{*}
```

## Functions

Apply functions to queries:

```
# Rate of change
per_second(sum:network.bytes_sent{*})

# Moving average (60-second window)
moving_avg(avg:system.cpu.user{*}, 60)

# Top N hosts by CPU
top(avg:system.cpu.user{*} by {host}, 10, 'mean', 'desc')

# Cumulative sum
cumsum(sum:http.requests{*})

# Absolute value
abs(avg:temperature{*})

# Log base 2
log2(avg:queue.size{*})

# Clamp values
clamp_min(avg:system.cpu.idle{*}, 0)
clamp_max(avg:system.cpu.user{*}, 100)

# Exponentially weighted moving average
ewma_3(avg:system.cpu.user{*})

# Anomaly detection
anomalies(avg:system.cpu.user{*}, 'basic', 2)

# Forecast
forecast(avg:system.disk.in_use{*}, 'linear', 1w)

# Outliers
outliers(avg:system.cpu.user{*} by {host}, 'dbscan', 2)
```

## Rollup

Control time aggregation granularity:

```
# Average over 60-second buckets
avg:system.cpu.user{*}.rollup(avg, 60)

# Sum over 5-minute buckets
sum:http.requests{*}.rollup(sum, 300)

# Count per minute
count:events{*}.rollup(count, 60)
```

## Fill

Handle missing data points:

```
avg:system.cpu.user{*}.fill(zero)
avg:system.cpu.user{*}.fill(last)
avg:system.cpu.user{*}.fill(linear)
avg:system.cpu.user{*}.fill(null)
```

## Timeshift

Compare with historical data:

```
# Compare with 1 week ago
avg:system.cpu.user{*}, week_before(avg:system.cpu.user{*})

# Compare with 1 day ago
avg:system.cpu.user{*}, day_before(avg:system.cpu.user{*})

# Compare with 1 month ago
avg:system.cpu.user{*}, month_before(avg:system.cpu.user{*})

# Arbitrary timeshift
timeshift(avg:system.cpu.user{*}, -3600)
```
