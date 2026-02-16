---
name: spawn-agent
description: Create a git worktree and spawn a coding agent in a new Zellij tab with a prompt
allowed-tools: Bash, Skill
---

# Spawn Agent Skill

Create a git worktree and spawn a new coding agent in a separate Zellij tab. This combines the `/worktree` and `/zellij` skills into a single workflow.

## Arguments

- `$ARGUMENTS` should contain:
  - **branch-name** (required): Name for the new branch and worktree
  - **prompt** (required): The prompt to pass to the coding agent (should be quoted if it contains spaces)

## Steps

1. **Validate environment**: Check that we're inside a Zellij session (`$ZELLIJ` is set)

2. **Parse arguments** from `$ARGUMENTS`:
   - First argument is the branch name
   - Everything after the branch name is the prompt

3. **Create the worktree** using the `/worktree` skill:
   ```
   /worktree <branch-name>
   ```
   This will create a worktree at `.worktrees/<branch-name>` based on the current branch.

4. know which codign agent are you.  Are you claude? are you codex? are you pi?  Set to $codingAgent

5. **Create a Zellij tab** using the `/zellij` skill patterns:
   - Create a tab named `<branch-name>`
   - Set the working directory to the worktree path
   - Run `echo '<prompt>' | $codingAgent` in the tab

   Refer to the `/zellij` skill for the KDL layout syntax and how to create tabs with commands.

6. **Report success**:
   - Worktree path
   - Branch name
   - Tab name
   - The prompt that was passed

## Example Usage

```
/spawn-agent feature-auth "Implement user authentication with JWT tokens"
/spawn-agent fix-bug-123 "Fix the null pointer exception in UserService.java"
```

## Error Handling

- If not in a Zellij session, report error and exit
- If the `/worktree` skill fails (e.g., branch exists), report the error and stop
