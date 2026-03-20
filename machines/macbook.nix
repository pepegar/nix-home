{pkgs, ...}: {
  imports = [
    ./base.nix

    # macOS-specific applications
    ../applications/ghostty
    ../applications/kitty
    ../applications/intellij-idea
    ../applications/karabinix
    ../applications/testcontainers
  ];

  # macOS-specific settings
  home.username = "pepe";
  home.homeDirectory = "/Users/pepe";

  # macOS-specific packages
  home.packages = with pkgs; [
    cocoapods
  ];

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "marge" = {
        hostname = "marge";
        user = "pepe";
        sendEnv = ["TERM"];
      };
      "lisa" = {
        hostname = "lisa";
        user = "pepe";
        identityFile = ["~/.ssh/local"];
      };
      "*".extraOptions = {
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
      };
      "*.github.com".extraOptions = {IdentityFile = "~/.ssh/id_ed25519";};
    };
  };
}
