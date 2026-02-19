# Navigation & Links

| Command | Description | Key options |
|---------|-------------|-------------|
| `open` | Open file in Obsidian | `file=`, `path=`, `newtab` |
| `backlinks` | Incoming links to a file | `file=`, `path=`, `counts`, `total`, `format=json\|tsv\|csv` |
| `links` | Outgoing links from a file | `file=`, `path=`, `total` |
| `orphans` | Files with no incoming links | `total`, `all` |
| `deadends` | Files with no outgoing links | `total`, `all` |
| `unresolved` | Broken/unresolved links | `total`, `counts`, `verbose`, `format=json\|tsv\|csv` |
| `outline` | Heading tree for a file | `file=`, `path=`, `format=tree\|md\|json`, `total` |
| `recents` | Recently opened files | `total` |

### Examples

```bash
# Explore a note's connections
obsidian backlinks file="Derivada" counts
obsidian links file="Derivada"
obsidian outline file="Derivada"

# Open a note in Obsidian
obsidian open file="Derivada" newtab

# Find vault health issues
obsidian orphans total       # Notes no one links to
obsidian deadends total      # Notes that link nowhere
obsidian unresolved verbose  # Broken links with source files
```
