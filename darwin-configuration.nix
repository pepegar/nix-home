{pkgs, ...}: {
  imports = [./homebrew.nix];

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
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.settings.max-jobs = 8;
  nix.settings.cores = 8;
  nix.settings.trusted-users = ["root" "pepe"];
  services.emacs.enable = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  ids.gids.nixbld = 350;
}
