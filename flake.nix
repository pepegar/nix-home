{
  description = "pepegar's nix home";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/nur";
  };
  outputs =
    { self, nixpkgs, pre-commit-hooks, flake-utils, home-manager, nur }@inputs:
    let
      nurNoPkgs = system:
        import nur { nurpkgs = inputs.nixpkgs.legacyPackages.${system}; };

      mkHomeConfig = machineModule: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };

          modules = [
            (nurNoPkgs system).repos.rycee.hmModules.emacs-init
            machineModule
          ];

          extraSpecialArgs = { inherit inputs system; };
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
        "pepe@bart" = mkHomeConfig ./machines/macbook.nix "aarch64-darwin";
        "pepe@lisa" = mkHomeConfig ./machines/lisa.nix "x86_64-linux";
        "pepe@marge" = mkHomeConfig ./machines/lisa.nix "x86_64-linux";
      };
    } // flake-utils.lib.eachDefaultSystem (system: {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt.enable = true;
            deadnix.enable = true;
            stylua.enable = true;
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
