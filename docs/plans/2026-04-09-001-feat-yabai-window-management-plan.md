---
title: "feat: Install yabai and integrate with home-manager"
type: feat
status: active
date: 2026-04-09
---

# feat: Install yabai and integrate with home-manager

## Overview

Replace both the slow AppleScript-based window movement and Raycast window snapping in the Karabiner window management layer with yabai. Yabai runs as a nix-darwin service in float layout mode (no tiling). Window nudging uses `--move`, and window snapping uses `--grid` with cycling scripts that rotate through 1/2, 2/3, 1/3 fractions.

## Problem Frame

The current window move commands (w/a/s/d in the `'` layer) use `osascript` to reposition windows via Apple Events, with noticeable latency (~200-500ms). Window snapping (h/l/k/j) uses Raycast, which works but adds an external dependency for something yabai can handle natively. Yabai's C-based CLI provides near-instant window operations without requiring SIP to be disabled.

## Requirements Trace

- R1. Yabai installed and running as a nix-darwin launchd service
- R2. Yabai configured in float layout (no tiling behavior)
- R3. Karabiner w/a/s/d uses `yabai -m window --move` instead of AppleScript
- R4. No SIP changes required
- R5. Karabiner h/l/k/j snaps windows using `yabai -m window --grid` with cycling (1/2 -> 2/3 -> 1/3)
- R6. Karabiner f (maximize) uses yabai `--grid 1:1:0:0:1:1`
- R7. Display switching (y/p) continues to work (either via yabai `--display` or keep Raycast)

## Scope Boundaries

- No tiling/BSP layout -- yabai is used only as a window movement/snapping daemon
- No skhd -- Karabiner already handles all hotkeys
- No scripting addition (`enableScriptingAddition = false`)
- Not configuring yabai for Linux machines

## Key Technical Decisions

- **nix-darwin `services.yabai` module**: First-class nix-darwin module managing the launchd agent. Matches existing pattern with tailscale in `darwin-configuration.nix`.
- **Separate `cfg/yabai.nix` file**: Matches the pattern of `cfg/homebrew.nix` -- imported from `darwin-configuration.nix`.
- **`layout = "float"`**: No tiling behavior, yabai just provides fast window operations.
- **Cycling scripts in `scripts/bin/`**: Yabai has no built-in cycle/toggle for window sizes. The standard approach is: query current window frame, compare width/height ratio to display, issue the next `--grid` command. These scripts live in `scripts/bin/` (already symlinked to `~/bin/` by `cfg/scripts.nix`) and are called from Karabiner's `shell_command`.
- **Full path to yabai in scripts**: Karabiner runs in a minimal shell environment. Scripts use the full nix path to avoid PATH issues.

## Open Questions

### Resolved During Planning

- **Does `--move rel:X:Y` need SIP disabled?** No. Works on floating windows without scripting addition.
- **Can yabai cycle snap sizes?** Not built-in. Must script it by querying window/display frames and comparing ratios.
- **Where does yabai config go?** nix-darwin (`services.yabai`), not home-manager.
- **How to handle the cycling state?** Compare current window width ratio to display width. Use ranges (e.g., 45-55% for "half") to handle padding/menu bar offset tolerance.

### Deferred to Implementation

- **Exact yabai binary path**: Verify after first `darwin-rebuild` whether it's at `/run/current-system/sw/bin/yabai` or elsewhere.
- **jq path**: Scripts need jq to parse yabai query JSON. Verify available path in Karabiner's environment (likely `/run/current-system/sw/bin/jq` or nix profile path).
- **Accessibility permissions**: Manual grant in System Settings after first run.
- **Display switching**: Verify `yabai -m window --display next/prev` works in float mode; if not, keep Raycast for y/p bindings.

## High-Level Technical Design

> *This illustrates the intended approach and is directional guidance for review, not implementation specification.*

Cycling snap logic (e.g., "snap left"):

```
query window frame (x, y, w, h)
query display frame (W, H)
ratio = window.w / display.W

if ratio ~= 50%  -> grid 1:3:0:0:2:1  (two-thirds left)
if ratio ~= 66%  -> grid 1:3:0:0:1:1  (one-third left)
else             -> grid 1:2:0:0:1:1  (half left, default)
```

Grid values reference:

| Position | 1/2 | 2/3 | 1/3 |
|---|---|---|---|
| Left | `1:2:0:0:1:1` | `1:3:0:0:2:1` | `1:3:0:0:1:1` |
| Right | `1:2:1:0:1:1` | `1:3:1:0:2:1` | `1:3:2:0:1:1` |
| Top | `2:1:0:0:1:1` | `3:1:0:0:1:2` | `3:1:0:0:1:1` |
| Bottom | `2:1:0:1:1:1` | `3:1:0:1:1:2` | `3:1:0:2:1:1` |

