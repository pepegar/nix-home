# Daily Notes & Tasks

## Daily Notes

| Command | Description | Key options |
|---------|-------------|-------------|
| `daily` | Open today's daily note | `paneType=tab\|split\|window` |
| `daily:read` | Read daily note contents | |
| `daily:path` | Get daily note file path | |
| `daily:append` | Append to daily note | `content=` (required), `inline`, `open`, `paneType=` |
| `daily:prepend` | Prepend to daily note | `content=` (required), `inline`, `open`, `paneType=` |

### Examples

```bash
obsidian daily:path
obsidian daily:read
obsidian daily:append content="- Nueva tarea para hoy"
```

## Tasks

| Command | Description | Key options |
|---------|-------------|-------------|
| `tasks` | List tasks | `file=`, `path=`, `total`, `done`, `todo`, `status="<char>"`, `verbose`, `format=json\|tsv\|csv`, `active`, `daily` |
| `task` | Show/update a task | `ref=<path:line>`, `file=`, `path=`, `line=`, `toggle`, `done`, `todo`, `status="<char>"`, `daily` |

### Examples

```bash
# List pending tasks in current vault
obsidian tasks todo

# List tasks from daily note
obsidian tasks daily

# Toggle a task by reference
obsidian task ref="Calculo I/Ejercicios.md:15" toggle
```

## Bookmarks

| Command | Description | Key options |
|---------|-------------|-------------|
| `bookmarks` | List bookmarks | `total`, `verbose`, `format=json\|tsv\|csv` |
| `bookmark` | Add a bookmark | `file=`, `subpath=`, `folder=`, `search=`, `url=`, `title=` |
