{ config, pkgs, ... }:

{
  imports = [
    cfg/emacs.nix
    cfg/git.nix
    cfg/ssh.nix
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.gitAndTools.gitFull
    pkgs.gnupg
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
