{ config, pkgs, ... }:

let 
  all-hies = import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
in  {
  imports = [
    ../applications/fzf
    ../applications/zsh
    ../applications/emacs
    ../applications/direnv

    ../cfg/git.nix
    ../cfg/ssh.nix
    ../cfg/email
    ../cfg/sbt
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.overlays = let path = ../overlays;
  in with builtins;
  map (n: import (path + ("/" + n))) (filter (n:
    match ".*\\.nix" n != null
    || pathExists (path + ("/" + n + "/default.nix")))
    (attrNames (readDir path)));

  home.packages = with pkgs; [
    gnupg
    pass
    htop
    openvpn
    stack
    ag
    metals-emacs

    # apps
    # Anki
    # LunaDisplay
    # Docker
    # Dash
    # iTerm2
    # Tunnelblick
  ];

  programs.zsh.sessionVariables = {
    NIX_PATH = "$HOME/.nix-defexpr/channels\${NIX_PATH:+:}$NIX_PATH";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
}
