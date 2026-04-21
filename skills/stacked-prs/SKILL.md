---
name: stacked-prs
description: "Manage stacked pull requests (dependent PR chains). Use whenever the user mentions stacked PRs, PR stacks, dependent PRs, rebasing a chain of PRs, cascading rebase, updating stack descriptions, syncing after a PR lands, or navigating between stacked branches. Also trigger when the user says 'stack', 'add to stack', 'stack status', 'submit stack', 'sync stack', or 'rebase stack'."
allowed-tools: Bash, Glob, Grep, Read
argument-hint: "<command> [args]"
---

# Stacked PRs

Manage chains of dependent pull requests where each PR builds on top of the previous one. This skill handles creating stacks, rebasing in cascade, syncing after merges, and keeping PR descriptions in sync.

Worktree + Zellij-tab management is delegated to the [`wt` skill](../wt/SKILL.md). Both skills share the same `<git-root>/.worktrees/<branch>` convention, so operations compose cleanly.

## Command Dispatch

Parse `$ARGUMENTS` to route to the correct operation. If empty, default to `list`.

| Command | Aliases | Description |
|---------|---------|-------------|
| `create <name>` | `init` | Initialize a new stack from the current branch |
| `add <branch>` | `push` | Add a new branch on top of the stack |
| `list` | `status`, `ls` | Show the current stack with PR status |
| `rebase` | | Rebase all branches in the stack onto their parents |
| `sync` | `land` | Sync stack after a PR lands (detect merged, rebase rest) |
| `submit` | `pr`, `prs` | Create/update PRs for the entire stack |
| `update-descriptions` | `desc` | Refresh the stack table in all PR descriptions |
| `navigate <up\|down\|N>` | `nav`, `go` | Move between stack entries via worktrees |

## Metadata Schema

All stack metadata lives in `git config --local`. This keeps it per-repo and avoids extra files.

**Per-branch:**
```
branch.<name>.stack-name   = "feature-auth"    # which stack this branch belongs to
branch.<name>.stack-parent = "develop"         # parent branch in the stack
branch.<name>.stack-order  = "1"               # 1-indexed position in the stack
```

**Per-stack:**
```
stack.<name>.base = "develop"    # the branch the stack is built on top of
```

**Reading all branches in a stack (ordered):**
```bash
get_stack_branches() {
  local stack_name="$1"
  git config --local --get-regexp 'branch\..*\.stack-name' | \
    grep " ${stack_name}$" | \
    sed 's/branch\.\(.*\)\.stack-name .*/\1/' | \
    while read branch; do
      order=$(git config --local "branch.$branch.stack-order" 2>/dev/null)
      echo "$order $branch"
    done | sort -n
}
```

Use this pattern throughout all operations.

---

## Operation: `create <name>`

Initialize a new stack, registering the current branch as position 1.

1. Get current branch: `git branch --show-current`
2. Parse the stack name from arguments
3. Check no existing stack has that name:
   ```bash
   git config --local --get-regexp 'branch\..*\.stack-name' | grep " $STACK_NAME$"
   ```
   If it exists, error and suggest a different name.
4. If the current branch already belongs to a stack, warn and ask for confirmation.
5. Ask the user which branch is the base (default: `develop`). This is what the bottom of the stack was branched from.
6. Store the stack base:
   ```bash
   git config --local "stack.$STACK_NAME.base" "$BASE_BRANCH"
   ```
7. Set metadata on the current branch:
   ```bash
   git config --local "branch.$CURRENT_BRANCH.stack-name" "$STACK_NAME"
   git config --local "branch.$CURRENT_BRANCH.stack-parent" "$BASE_BRANCH"
   git config --local "branch.$CURRENT_BRANCH.stack-order" "1"
   ```
8. Report: stack name, current branch as position 1, base branch.

---

## Operation: `add <branch-name>`

Create a new branch on top of the current stack, with a worktree.

1. Determine the current stack:
   ```bash
   CURRENT_BRANCH=$(git branch --show-current)
   STACK_NAME=$(git config --local "branch.$CURRENT_BRANCH.stack-name" 2>/dev/null)
   ```
   If not in a stack, check if there's exactly one stack in the repo and use that. Otherwise, ask.

2. Find the current top of the stack (highest order number and its branch).

