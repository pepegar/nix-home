{ config, pkgs, ... }:

with pkgs;


let
  rescuetime-overlay = import ../overlays/rescuetime.nix;
in rec {
  imports = [
    ../applications/fzf
    ../applications/xmonad
    ../applications/zsh
    ../applications/neovim
    ../applications/tmux

    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/xresources.nix
    ../cfg/sbt

    ../services/dunst.nix
    ../services/gnome-keyring.nix
    ../services/blueman.nix
  ];

  nixpkgs.overlays = [
    rescuetime-overlay
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.gnupg
    pkgs.pass
    pkgs.htop
    pkgs.jdk8
    pkgs.nix-prefetch-scripts
    pkgs.openvpn
    pkgs.dunst
    pkgs.sbt
    pkgs.emacs
    pkgs.libreoffice
    /**pkgs.neovim */
    pkgs.stack
  ];
}
