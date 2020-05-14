{ config, pkgs, ... }:

with pkgs;

let
  python-packages = python-packages: with python-packages; [
    flask
    dash
  ];
  python-with-packages = pkgs.python3.withPackages python-packages;

in rec {
  imports = [
    ../applications/fzf
    ../applications/zsh
    ../applications/neovim
    ../applications/emacs
    ../applications/tmux
    ../applications/direnv
    ../applications/go
    ../applications/rofi
    ../applications/texlive
    ../applications/i3

    ../services/network-manager-applet.nix
    ../services/dunst.nix

    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/xresources.nix
    ../cfg/sbt
    ../cfg/pandoc
  ];

  nixpkgs.overlays =
    let path = ../overlays; in with builtins;
          map (n: import (path + ("/" + n)))
            (filter (n: match ".*\\.nix" n != null ||
                        pathExists (path + ("/" + n + "/default.nix")))
              (attrNames (readDir path)));

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ag
    clang
    dunst
    ghq
    gnome3.nautilus
    gnupg
    graphviz
    heroku
    htop
    libreoffice
    metals-emacs
    metals-vim
    mr
    nix-prefetch-scripts
    obs-studio
    openvpn
    pass
    pavucontrol
    python-with-packages
    rescuetime
    robo3t
    rofi-vpn
    rxvt_unicode
    slack
    spotifywm
    sqlite
    vlc
    zotero
    ripgrep-all
  ];
}
