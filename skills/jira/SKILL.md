---
name: jira
description: Interact with Jira using the Atlassian CLI (acli). Use when the user asks to view, create, search, edit, transition, or comment on Jira issues/work items.
---

# Jira Skill

This skill enables Claude Code to interact with Jira Cloud using the Atlassian CLI (`acli`).

## Tool Overview

The `acli` CLI is Atlassian's official command-line tool for interacting with Jira Cloud.

```bash
acli jira <command> [subcommand] [flags]
```

## Common Operations

### View a Work Item

```bash
# View work item with default fields
acli jira workitem view KEY-123

# View with specific fields
acli jira workitem view KEY-123 --fields summary,description,status,assignee,comment

# View all fields
acli jira workitem view KEY-123 --fields '*all'

# View in JSON format
acli jira workitem view KEY-123 --json

# Open in web browser
acli jira workitem view KEY-123 --web
```

**Default fields**: key, issuetype, summary, status, assignee, description

### Search for Work Items

```bash
# Search with JQL query
acli jira workitem search --jql "project = TEAM"

# Search with specific fields
acli jira workitem search --jql "project = TEAM" --fields "key,summary,assignee,status"

# Limit results
acli jira workitem search --jql "project = TEAM" --limit 50

# Get count only
acli jira workitem search --jql "project = TEAM" --count

# Paginate through all results
acli jira workitem search --jql "project = TEAM" --paginate

# Output as JSON
acli jira workitem search --jql "project = TEAM" --json

# Output as CSV
acli jira workitem search --jql "project = TEAM" --csv

# Search using saved filter ID
acli jira workitem search --filter 10001

# Open search in browser
acli jira workitem search --jql "project = TEAM" --web
```

**Default fields**: issuetype, key, assignee, priority, status, summary

### Common JQL Queries

```bash
# Issues assigned to me
acli jira workitem search --jql "assignee = currentUser()"

# Issues in a specific status
acli jira workitem search --jql "project = TEAM AND status = 'In Progress'"

# Recently updated issues
acli jira workitem search --jql "project = TEAM AND updated >= -7d"

# Open issues by priority
acli jira workitem search --jql "project = TEAM AND status != Done ORDER BY priority DESC"

# Issues created this sprint
acli jira workitem search --jql "project = TEAM AND sprint in openSprints()"

# Unassigned issues
acli jira workitem search --jql "project = TEAM AND assignee IS EMPTY"

# Issues with specific label
acli jira workitem search --jql "project = TEAM AND labels = 'bug'"
```

### Create a Work Item

```bash
# Create with basic info
acli jira workitem create --project "TEAM" --type "Task" --summary "New task title"

# Create with description
acli jira workitem create --project "TEAM" --type "Bug" --summary "Bug title" --description "Detailed description"

# Create and assign
acli jira workitem create --project "TEAM" --type "Story" --summary "Story title" --assignee "@me"

# Create with labels
acli jira workitem create --project "TEAM" --type "Task" --summary "Task title" --label "backend,urgent"

# Create as child of epic/parent
acli jira workitem create --project "TEAM" --type "Task" --summary "Subtask" --parent "TEAM-100"

# Create from file (summary and description)
acli jira workitem create --project "TEAM" --type "Task" --from-file "issue.txt"

# Create with description from file
acli jira workitem create --project "TEAM" --type "Task" --summary "Title" --description-file "desc.md"

# Open editor for summary/description
acli jira workitem create --project "TEAM" --type "Task" --editor

# Output as JSON
acli jira workitem create --project "TEAM" --type "Task" --summary "Title" --json
```

**Work item types**: Epic, Story, Task, Bug, Subtask (varies by project)

**Assignee options**:
- `@me` - self-assign
- `default` - project's default assignee
- `user@email.com` - specific user email
- Account ID

### Edit a Work Item

```bash
# Edit summary
acli jira workitem edit --key "KEY-123" --summary "Updated summary"

# Edit description
acli jira workitem edit --key "KEY-123" --description "New description"

# Edit multiple issues
acli jira workitem edit --key "KEY-1,KEY-2,KEY-3" --labels "reviewed"

# Edit via JQL query (with confirmation skip)
acli jira workitem edit --jql "project = TEAM AND status = 'To Do'" --assignee "@me" --yes

# Change assignee
acli jira workitem edit --key "KEY-123" --assignee "user@email.com"

# Remove assignee
acli jira workitem edit --key "KEY-123" --remove-assignee

# Add labels
acli jira workitem edit --key "KEY-123" --labels "urgent,backend"

# Remove labels
acli jira workitem edit --key "KEY-123" --remove-labels "old-label"

# Change type
acli jira workitem edit --key "KEY-123" --type "Bug"
```

### Transition a Work Item

Move work items between statuses:

