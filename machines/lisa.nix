{...}: let
  sources = import ../nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in rec {
  imports = [
    ../applications/fzf
    ../applications/zsh
    ../applications/neovim
    ../applications/alacritty
    ../applications/emacs
    ../applications/direnv
    ../applications/go
    ../applications/rofi
    ../applications/texlive
    ../applications/starship
    ../applications/xmonad

    ../services/network-manager-applet.nix
    ../services/polybar.nix
    ../services/dunst.nix

    ../cfg/email
    ../cfg/git.nix
    ../cfg/xresources.nix
    ../cfg/sbt
  ];

  nixpkgs.overlays = let
    path = ../overlays;
  in
    with builtins;
      map (n: import (path + ("/" + n))) (filter (n:
        match ".*\\.nix" n
        != null
        || pathExists (path + ("/" + n + "/default.nix")))
      (attrNames (readDir path)));

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ag
    any-nix-shell
    bat
    eza
    ghq
    gnome3.nautilus
    gnupg
    graphviz
    heroku
    htop
    libreoffice
    mr
    nix-prefetch-scripts
    obs-studio
    openvpn
    pass
    pasystray
    pavucontrol
    prettyping
    rescuetime
    ripgrep-all
    robo3t
    rofi-vpn
    slack
    spotifywm
    sqlite
    vlc
    zotero
    obsidian
    nyxt
  ];

  home.sessionVariables = {
    DISPLAY = ":0";
    EDITOR = "emacs";
  };

  home.stateVersion = "22.05";
}
