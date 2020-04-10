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

  home.packages = with pkgs; [
    heroku
    ag
    clang
    gnupg
    pass
    htop
    jdk8
    nix-prefetch-scripts
    openvpn
    dunst
    sbt
    libreoffice
    slack
    sqlite
    metals-emacs
    metals-vim
    robo3t
    spotify
    python-with-packages
    run-jupyter
    graphviz
    ghq
    mr
  ];
}
