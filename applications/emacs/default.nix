{ pkgs, ... }:

{
  programs.emacs.enable = true;
  home.file.".emacs.d/lisp/pragmatapro.el".source = ./lisp/pragmatapro.el;
}
