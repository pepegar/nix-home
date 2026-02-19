# Searching

| Command | Description | Key options |
|---------|-------------|-------------|
| `search` | Search vault text | `query=` (required), `path=`, `limit=`, `total`, `case`, `format=text\|json` |
| `search:context` | Search with line context | `query=` (required), `path=`, `limit=`, `case`, `format=text\|json` |
| `search:open` | Open Obsidian search pane | `query=` |

> **Prefer `search:context`** over plain `search` — it returns matching lines, not just file paths.

### Examples

```bash
# Search for a concept with context
obsidian search:context query="Bolzano" limit=5

# Case-sensitive search in a specific folder
obsidian search:context query="Teorema" path="Calculo I" case

# Get just the count of results
obsidian search query="derivada" total

# JSON output for programmatic use
obsidian search:context query="continua" format=json

# Open search pane in Obsidian
obsidian search:open query="límite"
```
