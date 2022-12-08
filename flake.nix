{
  description = "pepegar's nix home";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nur.url = "github:nix-community/nur";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, pre-commit-hooks, flake-utils, home-manager
    , neovim-nightly-overlay, nur, emacs-overlay }@inputs:
    let
      nurNoPkgs = import nur {
        nurpkgs = inputs.nixpkgs.legacyPackages."aarch64-darwin";
      };
    in {
      nixosConfigurations = {
        lisa = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./machines/lisa/configuration.nix ];
        };
        marge = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/marge/configuration.nix
            home-manager.nixosModules.home-manager
          ];
        };
      };
      homeConfigurations = {
        pepe = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/Users/pepe";
          username = "pepe";
          configuration = {

            nixpkgs.overlays =
              [ neovim-nightly-overlay.overlay emacs-overlay.overlay ];
            imports = [
              ./machines/lisa.nix
              nurNoPkgs.repos.rycee.hmModules.emacs-init
            ];
          };
        };
        pepegarcia = home-manager.lib.homeManagerConfiguration {
          system = "aarch64-darwin";
          homeDirectory = "/Users/pepegarcia";
          username = "pepegarcia";
          configuration = {

            nixpkgs.overlays =
              [ neovim-nightly-overlay.overlay emacs-overlay.overlay ];
            imports = [
              ./machines/macbook.nix
              nurNoPkgs.repos.rycee.hmModules.emacs-init
            ];
          };
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system: {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt.enable = true;
            nix-linter.enable = true;
          };
        };
      };
      devShell = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;

        nativeBuildInputs = with nixpkgs.legacyPackages.${system}; [
          git
          nix
          nixfmt
        ];
      };
    });
}
