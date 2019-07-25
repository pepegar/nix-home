{ config, pkgs, ... }:

{
  imports = [
    ../cfg/emacs
    ../services/email.nix
    ../services/dunst.nix
    ../cfg/xmonad
    ../cfg/fzf
    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/xresources.nix
    ../services/gnome-keyring.nix
    ../cfg/zsh.nix
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
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 1800;
  };


}
