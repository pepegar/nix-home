# PR Description Stack Table

Each PR in a stack gets a navigation table at the top of its description. The table is wrapped in HTML comment markers so it can be updated idempotently.

## Template

```markdown
<!-- stack:start -->
### Stack: {stack_name}
| # | PR | Branch | Status |
|---|-----|--------|--------|
| 1 | [#{number}]({url}) | {branch} | {status} |
| 2 | **[#{number}]({url})** | **{branch}** | **<-- This PR** |
| 3 | [#{number}]({url}) | {branch} | {status} |
<!-- stack:end -->
```

The current PR's row is **bold** with the status replaced by `<-- This PR`.

## Status Mapping

Derive the status from the PR's `state` and `reviewDecision` fields:

| state | reviewDecision | Display |
|-------|---------------|---------|
| `MERGED` | any | `Merged` |
| `OPEN` | `APPROVED` | `Approved` |
| `OPEN` | `CHANGES_REQUESTED` | `Changes Requested` |
| `OPEN` | `REVIEW_REQUIRED` | `Review Pending` |
| `OPEN` | (none/null) | `Open` |
| (no PR) | -- | `No PR` |

## Updating Existing Descriptions

When updating a PR body:

1. **Check for existing markers**: look for `<!-- stack:start -->` and `<!-- stack:end -->`
2. **If found**: replace everything between the markers (inclusive) with the new table
3. **If not found**: prepend the table + a blank line to the existing body

This ensures the stack table is always at the top and doesn't corrupt the rest of the PR description.

## Building the Table

For each PR in the stack, generate a personalized table where that PR is marked as "This PR":

```
For pr_being_updated in all_prs:
  table_rows = []
  for each branch in stack (ordered):
    if branch == pr_being_updated.branch:
      row = bold, status = "<-- This PR"
    else:
      row = normal, status = derived from gh API
    table_rows.append(row)

  full_table = header + table_rows wrapped in markers
  update pr body with full_table
```

## Escaping

PR body content passed to `gh pr edit --body` needs careful handling:
- Use a temp file and `--body-file` to avoid shell escaping issues:
  ```bash
  echo "$new_body" > /tmp/pr-body-$pr_number.md
  gh pr edit "$pr_number" --body-file /tmp/pr-body-$pr_number.md
  rm /tmp/pr-body-$pr_number.md
  ```
- This is safer than passing the body as a string argument, especially when the body contains markdown tables, links, and special characters.
