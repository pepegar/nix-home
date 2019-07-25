{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; rec {
    metals-emacs = callPackage pkgs/metals-emacs { inherit pkgs; };
  };
}
