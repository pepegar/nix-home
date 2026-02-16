# Prune Git Worktrees

Safely clean up git worktrees by checking for open PRs, unmerged commits, and uncommitted files before deletion.

## Arguments

- `$ARGUMENTS` may contain:
  - `--force`: Skip confirmation prompts and delete all safe worktrees
  - `--dry-run`: Show what would be deleted without actually deleting

## Safety Checks

Before deleting any worktree, perform these checks in order:

| Check | Command | Blocks Deletion? |
|-------|---------|------------------|
| Protected branch | `[[ "$BRANCH" =~ ^(main\|master\|develop)$ ]]` | Yes |
| Current worktree | Compare paths with current working directory | Always |
| Open PR | `gh pr list --head "$BRANCH" --state open` | Yes (merged PRs are safe) |
| Unmerged commits | `git log $DEFAULT_BRANCH..$BRANCH --oneline` | Yes |
| Uncommitted files | `git -C "$PATH" status --porcelain` | Yes |

## Workflow

### Step 1: Parse Arguments

```bash
FORCE=false
DRY_RUN=false
for arg in $ARGUMENTS; do
  case "$arg" in
    --force) FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
  esac
done
```

### Step 2: Get Default Branch and Current Directory

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$DEFAULT_BRANCH" ]; then
  DEFAULT_BRANCH="main"
fi
CURRENT_DIR=$(pwd -P)
REPO_ROOT=$(git rev-parse --show-toplevel)
```

### Step 3: List All Worktrees

```bash
git worktree list --porcelain
```

Parse the output to extract worktree path and branch for each entry.

### Step 4: Analyze Each Worktree

For each worktree (excluding the main repository):

1. **Check if protected branch**:
   ```bash
   if [[ "$BRANCH" =~ ^(main|master|develop)$ ]]; then
     REASON="PROTECTED"
     SAFE=false
   fi
   ```

2. **Check if current worktree**:
   ```bash
   WORKTREE_REAL=$(cd "$WORKTREE_PATH" && pwd -P)
   if [ "$WORKTREE_REAL" = "$CURRENT_DIR" ]; then
     REASON="CURRENT"
     SAFE=false
   fi
   ```

3. **Check for open PR**:
   ```bash
   OPEN_PR=$(gh pr list --head "$BRANCH" --state open --json number,url --jq '.[0].number // empty' 2>/dev/null)
   if [ -n "$OPEN_PR" ]; then
     REASON="HAS_PR: #$OPEN_PR"
     SAFE=false
   fi
   ```

4. **Check for unmerged commits**:
   ```bash
   UNMERGED=$(git log --oneline "$DEFAULT_BRANCH".."$BRANCH" 2>/dev/null | head -5)
   if [ -n "$UNMERGED" ]; then
     REASON="UNMERGED_COMMITS"
     SAFE=false
   fi
   ```

5. **Check for uncommitted changes**:
   ```bash
   DIRTY=$(git -C "$WORKTREE_PATH" status --porcelain 2>/dev/null)
   if [ -n "$DIRTY" ]; then
     REASON="DIRTY"
     SAFE=false
   fi
   ```

6. **Get last commit info** (for display):
   ```bash
   LAST_COMMIT=$(git -C "$WORKTREE_PATH" log -1 --format="%cr" 2>/dev/null || echo "unknown")
   ```

### Step 5: Display Analysis

Output a categorized summary:

```
## Worktree Prune Analysis

### Safe to Delete (N)
| Branch | Path | Last Commit |
|--------|------|-------------|
| feature-old | .worktrees/feature-old | 3 weeks ago |

### Unsafe - Cannot Delete (N)
| Branch | Path | Reason |
|--------|------|--------|
| feature-wip | .worktrees/feature-wip | HAS_PR: #42 |

### Skipped (N)
| Branch | Path | Reason |
|--------|------|--------|
| main | /repo | PROTECTED |
```

### Step 6: Delete Safe Worktrees

If `--dry-run` is set, stop here after showing the analysis.

For each safe worktree:

1. **If not --force**, ask for confirmation:
   ```
   Delete worktree 'feature-old' at .worktrees/feature-old? [y/N]
   ```
   Use AskUserQuestion tool for each worktree.

2. **Remove the worktree**:
   ```bash
   git worktree remove "$WORKTREE_PATH"
   ```

3. **Delete the branch** (if it still exists):
   ```bash
   git branch -d "$BRANCH" 2>/dev/null || true
   ```

### Step 7: Cleanup

After processing all deletions:

```bash
git worktree prune
```

### Step 8: Final Summary

Output what was deleted:

```
## Deletion Summary

Deleted 2 worktrees:
- feature-old (.worktrees/feature-old)
- bugfix-123 (.worktrees/bugfix-123)

Skipped 1 worktree (user declined):
- feature-maybe

Run `git worktree list` to see remaining worktrees.
```

## Example Usage

```
/worktree prune
# Interactive mode - asks for confirmation for each safe worktree

/worktree prune --dry-run
# Shows what would be deleted without deleting anything

/worktree prune --force
# Deletes all safe worktrees without confirmation
```

## Notes

- The main repository worktree is never deleted
- Protected branches (main, master, develop) are always skipped
- Merged PRs are considered safe to delete (only open PRs block deletion)
- Always run `git worktree prune` at the end to clean up stale worktree references
