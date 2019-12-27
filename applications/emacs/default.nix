{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.ace-window
      epkgs.add-node-modules-path
      epkgs.all-the-icons
      epkgs.company
      epkgs.counsel
      epkgs.counsel-projectile
      epkgs.dashboard
      epkgs.dashboard
      epkgs.doom-themes
      epkgs.exec-path-from-shell
      epkgs.expand-region
      epkgs.flx
      epkgs.flx
      epkgs.flycheck
      epkgs.forge
      epkgs.graphql-mode
      epkgs.haskell-mode
      epkgs.hindent
      epkgs.ivy
      epkgs.ivy-posframe
      epkgs.lsp-mode
      epkgs.magit
      epkgs.multiple-cursors
      epkgs.neotree
      epkgs.nix-mode
      epkgs.prettier-js
      epkgs.projectile
      epkgs.rainbow-delimiters
      epkgs.rainbow-mode
      epkgs.rainbow-mode
      epkgs.sbt-mode
      epkgs.scala-mode
      epkgs.swiper
      epkgs.tide
      epkgs.web-mode
    ];
  };

  home.file.".emacs.d/init.el".source = ./init.el;
  home.file.".emacs.d/lisp/pragmatapro.el".source = ./lisp/pragmatapro.el;
}
