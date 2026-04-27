---
name: wt
description: Manage a per-feature workflow of git worktrees + Zellij tabs + background agent dispatch via the `wt` CLI. Use when the user asks to create a worktree, open a Zellij tab for a branch, send keys/commands to a tab without switching focus, or orchestrate parallel coding agents across branches.
allowed-tools: Bash
---

# wt — Worktree + Zellij Workflow

`wt` is the one-stop-shop CLI for pepe's feature-branch workflow:

- Every feature gets its own git branch.
- Every branch is checked out into an isolated worktree at `<git-root>/.worktrees/<branch>`.
- Every worktree has its own Zellij tab (tab name == branch name).
- Commands can be dispatched to any tab's initial pane **without switching focus**, so multiple coding agents can run in parallel.

This skill lets agents drive that workflow. Prefer `wt` over the older `/worktree`, `/zellij`, `/spawn-agent`, or `/kickoff` skills when the goal is to manage the feature-branch + tab lifecycle. Those older skills are still useful for one-off operations (e.g. pruning worktrees, creating an arbitrary Zellij pane).

## Requirements

- Zellij 0.44 or newer (for `write-chars --pane-id` and `send-keys --pane-id`).
- Must be run from inside a git repository.
- `wt zellij` and `wt send` also require an active Zellij session (`$ZELLIJ` is set).

## Global flags

- `--debug` (or `WT_DEBUG=1`) — traces every shell command to stderr via `set -x`, prefixed with `file:line:function`. Useful when a subcommand hangs or misbehaves. Must appear before the subcommand: `wt --debug agent foo "bar"`.

## Subcommands

`wt` splits into two layers:

- **Porcelain** — opinionated one-shot flows (`start`, `agent`, `switch`, `done`). Prefer these by default; they collapse the common cases into a single command.
- **Plumbing** — composable primitives (`new`, `zellij`, `send`, `path`, `list`, `remove`). Drop down to these when porcelain is too coarse or when scripting.

## Porcelain

### `wt start <branch> [--from <ref>] [--desc <description>]`

`wt new` + `wt zellij` in one shot: creates the branch + worktree and opens a Zellij tab focused on it. The default entry point for "I want to start working on a feature."

```bash
wt start feature-auth --desc "OAuth2 login"
wt start hotfix-123 --from origin/main
```

### `wt agent <branch> <prompt>... [--from <ref>] [--wait-for <text>] [--wait-timeout <secs>] [--no-wait]`

Ensure the branch + worktree + Zellij tab exist (creating whichever pieces are missing), then dispatch `claude --dangerously-skip-permissions "<prompt>"` into the tab **without stealing focus**. Use this to fan out parallel coding agents across branches.

Before sending, polls the tab's pane buffer (via `zellij action dump-screen --pane-id`) until the wait pattern appears, so the prompt isn't fired into a shell that's still loading direnv / devenv / nix-shell. Defaults: pattern `❯ ` (trailing space, to match an idle starship-style prompt rather than any stray `❯` in output), timeout 15s. Override with `--wait-for`. On timeout, sends anyway and warns — safer than hanging.

```bash
wt agent feature-auth "Implement the OAuth2 flow end-to-end"
wt agent hotfix-123 --from origin/main "Fix the login timeout bug in auth/session.ts"
wt agent slow-repo --wait-for '$ ' --wait-timeout 60 "Run the full test suite"
wt agent feature-x --no-wait "echo hi"
```

Idempotent: re-running with an existing branch/tab just sends another prompt.

### `wt switch <branch>`

Focus the Zellij tab for `<branch>`, opening it via `wt zellij` if it doesn't exist yet. Requires the worktree to already exist.

```bash
wt switch feature-auth
```

### `wt done <branch>`

Safely retire a feature. Refuses to proceed unless:

1. The worktree has a clean working tree (no uncommitted changes).
2. The branch has **0 unmerged commits** vs its upstream (or vs `main`/`master` when no upstream is set).

On pass, delegates to `wt remove`. For force-removal without safety gates, use `wt remove` directly.

```bash
wt done feature-auth
```

## Plumbing

### `wt new <branch> [--from <ref>] [--desc <description>] [--no-copy-ignored]`

Create a new branch and worktree at `<git-root>/.worktrees/<branch>`.

- Base branch defaults to the current branch; override with `--from <ref>` (e.g. `--from origin/main`).
- `--desc` stores a description on the branch via `git config branch.<name>.description`.
- By default, clones gitignored top-level entries (`node_modules`, `.venv`, `.env`, build dirs, ...) from the current worktree using copy-on-write (`cp -c` / APFS clonefile on macOS, `cp --reflink=auto` on btrfs/xfs). Falls back to a regular recursive copy on filesystems without CoW. Pass `--no-copy-ignored` to skip — useful when the source has stale build artifacts you don't want to drag in.
- Prints the absolute worktree path on stdout; progress goes to stderr.
- Fails loudly if the branch or worktree already exists.

