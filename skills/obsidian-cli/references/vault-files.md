# Vault & File Operations

## Vault Info

| Command | Description | Key options |
|---------|-------------|-------------|
| `vault` | Vault name, path, file/folder counts, size | `info=name\|path\|files\|folders\|size` |
| `vaults` | List known vaults | `verbose` (include paths), `total` |
| `version` | Obsidian version | |
| `files` | List files | `folder=<path>`, `ext=<ext>`, `total` |
| `folders` | List folders | `folder=<path>`, `total` |
| `file` | File metadata (path, size, dates) | `file=`, `path=` |
| `folder` | Folder info | `path=`, `info=files\|folders\|size` |
| `wordcount` | Word/char count | `file=`, `path=`, `words`, `characters` |

### Targeting a specific vault

```bash
obsidian vault="Math" <command> ...
```

List known vaults with `obsidian vaults verbose`.

## Reading & Writing

| Command | Description | Key options |
|---------|-------------|-------------|
| `read` | Read file contents | `file=`, `path=` |
| `create` | Create a new file | `name=`, `path=`, `content=`, `template=`, `overwrite`, `open`, `newtab` |
| `append` | Append content | `file=`, `path=`, `content=` (required), `inline` |
| `prepend` | Prepend content | `file=`, `path=`, `content=` (required), `inline` |
| `delete` | Delete a file | `file=`, `path=`, `permanent` |
| `move` | Move/rename file | `file=`, `path=`, `to=` (required) |
| `rename` | Rename a file | `file=`, `path=`, `name=` (required) |

### Examples

```bash
# Create a new note with frontmatter
obsidian create name="Mi nota" path="Calculo I/Mi nota.md" content="---\ntags:\n  - calculus\n---\n\nContenido aquí."

# Append content to an existing note
obsidian append file="Derivada" content="\n## Nueva sección\n\nTexto adicional."
```
