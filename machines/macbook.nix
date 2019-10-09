{ config, pkgs, ... }:

{
  imports = [
    ../applications/fzf
    ../applications/zsh

    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/sbt
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
    pkgs.sbt
    pkgs.emacs
    pkgs.stack
  ];

  programs.zsh.initExtra = ''
  source ~/.nix-profile/etc/profile.d/nix.sh
  '';

  programs.zsh.sessionVariables = {
    NIX_PATH = "$HOME/.nix-defexpr/channels\${NIX_PATH:+:}$NIX_PATH";
  };

}