3. Parse the new branch name from arguments. If not provided, ask the user.

4. Create the worktree and branch from the stack top via `wt`:
   ```bash
   wt new "$NEW_BRANCH" --from "$TOP_BRANCH" --desc "$DESCRIPTION"
   ```
   This handles the `.worktrees/<branch>` path, gitignored-file cloning, and branch description in one shot. Optionally follow with `wt zellij "$NEW_BRANCH"` to open a tab for it.

5. Set stack metadata:
   ```bash
   NEW_ORDER=$((TOP_ORDER + 1))
   git config --local "branch.$NEW_BRANCH.stack-name" "$STACK_NAME"
   git config --local "branch.$NEW_BRANCH.stack-parent" "$TOP_BRANCH"
   git config --local "branch.$NEW_BRANCH.stack-order" "$NEW_ORDER"
   ```

6. Report: new branch, worktree path, position in stack, parent branch. (`wt new` already stored the branch description via `--desc`.)

---

## Operation: `list`

Show the full stack with branch info, PR status, and sync state.

1. Determine the stack from the current branch. If not in a stack, list all stacks and let the user pick.

2. Get all branches in order using `get_stack_branches`.

3. For each branch, gather:
   - **PR info**: `gh pr list --head "$branch" --state all --json number,state,url,reviewDecision --jq '.[0]'`
   - **Needs rebase?** Compare merge-base with **immediate parent** tip only (not transitive):
     ```bash
     parent=$(git config --local "branch.$branch.stack-parent")
     merge_base=$(git merge-base "$branch" "$parent" 2>/dev/null)
     parent_tip=$(git rev-parse "$parent" 2>/dev/null)
     # needs rebase if merge_base != parent_tip
     ```
     Note: a branch can show `up-to-date` while being transitively stale — its parent hasn't moved yet, but a grandparent has. The rebase cascade surfaces this naturally: once branch N is rebased, branch N+1's parent tip changes and it will then show `needs-rebase`.
   - **Has worktree?** `git worktree list | grep "\[$branch\]"`
   - **Current?** Compare with `git branch --show-current`

4. Display:
   ```
   Stack: feature-auth (base: develop)

   #  Branch              PR       Review          Rebase
   1  auth-base           #123     Approved        needs-rebase
   2  auth-validation     #124     Changes Req.    needs-rebase    <-- you are here
   3  auth-tests          --       --              up-to-date  (transitively stale; will need rebase after #2 is rebased)
   ```

---

## Operation: `rebase`

Rebase every branch in the stack onto its parent, in order. See [Rebase Cascade](references/rebase-cascade.md) for the full algorithm.

**Summary:**

1. Get the stack branches in order.
2. Fetch the base branch: `git fetch origin "$BASE_BRANCH"`
3. For each branch in order (1, 2, 3, ...):
   - Check if rebase is needed (merge-base vs parent tip)
   - If needed: `git rebase --onto "$parent" "$(git merge-base $branch $parent)" "$branch"`
   - If conflict: stop, report the branch and conflicting files, instruct user to resolve
4. After all rebases: force-push all branches with `--force-with-lease`
5. Report results.

When resuming after conflict resolution, the skill checks each branch and skips ones already up-to-date.

---

## Operation: `sync`

After one or more PRs have been merged, clean up and rebase remaining branches.

1. Get stack branches in order.
2. Detect merged branches:
   ```bash
   gh pr list --head "$branch" --state merged --json number --jq '.[0].number // empty'
   ```
3. For contiguous merged branches from the bottom:
   - Update the next unmerged branch's parent to the merged branch's parent (or base):
     ```bash
     git config --local "branch.$next_unmerged.stack-parent" "$new_parent"
     ```
   - Update the GitHub PR's base branch:
     ```bash
     gh pr edit "$pr_number" --base "$new_parent"
     ```
   - Remove stack metadata from the merged branch:
     ```bash
     git config --local --unset "branch.$merged.stack-name"
     git config --local --unset "branch.$merged.stack-parent"
     git config --local --unset "branch.$merged.stack-order"
     ```
