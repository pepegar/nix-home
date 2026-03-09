#!/usr/bin/env bash

# ghqj - Open a ghq-managed repository in a new Zellij tab
# Uses fzf to interactively select from ghq list

set -euo pipefail

GHQ_ROOT=$(ghq root)

selected=$(ghq list | fzf \
    --height=40% \
    --layout=reverse \
    --border=rounded \
    --header="📂 Select repository | Enter: open in new tab, Esc: cancel" \
    --preview "ls --color=always ${GHQ_ROOT}/{}" \
    --preview-window=right:40%)

if [[ -z "$selected" ]]; then
    exit 0
fi

repo_path="${GHQ_ROOT}/${selected}"
tab_name=$(basename "$selected")

if [[ -n "${ZELLIJ:-}" ]]; then
    zellij action new-tab --name "$tab_name" --cwd "$repo_path"
else
    echo "$repo_path"
fi
