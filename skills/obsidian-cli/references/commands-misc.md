# Commands, Hotkeys & Misc

## Commands & Hotkeys

| Command | Description | Key options |
|---------|-------------|-------------|
| `commands` | List command IDs | `filter=<prefix>` (e.g. `filter=editor`) |
| `command` | Execute a command | `id=` (required) |
| `hotkeys` | List hotkeys | `total`, `verbose`, `all`, `format=json\|tsv\|csv` |
| `hotkey` | Get hotkey for command | `id=` (required), `verbose` |

## Bases (Obsidian databases)

| Command | Description | Key options |
|---------|-------------|-------------|
| `bases` | List base files | |
| `base:views` | List views in a base | |
| `base:query` | Query a base | `file=`, `path=`, `view=`, `format=json\|csv\|tsv\|md\|paths` |
| `base:create` | Create item in a base | `file=`, `path=`, `view=`, `name=`, `content=`, `open`, `newtab` |

## Misc

| Command | Description |
|---------|-------------|
| `random` | Open a random note (`folder=`, `newtab`) |
| `random:read` | Read a random note (`folder=`) |
| `reload` | Reload the vault |
| `restart` | Restart Obsidian |
| `workspace` | Show workspace tree (`ids`) |
| `tabs` | List open tabs (`ids`) |
| `tab:open` | Open a new tab (`group=`, `file=`, `view=`) |