4. If a middle branch was merged out of order, warn the user and explain what happened. Proceed with best-effort: treat it as merged and adjust parents accordingly.
5. Renumber remaining branches to be contiguous from 1.
6. Fetch updated base and run the rebase cascade on remaining branches.
7. Force-push all updated branches with `--force-with-lease`.
8. Run `update-descriptions` (via the Python script) to refresh all PR stack tables.
9. Clean up worktrees, branches, and Zellij tabs for merged entries via `wt`:
   ```bash
   wt rm "$merged_branch" 2>/dev/null || true
   ```
10. Report what was synced, removed, and rebased.

---

## Operation: `submit`

Create or update GitHub PRs for all branches in the stack.

1. Get stack branches in order.
2. Push all branches that have unpushed commits:
   ```bash
   git push --force-with-lease origin "$branch"
   ```
3. For each branch:
   - Check for existing PR: `gh pr list --head "$branch" --state open --json number,url --jq '.[0]'`
   - Determine the target base:
     - Position 1: the stack's base branch (e.g., `develop`)
     - Position N > 1: the branch at position N-1
   - **If no PR exists**, create one:
     - Get branch description: `git config "branch.$branch.description"`
     - Extract JIRA tag if present: `[[ "$branch" =~ ([A-Z]+-[0-9]+) ]]`
     - Construct title: `[$JIRA_TAG] $description` or just `$description`
     - Create:
       ```bash
       gh pr create --head "$branch" --base "$target_base" --title "$title" --assignee "@me" --body "$BODY"
       ```
   - **If PR exists**, update base if it changed:
     ```bash
     current_base=$(gh pr view "$pr_number" --json baseRefName --jq '.baseRefName')
     if [ "$current_base" != "$expected_base" ]; then
       gh pr edit "$pr_number" --base "$expected_base"
     fi
     ```
4. After all PRs exist, run `update-descriptions` (via the Python script) to insert/refresh stack tables.
5. Report all PRs with numbers and URLs.

---

## Operation: `update-descriptions`

Update the stack navigation table in all PR descriptions. See [PR Descriptions](references/pr-descriptions.md) for the template format.

**Use the bundled Python script** — it handles git config parsing, `gh` API calls, status mapping, multiline body escaping, and temp files reliably (bash struggles with multiline markdown in variables):

```bash
python3 "$(dirname "$SKILL_PATH")/scripts/update-stack-descriptions.py"
```

Or with an explicit stack name:
```bash
python3 "$(dirname "$SKILL_PATH")/scripts/update-stack-descriptions.py" --stack-name "my-stack"
```

The script (at `scripts/update-stack-descriptions.py` relative to this skill):
1. Reads stack branches from `git config --local` metadata
2. Fetches PR info (number, state, reviewDecision, url) via `gh pr list` for each branch
3. Derives display status (Merged, Approved, Changes Requested, Review Pending, Open)
4. Builds a personalized stack table per PR (current PR highlighted with bold + `<-- This PR`)
5. For each PR: reads existing body, replaces `<!-- stack:start -->...<!-- stack:end -->` markers (or prepends if absent), writes to a temp file, and calls `gh pr edit --body-file`
6. Reports progress and skips branches without PRs

**When to resolve `SKILL_PATH`:** The `$SKILL_PATH` variable refers to the absolute path of this SKILL.md file. Resolve it from the skill location provided in the agent's available skills list. For example, if the skill is at `/Users/pepe/.agents/skills/stacked-prs/SKILL.md`, the script is at `/Users/pepe/.agents/skills/stacked-prs/scripts/update-stack-descriptions.py`.

---

## Operation: `navigate <target>`

Switch to a different branch's worktree within the stack.

1. Get current position:
   ```bash
   CURRENT_BRANCH=$(git branch --show-current)
   CURRENT_ORDER=$(git config --local "branch.$CURRENT_BRANCH.stack-order")
   ```
2. Parse target:
   - `up` = current order - 1
   - `down` = current order + 1
   - A number = go to that position
   - A branch name = find it in the stack
3. Find the target branch from its order.
4. Focus its Zellij tab (creating one if needed) via `wt`:
   ```bash
   wt switch "$TARGET_BRANCH"
   ```
   The worktree must already exist from `add`. If it doesn't (e.g. the branch was created outside this skill), fall back to `wt new "$TARGET_BRANCH" --from "$(git config --local branch.$TARGET_BRANCH.stack-parent)"` first.
5. Report the worktree path via `wt path "$TARGET_BRANCH"` so the user can `cd` from another shell if needed.
