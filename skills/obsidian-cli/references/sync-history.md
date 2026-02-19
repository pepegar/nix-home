# Sync & History

## Sync

| Command | Description | Key options |
|---------|-------------|-------------|
| `sync` | Pause/resume sync | `on`, `off` |
| `sync:status` | Sync status | |
| `sync:history` | Sync versions for a file | `file=`, `path=`, `total` |
| `sync:read` | Read a sync version | `file=`, `path=`, `version=` (required) |
| `sync:restore` | Restore a sync version | `file=`, `path=`, `version=` (required) |
| `sync:deleted` | Deleted files in sync | `total` |
| `sync:open` | Open sync history UI | `file=`, `path=` |

## Local History

| Command | Description | Key options |
|---------|-------------|-------------|
| `history` | Local history versions | `file=`, `path=` |
| `history:list` | Files with history | |
| `history:read` | Read a history version | `file=`, `path=`, `version=` |
| `history:restore` | Restore a version | `file=`, `path=`, `version=` (required) |
| `history:open` | Open file recovery UI | `file=`, `path=` |

## Diff

| Command | Description | Key options |
|---------|-------------|-------------|
| `diff` | Diff versions | `file=`, `path=`, `from=`, `to=`, `filter=local\|sync` |
