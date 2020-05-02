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
    heroku
    ag
    clang
    gnupg
    pass
    htop
    nix-prefetch-scripts
    openvpn
    dunst
    libreoffice
    slack
    sqlite
    metals-emacs
    metals-vim
    robo3t
    spotify
    python-with-packages
    graphviz
    ghq
    mr
    zotero
    rofi-vpn
    rescuetime
    rxvt_unicode
    pavucontrol
  ];
}