```bash
wt new feature-auth
wt new hotfix-123 --from origin/main --desc "Fix login timeout"
cd "$(wt new quick-test)"   # use the printed path
```

### `wt zellij <branch>`

Open a new Zellij tab named `<branch>` with its cwd pointed at the worktree. The tab's initial pane records its `$ZELLIJ_PANE_ID` to `~/.cache/wt/panes/<hash>.pid` so `wt send` can target it later.

- Requires the worktree to already exist (run `wt new` first).
- The tab inherits Zellij's default `compact-bar` UI.
- Focus switches to the new tab (Zellij's default on `new-tab`).

```bash
wt zellij feature-auth
```

### `wt send <branch> <text>... [--no-enter]`

Write text to the branch's Zellij tab **without switching focus**.

- Resolves the worktree's stashed pane id and calls `zellij action write-chars --pane-id <id>`.
- Presses Enter afterwards with `send-keys --pane-id <id> Enter`, unless `--no-enter` is given.
- Waits up to ~2 seconds for the pane id file to appear (handles the race just after `wt zellij`).
- Fails with a helpful message if no tab exists for that branch yet.

```bash
wt send feature-auth "npm test"
wt send feature-auth 'echo "hello from $(pwd)"'
wt send feature-auth --no-enter "vim README.md"
```

**Important**: quote the text. Shell expansion happens in the caller's shell before `wt` sees it, same as any command invocation.

### `wt path <branch>`

Print the conventional worktree path for a branch. Useful for scripting.

```bash
cd "$(wt path feature-auth)"
```

### `wt list`

Thin wrapper around `git worktree list`.

### `wt remove <branch> [--keep-branch] [--keep-tab]`

Force-remove the worktree at `<git-root>/.worktrees/<branch>`, delete the branch ref, and close the matching Zellij tab. Designed to never leave the repo half-broken, even when `git worktree remove` alone would fail.

- Fallback chain: `git worktree remove --force` → `git worktree remove --force --force` (for locked worktrees / submodules) → `rm -rf` + `git worktree prune` (for stale git metadata or dangling dirs).
- Refuses to operate on `main`/`master`/`develop`, on the current worktree, or on any path outside `.worktrees/`.
- Clears the cached pane id stash so a future `wt zellij <branch>` starts clean.
- Deletes the branch with `git branch -D` by default; pass `--keep-branch` to leave the ref in place.
- Closes the Zellij tab named `<branch>` (via `go-to-tab-name` + `close-tab`) when `$ZELLIJ` is set; pass `--keep-tab` to leave it open.
- Aliased as `wt rm`.

```bash
wt rm feature-auth                  # nuke worktree + branch + tab
wt rm feature-auth --keep-branch    # keep the branch ref around
wt rm feature-auth --keep-tab       # leave the Zellij tab open
```

## Typical Flows

### Kick off a new feature

```bash
wt start feature-auth --desc "OAuth2 login"
```

### Fan out parallel agents

```bash
wt agent feature-auth   "Implement the OAuth2 flow"
wt agent feature-billing "Add Stripe webhook handling"
wt agent hotfix-123     "Fix the login timeout in auth/session.ts"
```

Each agent runs in its own tab; `wt agent` never steals focus, so you stay in your original tab while they work.

### Run a quick check across tabs (plumbing)

```bash
for b in feature-auth feature-billing hotfix-123; do
  wt send "$b" "npm test"
done
```

### Finish up cleanly

```bash
wt done feature-auth   # refuses if dirty or unmerged
```

## Naming and location conventions

| Thing | Convention |
|-------|------------|
| Worktree path | `<git-root>/.worktrees/<branch>` |
| Zellij tab name | `<branch>` (exact match) |
| Pane id stash | `~/.cache/wt/panes/<sha256(worktree-path)>.pid` |
| Initial pane launcher | `~/.cache/wt/pane-init` (auto-generated) |

## Failure modes to check

- **Zellij version**: if `write-chars --pane-id` fails with "unknown option", the installed Zellij is too old. Upgrade to 0.44+.
- **Stale pane id**: if the tab's initial pane has been closed, the stashed id is stale. Open a fresh tab with `wt zellij <branch>` (this clears the old stash).
- **Not in a git repo / Zellij session**: `wt new` works anywhere in a git repo; `wt zellij` and `wt send` additionally require `$ZELLIJ` to be set.

## Related skills

- `/kickoff` — richer interactive kickoff including Jira integration.
- `/zellij` — low-level Zellij pane/tab primitives when `wt` is too coarse.
