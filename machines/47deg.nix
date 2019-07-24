{ config, pkgs, ... }:

{
  imports = [
    cfg/emacs
    cfg/email.nix
    cfg/fzf.nix    
    cfg/git.nix
    cfg/ssh.nix
    cfg/xresources.nix
    cfg/gnome-keyring.nix
    cfg/zsh.nix
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
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 1800;
  };
}
