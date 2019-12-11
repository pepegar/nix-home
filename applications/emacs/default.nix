{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.magit
      epkgs.expand-region
      epkgs.flycheck
      epkgs.graphql-mode
      epkgs.neotree
      epkgs.rainbow-mode
      epkgs.tide
      epkgs.company
      epkgs.web-mode
      epkgs.haskell-mode
      epkgs.prettier-js
      epkgs.nix-mode
      epkgs.add-node-modules-path
      epkgs.flx
      epkgs.hindent
      epkgs.doom-themes
      epkgs.all-the-icons
      epkgs.dashboard
      epkgs.dashboard
      epkgs.rainbow-mode
      epkgs.rainbow-delimiters
      epkgs.ace-window
      epkgs.scala-mode
      epkgs.sbt-mode
      epkgs.lsp-mode

      epkgs.projectile
      epkgs.ivy
      epkgs.flx
      epkgs.swiper
      epkgs.counsel
      epkgs.counsel-projectile
      epkgs.ivy-posframe
    ];
  };

  home.file.".emacs.d/init.el".source = ./init.el;
  home.file.".emacs.d/lisp/pragmatapro.el".source = ./lisp/pragmatapro.el;
}
