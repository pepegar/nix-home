{ pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    width = 60;
    lines = 10;
    borderWidth = 2;
    padding = 30;
    theme = "paper-float";
  };
}
