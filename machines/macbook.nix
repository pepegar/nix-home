{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    #../applications/firefox
    ../applications/chrome
    ../applications/claude
    ../applications/codex
    ../applications/opencode
    ../applications/pi
    ../applications/direnv
    ../applications/emacs
    ../applications/fzf
    ../applications/ghostty
    ../applications/kitty
    ../applications/go
    ../applications/intellij-idea
    ../applications/karabinix
    ../applications/llm
    ../applications/neovim
    ../applications/nushell
    ../applications/starship
    ../applications/testcontainers
    ../applications/vscode
    ../applications/zellij
    ../applications/zsh
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
  home.stateVersion = "22.11";
  home.username = "pepe";
  home.homeDirectory = "/Users/pepe";

  xdg.configFile."nix/nix.conf".text = ''
    warn-dirty = false
    accept-flake-config = true
    substituters = https://cache.nixos.org https://devenv.cachix.org
  '';

  nixpkgs.overlays = [
    inputs.nur.overlays.default
  ];

  home.sessionVariables = let
    secrets = import ../secrets.nix;
  in {
    DD_API_KEY = secrets.DATADOG_API_KEY;
    DD_APP_KEY = secrets.DATADOG_APP_KEY;
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
  };
  home.packages = with pkgs; [
    inputs.devenv.packages."${pkgs.stdenv.hostPlatform.system}".devenv
    inputs.tmux-zellij.packages."${pkgs.stdenv.hostPlatform.system}".tmux-zellij
    alejandra
    asciinema
    aws-vault
    bat
    bazelisk
    buildifier
    cargo
    cocoapods
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

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "marge" = {
        hostname = "marge";
        user = "pepe";
      };
      "lisa" = {
        hostname = "lisa";
        user = "pepe";
        identityFile = ["~/.ssh/local"];
      };
      "*".extraOptions = {
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
      };
      "*.github.com".extraOptions = {IdentityFile = "~/.ssh/id_ed25519";};
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
