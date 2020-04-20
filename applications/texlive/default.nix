{ pkgs, ... }:

{
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs)
        collection-fontsrecommended
        algorithms
        scheme-medium
        wrapfig
        capt-of
        framed
      ;
    };
  };
}
