{
  description = "pepegar's nix home";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://gent.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "gent.cachix.org-1:V2dfRGc+kcxpr+0WXZXe5fOTrfW+ZnAOI7FR1aLV0e8="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv/latest";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/nur";
    nix-darwin.url = "github:LnL7/nix-darwin";
    karabinix.url = "github:pepegar/karabinix";
    tmux-zellij.url = "github:pepegar/tmux-zellij";
    gent.url = "github:pepegar/gent";
    tui-wright.url = "github:pepegar/tui-wright";
    zellij-cmd-k.url = "github:pepegar/zellij-cmd-k";
    playwright-cli.url = "github:microsoft/playwright-cli";
    playwright-cli.flake = false;
    chrome-devtools-mcp.url = "github:ChromeDevTools/chrome-devtools-mcp";
    chrome-devtools-mcp.flake = false;
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    pre-commit-hooks,
    home-manager,
    nur,
    nix-darwin,
    karabinix,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
      ];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            deadnix.enable = true;
            stylua.enable = true;
          };
        };
      in {
        formatter = pkgs.alejandra;

        checks = {
          inherit pre-commit-check;
        };

        devShells.default = pkgs.mkShell {
          inherit (pre-commit-check) shellHook;
          nativeBuildInputs = with pkgs; [
            git
            alejandra
            deadnix
            stylua
          ];
        };
      };

      flake = let
        user = "pepe";

        nurNoPkgs = system:
          import nur {nurpkgs = inputs.nixpkgs.legacyPackages.${system};};

        mkHomeConfig = machineModule: system:
          home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {inherit system;};
            modules = [
              (nurNoPkgs system).repos.rycee.hmModules.emacs-init
              karabinix.homeManagerModules.karabinix
              machineModule
            ];
            extraSpecialArgs = {inherit inputs system;};
          };

        mkDarwinConfig = extraModules:
          nix-darwin.lib.darwinSystem {
            modules = [./cfg/darwin-configuration.nix] ++ extraModules;
          };

        darwinMachines = ["bart" "homer" "milhouse"];
      in {
        nixosConfigurations = {
          lisa = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [./machines/lisa/configuration.nix];
          };
          marge = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/marge/configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.extraSpecialArgs = {
                  inherit inputs;
                  system = "x86_64-linux";
                };
                home-manager.sharedModules = [
                  (nurNoPkgs "x86_64-linux").repos.rycee.hmModules.emacs-init
                  karabinix.homeManagerModules.karabinix
                ];
              }
            ];
          };
        };

        homeConfigurations = {
          "${user}@bart" = mkHomeConfig ./machines/macbook.nix "aarch64-darwin";
          "${user}@lisa" = mkHomeConfig ./machines/lisa.nix "x86_64-linux";
          "${user}@marge" = mkHomeConfig ./machines/linux-server.nix "x86_64-linux";
          "${user}" = mkHomeConfig ./machines/macbook.nix "aarch64-darwin";
        };

        darwinConfigurations = builtins.listToAttrs (
          map (name: {
            inherit name;
            value = mkDarwinConfig [];
          })
          darwinMachines
        );
      };
    };
}