```bash
# Transition single issue
acli jira workitem transition --key "KEY-123" --status "In Progress"

# Transition multiple issues
acli jira workitem transition --key "KEY-1,KEY-2" --status "Done"

# Transition via JQL (with confirmation skip)
acli jira workitem transition --jql "project = TEAM AND assignee = currentUser()" --status "Done" --yes

# Transition using filter
acli jira workitem transition --filter 10001 --status "To Do" --yes
```

**Common statuses**: To Do, In Progress, In Review, Done (varies by project workflow)

#### GSC Project Workflow

The GSC (Platform - GNC, Sync & Collab) project has a specific workflow that requires transitioning through intermediate statuses. You cannot skip steps.

**GSC Statuses** (in order):
1. Backlog
2. Ready for Development
3. In Development
4. Ready for Review (peer review)
5. Done

**To transition to peer review from Backlog:**
```bash
acli jira workitem transition --key "GSC-123" --status "Ready for Development"
acli jira workitem transition --key "GSC-123" --status "In Development"
acli jira workitem transition --key "GSC-123" --status "Ready for Review"
```

**Note**: If a direct transition fails with "No allowed transitions found", you need to transition through intermediate statuses.

### Assign a Work Item

```bash
# Assign to self
acli jira workitem assign --key "KEY-123" --assignee "@me"

# Assign to specific user
acli jira workitem assign --key "KEY-123" --assignee "user@email.com"

# Assign to default
acli jira workitem assign --key "KEY-123" --assignee "default"

# Remove assignee
acli jira workitem assign --key "KEY-123" --remove-assignee

# Bulk assign via JQL
acli jira workitem assign --jql "project = TEAM AND status = 'To Do'" --assignee "@me" --yes
```

### Comment on a Work Item

```bash
# Add comment
acli jira workitem comment --key "KEY-123" --body "This is my comment"

# Add comment from file
acli jira workitem comment --key "KEY-123" --body-file "comment.md"

# Comment on multiple issues
acli jira workitem comment --key "KEY-1,KEY-2" --body "Bulk comment"

# Edit last comment by same author
acli jira workitem comment --key "KEY-123" --body "Updated comment" --edit-last

# Open editor for comment
acli jira workitem comment --key "KEY-123" --editor
```

### Archive/Unarchive Work Items

```bash
# Archive
acli jira workitem archive KEY-123

# Unarchive
acli jira workitem unarchive KEY-123
```

### Clone a Work Item

```bash
acli jira workitem clone KEY-123
```

### Delete a Work Item

```bash
acli jira workitem delete KEY-123
```

## Project Operations

### List Projects

```bash
# List projects (default: 30)
acli jira project list

# List recently viewed (up to 20)
acli jira project list --recent

# List all projects
acli jira project list --paginate

# List with limit
acli jira project list --limit 50

# Output as JSON
acli jira project list --json
```

### View a Project

```bash
acli jira project view TEAM
```

## Filter Operations

```bash
# Search for filters
acli jira filter search

# Change filter owner
acli jira filter change-owner --filter-id 10001 --new-owner "user@email.com"
```

## Authentication

```bash
# Authenticate (interactive)
acli jira auth

# Check auth status
acli jira auth status
```

## Output Formats

Most commands support these output flags:
- `--json` - JSON format (useful for parsing)
- `--csv` - CSV format (for search results)
- `--web` - Open in browser

## Quick Reference

| Task | Command |
|------|---------|
| View issue | `acli jira workitem view KEY-123` |
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

## Usage Patterns for Claude Code

### Get Context for a Ticket

```bash
# View full details including comments
acli jira workitem view KEY-123 --fields '*all'
```

### Update Progress

```bash
# Move to In Progress and assign to self
acli jira workitem transition --key KEY-123 --status "In Progress"
acli jira workitem assign --key KEY-123 --assignee "@me"
```

### Add Implementation Notes

```bash
acli jira workitem comment --key KEY-123 --body "Implementation complete. Changes:
- Added new endpoint /api/users
- Updated database schema
- Added unit tests"
```

### Find Related Work

```bash
# Find all issues in same epic
acli jira workitem search --jql "parent = TEAM-50"

# Find issues with same label
acli jira workitem search --jql "project = TEAM AND labels = 'api-v2'"
```

## Link Operations

### List Available Link Types

```bash
acli jira workitem link type
```

**Common link types**: Blocks, Cloners, Duplicate, Relates

### List Links on a Work Item

```bash
# List all links for a work item (--key flag is required)
acli jira workitem link list --key KEY-123

# Output as JSON
acli jira workitem link list --key KEY-123 --json
```

### Create Links Between Work Items

