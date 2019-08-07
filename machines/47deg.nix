{ config, pkgs, ... }:

{
  imports = [
    ../applications/fzf
    ../applications/xmonad
    ../applications/zsh

    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/xresources.nix
    ../cfg/sbt

    ../services/dunst.nix
    ../services/email.nix
    ../services/gnome-keyring.nix
    ../services/gpg-agent.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.gitAndTools.gitFull
    pkgs.gnupg
    pkgs.pass
    pkgs.htop
    pkgs.jdk8
    pkgs.nix-prefetch-scripts
    pkgs.openvpn
    pkgs.dunst
    pkgs.sbt
    pkgs.python
    pkgs.emacs
    pkgs.metals-emacs
    pkgs.libreoffice
    pkgs.stack
  ];

}
