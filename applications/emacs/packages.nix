{ pkgs, ... }:

with pkgs;
{
  programs.emacs.init.usePackage = {

    macrostep.enable = true;
    general.enable = true;
    hydra.enable = true;
    initchart.enable = true;

    restart-emacs.enable = true;
    restart-emacs.command = [ "restart-emacs" ];

    git-gutter.enable = true;
    git-gutter.config = "(global-git-gutter-mode t)";

    undo-fu.enable = true;
    undo-fu-session.enable = true;
    undo-fu-session.config = "(global-undo-fu-session-mode 1)";

    undo-tree.enable = true;
    undo-tree.command = [ "undo-tree-visualize" ];

    winum.enable = true;
    winum.config = "(winum-mode)";

    which-key.enable = true;
    which-key.config = ''
      (which-key-setup-side-window-bottom)
      (which-key-mode)
    '';

    selectrum = {
      enable = true;
      config = ''
        (selectrum-mode +1)
      '';
    };

    selectrum-prescient = {
      enable = true;
      config = ''
        (selectrum-prescient-mode +1)
        (prescient-persist-mode +1)
      '';
    };

    consult = {
      enable = true;
      command = [
        "consult-buffer"
      ];
      extraConfig = ''
        :general
        ("C-s" 'consult-line)
        ("C-h a" 'consult-apropos)
      '';
    };

    consult-selectrum = {
      enable = true;
      hook = [ "(consult-mode . (lambda () (require 'consult-selectrum)))" ];
    };

    projectile = {
      enable = true;
      extraPackages = [
        fd
        ripgrep
      ];
      hook = [ "(selectrum-mode . projectile-mode)" ];
      extraConfig = ''
        :custom
        (projectile-indexing-method 'alien)
        (projectile-sort-order 'recentf-active)
        (projectile-enable-caching t)
      '';
    };

    envrc.enable = true;

    magit = {
      enable = true;
      command = [ "magit-status" ];
    };

    treemacs = {
      enable = true;
      command = [
        "treemacs"
        "treemacs-select-window"
      ];
      config = ''
        (treemacs-git-mode 'deferred)
        (require 'treemacs-magit)
        (require 'treemacs-projectile)
      '';
      extraConfig = ''
        :custom
        (treemacs-width 30)
        (treemacs-python-executable "${python3}/bin/python")
      '';
    };

    treemacs-projectile.enable = true;
    treemacs-projectile.defer = true;

    treemacs-magit.enable = true;
    treemacs-magit.defer = true;

    posframe.enable = true;
    posframe.defer = true;

    all-the-icons.enable = true;
    all-the-icons.extraPackages = [ emacs-all-the-icons-fonts ];

    doom-themes = {
      enable = true;
      config = ''
        (load-theme 'doom-opera t)
        (require 'doom-themes-ext-treemacs)
        (doom-themes-treemacs-config)
      '';
      extraConfig = ''
        :custom
        (doom-themes-treemacs-theme "doom-colors")
      '';
    };

    doom-modeline = {
      enable = true;
      config = ''
        (doom-modeline-def-modeline 'my/main
          '(bar window-number parrot matches buffer-info " " buffer-position)
          '(misc-info process checker repl lsp vcs indent-info buffer-encoding "   "))
        (defun doom-modeline-set-my/main-modeline ()
          (doom-modeline-set-modeline 'my/main t))
        (add-hook 'doom-modeline-mode-hook 'doom-modeline-set-my/main-modeline)
        (doom-modeline-mode 1)
        (defun my/configure-face-attributes ()
          (progn
            (set-face-attribute 'mode-line nil :family "Cica" :height 120)
            (set-face-attribute 'mode-line-inactive nil :family "Cica" :height 120)))
        (add-hook 'after-init-hook 'my/configure-face-attributes)
      '';
      extraConfig = ''
        :custom
        (all-the-icons-scale-factor 1.1)
        (doom-modeline-height 1)
        (doom-modeline-bar-width 3)
        (doom-modeline-buffer-file-name-style 'truncate-with-project)
      '';
    };

    nyan-mode.enable = true;
    nyan-mode.config = "(nyan-mode 1)";

    hide-mode-line = {
      enable = false;
      hook = [
        "(help-mode . hide-mode-line-mode)"
        "(vterm-mode . hide-mode-line-mode)"
      ];
    };

    mode-line-bell.enable = true;
    mode-line-bell.config = "(mode-line-bell-mode 1)";

    pdf-tools = {
      enable = true;
      mode = [ ''("\\.pdf\\'" . pdf-view-mode)'' ];
    };

    ebib.enable = true;
    ebib.command = [ "ebib" ];

    dashboard = {
      enable = true;
      extraConfig = ''
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-banner-logo-title "The One True Editor, Emacs")
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-set-init-info nil)
  (dashboard-set-navigator t)
  (dashboard-footer-icon (cond ((display-graphic-p)
                                (all-the-icons-faicon "code" :height 1.5 :v-adjust -0.1 :face 'error))
                               (t (propertize ">" 'face 'font-lock-doc-face))))
'';
      config = ''
      (defun dashboard-load-packages (list-size)
      (insert (make-string (ceiling (max 0 (- dashboard-banner-length 38)) 2) ? )
              (format "[%d packages loaded in %s]" (length package-activated-list) (emacs-init-time))))

      (add-to-list 'dashboard-item-generators '(packages . dashboard-load-packages))

      (setq dashboard-items '((packages)
                          (projects . 10)
                          (recents . 10)))
      (dashboard-setup-startup-hook)
      '';
    };

  };
}
