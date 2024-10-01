{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../applications/alacritty
    ../applications/karabiner
    ../applications/go
    ../applications/direnv
    ../applications/fzf
    ../applications/neovim
    ../applications/starship
    ../applications/tmux
    ../applications/zsh
    ../applications/fish
    ../applications/emacs
    ../applications/vscode
    ../applications/wezterm
    ../applications/zellij
    ../applications/intellij-idea
    ../cfg/email
    ../cfg/git.nix
    ../cfg/sbt
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.command-not-found.enable = true;
  home.stateVersion = "22.11";
  home.username = "pepe";
  home.homeDirectory = "/Users/pepe";

  nixpkgs.overlays = let
    path = ../overlays;
  in
    with builtins;
      map (n: import (path + ("/" + n))) (filter (n:
        match ".*\\.nix" n
        != null
        || pathExists (path + ("/" + n + "/default.nix")))
      (attrNames (readDir path)));

  home.packages = with pkgs; [
    inputs.devenv.packages."${pkgs.system}".devenv
    aws-vault
    bat
    bazelisk
    buildifier
    cargo
    cocoapods
    eza
    fd
    gh
    git-crypt
    git-town
    gnupg
    graphviz
    htop
    hub
    jq
    kotlin-language-server
    alejandra
    minio-client
    nix-tree
    pass
    prettyping
    ripgrep
    ruby
    silver-searcher
    sops
    #xcodes
    yq
    jira-cli-go
    tree-sitter
  ];

  programs.zsh.sessionVariables = {
    NIX_PATH = "$HOME/.nix-defexpr/channels\${NIX_PATH:+:}$NIX_PATH";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
  };

  programs.ssh = {
    enable = true;
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
      "*".extraOptions = {AddKeysToAgent = "yes";};
      "*.github.com".extraOptions = {IdentityFile = "~/.ssh/id_ed25519";};
    };
  };

  nix = {
    settings = {
      trusted-users = "root pepe";
      experimental-features = "nix-command flakes";
      substituters = [
        "https://cache.nixos.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      accept-flake-config = true;
    };
    package = pkgs.nix;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
