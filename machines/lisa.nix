{pkgs, ...}: {
  imports = [
    ./base.nix

    # Linux-specific applications
    ../applications/alacritty
    # ../applications/rofi  # Commented out due to deprecated options
    ../applications/texlive
    ../applications/xmonad

    # Linux-specific services - commented out problematic ones for now
    # ../services/network-manager-applet.nix
    # ../services/polybar.nix
    # ../services/dunst.nix

    # Linux-specific configuration
    ../cfg/xresources.nix
  ];

  # Linux-specific settings
  home.username = "pepe";
  home.homeDirectory = "/home/pepe";

  # Override some session variables for Linux
  home.sessionVariables = {
    DISPLAY = ":0";
    EDITOR = "emacs"; # You had this as "emacs" in lisa.nix, keeping for Linux
  };

  # Linux-specific packages (from your existing lisa.nix)
  home.packages = with pkgs; [
    ag
    any-nix-shell
    ghq
    gnome.nautilus
    heroku
    libreoffice
    mr
    nix-prefetch-scripts
    obs-studio
    openvpn
    pasystray
    pavucontrol
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

  # Apply the old overlays system from lisa.nix
  nixpkgs.overlays = let
    path = ../overlays;
  in
    with builtins;
      map (n: import (path + ("/" + n))) (filter (n:
        match ".*\\.nix" n
        != null
        || pathExists (path + ("/" + n + "/default.nix")))
      (attrNames (readDir path)));

  home.stateVersion = "22.05";
}
