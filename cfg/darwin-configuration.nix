{pkgs, ...}: {
  imports = [
    ./homebrew.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/.config/home-manager/darwin-configuration.nix";
  # Needed since Determinate Nix manages the main config file for system.
  environment.etc."nix/nix.custom.conf".text = pkgs.lib.mkForce ''
    # Add nix settings to seperate conf file
    # since we use Determinate Nix on our systems.
    trusted-users = pepe
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

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
  nix.enable = false;
  nix.settings.max-jobs = 16;
  nix.settings.cores = 16;
  nix.settings.trusted-users = ["root" "pepe"];
  nixpkgs.hostPlatform = "aarch64-darwin";
  ids.gids.nixbld = 350;

  # touchid PLZ
  security.pam.services.sudo_local.touchIdAuth = true;
}
