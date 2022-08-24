{ ... }: {

  programs.emacs.init.usePackage = {
    mule = {
      config = ''
        (when (fboundp 'set-charset-priority)
          (set-charset-priority 'unicode))
        (prefer-coding-system        'utf-8)
        (set-terminal-coding-system  'utf-8)
        (set-keyboard-coding-system  'utf-8)
        (set-selection-coding-system 'utf-8)
        (setq locale-coding-system   'utf-8)
        (setq-default buffer-file-coding-system 'utf-8)
      '';
      enable = true;
    };

    emacs = {
      enable = true;
      config = ''
        (put 'downcase-region 'disabled nil)
        (fset 'yes-or-no-p 'y-or-n-p)
        (load (concat user-emacs-directory "localrc.el") 'noerror)
      '';

      extraConfig = ''
        :custom
        (make-backup-files nil)
        (c-basic-offset 2)
        (tab-width 2)
        (tab-always-indent nil)
        (indent-tabs-mode nil)
        (show-paren-mode t)
        (electric-pair-mode t)
        (delete-selection-mode t)
        (global-auto-revert-mode t)
        (global-display-line-numbers-mode t)
        (custom-file null-device "Do not store customizations")
        ; Smooth scrolling
        (redisplay-dont-pause t)
        (scroll-margin 5)
        (scroll-step 1)
        (scroll-conservatively 10000)
        (scroll-preserve-screen-position t)
      '';
    };

    mwim = {
      enable = true;
      bind = {
        "C-a" = "mwim-beginning";
        "C-e" = "mwim-end";
      };
    };

    simple = {
      enable = true;
      hook = [ "(before-save . delete-trailing-whitespace)" ];
      config = ''
        (column-number-mode t)
        (global-visual-line-mode t)
      '';
    };

    dashboard = {
      enable = true;
      config = ''
        (dashboard-setup-startup-hook)
        (setq dashboard-center-content t)
        (setq dashboard-show-shortcuts nil)
        (setq dashboard-items '((recents . 5)
	        (bookmarks .  5)
	        (projects . 5)
	        (agenda . 5)
	        (registers . 5)))
        (setq dashboard-startup-banner 'logo)
        (setq dashboard-set-navigator t)
        (setq dashboard-set-heading-icons t)
        (setq dashboard-set-file-icons t)
        (setq dashboard-set-navigator t)
        ;;(setq dashboard-set-navigator t)
        ;;(setq dashboard-navigator-buttons '(icon title help action face prefix suffix))
        (setq dashboard-set-init-info t)
        (setq dashboard-week-agenda t)
        (setq dashboard-filter-agenda-entry 'dashboard-no-filter-agenda)
      '';
    };

    doom-modeline = {
      enable = true;
      hook = [ "(after-init . doom-modeline-mode)" ];
    };

    page-break-lines = {
      enable = true;
      config = ''
        (set-fontset-font "fontset-default"
                    (cons page-break-lines-char page-break-lines-char)
                    (face-attribute 'default :family))
      '';
    };
  };
}
