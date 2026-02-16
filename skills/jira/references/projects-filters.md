# Projects, Filters & Auth

## List Projects

```bash
acli jira project list                  # Default: 30 results
acli jira project list --recent         # Recently viewed (up to 20)
acli jira project list --paginate       # All projects
acli jira project list --limit 50
acli jira project list --json
```

## View a Project

```bash
acli jira project view TEAM
```

## Filter Operations

```bash
acli jira filter search
acli jira filter change-owner --filter-id 10001 --new-owner "user@email.com"
```

## Other Work Item Operations

```bash
acli jira workitem archive KEY-123
acli jira workitem unarchive KEY-123
acli jira workitem clone KEY-123
acli jira workitem delete KEY-123
```

## Authentication

```bash
acli jira auth              # Interactive auth
acli jira auth status       # Check status
```
