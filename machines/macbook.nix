{ config, pkgs, ... }: {
  imports = [
    ../applications/alacritty
    ../applications/go
    ../applications/direnv
    ../applications/fzf
    ../applications/neovim
    ../applications/starship
    ../applications/tmux
    ../applications/zsh
    ../applications/emacs
    ../cfg/email
    ../cfg/git.nix
    ../cfg/karabiner
    ../cfg/sbt
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.overlays = let path = ../overlays;
  in with builtins;
  map (n: import (path + ("/" + n))) (filter (n:
    match ".*\\.nix" n != null
    || pathExists (path + ("/" + n + "/default.nix")))
    (attrNames (readDir path)));

  home.packages = with pkgs; [
    git-crypt
    bat
    gnupg
    prettyping
    pass
    htop
    ag
    ghq
    gh
    graphviz
    #exa
    jq
    rnix-lsp
    bazelisk
    buildifier
    sops
    cocoapods
    ncdu
    #nur.repos.zachcoyle.kotlin-language-server
  ];

  programs.zsh.sessionVariables = {
    NIX_PATH = "$HOME/.nix-defexpr/channels\${NIX_PATH:+:}$NIX_PATH";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
}
