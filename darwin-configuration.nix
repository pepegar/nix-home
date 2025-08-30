{pkgs, ...}: {
  imports = [
    ./cfg/homebrew.nix
    ./cfg/karabiner-elements-override.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/.config/home-manager/darwin-configuration.nix";
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  # programs.bash.enable = true;
  programs.zsh.enable = true;
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.primaryUser = "pepe";
  system.stateVersion = 4;
  system.defaults = {
    trackpad.Clicking = true;
    dock.autohide = true;
  };

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.settings.max-jobs = 16;
  nix.settings.cores = 16;
  nix.settings.trusted-users = ["root" "pepe"];
  services.karabiner-elements = {
    enable = true;
    #package = pkgs.karabiner-elements.overrideAttrs (old: {
    #version = "15.0.0";

    #src = pkgs.fetchurl {
    #inherit (old.src) url;
    #hash = "sha256-xWCsbkP9cVnDjWFTgWl5KrR7wEpcQYM4Md99pTI/l14=";
    #};

    #dontFixup = true;
    #});
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  ids.gids.nixbld = 350;
}
