{ config, pkgs, ... }:

{
  imports = [
    ../applications/fzf
    ../applications/zsh
    ../applications/neovim
    ../applications/emacs
    #../applications/tmux

    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/email
    ../cfg/sbt
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.overlays =
    let path = ../overlays; in with builtins;
          map (n: import (path + ("/" + n)))
            (filter (n: match ".*\\.nix" n != null ||
                        pathExists (path + ("/" + n + "/default.nix")))
              (attrNames (readDir path)));

  home.packages = with pkgs; [
    gnupg
    pass
    htop
    jdk8
    nix-prefetch-scripts
    openvpn
    sbt
    stack
    ag
    texFull
    metals-emacs
    metals-vim

    # apps
    Anki
    # LunaDisplay
    # Docker
    Dash
    iTerm2
  ];


  programs.zsh.initExtra = ''
  source ~/.nix-profile/etc/profile.d/nix.sh
  '';

  programs.zsh.sessionVariables = {
    NIX_PATH = "$HOME/.nix-defexpr/channels\${NIX_PATH:+:}$NIX_PATH";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

}
