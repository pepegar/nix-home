{ pkgs, ... }:

{
  home.file.".pandoc/47deg.tex".source = ./47deg.tex;
  home.file.".pandoc/img/47-brand-red.png".source = ./img/47-brand-red.png;
}
