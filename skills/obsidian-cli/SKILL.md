---
name: obsidian-cli
description: Interact with Obsidian vaults via the `obsidian` CLI. Use when the user asks to search notes, read/create/edit vault files, manage tags/properties, check backlinks/orphans, open notes in Obsidian, or perform any vault operation through the command line.
---

# Obsidian CLI

The `obsidian` CLI communicates directly with a running Obsidian instance. **Obsidian must be open** for commands to work.

## Syntax

```
obsidian <command> [key=value ...] [flags]
```

- **Positional flags** (no `=`): boolean options like `total`, `verbose`, `open`, `case`
- **Key-value params**: `file=<name>`, `path=<path>`, `query=<text>`, etc.
- **Quote values with spaces**: `file="My Note"`, `content="Hello world"`
- **Newlines/tabs in content**: use `\n` and `\t`
- **`file=` vs `path=`**: `file` resolves by name (like wikilinks); `path` is the exact relative path (e.g. `path="Calculo I/Derivada.md"`)
- **Most commands default to the active file** when `file`/`path` is omitted

## Quick Reference

| Task | Command |
|------|---------|
| Search with context | `obsidian search:context query="term" limit=5` |
| Read a note | `obsidian read file="Note Name"` |
| Create a note | `obsidian create name="Title" path="folder/Title.md" content="..."` |
| Append to note | `obsidian append file="Note" content="new text"` |
| Open in Obsidian | `obsidian open file="Note" newtab` |
| Backlinks | `obsidian backlinks file="Note" counts` |
| Outgoing links | `obsidian links file="Note"` |
| Heading outline | `obsidian outline file="Note"` |
| List tags | `obsidian tags counts sort=count` |
| Read property | `obsidian property:read name="tags" file="Note"` |
| Set property | `obsidian property:set name="tags" value="a,b" type=list file="Note"` |
| Daily note | `obsidian daily:read` |
| Orphan notes | `obsidian orphans total` |
| Broken links | `obsidian unresolved verbose` |

## Tips

- **Prefer `search:context`** over plain `search` — it returns matching lines, not just file paths.
- **Use `format=json`** when you need to parse output programmatically.
- **`file=` does fuzzy wikilink resolution** — you don't need the full path or `.md` extension.
- **Combine with pipes**: `obsidian tags counts sort=count | head -20` for top tags.
- **stderr noise**: The CLI prints a loading message to stderr on every call — ignore it or redirect with `2>/dev/null`.

## Detailed References

Read these files for full command tables, options, and examples:

- `references/vault-files.md` — Vault info, file listing, reading, writing, moving
- `references/search.md` — Search commands and examples
- `references/navigation-links.md` — Links, backlinks, orphans, deadends, outline
- `references/tags-properties.md` — Tags, properties, aliases
- `references/daily-notes-tasks.md` — Daily notes, tasks, bookmarks
- `references/plugins-themes.md` — Plugin/theme/snippet management
- `references/sync-history.md` — Sync, local history, diff
- `references/commands-misc.md` — Commands, hotkeys, bases, workspace, tabs
