{pkgs, ...}: {
  imports = [
    ./base.nix

    # Linux machines still use emacs
    ../applications/emacs
  ];

  # Linux server settings
  home.username = "pepe";
  home.homeDirectory = "/home/pepe";

  # Override some session variables for Linux servers
  home.sessionVariables = {
    EDITOR = "nvim"; # Using nvim for servers
  };

  # Server-specific packages (no GUI applications)
  home.packages = with pkgs; [
    # Only CLI tools for servers
    mr
    sqlite
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
