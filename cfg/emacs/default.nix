{pkgs, ...}:

{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.all-the-icons
      epkgs.rainbow-delimiters
      epkgs.all-the-icons-dired
      epkgs.page-break-lines
      epkgs.dashboard
      epkgs.golden-ratio
      epkgs.auto-package-update
      epkgs.move-text
      epkgs.company
      epkgs.paredit
      epkgs.magit
      epkgs.forge
      epkgs.projectile
      epkgs.diminish
      epkgs.doom-modeline
      epkgs.flycheck
      epkgs.ivy
      epkgs.flx
      epkgs.counsel
      epkgs.counsel-projectile
      epkgs.swiper
      epkgs.ace-window
      epkgs.posframe
      epkgs.hydra
      epkgs.restclient
      epkgs.org
      epkgs.ob-restclient
      epkgs.org-bullets
      epkgs.org-present
      epkgs.multiple-cursors
      epkgs.mc-extras
      epkgs.expand-region
      epkgs.avy
      epkgs.yasnippet
      epkgs.yasnippet-snippets
      epkgs.xresources-theme
      epkgs.doom-themes
      epkgs.spacemacs-theme
      epkgs.idea-darkula-theme
      epkgs.punpun-theme
      epkgs.white-theme
      epkgs.arjen-grey-theme
      epkgs.atom-one-dark-theme
      epkgs.birds-of-paradise-plus-theme
      epkgs.bliss-theme
      epkgs.cyberpunk-theme
      epkgs.espresso-theme
      epkgs.github-theme
      epkgs.heroku-theme
      epkgs.idea-darkula-theme
      epkgs.plan9-theme
      epkgs.soothe-theme
      epkgs.subatomic-theme
      epkgs.sublime-themes
      epkgs.white-theme
      epkgs.madhat2r-theme
      epkgs.kosmos-theme
      epkgs.nord-theme
      epkgs.scala-mode
      epkgs.sbt-mode
      epkgs.flycheck
      epkgs.lsp-mode
      epkgs.lsp-ui
      epkgs.company-lsp
      epkgs.haskell-mode
      epkgs.idris-mode
      epkgs.nix-mode
      epkgs.groovy-mode
      epkgs.yaml-mode
      epkgs.json-mode
      epkgs.dhall-mode
      epkgs.markdown-mode
      epkgs.markdown-toc
    ];
  };

  home.file.".emacs.d/init.el".source = ./init.el;
  home.file.".emacs.d/custom.el".text = "";
  home.file.".emacs.d/lisp/pragmatapro.el".source = ./lisp/pragmatapro.el;
  home.file.".emacs.d/lisp/xresources-theme.el".source = ./lisp/xresources-theme.el;

}
