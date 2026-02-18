---
name: kickoff
description: Kick off a new task by creating a git worktree and opening a Zellij tab for it. Use when the user wants to start working on something new in an isolated workspace.
allowed-tools: Bash
skills: jira
---

# Kickoff

Create a new isolated workspace for a task: a git worktree with a dedicated Zellij tab.

## Arguments

- `$ARGUMENTS` may contain:
  - A **Jira issue key** (e.g. `TEAM-123`) — the task comes from Jira
  - A **free-text description** of what to work on — the task does NOT come from Jira
  - Both, or neither (interactive)

## Prerequisites

- Must be inside a git repository
- Must be inside a Zellij session (`$ZELLIJ` env var is set)

## Steps

### 1. Gather context

```bash
git branch --show-current    # base branch
git rev-parse --show-toplevel # repo root
echo $ZELLIJ                 # must be non-empty
```

### 2. Determine the branch name

There are two flows depending on whether the task comes from Jira or not:

#### Flow A — Jira issue provided

If the user provides a Jira issue key (e.g. `TEAM-123`):

1. Fetch the issue details using the **jira skill** (`acli jira workitem view TEAM-123`).
2. Use the **Jira issue key** as the branch name (e.g. `TEAM-123`).
3. Use the issue summary as the description.

#### Flow B — No Jira issue

If the user describes a task without a Jira key:

1. **Ask the user** whether they want to create a Jira issue for this task.
2. **If yes**: Create the issue using the **jira skill** (`acli jira workitem create ...`), then use the resulting issue key as the branch name (Flow A).
3. **If no**: Create a branch with a short, descriptive, kebab-case name derived from the task description (e.g. `fix-oauth-timeout`, `speed-up-tests`). Ask the user to confirm the proposed name.

### 3. Create the git worktree

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
BRANCH_NAME="<branch-name>"   # from step 2
mkdir -p "$REPO_ROOT/.worktrees"
git worktree add -b "$BRANCH_NAME" "$REPO_ROOT/.worktrees/$BRANCH_NAME"
git config "branch.$BRANCH_NAME.description" "<description>"
```

The worktree path is always `<repo-root>/.worktrees/<branch-name>`.

### 4. Create a Zellij tab

Derive a short **tab name** from the branch name (e.g. `TEAM-123` stays as-is, `fix-oauth-timeout` stays as-is).

Create a temporary KDL layout and open the tab:

```bash
WORKTREE_PATH="$REPO_ROOT/.worktrees/$BRANCH_NAME"
TAB_NAME="$BRANCH_NAME"

cat > /tmp/kickoff-tab.kdl << EOF
layout {
    default_tab_template {
        children
        pane size=1 borderless=true {
            plugin location="zellij:compact-bar"
        }
    }
    tab name="$TAB_NAME" cwd="$WORKTREE_PATH" {
        pane
    }
}
EOF

zellij action new-tab -l /tmp/kickoff-tab.kdl
```

### 5. Report

Display a summary:
- **Branch:** the new branch name
- **Based on:** the base branch
- **Worktree:** the worktree path
- **Zellij tab:** the tab name
- **Description:** the task description
- **Jira issue:** the issue key (if applicable, with a link)

## Example Usage

```
# Kick off work on an existing Jira issue
/kickoff TEAM-123

# Kick off a task described in free text (will ask about Jira)
/kickoff Fix the OAuth login timeout issue

# Kick off with a Jira key and extra context
/kickoff TEAM-456 Focus on the database migration part
```
