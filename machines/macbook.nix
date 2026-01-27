{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    #../applications/firefox
    ../applications/chrome
    ../applications/claude
    ../applications/codex
    ../applications/opencode
    ../applications/direnv
    ../applications/emacs
    ../applications/fzf
    ../applications/ghostty
    ../applications/kitty
    ../applications/go
    ../applications/intellij-idea
    ../applications/karabinix
    ../applications/llm
    ../applications/neovim
    ../applications/nushell
    ../applications/starship
    ../applications/testcontainers
    ../applications/vscode
    ../applications/zellij
    ../applications/zsh
    ../cfg/email
    ../cfg/git.nix
    ../cfg/sbt
    ../cfg/gradle
    ../cfg/yarn
    ../cfg/scripts.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  manual.manpages.enable = false;
  programs.command-not-found.enable = true;
  home.stateVersion = "22.11";
  home.username = "pepe";
  home.homeDirectory = "/Users/pepe";

  nixpkgs.overlays = [
    inputs.nur.overlays.default
  ];

  home.packages = with pkgs; [
    inputs.devenv.packages."${pkgs.system}".devenv
    alejandra
    aws-vault
    bat
    bazelisk
    buildifier
    cargo
    cocoapods
    difftastic
    eza
    fd
    gemini-cli
    gh
    git-crypt
    git-town
    gnupg
    graphviz
    htop
    hub
    jq
    minio-client
    nix-tree
    pass
    prettyping
    ripgrep
    ruby
    silver-searcher
    sops
    tree-sitter
    tree
    uv
    xcodes
    yq
    zig
  ];

  programs.zsh.sessionVariables = {
    NIX_PATH = "$HOME/.nix-defexpr/channels\${NIX_PATH:+:}$NIX_PATH";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "marge" = {
        hostname = "marge";
        user = "pepe";
      };
      "lisa" = {
        hostname = "lisa";
        user = "pepe";
        identityFile = ["~/.ssh/local"];
      };
      "*".extraOptions = {AddKeysToAgent = "yes";};
      "*.github.com".extraOptions = {IdentityFile = "~/.ssh/id_ed25519";};
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
