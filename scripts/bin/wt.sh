#!/usr/bin/env bash
# wt — git worktree + Zellij workflow helper
#
# Global flags (must precede the subcommand):
#   --debug          Trace every command (set -x). Also via WT_DEBUG=1.
#
# Plumbing (composable primitives):
#   wt new    <branch> [--from <ref>] [--desc <description>] [--no-copy-ignored]
#   wt zellij <branch>
#   wt send   <branch> <text>... [--no-enter]
#   wt path   <branch>
#   wt list
#   wt remove <branch> [--keep-branch] [--keep-tab]
#
# Porcelain (opinionated workflows built on top of plumbing):
#   wt start  <branch> [--from <ref>] [--desc <description>]
#   wt agent  <branch> <prompt>... [--from <ref>]
#   wt switch <branch>
#   wt done   <branch>
#
#   wt help
#
# Conventions:
#   - Worktrees always live at <git-root>/.worktrees/<branch>
#   - Zellij tab name == branch name
#   - The pane id of the tab's initial pane is stashed under
#     ~/.cache/wt/panes/<sha256(worktree-path)>.pid so `wt send` can target it
#     via `zellij action write-chars --pane-id` without switching focus.
#   - Requires Zellij 0.44+ for --pane-id support.

set -euo pipefail

WT_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wt"
WT_PANE_DIR="${WT_CACHE_DIR}/panes"
WT_PANE_INIT="${WT_CACHE_DIR}/pane-init"

die() {
  echo "wt: $*" >&2
  exit 1
}

info() {
  echo "wt: $*" >&2
}

require_git() {
  git rev-parse --git-dir >/dev/null 2>&1 || die "not inside a git repository"
}

require_zellij() {
  [[ -n "${ZELLIJ:-}" ]] || die "not inside a Zellij session (\$ZELLIJ is unset)"
}

repo_root() {
  # Always the *main* worktree root, even when called from a linked worktree.
  # `--show-toplevel` returns the current worktree's root, which nests
  # `.worktrees/` under itself when you `wt new` from inside another worktree.
  local common_dir
  common_dir="$(git rev-parse --path-format=absolute --git-common-dir)"
  dirname "$common_dir"
}

worktree_path_for() {
  printf '%s/.worktrees/%s' "$(repo_root)" "$1"
}

