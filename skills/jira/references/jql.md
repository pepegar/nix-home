# Common JQL Queries

```bash
# Issues assigned to me
acli jira workitem search --jql "assignee = currentUser()"

# Issues in a specific status
acli jira workitem search --jql "project = TEAM AND status = 'In Progress'"

# Recently updated issues
acli jira workitem search --jql "project = TEAM AND updated >= -7d"

# Open issues by priority
acli jira workitem search --jql "project = TEAM AND status != Done ORDER BY priority DESC"

# Issues in current sprint
acli jira workitem search --jql "project = TEAM AND sprint in openSprints()"

# Unassigned issues
acli jira workitem search --jql "project = TEAM AND assignee IS EMPTY"

# Issues with specific label
acli jira workitem search --jql "project = TEAM AND labels = 'bug'"

# All issues in same epic
acli jira workitem search --jql "parent = TEAM-50"

# Issues with same label
acli jira workitem search --jql "project = TEAM AND labels = 'api-v2'"
```

## Search Options

```bash
acli jira workitem search --jql "..." --limit 50        # Limit results
acli jira workitem search --jql "..." --count            # Count only
acli jira workitem search --jql "..." --paginate         # All results
acli jira workitem search --jql "..." --json             # JSON output
acli jira workitem search --jql "..." --csv              # CSV output
acli jira workitem search --filter 10001                 # Saved filter
acli jira workitem search --jql "..." --web              # Open in browser
```

**Default fields**: issuetype, key, assignee, priority, status, summary
