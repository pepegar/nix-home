{
  description = "pepegar's nix home";

  inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.neovim-nightly-overlay.url =
    "github:nix-community/neovim-nightly-overlay";

  outputs = { self, nixpkgs, pre-commit-hooks, flake-utils, home-manager
    , neovim-nightly-overlay }:
    let overlays = [ neovim-nightly-overlay.overlay ];
    in {
      homeConfigurations = {
        pepegarcia = home-manager.lib.homeManagerConfiguration {
          system = "x86_64-darwin";
          homeDirectory = "/Users/pepegarcia";
          username = "pepe";
          configuration = {
            nixpkgs.overlays = overlays;
            imports = [ ./machines/macbook.nix ];
          };
        };
      };
    } // flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ]
    (system: {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = { nixfmt.enable = true; };
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
