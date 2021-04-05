{ pkgs, ... }:

with pkgs; {
  programs.emacs.init.usePackage = {

    use-package = {
      enable = true;
      package = epkgs:
        epkgs.use-package.overrideAttrs (drv: {
          src = fetchGit {
            url = "git://github.com/jwiegley/use-package.git";
            rev = "caa92f1d64fc25480551757d854b4b49981dfa6b";
          };
        });
    };

    macrostep.enable = true;
    general.enable = true;
    hydra.enable = true;
    ripgrep.enable = true;

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
      after = [ "projectile" ];
      command = [ "consult-buffer" ];
      bind = {
        "C-x C-b" = "consult-buffer";
        "C-s" = "consult-line";
        "C-c a g" = "consult-ripgrep";
      };
      config = ''
        (autoload 'projectile-project-root "projectile")
        (setq consult-project-root-function #'projectile-project-root)
      '';
    };

    consult-selectrum = {
      enable = true;
      after = [ "consult" "selectrum" ];
      hook = [ "(consult-mode . (lambda () (require 'consult-selectrum)))" ];
    };

    embark = {
      enable = true;
      bind = { "C-," = "embark-act"; };
    };

    embark-consult = {
      enable = true;
      after = [ "embark" "consult" ];
      demand = true;
      hook = [ "(embark-collect-mode . embark-consult-preview-minor-mode)" ];
    };

    marginalia = {
      enable = true;
      config = ''
        ;; Must be in the :init section of use-package such that the mode gets
        ;; enabled right away. Note that this forces loading the package.
        (marginalia-mode)

        ;; When using Selectrum, ensure that Selectrum is refreshed when cycling annotations.
        (advice-add #'marginalia-cycle :after
                    (lambda () (when (bound-and-true-p selectrum-mode) (selectrum-exhibit))))

        (setq marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
      '';
    };

    projectile = {
      enable = true;
      extraPackages = [ fd ripgrep ];
      hook = [ "(selectrum-mode . projectile-mode)" ];
      extraConfig = ''
        :custom
        (projectile-indexing-method 'alien)
        (projectile-sort-order 'recentf-active)
        (projectile-enable-caching t)
        (projectile-project-search-path '(
          "~/projects/github.com/47deg/"
          "~/projects/github.com/higherkindness/"
          "~/projects/github.com/pepegar/"
          "~/projects/github.com/app-2020/"
          "~/projects/github.com/gsk-aiops/"
           "~/.config/"))
      '';
      bind = {
        "C-c p h" = "projectile-find-file";
        "C-c p r" = "projectile-replace";
        "C-c p v" = "projectile-vc";
        "C-c p p" = "projectile-switch-project";
      };
      config = ''
        (setq ad-redefinition-action 'accept)
      '';
    };

    envrc = {
      enable = true;
      demand = true;
      config = ''
        (envrc-global-mode)
        (define-key envrc-mode-map (kbd "C-c e") 'envrc-command-map)
        (define-key envrc-command-map (kbd "R") 'envrc-reload-all)
      '';
      extraPackages = [ direnv ];
    };

    magit = {
      enable = true;
      command = [ "magit-status" ];
    };

    forge = {
      enable = true;
      after = [ "magit" ];
    };

    treemacs = {
      enable = true;
      command = [ "treemacs" "treemacs-select-window" ];
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
        (load-theme 'doom-Iosvkem t)
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

    mode-line-bell.enable = true;
    mode-line-bell.config = "(mode-line-bell-mode 1)";

    pdf-tools = {
      enable = true;
      mode = [ ''("\\.pdf\\'" . pdf-view-mode)'' ];
    };

    ebib.enable = true;
    ebib.command = [ "ebib" ];
  };
}
