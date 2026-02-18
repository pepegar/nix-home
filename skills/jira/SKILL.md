---
name: jira
description: Interact with Jira using the Atlassian CLI (acli). Use when the user asks to view, create, search, edit, transition, or comment on Jira issues/work items.
---

# Jira Skill

Interact with Jira Cloud using `acli jira <command> [subcommand] [flags]`.

> **IMPORTANT**: Jira Cloud uses **ADF (Atlassian Document Format)** for descriptions, NOT Markdown or wiki markup. When creating or editing issue descriptions, always use ADF JSON format. See `references/adf.md` for the full specification and examples.

## Quick Reference

| Task | Command |
|------|---------|
| View issue | `acli jira workitem view KEY-123` |
| View all fields | `acli jira workitem view KEY-123 --fields '*all'` |
| Search issues | `acli jira workitem search --jql "project = TEAM"` |
| My issues | `acli jira workitem search --jql "assignee = currentUser()"` |
| Create issue | `acli jira workitem create --project TEAM --type Task --summary "Title"` |
| Edit issue | `acli jira workitem edit --key KEY-123 --summary "New title"` |
| Transition | `acli jira workitem transition --key KEY-123 --status "Done"` |
| Assign to me | `acli jira workitem assign --key KEY-123 --assignee "@me"` |
| Add comment | `acli jira workitem comment --key KEY-123 --body "Comment"` |
| List projects | `acli jira project list` |
| List links | `acli jira workitem link list --key KEY-123` |
| Create link | `acli jira workitem link create --out KEY-1 --in KEY-2 --type Blocks --yes` |
| Link types | `acli jira workitem link type` |

## Common Operations

### View

```bash
acli jira workitem view KEY-123
acli jira workitem view KEY-123 --fields summary,description,status,assignee,comment
acli jira workitem view KEY-123 --fields '*all'
acli jira workitem view KEY-123 --json
acli jira workitem view KEY-123 --web
```

### Search

```bash
acli jira workitem search --jql "project = TEAM"
acli jira workitem search --jql "project = TEAM" --fields "key,summary,assignee,status"
acli jira workitem search --jql "project = TEAM" --limit 50
acli jira workitem search --jql "project = TEAM" --json
```

See `references/jql.md` for common JQL query patterns.

### Create

```bash
acli jira workitem create --project "TEAM" --type "Task" --summary "Title"
acli jira workitem create --project "TEAM" --type "Bug" --summary "Title" --description "Details"
acli jira workitem create --project "TEAM" --type "Task" --summary "Title" --assignee "@me"
acli jira workitem create --project "TEAM" --type "Task" --summary "Subtask" --parent "TEAM-100"
acli jira workitem create --project "TEAM" --type "Task" --summary "Title" --label "backend,urgent"
```

**Types**: Epic, Story, Task, Bug, Subtask (varies by project)
**Assignee**: `@me`, `default`, `user@email.com`, or Account ID

### Edit

```bash
acli jira workitem edit --key "KEY-123" --summary "Updated summary"
acli jira workitem edit --key "KEY-123" --description "New description"
acli jira workitem edit --key "KEY-123" --assignee "user@email.com"
acli jira workitem edit --key "KEY-123" --labels "urgent,backend"
acli jira workitem edit --key "KEY-1,KEY-2,KEY-3" --labels "reviewed"
```

### Transition

```bash
acli jira workitem transition --key "KEY-123" --status "In Progress"
acli jira workitem transition --key "KEY-1,KEY-2" --status "Done"
```

**Common statuses**: To Do, In Progress, In Review, Done (varies by project)

See `references/workflows.md` for project-specific workflows (e.g., GSC).

### Assign

```bash
acli jira workitem assign --key "KEY-123" --assignee "@me"
acli jira workitem assign --key "KEY-123" --assignee "user@email.com"
acli jira workitem assign --key "KEY-123" --remove-assignee
```

### Comment

```bash
acli jira workitem comment --key "KEY-123" --body "This is my comment"
acli jira workitem comment --key "KEY-123" --body-file "comment.md"
acli jira workitem comment --key "KEY-123" --body "Updated comment" --edit-last
```

## Output Formats

Most commands support: `--json`, `--csv` (search), `--web` (open in browser).

## Detailed References

Read these files for advanced usage:

- `references/jql.md` — Common JQL query patterns
- `references/links.md` — Link operations (create, list, delete, bulk)
- `references/adf.md` — Atlassian Document Format for rich descriptions
- `references/workflows.md` — Project-specific workflows (GSC)
- `references/projects-filters.md` — Project listing, filter operations, auth
