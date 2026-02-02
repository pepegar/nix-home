---
name: worktree
description: Create a new git worktree from a branch off the current branch
argument-hint: <branch-name> [worktree-path]
allowed-tools: Bash
---

# Create Git Worktree

Create a new git worktree with a branch that's based off the current branch.

## Arguments

- `$ARGUMENTS` should contain:
  - **branch-name** (required): Name for the new branch
  - **worktree-path** (optional): Path for the worktree directory. Defaults to `.worktrees/<branch-name>`

## Steps

1. Get the current branch name using `git branch --show-current`
2. Get the repo root using `git rev-parse --show-toplevel`
3. Parse the arguments from `$ARGUMENTS`:
   - First argument is the branch name
   - Second argument (if provided) is the worktree path, otherwise use `<repo-root>/.worktrees/<branch-name>`
4. Ensure `.worktrees` directory exists
5. Create the worktree with a new branch based on the current branch:
   ```bash
   git worktree add -b <new-branch> <worktree-path>
   ```
6. Report the created worktree location and the base branch

## Example Usage

```
/worktree feature-auth
# Creates worktree at .worktrees/feature-auth with branch feature-auth based on current branch

/worktree feature-auth ~/projects/myrepo-auth
# Creates worktree at ~/projects/myrepo-auth with branch feature-auth
```

## Output

After creating the worktree, display:
- The new branch name
- The base branch it was created from
- The worktree path