# Clone gitignored top-level entries (node_modules, .venv, .env, ...) from
# $1 into $2 using copy-on-write where the filesystem supports it.
# APFS clonefile (cp -c) on macOS, reflink on btrfs/xfs, plain cp -R elsewhere.
copy_ignored_into() {
  local src="$1" dst="$2"
  local cp_flag=""
  case "$(uname -s)" in
    Darwin) cp_flag="-c" ;;
    Linux)  cp_flag="--reflink=auto" ;;
  esac

  local count=0 entry src_path dst_path
  while IFS= read -r -d '' entry; do
    [[ -z "$entry" ]] && continue
    case "$entry" in
      .git|.git/*|.worktrees|.worktrees/*) continue ;;
    esac
    entry="${entry%/}"
    src_path="${src}/${entry}"
    dst_path="${dst}/${entry}"
    [[ -e "$src_path" ]] || continue

    mkdir -p "$(dirname "$dst_path")"
    if [[ -n "$cp_flag" ]]; then
      cp -R $cp_flag "$src_path" "$dst_path" 2>/dev/null \
        || cp -R "$src_path" "$dst_path"
    else
      cp -R "$src_path" "$dst_path"
    fi
    count=$((count + 1))
  done < <(cd "$src" && git ls-files --others --ignored --exclude-standard --directory -z)

  [[ $count -gt 0 ]] && info "cloned $count gitignored entries from $src"
  return 0
}

# Compute the stash file for a worktree path. Hashed so paths with slashes
# and unicode survive as flat filenames.
pane_id_file_for() {
  local worktree="$1"
  local hash
  if command -v shasum >/dev/null 2>&1; then
    hash="$(printf '%s' "$worktree" | shasum -a 256 | cut -d' ' -f1)"
  else
    hash="$(printf '%s' "$worktree" | sha256sum | cut -d' ' -f1)"
  fi
  printf '%s/%s.pid' "$WT_PANE_DIR" "$hash"
}

# Write a tiny bootstrap that records $ZELLIJ_PANE_ID to its first arg, then
# execs the user's login shell. Zellij runs this as the tab's initial command.
ensure_pane_init() {
  mkdir -p "$WT_CACHE_DIR" "$WT_PANE_DIR"
  if [[ ! -x "$WT_PANE_INIT" ]]; then
    cat >"$WT_PANE_INIT" <<'EOSCRIPT'
#!/usr/bin/env bash
# Written by wt. Records the Zellij pane id so `wt send` can target this pane.
if [[ -n "${1:-}" ]]; then
  mkdir -p "$(dirname "$1")"
  printf '%s' "${ZELLIJ_PANE_ID:-}" >"$1"
fi
exec "${SHELL:-/bin/bash}" -l
EOSCRIPT
    chmod +x "$WT_PANE_INIT"
  fi
}

cmd_new() {
  local branch="" from="" desc="" copy_ignored=1
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --from) from="$2"; shift 2 ;;
      --desc) desc="$2"; shift 2 ;;
      --no-copy-ignored) copy_ignored=0; shift ;;
      -h|--help)
        cat <<'EOF'
Usage: wt new <branch> [--from <ref>] [--desc <description>] [--no-copy-ignored]

Create a new branch and worktree at <git-root>/.worktrees/<branch>. The
branch is forked from the current branch by default, or from --from <ref>.
By default, gitignored top-level entries (node_modules, .venv, .env, ...)
are cloned from the current worktree using copy-on-write where supported
(APFS clonefile on macOS, reflink on btrfs/xfs). Pass --no-copy-ignored
to skip.
Prints the worktree path on stdout.
EOF
        return 0 ;;
      --) shift ;;
      -*) die "unknown flag for 'new': $1" ;;
      *)
        [[ -z "$branch" ]] || die "unexpected argument: $1"
        branch="$1"; shift ;;
    esac
  done
  [[ -n "$branch" ]] || die "missing branch name (wt new <branch>)"
  require_git

  local root worktree base
  root="$(repo_root)"
  worktree="${root}/.worktrees/${branch}"
  base="${from:-$(git branch --show-current)}"
  [[ -n "$base" ]] || die "cannot determine base branch (are you in a detached HEAD?)"

  [[ ! -e "$worktree" ]] || die "worktree already exists: $worktree"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    die "branch already exists: $branch (delete it or use a different name)"
  fi

  mkdir -p "${root}/.worktrees"
  git worktree add -b "$branch" "$worktree" "$base" >&2
  if [[ -n "$desc" ]]; then
    git config "branch.${branch}.description" "$desc"
  fi
  if [[ $copy_ignored -eq 1 ]]; then
    copy_ignored_into "$root" "$worktree"
  fi
  echo "$worktree"
}

cmd_zellij() {
  local branch=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        cat <<'EOF'
Usage: wt zellij <branch>

Open a new Zellij tab named <branch> with cwd set to the worktree at
<git-root>/.worktrees/<branch>. Records the tab's initial pane id so that
`wt send <branch> ...` can write to it without switching focus.
EOF
        return 0 ;;
      -*) die "unknown flag for 'zellij': $1" ;;
      *)
        [[ -z "$branch" ]] || die "unexpected argument: $1"
        branch="$1"; shift ;;
    esac
  done
  [[ -n "$branch" ]] || die "missing branch name (wt zellij <branch>)"
  require_git
  require_zellij

  local worktree
  worktree="$(worktree_path_for "$branch")"
  [[ -d "$worktree" ]] || die "worktree not found: $worktree (run: wt new $branch)"

  ensure_pane_init
  local pane_id_file layout rc=0
  pane_id_file="$(pane_id_file_for "$worktree")"
  layout="$(mktemp -t "wt-zellij-XXXXXX").kdl"

  # Clear any stale pane id from a previous tab for the same worktree.
  rm -f "$pane_id_file"

  cat >"$layout" <<EOF
layout {
    default_tab_template {
        children
        pane size=1 borderless=true {
            plugin location="zellij:compact-bar"
        }
    }
    tab name="${branch}" cwd="${worktree}" focus=true {
        pane command="${WT_PANE_INIT}" {
            args "${pane_id_file}"
        }
    }
}
EOF

  zellij action new-tab -l "$layout" || rc=$?
  rm -f "$layout"
  [[ $rc -eq 0 ]] || die "zellij action new-tab failed (exit $rc)"
  info "opened zellij tab '${branch}' at ${worktree}"
}

cmd_send() {
  local branch="" no_enter=0
  local -a words=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-enter) no_enter=1; shift ;;
      -h|--help)
        cat <<'EOF'
Usage: wt send <branch> <text>... [--no-enter]

Send text to the Zellij tab associated with <branch> (by writing to its
initial pane). Presses Enter after the text unless --no-enter is given.
Does not switch Zellij focus.
EOF
        return 0 ;;
      --) shift; while [[ $# -gt 0 ]]; do words+=("$1"); shift; done ;;
      *)
        if [[ -z "$branch" ]]; then
          branch="$1"
        else
          words+=("$1")
        fi
        shift ;;
    esac
  done
  [[ -n "$branch" ]] || die "missing branch name (wt send <branch> <text>)"
  [[ ${#words[@]} -gt 0 ]] || die "missing text to send"
  require_git
  require_zellij

  local worktree pane_id_file pane_id
  worktree="$(worktree_path_for "$branch")"
  pane_id_file="$(pane_id_file_for "$worktree")"

  # The init pane may still be booting; wait up to ~2s for the stash file.
  local tries=0
  while [[ ! -s "$pane_id_file" && $tries -lt 20 ]]; do
    sleep 0.1
    tries=$((tries + 1))
  done
  [[ -s "$pane_id_file" ]] \
    || die "no pane id recorded for '${branch}' (run: wt zellij ${branch})"
  pane_id="$(cat "$pane_id_file")"

  local text="${words[*]}"
  zellij action write-chars --pane-id "$pane_id" "$text"
  [[ $no_enter -eq 1 ]] || zellij action send-keys --pane-id "$pane_id" "Enter"
}

cmd_path() {
  local branch="${1:-}"
  [[ -n "$branch" ]] || die "missing branch name (wt path <branch>)"
  require_git
  worktree_path_for "$branch"
}

cmd_list() {
  require_git
  git worktree list
}

cmd_remove() {
  local branch="" keep_branch=0 keep_tab=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --keep-branch) keep_branch=1; shift ;;
      --keep-tab)    keep_tab=1; shift ;;
      -h|--help)
        cat <<'EOF'
Usage: wt remove <branch> [--keep-branch] [--keep-tab]

Force-remove the worktree at <git-root>/.worktrees/<branch>, delete the
branch ref, and close the matching Zellij tab. Tries
`git worktree remove --force`, then `--force --force`, and finally falls
back to `rm -rf` + `git worktree prune` so it never leaves the repo in a
broken state. Also clears the cached pane id for the worktree.
Pass --keep-branch to leave the branch ref in place.
Pass --keep-tab to leave the Zellij tab open.
EOF
        return 0 ;;
      --) shift ;;
      -*) die "unknown flag for 'remove': $1" ;;
      *)
        [[ -z "$branch" ]] || die "unexpected argument: $1"
        branch="$1"; shift ;;
    esac
  done
  [[ -n "$branch" ]] || die "missing branch name (wt remove <branch>)"
  require_git

  case "$branch" in
    main|master|develop) die "refusing to remove protected branch: $branch" ;;
  esac

  local root worktree current
  root="$(repo_root)"
  worktree="$(worktree_path_for "$branch")"
  current="$(git rev-parse --show-toplevel)"

  [[ "$worktree" != "$current" ]] \
    || die "cannot remove the current worktree ($worktree)"

  case "$worktree" in
    "${root}/.worktrees/"?*) : ;;
    *) die "refusing to rm path outside .worktrees: $worktree" ;;
  esac

  if git worktree remove --force "$worktree" 2>/dev/null; then
    info "removed worktree: $worktree"
  elif git worktree remove --force --force "$worktree" 2>/dev/null; then
    info "removed worktree (double-force): $worktree"
  else
    info "git worktree remove failed; falling back to rm -rf + prune"
    rm -rf -- "$worktree" || true
    git worktree prune 2>/dev/null || true
    info "forcibly removed worktree: $worktree"
  fi

  rm -f "$(pane_id_file_for "$worktree")"

  if [[ $keep_branch -eq 0 ]]; then
    if git show-ref --verify --quiet "refs/heads/$branch"; then
      if git branch -D "$branch" >&2; then
        info "deleted branch: $branch"
      else
        info "could not delete branch: $branch"
      fi
    else
      info "branch already gone: $branch"
    fi
  fi

  if [[ $keep_tab -eq 0 && -n "${ZELLIJ:-}" ]]; then
    if zellij action go-to-tab-name "$branch" >/dev/null 2>&1; then
      if zellij action close-tab >/dev/null 2>&1; then
        info "closed zellij tab: $branch"
      else
        info "could not close zellij tab: $branch"
      fi
    fi
  fi
}

# --- Porcelain ---------------------------------------------------------------
# Opinionated one-shot flows built on top of the plumbing above. These exist
# to collapse the common case ("I want to start working on a branch") into a
# single command. For escape hatches, drop down to the plumbing.

# Is a Zellij pane with the given id still alive? Probes by dumping its
# buffer to a temp file; an empty dump means the pane is gone (or never
# existed). Returns 0 if live, 1 otherwise.
pane_is_live() {
  local pane_id="$1"
  [[ -n "$pane_id" ]] || return 1
  local dump
  dump="$(mktemp -t wt-probe-XXXXXX)"
  zellij action dump-screen --pane-id "$pane_id" --path "$dump" >/dev/null 2>&1 || true
  if [[ -s "$dump" ]]; then
    rm -f "$dump"; return 0
  fi
  rm -f "$dump"; return 1
}

# Does a wt-managed tab already exist for this worktree? The pane-id stash
# is the cheap check, but it can go stale if the tab was closed outside
# `wt rm`. So we also probe the pane for liveness; a dead pane means the
# stash is stale — we clear it so a fresh `wt zellij` will be triggered.
# (`zellij action query-tab-names` can hang from non-TTY shells on Zellij
# 0.44, so we avoid it.)
wt_tab_exists() {
  local worktree="$1"
  local f
  f="$(pane_id_file_for "$worktree")"
  [[ -s "$f" ]] || return 1
  local pane_id
  pane_id="$(cat "$f")"
  if pane_is_live "$pane_id"; then
    return 0
  fi
  info "stale pane id for $(basename "$worktree") (pane $pane_id gone); clearing stash"
  rm -f "$f"
  return 1
}

# Poll a Zellij pane's rendered buffer until $pattern appears, or timeout.
# Usage: wait_for_pane_text <pane_id> <pattern> <timeout_seconds>
# Returns 0 if matched, 1 on timeout.
# Dumps to a temp file (not stdout) because `zellij action dump-screen` can
# hang when its stdout isn't a TTY.
wait_for_pane_text() {
  local pane_id="$1" pattern="$2" timeout="$3"
  local deadline dump
  dump="$(mktemp -t wt-dump-XXXXXX)"
  deadline=$(( $(date +%s) + timeout ))
  while (( $(date +%s) < deadline )); do
    if zellij action dump-screen --pane-id "$pane_id" --path "$dump" >/dev/null 2>&1 \
        && grep -qF -- "$pattern" "$dump"; then
      rm -f "$dump"
      return 0
    fi
    sleep 0.4
  done
  if [[ "${WT_DEBUG:-0}" == "1" ]]; then
    echo "wt: --- last dump of pane $pane_id (looking for $(printf '%q' "$pattern")) ---" >&2
    tail -20 "$dump" >&2
    echo "wt: --- end dump ---" >&2
  fi
  rm -f "$dump"
  return 1
}

cmd_start() {
  local -a new_args=()
  local branch=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        cat <<'EOF'
Usage: wt start <branch> [--from <ref>] [--desc <description>]

Porcelain: `wt new` + `wt zellij`. Creates the branch + worktree and opens
a Zellij tab focused on it. The 90% entry point for starting work on a
feature.
EOF
        return 0 ;;
      *)
        [[ -z "$branch" && "$1" != -* ]] && branch="$1"
        new_args+=("$1"); shift ;;
    esac
  done
  [[ -n "$branch" ]] || die "missing branch name (wt start <branch>)"
  require_git
  require_zellij

  cmd_new "${new_args[@]}" >/dev/null
  cmd_zellij "$branch"
}

cmd_agent() {
  local branch="" from=""
  local wait_for="❯ " wait_timeout=15
  local -a words=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --from) from="$2"; shift 2 ;;
      --wait-for) wait_for="$2"; shift 2 ;;
      --wait-timeout) wait_timeout="$2"; shift 2 ;;
      --no-wait) wait_for=""; shift ;;
      -h|--help)
        cat <<'EOF'
Usage: wt agent <branch> <prompt>... [--from <ref>]
                                     [--wait-for <text>] [--wait-timeout <secs>]
                                     [--no-wait]

Porcelain: create the branch+worktree (if missing), open a Zellij tab, and
dispatch `claude --dangerously-skip-permissions "<prompt>"` into it without
stealing focus. Use to fan out parallel coding agents across branches.

Before sending, polls the tab's pane buffer until <text> appears (default
"❯", 15s timeout) so the prompt isn't fired into a shell that's still
loading direnv/devenv. Default pattern is "❯ " (starship-style prompt with
trailing space); override with --wait-for. On timeout, sends anyway and
warns. Pass --no-wait to skip entirely.
EOF
        return 0 ;;
      --) shift; while [[ $# -gt 0 ]]; do words+=("$1"); shift; done ;;
      *)
        if [[ -z "$branch" ]]; then branch="$1"; else words+=("$1"); fi
        shift ;;
    esac
  done
  [[ -n "$branch" ]] || die "missing branch name (wt agent <branch> <prompt>)"
  [[ ${#words[@]} -gt 0 ]] || die "missing prompt for agent"
  require_git
  require_zellij

  local worktree
  worktree="$(worktree_path_for "$branch")"
  if [[ ! -d "$worktree" ]]; then
    if [[ -n "$from" ]]; then
      cmd_new "$branch" --from "$from" >/dev/null
    else
      cmd_new "$branch" >/dev/null
    fi
  fi

  if ! wt_tab_exists "$worktree"; then
    cmd_zellij "$branch"
  fi

  if [[ -n "$wait_for" ]]; then
    local pane_id_file pane_id tries=0
    pane_id_file="$(pane_id_file_for "$worktree")"
    while [[ ! -s "$pane_id_file" && $tries -lt 20 ]]; do
      sleep 0.1
      tries=$((tries + 1))
    done
    if [[ -s "$pane_id_file" ]]; then
      pane_id="$(cat "$pane_id_file")"
      info "waiting up to ${wait_timeout}s for '${wait_for}' in ${branch}…"
      if wait_for_pane_text "$pane_id" "$wait_for" "$wait_timeout"; then
        info "shell ready in ${branch}"
      else
        info "timeout waiting for '${wait_for}' in ${branch} — sending anyway"
      fi
    fi
  fi

  local prompt="${words[*]}"
  local quoted
  printf -v quoted '%q' "$prompt"
  cmd_send "$branch" "claude --dangerously-skip-permissions $quoted"
}

cmd_switch() {
  local branch=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        cat <<'EOF'
Usage: wt switch <branch>

Porcelain: focus the Zellij tab for <branch>, opening it (via `wt zellij`)
if it doesn't exist yet. Requires the worktree to already exist.
EOF
        return 0 ;;
      *)
        [[ -z "$branch" ]] || die "unexpected argument: $1"
        branch="$1"; shift ;;
    esac
  done
  [[ -n "$branch" ]] || die "missing branch name (wt switch <branch>)"
  require_git
  require_zellij

  local worktree
  worktree="$(worktree_path_for "$branch")"
  if wt_tab_exists "$worktree"; then
    zellij action go-to-tab-name "$branch"
  else
    cmd_zellij "$branch"
  fi
}

cmd_done() {
  local branch=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        cat <<'EOF'
Usage: wt done <branch>

Porcelain: safely finish a feature. Refuses to proceed unless the worktree
has a clean tree and the branch is fully merged into its upstream (or into
main/master when no upstream is set). On pass, delegates to `wt remove`.
Use `wt remove` directly to force-remove without safety gates.
EOF
        return 0 ;;
      *)
        [[ -z "$branch" ]] || die "unexpected argument: $1"
        branch="$1"; shift ;;
    esac
  done
  [[ -n "$branch" ]] || die "missing branch name (wt done <branch>)"
  require_git

  local worktree
  worktree="$(worktree_path_for "$branch")"
  [[ -d "$worktree" ]] || die "worktree not found: $worktree"

  if [[ -n "$(git -C "$worktree" status --porcelain)" ]]; then
    die "worktree has uncommitted changes: $worktree (commit/stash, or use: wt rm $branch)"
  fi

  local upstream="" target=""
  if upstream="$(git -C "$worktree" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"; then
    target="$upstream"
  elif git show-ref --verify --quiet refs/heads/main; then
    target="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    target="master"
  fi

  if [[ -n "$target" ]]; then
    local ahead
    ahead="$(git -C "$worktree" rev-list --count "${target}..${branch}" 2>/dev/null || echo "?")"
    if [[ "$ahead" != "0" ]]; then
      die "branch '$branch' has $ahead unmerged commit(s) vs $target (push/merge first, or use: wt rm $branch)"
    fi
  else
    info "no upstream or main/master found to check merge status; proceeding"
  fi

  info "clean + merged — removing"
  cmd_remove "$branch"
}

usage() {
  cat <<'EOF'
wt — git worktree + Zellij workflow helper

Porcelain (opinionated one-shot flows — use these by default):
  wt start <branch> [--from <ref>] [--desc <description>]
      Create branch + worktree + Zellij tab in one go.
  wt agent <branch> <prompt>... [--from <ref>]
      Ensure branch/worktree/tab exist, then dispatch a `claude` agent
      into the tab without switching focus.
  wt switch <branch>
      Focus the tab for <branch>, opening it if needed.
  wt done <branch>
      Safely retire a branch: only removes if the worktree is clean and
      the branch has no unmerged commits vs upstream/main.

Plumbing (composable primitives — drop down when porcelain is too coarse):
  wt new <branch> [--from <ref>] [--desc <description>] [--no-copy-ignored]
      Create a new branch and worktree at <git-root>/.worktrees/<branch>.
      Clones gitignored entries (node_modules, .venv, ...) via copy-on-write
      by default; pass --no-copy-ignored to skip.
  wt zellij <branch>
      Open a Zellij tab named <branch> with cwd in the worktree.
  wt send <branch> <text>... [--no-enter]
      Send text (+ Enter) to the tab's initial pane without switching focus.
  wt path <branch>
      Print the worktree path for a branch.
  wt list
      List all git worktrees.
  wt remove <branch> [--keep-branch] [--keep-tab]
      Force-remove the worktree, delete the branch, and close the Zellij
      tab. No safety gates — use `wt done` for the safe version.

  wt help
      Show this message.

Global flags:
  --debug
      Trace every command to stderr (bash `set -x` with file:line:function
      prefix). Equivalent to setting `WT_DEBUG=1`. Must appear before the
      subcommand: `wt --debug agent foo "bar"`.

Requires Zellij 0.44+ for non-focus pane targeting.
EOF
}

main() {
  # Consume global flags before the subcommand.
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --debug) WT_DEBUG=1; shift ;;
      *) break ;;
    esac
  done

  if [[ "${WT_DEBUG:-0}" == "1" ]]; then
    export PS4='+ ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:-main}> '
    set -x
  fi

  local sub="${1:-}"
  [[ $# -gt 0 ]] && shift || true
  case "$sub" in
    new)       cmd_new    "$@" ;;
    zellij|z)  cmd_zellij "$@" ;;
    send|s)    cmd_send   "$@" ;;
    path|p)    cmd_path   "$@" ;;
    list|ls)   cmd_list   "$@" ;;
    remove|rm) cmd_remove "$@" ;;
    start)     cmd_start  "$@" ;;
    agent|a)   cmd_agent  "$@" ;;
    switch|sw) cmd_switch "$@" ;;
    done)      cmd_done   "$@" ;;
    help|-h|--help|"") usage ;;
    *) die "unknown subcommand: $sub (try 'wt help')" ;;
  esac
}

main "$@"
