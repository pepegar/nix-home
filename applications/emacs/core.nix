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
        (global-linum-mode t)
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
  };
}
