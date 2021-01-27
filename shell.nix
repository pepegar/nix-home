let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  nix-pre-commit-hooks = import (builtins.fetchTarball
    "https://github.com/cachix/pre-commit-hooks.nix/tarball/master"); # can't really make this work with niv...
  pre-commit-check = nix-pre-commit-hooks.run {
    src = ./.;
    hooks = { nixfmt.enable = true; };
  };
in pkgs.mkShell {
  buildInputs = [ pkgs.nixfmt ];
  shellHook = ''
    ${pre-commit-check.shellHook}
  '';
}
