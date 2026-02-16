# Atlassian Document Format (ADF)

Jira Cloud uses ADF (JSON-based) for rich text. Do NOT use Markdown or wiki markup.

**References**:
- Docs: https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/
- Schema: https://unpkg.com/@atlaskit/adf-schema@51.5.7/dist/json-schema/v1/full.json

## Using ADF with acli

**IMPORTANT**: For complex ADF (headings, lists, code blocks, tables), use `--from-json` instead of `--description-file`. The `--description-file` flag has bugs with complex ADF.

### Simple Text Only

```bash
acli jira workitem edit --key "KEY-123" --description-file simple.json
```

### Complex ADF (Recommended)

```bash
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

acli jira workitem edit --from-json /tmp/edit.json --yes
```

### Generate Example JSON

```bash
acli jira workitem edit --generate-json
```

## Document Structure

Every ADF document:

```json
{
  "version": 1,
  "type": "doc",
  "content": [/* block nodes */]
}
```

## Block Nodes

| Node | Purpose | Parent |
|------|---------|--------|
| `paragraph` | Text container | doc |
| `heading` | Headers (attrs: level 1-6) | doc |
| `bulletList` | Unordered list | doc |
| `orderedList` | Numbered list | doc |
| `listItem` | List item | bulletList, orderedList |
| `codeBlock` | Code (attrs: language) | doc |
| `blockquote` | Quoted text | doc |
| `table` | Data table | doc |
| `tableRow` | Table row | table |
| `tableHeader` | Header cell | tableRow |
| `tableCell` | Data cell | tableRow |
| `rule` | Horizontal divider | doc |
| `panel` | Info panel (attrs: panelType) | doc |

## Inline Nodes

| Node | Purpose |
|------|---------|
| `text` | Plain text (can have marks) |
| `hardBreak` | Line break |
| `inlineCard` | Embedded link card |
| `mention` | User mention |
| `emoji` | Emoji character |

## Marks (Text Formatting)

Applied to `text` nodes via the `marks` array:

| Mark | Purpose | Attributes |
|------|---------|------------|
| `strong` | **Bold** | none |
| `em` | *Italic* | none |
| `code` | `Monospace` | none |
| `link` | Hyperlink | `href` (required) |
| `strike` | ~~Strikethrough~~ | none |
| `underline` | Underline | none |
| `textColor` | Colored text | `color` (hex) |

## Examples

### Paragraph with Bold

```json
{
  "version": 1, "type": "doc",
  "content": [{
    "type": "paragraph",
    "content": [
      {"type": "text", "text": "This is "},
      {"type": "text", "text": "bold", "marks": [{"type": "strong"}]},
      {"type": "text", "text": " text."}
    ]
  }]
}
```

### Heading + Paragraph

```json
{
  "version": 1, "type": "doc",
  "content": [
    {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Overview"}]},
    {"type": "paragraph", "content": [{"type": "text", "text": "Description text here."}]}
  ]
}
```

### Bullet List

```json
{
  "version": 1, "type": "doc",
  "content": [{
    "type": "bulletList",
    "content": [
      {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "First item"}]}]},
      {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Second item"}]}]}
    ]
  }]
}
```

### Ordered List

```json
{
  "version": 1, "type": "doc",
  "content": [{
    "type": "orderedList",
    "content": [
      {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Step one"}]}]},
      {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Step two"}]}]}
    ]
  }]
}
```

### Code Block

```json
{
  "version": 1, "type": "doc",
  "content": [{
    "type": "codeBlock", "attrs": {"language": "kotlin"},
    "content": [{"type": "text", "text": "fun main() {\n    println(\"Hello\")\n}"}]
  }]
}
```

**Languages**: java, kotlin, javascript, typescript, python, sql, bash, shell, go, rust, json, xml, html, css, etc.

### Link

```json
{
  "type": "paragraph",
  "content": [
    {"type": "text", "text": "See "},
    {"type": "text", "text": "documentation", "marks": [{"type": "link", "attrs": {"href": "https://example.com"}}]}
  ]
}
```

### Table

```json
{
  "type": "table",
  "content": [
    {"type": "tableRow", "content": [
      {"type": "tableHeader", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Header 1"}]}]},
      {"type": "tableHeader", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Header 2"}]}]}
    ]},
    {"type": "tableRow", "content": [
      {"type": "tableCell", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Cell 1"}]}]},
      {"type": "tableCell", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Cell 2"}]}]}
    ]}
  ]
}
```

### Full Task Description Example

```json
{
  "version": 1, "type": "doc",
  "content": [
    {"type": "paragraph", "content": [{"type": "text", "text": "Create the workspace_trash table for storing trash metadata."}]},
    {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Files to Create"}]},
    {"type": "bulletList", "content": [
      {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "migrations/create-workspace-trash.up.sql", "marks": [{"type": "code"}]}]}]},
      {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "migrations/create-workspace-trash.down.sql", "marks": [{"type": "code"}]}]}]}
    ]},
    {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "SQL Migration"}]},
    {"type": "codeBlock", "attrs": {"language": "sql"}, "content": [
      {"type": "text", "text": "CREATE TABLE workspace_trash (\n    workspace_id UUID NOT NULL,\n    item_type VARCHAR(20) NOT NULL\n);"}
    ]},
    {"type": "heading", "attrs": {"level": 2}, "content": [{"type": "text", "text": "Definition of Done"}]},
    {"type": "orderedList", "content": [
      {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Migration file created"}]}]},
      {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Up migration runs successfully"}]}]},
      {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Down migration runs successfully"}]}]}
    ]}
  ]
}
```

## Workflow for Editing Descriptions

1. Create a temp JSON file with ADF wrapped in `--from-json` format:
   ```json
   {"issues": ["KEY-123"], "description": {"version": 1, "type": "doc", "content": [...]}}
   ```
2. Apply: `acli jira workitem edit --from-json /tmp/edit.json --yes`
3. Delete the temp file after success

## Key Rules

1. Root must be `doc` with `version: 1`
2. Text goes inside containers — never directly under `doc`
3. Lists need `listItem` children which contain paragraphs
4. Tables need `tableRow` → `tableHeader`/`tableCell` → `paragraph`
5. Marks are arrays on text nodes: `"marks": [{"type": "strong"}]`
6. Code blocks use `\n` for newlines in text content

## Common Mistakes

| Wrong | Correct |
|-------|---------|
| Markdown (`## Heading`) | ADF heading node |
| Wiki markup (`h2. Heading`) | ADF heading node |
| `--description-file` for complex ADF | `--from-json` with issues array |
| Missing `version: 1` in root | Always include version |
| Text directly in doc | Text inside paragraph/heading nodes |
| Marks on non-text nodes | Marks only on text nodes |
