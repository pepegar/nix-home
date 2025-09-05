{
  description = "pepegar's nix home";

  nixConfig = {
    substituters = ["https://cache.nixos.org"];

    trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    devenv.url = "github:cachix/devenv/latest";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/nur";
    nix-darwin.url = "github:LnL7/nix-darwin";
    karabinix.url = "github:pepegar/karabinix";
  };
  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    flake-utils,
    home-manager,
    nur,
    nix-darwin,
    karabinix,
    ...
  } @ inputs: let
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
  in
    {
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
          ];
        };
      };
      homeConfigurations = {
        "${user}@bart" = mkHomeConfig ./machines/macbook.nix "aarch64-darwin";
        "${user}@lisa" = mkHomeConfig ./machines/lisa.nix "x86_64-linux";
        "${user}@marge" = mkHomeConfig ./machines/lisa.nix "x86_64-linux";
        "${user}" = mkHomeConfig ./machines/macbook.nix "aarch64-darwin";
      };
      darwinConfigurations = {
        bart = nix-darwin.lib.darwinSystem {
          modules = [
            ./cfg/darwin-configuration.nix
          ];
        };
        homer = nix-darwin.lib.darwinSystem {
          modules = [
            ./cfg/darwin-configuration.nix
          ];
        };
        milhouse = nix-darwin.lib.darwinSystem {
          modules = [
            ./cfg/darwin-configuration.nix
          ];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            deadnix.enable = true;
            stylua.enable = true;
          };
        };
      };
      devShell = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;

        nativeBuildInputs = with nixpkgs.legacyPackages.${system}; [
          git
        ];
      };
    });
}
