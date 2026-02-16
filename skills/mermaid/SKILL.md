---
name: mermaid
description: Generate mermaid.live URLs from diagram code, or decode URLs back to diagram code.
allowed-tools: Bash
---

# Mermaid Live URL Generator

Generate shareable [mermaid.live](https://mermaid.live) URLs from Mermaid diagram code, or decode existing URLs back to source code.

## How It Works

Mermaid.live encodes diagram state in the URL fragment as:

1. **JSON** — `{"code": "<diagram>", "mermaid": "{\"theme\":\"default\"}", "updateDiagram": true}`
2. **zlib compress** (wbits=15)
3. **Base64url encode** (no padding)
4. **URL** — `https://mermaid.live/edit#pako:<encoded>`

## Script

A self-contained Python script is available at the same directory as this skill file:

```bash
# Encode a diagram file
uvx /path/to/mermaid_url.py encode diagram.mmd

# Encode from stdin
echo 'flowchart TD
  A --> B' | uvx /path/to/mermaid_url.py encode -

# Encode inline code
uvx /path/to/mermaid_url.py encode 'flowchart TD
  A --> B'

# Decode a URL back to diagram code
uvx /path/to/mermaid_url.py decode 'https://mermaid.live/edit#pako:...'
```

**Important**: Resolve the actual path of the script before running it. The script lives in the same directory as this SKILL.md file. Use `readlink -f` or equivalent to resolve the symlink if needed.

## Arguments

- `$ARGUMENTS` should contain:
  - **encode** or **decode** (required): The operation to perform
  - For **encode**: A file path, inline diagram code, or `-` for stdin
  - For **decode**: A mermaid.live URL

## Steps

1. Determine the absolute path to `mermaid_url.py` next to this skill file (resolve symlinks)
2. Run the script with `uvx` passing the user's arguments:
   ```bash
   uvx <resolved_path>/mermaid_url.py encode <input>
   uvx <resolved_path>/mermaid_url.py decode <url>
   ```
3. Return the generated URL or decoded diagram code to the user

## Example Usage

```
/mermaid encode diagram.mmd
/mermaid decode https://mermaid.live/edit#pako:eNpV...
/mermaid encode 'sequenceDiagram
  Alice->>Bob: Hello
  Bob-->>Alice: Hi'
```
