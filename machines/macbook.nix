{ pkgs, ... }: {
  imports = [
    ../applications/alacritty
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
    ../applications/intellij-idea
    ../cfg/email
    ../cfg/git.nix
    ../cfg/karabiner
    ../cfg/sbt
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.command-not-found.enable = true;
  home.stateVersion = "22.11";
  home.username = "pepe";
  home.homeDirectory = "/Users/pepe";

  nixpkgs.overlays = let path = ../overlays;
  in with builtins;
  map (n: import (path + ("/" + n))) (filter (n:
    match ".*\\.nix" n != null
    || pathExists (path + ("/" + n + "/default.nix")))
    (attrNames (readDir path)));

  home.packages = with pkgs; [
    cargo
    minio-client
    git-crypt
    bat
    gnupg
    prettyping
    pass
    htop
    silver-searcher
    gh
    graphviz
    jq
    ruby
    rnix-lsp
    bazelisk
    buildifier
    sops
    cocoapods
    aws-vault
    yq
    eza
    hub
    xcodes
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
        identityFile = [ "~/.ssh/local" ];
      };
      "*".extraOptions = { AddKeysToAgent = "yes"; };
      "*.github.com".extraOptions = { IdentityFile = "~/.ssh/id_ed25519"; };
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

}
