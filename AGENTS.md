# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix-based dotfiles repository using Home Manager and nix-darwin for cross-platform configuration management. The repository manages configurations for multiple machines:

- **Darwin (macOS)**: `bart`, `homer`, `milhouse` machines
- **NixOS Linux**: `lisa`, `marge` machines
- **User**: `pepe` across all systems

## Architecture

### Core Structure
- `flake.nix`: Main entry point defining inputs, outputs, and system configurations
- `home.nix`: Base Home Manager configuration (mostly empty template)
- `darwin-configuration.nix`: macOS system-level configuration via nix-darwin
- `machines/`: Machine-specific configurations
  - `macbook.nix`: Configuration for macOS machines (imports applications and configs)
  - `lisa.nix`, `lisa/`: Linux machine configuration
  - `marge/`: Another Linux machine configuration

### Configuration Organization
- `applications/`: Application-specific configurations (alacritty, emacs, neovim, vscode, etc.)
- `cfg/`: General configuration modules (git, email, scripts, etc.)
- `services/`: System services configuration (dunst, polybar, etc.)
- `overlays/`: Nix package overlays and custom packages
- `scripts/`: Custom shell scripts managed as part of the configuration

### Application Configurations
Each application in `applications/` follows a consistent pattern:
- `default.nix`: Main configuration file
- Additional config files as needed (e.g., `applications/alacritty/colorschemes.yml`)

## Common Commands

### Building and Switching Configurations

**Home Manager (user-level configurations):**
```bash
# Build and switch home configuration for current machine
home-manager switch --flake .

# Build specific machine configuration
home-manager switch --flake .#pepe@bart
```

**Darwin (macOS system-level configurations):**
```bash
# Build and switch darwin configuration
darwin-rebuild switch --flake .

# Build specific darwin machine
darwin-rebuild switch --flake .#bart
```

**NixOS (for Linux machines):**
```bash
# Build and switch NixOS configuration
sudo nixos-rebuild switch --flake .#lisa
```

### Development and Maintenance

**Code formatting and linting:**
```bash
# Format Nix code with alejandra
alejandra .

# Check for dead code
deadnix

# Format Lua code (for neovim configs)
stylua .
```

**Development shell:**
```bash
# Enter development shell with pre-commit hooks
nix develop
```

## Key Configuration Patterns

### Module Imports
Machine configurations import relevant modules:
```nix
imports = [
  ../applications/alacritty
  ../applications/neovim
  ../cfg/git.nix
  # ...
];
```

### Overlays System
Overlays are automatically loaded from the `overlays/` directory. Each overlay file should either:
- Be a `.nix` file directly
- Be a directory with a `default.nix` file

### Scripts Integration
Custom scripts in `scripts/bin/` are automatically symlinked to `~/bin/` via `cfg/scripts.nix`.

### Package Management
- System packages: Defined in `home.packages` in machine configs
- Application-specific packages: Managed within each application's configuration
- Homebrew (macOS): Managed via `homebrew.nix` for GUI applications

## Development Workflow

1. Make changes to configuration files
2. **Always run `home-manager switch --flake .` after making changes** to apply them
3. Use `nix develop` to enter development shell with pre-commit hooks
4. Format code with `alejandra .` before committing
5. Check for unused code with `deadnix`

> **Important**: After modifying any configuration files in this repository, you must run `home-manager switch --flake .` to apply the changes. This ensures the new configuration is activated.

## Machine-Specific Notes

- **macOS machines**: Use both darwin-rebuild (system) and home-manager (user) configurations
- **Linux machines**: Use nixos-rebuild for system config and home-manager for user config
- Configuration is shared across machines with machine-specific imports in the `machines/` directory