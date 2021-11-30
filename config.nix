{
  allowUnfree = true;
  allowBroken = true;
  packageOverrides = pkgs:
    with pkgs; rec {
      metals-emacs = callPackage pkgs/metals-emacs { inherit pkgs; };
      metals-vim = callPackage pkgs/metals-vim { inherit pkgs; };
    };
}