```bash
# Create a "Blocks" link (KEY-1 blocks KEY-2)
acli jira workitem link create --out KEY-1 --in KEY-2 --type Blocks --yes

# Create a "Relates" link
acli jira workitem link create --out KEY-1 --in KEY-2 --type Relates --yes

# Create from JSON file (for bulk operations)
acli jira workitem link create --from-json links.json

# Generate example JSON structure
acli jira workitem link create --generate-json
```

**Link direction**:
- `--out` = the outward/source work item (e.g., the blocker)
- `--in` = the inward/target work item (e.g., the blocked item)
- `--yes` = skip confirmation prompt

### Delete Links

```bash
acli jira workitem link delete --key KEY-123 --link-id 12345
```

### Bulk Link Creation Pattern

When creating many dependencies, you can run multiple link commands in parallel:

```bash
# Example: Create blocking dependencies for an epic's tasks
acli jira workitem link create --out GSC-945 --in GSC-946 --type Blocks --yes
acli jira workitem link create --out GSC-946 --in GSC-947 --type Blocks --yes
# etc.
```

---

## Atlassian Document Format (ADF)

Jira Cloud uses **Atlassian Document Format (ADF)**, a JSON-based format for rich text. Do NOT use Markdown or wiki markup - they won't render correctly.

**References**:
- Documentation: https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/
- JSON Schema: https://unpkg.com/@atlaskit/adf-schema@51.5.7/dist/json-schema/v1/full.json

### How to Use ADF with acli

**IMPORTANT**: For complex ADF (headings, lists, code blocks, tables), use `--from-json` instead of `--description-file`. The `--description-file` flag has bugs with complex ADF structures.

#### For Simple Text Only
```bash
# Simple paragraph - can use --description-file
acli jira workitem edit --key "KEY-123" --description-file simple.json
```

#### For Complex ADF (Recommended Method)
```bash
# Create JSON file with issues array and description
cat > /tmp/edit.json << 'EOF'
{
  "issues": ["KEY-123"],
  "description": {
    "version": 1,
    "type": "doc",
    "content": [
      {"type": "paragraph", "content": [{"type": "text", "text": "Description"}]},
      {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Section"}]},
      {"type": "bulletList", "content": [
        {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Item 1"}]}]}
      ]}
    ]
  }
}
EOF

# Apply with --from-json (requires --yes to skip confirmation)
acli jira workitem edit --from-json /tmp/edit.json --yes
```

#### Generate Example JSON Structure
```bash
acli jira workitem edit --generate-json
```

### ADF Document Structure

Every ADF document has this root structure:

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    // block nodes go here
  ]
}
```

### Block Node Types

| Node Type | Purpose | Parent |
|-----------|---------|--------|
| `paragraph` | Text container | doc |
| `heading` | Section headers (attrs: level 1-6) | doc |
| `bulletList` | Unordered list | doc |
| `orderedList` | Numbered list | doc |
| `listItem` | List item | bulletList, orderedList |
| `codeBlock` | Code snippet (attrs: language) | doc |
| `blockquote` | Quoted text | doc |
| `table` | Data table | doc |
| `tableRow` | Table row | table |
| `tableHeader` | Header cell | tableRow |
| `tableCell` | Data cell | tableRow |
| `rule` | Horizontal divider | doc |
| `panel` | Info panel (attrs: panelType) | doc |

### Inline Node Types

| Node Type | Purpose |
|-----------|---------|
| `text` | Plain text (can have marks) |
| `hardBreak` | Line break |
| `inlineCard` | Embedded link card |
| `mention` | User mention |
| `emoji` | Emoji character |

### Mark Types (Text Formatting)

Marks are applied to `text` nodes via the `marks` array:

| Mark | Purpose | Attributes |
|------|---------|------------|
| `strong` | **Bold** | none |
| `em` | *Italic* | none |
| `code` | `Monospace` | none |
| `link` | Hyperlink | `href` (required) |
| `strike` | ~~Strikethrough~~ | none |
| `underline` | Underline | none |
| `textColor` | Colored text | `color` (hex) |

### Complete Examples

#### Simple Paragraph with Bold Text

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [
        {"type": "text", "text": "This is "},
        {"type": "text", "text": "bold", "marks": [{"type": "strong"}]},
        {"type": "text", "text": " text."}
      ]
    }
  ]
}
```

#### Heading + Paragraph

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "heading",
      "attrs": {"level": 2},
      "content": [{"type": "text", "text": "Overview"}]
    },
    {
      "type": "paragraph",
      "content": [{"type": "text", "text": "Description text here."}]
    }
  ]
}
```

#### Bullet List

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [{"type": "text", "text": "First item"}]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [{"type": "text", "text": "Second item"}]
            }
          ]
        }
      ]
    }
  ]
}
```