## Implementation Units

- [ ] **Unit 1: Add yabai nix-darwin service**

  **Goal:** Install yabai and configure it as a float-mode-only service via nix-darwin.

  **Requirements:** R1, R2, R4

  **Dependencies:** None

  **Files:**
  - Create: `cfg/yabai.nix`
  - Modify: `cfg/darwin-configuration.nix` (add import)

  **Approach:**
  - Create `cfg/yabai.nix` with `services.yabai.enable = true`, `config.layout = "float"`, and `enableScriptingAddition = false`
  - Add app rules in `extraConfig` for apps that shouldn't be managed (System Settings, Finder, Activity Monitor)
  - Import `./yabai.nix` from `darwin-configuration.nix`
  - Apply with `darwin-rebuild switch --flake .`

  **Patterns to follow:**
  - `cfg/homebrew.nix` for module structure and import pattern

  **Verification:**
  - `darwin-rebuild switch --flake .` succeeds
  - `pgrep yabai` shows the daemon running
  - `yabai -m query --windows` returns window data
  - Note the exact yabai binary path for use in subsequent units

- [ ] **Unit 2: Create cycling snap scripts**

  **Goal:** Create shell scripts that implement cycling window snapping (1/2 -> 2/3 -> 1/3) for each direction.

  **Requirements:** R5

  **Dependencies:** Unit 1

  **Files:**
  - Create: `scripts/bin/yabai-snap-left.sh`
  - Create: `scripts/bin/yabai-snap-right.sh`
  - Create: `scripts/bin/yabai-snap-top.sh`
  - Create: `scripts/bin/yabai-snap-bottom.sh`

  **Approach:**
  - Each script: query window frame and display frame via `yabai -m query`, parse with jq, compare width (horizontal) or height (vertical) ratio to display, issue the next `--grid` command in the cycle
  - Use ratio ranges with tolerance (e.g., 45-55% for half) to handle padding/menu bar offset
  - Use full paths to yabai and jq binaries
  - Scripts are automatically symlinked to `~/bin/` by existing `cfg/scripts.nix`

  **Test scenarios:**
  - Running `~/bin/yabai-snap-left.sh` snaps window to left half
  - Running it again cycles to left two-thirds
  - Running it again cycles to left one-third
  - Running it again returns to left half
  - Same cycle works for right, top, bottom

  **Verification:**
  - Scripts are executable and work when run from terminal
  - Cycling works correctly across multiple invocations

- [ ] **Unit 3: Update Karabiner window management layer**

  **Goal:** Replace all window management bindings to use yabai instead of AppleScript/Raycast.

  **Requirements:** R3, R5, R6, R7

  **Dependencies:** Unit 1, Unit 2

  **Files:**
  - Modify: `applications/karabinix/default.nix`

  **Approach:**
  - Update `mkMoveWindow` helper to use `yabai -m window --move rel:DX:DY` (full path)
  - Replace h/l/k/j `raycastWindow` calls with `~/bin/yabai-snap-{left,right,top,bottom}.sh`
  - Replace f (maximize) with `yabai -m window --grid 1:1:0:0:1:1`
  - Test y/p display switching with `yabai -m window --display prev/next`; if it works, replace Raycast calls; otherwise keep Raycast for those two bindings
  - Remove `mkMoveWindow` AppleScript helper (no longer needed)

  **Patterns to follow:**
  - Existing `mkToEvent { shell_command = ... }` pattern

  **Test scenarios:**
  - w/a/s/d nudges window by 100px in expected direction (near-instant)
  - h/l/k/j cycles through snap sizes
  - f maximizes window
  - y/p switches displays

  **Verification:**
  - `home-manager switch --flake .` succeeds
  - All window management bindings work from the Karabiner layer

## Risks & Dependencies

- **Accessibility permissions**: Yabai requires manual grant. If not granted, all operations silently fail.
- **macOS version compatibility**: On Sequoia, float-mode operations (`--move`, `--grid`, `--display`) work. Space management is broken but we don't use it.
- **Two rebuild commands**: `darwin-rebuild switch --flake .` for the yabai service, `home-manager switch --flake .` for Karabiner config changes.
- **jq dependency in scripts**: Scripts need jq available at a known path. If jq isn't in the nix-darwin system profile, it may need to be added to `environment.systemPackages`.

## Sources & References

- [nix-darwin services.yabai options](https://mynixos.com/nix-darwin/options/services.yabai)
- [yabai Wiki - Commands](https://github.com/koekeishiya/yabai/wiki/Commands)
- [Cycling window sizes - Discussion #1025](https://github.com/koekeishiya/yabai/discussions/1025)
- Existing patterns: `cfg/homebrew.nix`, `cfg/darwin-configuration.nix`, `cfg/scripts.nix`
