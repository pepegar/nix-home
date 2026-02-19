# Tags & Properties

## Tags

| Command | Description | Key options |
|---------|-------------|-------------|
| `tags` | List vault tags | `file=`, `path=`, `counts`, `sort=count`, `total`, `format=json\|tsv\|csv`, `active` |
| `tag` | Tag info/occurrences | `name=` (required), `total`, `verbose` |
| `aliases` | List aliases | `file=`, `path=`, `total`, `verbose`, `active` |

### Examples

```bash
# List tags sorted by frequency
obsidian tags counts sort=count

# Top 20 tags
obsidian tags counts sort=count | head -20

# Tags for a specific file
obsidian tags file="Derivada"
```

## Properties

| Command | Description | Key options |
|---------|-------------|-------------|
| `properties` | List properties | `file=`, `path=`, `name=`, `total`, `sort=count`, `counts`, `format=yaml\|json\|tsv`, `active` |
| `property:read` | Read a property value | `name=` (required), `file=`, `path=` |
| `property:set` | Set a property | `name=`, `value=` (both required), `type=text\|list\|number\|checkbox\|date\|datetime`, `file=`, `path=` |
| `property:remove` | Remove a property | `name=` (required), `file=`, `path=` |

### Examples

```bash
# Set/read properties on a note
obsidian property:set name="tags" value="calculus,derivatives" type=list file="Derivada"
obsidian property:read name="tags" file="Derivada"

# Remove a property
obsidian property:remove name="draft" file="Derivada"
```
