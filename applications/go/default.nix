{ pkgs, ... }:

{
  programs.go = {
    enable = true;
    package = pkgs.go_1_17;
    goPath = "go";
  };
}