#### Ordered (Numbered) List

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "orderedList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [{"type": "text", "text": "Step one"}]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [{"type": "text", "text": "Step two"}]
            }
          ]
        }
      ]
    }
  ]
}
```

#### Code Block

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "codeBlock",
      "attrs": {"language": "kotlin"},
      "content": [
        {"type": "text", "text": "fun main() {\n    println(\"Hello\")\n}"}
      ]
    }
  ]
}
```

**Supported languages**: java, kotlin, javascript, typescript, python, sql, bash, shell, go, rust, json, xml, html, css, etc.

#### Link

```json
{
  "type": "paragraph",
  "content": [
    {"type": "text", "text": "See "},
    {
      "type": "text",
      "text": "documentation",
      "marks": [{"type": "link", "attrs": {"href": "https://example.com"}}]
    }
  ]
}
```

#### Table

```json
{
  "type": "table",
  "content": [
    {
      "type": "tableRow",
      "content": [
        {
          "type": "tableHeader",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Header 1"}]}]
        },
        {
          "type": "tableHeader",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Header 2"}]}]
        }
      ]
    },
    {
      "type": "tableRow",
      "content": [
        {
          "type": "tableCell",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Cell 1"}]}]
        },
        {
          "type": "tableCell",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Cell 2"}]}]
        }
      ]
    }
  ]
}
```

#### Inline Code

```json
{
  "type": "paragraph",
  "content": [
    {"type": "text", "text": "Run "},
    {"type": "text", "text": "npm install", "marks": [{"type": "code"}]},
    {"type": "text", "text": " to install."}
  ]
}
```

### Full Task Description Example

```json
{
  "version": 1,
  "type": "doc",
  "content": [
    {
      "type": "paragraph",
      "content": [{"type": "text", "text": "Create the workspace_trash table for storing trash metadata."}]
    },
    {
      "type": "heading",
      "attrs": {"level": 2},
      "content": [{"type": "text", "text": "Files to Create"}]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {"type": "text", "text": "migrations/create-workspace-trash.up.sql", "marks": [{"type": "code"}]}
              ]
            }
          ]
        },
        {
          "type": "listItem",
          "content": [
            {
              "type": "paragraph",
              "content": [
                {"type": "text", "text": "migrations/create-workspace-trash.down.sql", "marks": [{"type": "code"}]}
              ]
            }
          ]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": {"level": 2},
      "content": [{"type": "text", "text": "SQL Migration"}]
    },
    {
      "type": "codeBlock",
      "attrs": {"language": "sql"},
      "content": [
        {"type": "text", "text": "CREATE TABLE workspace_trash (\n    workspace_id UUID NOT NULL,\n    item_type VARCHAR(20) NOT NULL\n);"}
      ]
    },
    {
      "type": "heading",
      "attrs": {"level": 2},
      "content": [{"type": "text", "text": "Definition of Done"}]
    },
    {
      "type": "orderedList",
      "content": [
        {
          "type": "listItem",
          "content": [
            {"type": "paragraph", "content": [{"type": "text", "text": "Migration file created"}]}
          ]
        },
        {
          "type": "listItem",
          "content": [
            {"type": "paragraph", "content": [{"type": "text", "text": "Up migration runs successfully"}]}
          ]
        },
        {
          "type": "listItem",
          "content": [
            {"type": "paragraph", "content": [{"type": "text", "text": "Down migration runs successfully"}]}
          ]
        }
      ]
    }
  ]
}
```

### Workflow for Editing Descriptions

1. **Create a temp JSON file** with ADF content wrapped in the `--from-json` format:
   ```json
   {
     "issues": ["KEY-123"],
     "description": {
       "version": 1,
       "type": "doc",
       "content": [...]
     }
   }
   ```
2. **Use --from-json** to apply it:
   ```bash
   acli jira workitem edit --from-json /tmp/edit.json --yes
   ```
3. **Delete the temp file** after success

**Note**: You can edit multiple issues at once by adding more keys to the `issues` array.

### Common Mistakes

| ❌ Wrong | ✅ Correct |
|---------|-----------|
| Using Markdown (`## Heading`) | Use ADF heading node |
| Using wiki markup (`h2. Heading`) | Use ADF heading node |
| Using `--description-file` for complex ADF | Use `--from-json` with issues array |
| Missing `version: 1` in root | Always include version |
| Text directly in doc | Text must be inside paragraph/heading nodes |
| Marks on non-text nodes | Marks only apply to text nodes |

### Key Rules

1. **Root must be `doc`** with `version: 1`
2. **Text goes inside containers** - never directly under `doc`
3. **Lists need listItem children** which contain paragraphs
4. **Tables need tableRow → tableHeader/tableCell → paragraph**
5. **Marks are arrays** on text nodes: `"marks": [{"type": "strong"}]`
6. **Code blocks use `\n`** for newlines in the text content
