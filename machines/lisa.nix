{ ... }:

let
  sources = import ../nix/sources.nix;
  pkgs = import sources.nixpkgs { };
in rec {
  imports = [
    ../applications/fish
    ../applications/fzf
    ../applications/zsh
    ../applications/neovim
    ../applications/alacritty
    ../applications/emacs
    ../applications/tmux
    ../applications/direnv
    ../applications/go
    ../applications/rofi
    ../applications/texlive
    ../applications/xmonad

    ../services/network-manager-applet.nix
    ../services/polybar.nix
    ../services/dunst.nix

    ../cfg/email
    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/xresources.nix
    ../cfg/sbt
    ../cfg/pandoc
  ];

  nixpkgs.overlays = let path = ../overlays;
  in with builtins;
  map (n: import (path + ("/" + n))) (filter (n:
    match ".*\\.nix" n != null
    || pathExists (path + ("/" + n + "/default.nix")))
    (attrNames (readDir path)));

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ag
    any-nix-shell
    bat
    clang
    exa
    ghq
    gnome3.nautilus
    gnupg
    graphviz
    heroku
    htop
    libreoffice
    mr
    nix-prefetch-scripts
    obs-studio
    openvpn
    pass
    pasystray
    pavucontrol
    prettyping
    rescuetime
    ripgrep-all
    robo3t
    rofi-vpn
    slack
    spotifywm
    sqlite
    vlc
    zotero
    obsidian
    nyxt
  ];

  home.sessionVariables = {
    DISPLAY = ":0";
    EDITOR = "emacs";
  };
}
