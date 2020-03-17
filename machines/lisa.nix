{ config, pkgs, ... }:

with pkgs;

let
  rescuetime-overlay = import ../overlays/rescuetime.nix;
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

    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/xresources.nix
    ../cfg/sbt
  ];

  nixpkgs.overlays =
    let path = ../overlays; in with builtins;
          map (n: import (path + ("/" + n)))
            (filter (n: match ".*\\.nix" n != null ||
                        pathExists (path + ("/" + n + "/default.nix")))
              (attrNames (readDir path)));

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.heroku
    pkgs.ag
    pkgs.clang
    pkgs.gnupg
    pkgs.pass
    pkgs.htop
    pkgs.jdk8
    pkgs.nix-prefetch-scripts
    pkgs.openvpn
    pkgs.dunst
    pkgs.sbt
    pkgs.libreoffice
    pkgs.slack
    pkgs.sqlite
    pkgs.metals-emacs
    pkgs.metals-vim
    pkgs.robo3t
    pkgs.spotify
    python-with-packages
  ];
}
