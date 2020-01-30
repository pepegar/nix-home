{ config, pkgs, ... }:

{
  imports = [
    ../applications/fzf
    ../applications/xmonad
    ../applications/emacs
    ../applications/zsh
    ../applications/neovim
    ../applications/tmux

    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/sbt

    ../services/dunst.nix
    ../services/gnome-keyring.nix
    ../services/blueman.nix
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
    pkgs.libreoffice
    /**pkgs.neovim */
    pkgs.stack
  ];
}
