{...}:
{

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
      bind = {
        "C-c C-c" = "comment-or-uncomment-region-or-line";
      };
      config = ''
      (put 'downcase-region 'disabled nil)
      (fset 'yes-or-no-p 'y-or-n-p)
      (load (concat user-emacs-directory "localrc.el") 'noerror)
      '';

      enable = true;
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
