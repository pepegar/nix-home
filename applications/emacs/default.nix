{pkgs, ...}:

{
  home.file.".emacs.d/init.el".source = ./init.el;
  home.file.".emacs.d/lisp/pragmatapro.el".source = ./lisp/pragmatapro.el;
  home.file.".emacs.d/lisp/xresources-theme.el".source = ./lisp/xresources-theme.el;
}
