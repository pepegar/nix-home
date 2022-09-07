{
  description = "pepegar's nix home";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager?rev=ac2287df5a2d6f0a44bbcbd11701dbbf6ec43675";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nur.url = "github:nix-community/nur?rev61559589a9bb4f2e2301d9e4a59f3f1fac4cec59";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay?rev=ae5528c72a1e1afbbcb7be7e813f4b3598f919ed";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
      nixpkgs,
      pre-commit-hooks,
      flake-utils,
      home-manager,
      neovim-nightly-overlay,
      nur,
      emacs-overlay
  }@inputs:
    let
      nurNoPkgs = import inputs.nur {
        nurpkgs = inputs.nixpkgs.legacyPackages."aarch64-darwin";
      };
    in {
      homeConfigurations = {
        pepegarcia = home-manager.lib.homeManagerConfiguration {
          system = "aarch64-darwin";
          homeDirectory = "/Users/pepegarcia";
          username = "pepegarcia";
          configuration = {

            nixpkgs.overlays = [
              neovim-nightly-overlay.overlay
              emacs-overlay.overlay
            ];
            imports = [
              ./machines/macbook.nix
              nurNoPkgs.repos.rycee.hmModules.emacs-init
            ];
          };
        };
      };
    } // flake-utils.lib.eachDefaultSystem
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
