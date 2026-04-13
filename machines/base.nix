{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    # Applications - cross-platform
    ../applications/chrome
    ../applications/codex
    ../applications/opencode
    ../applications/pi
    ../applications/direnv
    ../applications/emacs
    ../applications/fzf
    ../applications/gent
    ../applications/go
    ../applications/llm
    ../applications/neovim
    ../applications/nushell
    ../applications/starship
    ../applications/vscode
    ../applications/zellij
    ../applications/zsh

    # Configuration modules
    ../cfg/email
    ../cfg/git.nix
    ../cfg/sbt
    ../cfg/gradle
    ../cfg/yarn
    ../cfg/agents.nix
    ../cfg/scripts.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  news.display = "silent";
  manual.manpages.enable = false;
  programs.command-not-found.enable = true;
  home.stateVersion = lib.mkDefault "22.11";

  nixpkgs.overlays = [
    inputs.nur.overlays.default
  ];

  home.sessionVariables = let
    secrets = import ../secrets.nix;
  in {
    DD_API_KEY = secrets.DATADOG_API_KEY;
    DD_APP_KEY = secrets.DATADOG_APP_KEY;
    THINGS_AUTH_TOKEN = secrets.THINGS_AUTH_TOKEN;
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
  };

  # Common packages across all platforms
  home.packages = with pkgs; [
    inputs.devenv.packages."${pkgs.stdenv.hostPlatform.system}".devenv
    inputs.gent.packages."${pkgs.stdenv.hostPlatform.system}".gent
    inputs.tmux-zellij.packages."${pkgs.stdenv.hostPlatform.system}".tmux-zellij
    inputs.tui-wright.packages."${pkgs.stdenv.hostPlatform.system}".default
    alejandra
    asciinema
    aws-vault
    bat
    bazelisk
    buildifier
    cargo
    difftastic
    eza
    fd
    gemini-cli
    gh
    git-crypt
    git-town
    gnupg
    graphviz
    htop
    hub
    jq
    minio-client
    nix-tree
    pass
    prettyping
    ripgrep
    ruby
    silver-searcher
    sops
    tree
    tree-sitter
    uv
    yq
    zig
  ];

  programs.zsh.sessionVariables = {
    NIX_PATH = "$HOME/.nix-defexpr/channels\${NIX_PATH:+:}$NIX_PATH";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  xdg.configFile."nix/nix.conf".text = ''
    warn-dirty = false
    accept-flake-config = true
    substituters = https://cache.nixos.org https://devenv.cachix.org
  '';
}
