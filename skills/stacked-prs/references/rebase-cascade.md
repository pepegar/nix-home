# Rebase Cascade Algorithm

When rebasing a stack, each branch must be rebased onto its parent in order from bottom to top. This ensures each branch sees the updated parent before it gets rebased itself.

## Algorithm

```
For each branch in the stack (order 1, 2, 3, ...):
  parent = git config branch.<branch>.stack-parent
  merge_base = git merge-base <branch> <parent>
  parent_tip = git rev-parse <parent>

  if merge_base == parent_tip:
    skip (already up-to-date)
  else:
    git rebase --onto <parent> <merge_base> <branch>
    if rebase fails (conflict):
      STOP and report
```

The `--onto` form is important because it works from any directory without needing to be inside the branch's worktree. It moves the branch pointer directly.

## Before Starting

Fetch the latest base branch so the first branch in the stack rebases onto the latest upstream:

```bash
BASE=$(git config --local "stack.$STACK_NAME.base")
git fetch origin "$BASE"
# Update the local tracking branch
git update-ref "refs/heads/$BASE" "origin/$BASE"
```

Only update the local ref if the base branch has no local-only commits (it shouldn't for branches like `develop` or `main`).

## Force Pushing

After all rebases succeed, push all rebased branches:

```bash
for branch in $ALL_BRANCHES; do
  git push --force-with-lease origin "$branch"
done
```

Always use `--force-with-lease` to prevent overwriting someone else's push. If it fails, it means someone pushed to that branch externally. In that case, warn the user and suggest fetching + re-running the rebase.

## Conflict Handling

When `git rebase --onto` fails due to a conflict:

1. **Identify the branch**: report which branch (and its position in the stack) has the conflict
2. **Identify the files**: `git diff --name-only --diff-filter=U` shows conflicting files
3. **Direct the user to the worktree**: conflicts must be resolved in `.worktrees/<branch>` (or the main worktree if that's where the branch lives)
4. **Instruct them**:
   - Edit the conflicting files to resolve
   - `git add <resolved-files>`
   - `git rebase --continue`
5. **Resume**: after resolving, the user re-runs `/stacked-prs rebase`. The skill checks each branch from the beginning — already-rebased branches (where merge_base == parent_tip) are skipped automatically.

## When the Base Branch Has Been Updated

If `develop` has new commits since the stack was last rebased:

- Branch 1's parent is `develop`, so it naturally rebases onto the new `develop` tip
- Branches 2, 3, ... rebase onto their respective parents (which now include branch 1's rebased version)
- The cascade handles this correctly with no special logic needed

## Partial Rebase (After Conflict Resolution)

When resuming after a conflict in branch N:
- Branches 1 through N-1: already rebased, merge_base == parent_tip, skipped
- Branch N: just had its conflict resolved and rebase completed, also up-to-date now
- Branches N+1 onward: still need rebasing, proceed normally

The stateless check (merge_base vs parent_tip) makes resumption automatic.
