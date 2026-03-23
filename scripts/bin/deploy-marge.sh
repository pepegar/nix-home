#!/usr/bin/env bash
set -euo pipefail

FLAKE_DIR="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

if grep -qa "GITCRYPT" "${FLAKE_DIR}/services/tailscale/default.nix"; then
  echo "error: git-crypt files are locked. Run 'git-crypt unlock' first." >&2
  exit 1
fi

REMOTE_FLAKE="/tmp/home-manager-deploy"

echo "Syncing flake to marge..."
rsync -a --delete --exclude='.git' "${FLAKE_DIR}/" "pepe@marge:${REMOTE_FLAKE}/"

echo "Building and switching on marge..."
ssh -t pepe@marge "sudo nixos-rebuild switch --flake \"${REMOTE_FLAKE}#marge\" $*"
