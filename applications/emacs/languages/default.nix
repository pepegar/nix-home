{...}: {

  imports = [
    ./nix
    ./scala
    ./python
    ./jupyter
    ./restclient
    ./org
  ];

  programs.emacs.init.usePackage = {

    rainbow-delimiters = {
      enable = true;
      hook = [
        "(prog-mode . rainbow-delimiters-mode)"
      ];
    };

    smartparens.enable = true;
    smartparens.config = "(require 'smartparens-config)";

    flycheck.enable = true;
    flycheck.config = ''
      (require 'pkg-info)
    '';

    yasnippet.enable = true;
    yasnippet.defer = true;

    lsp-ui = {
      enable = true;
      command = [ "lsp-ui-mode" ];
      bindLocal = {
        lsp-mode-map = {
          "C-c r d" = "lsp-ui-doc-glance";
          "C-c f s" = "lsp-ui-find-workspace-symbol";
        };
      };
      config = ''
          (setq lsp-ui-sideline-enable t
                lsp-ui-sideline-show-symbol nil
                lsp-ui-sideline-show-hover nil
                lsp-ui-sideline-show-code-actions nil
                lsp-ui-sideline-update-mode 'point)
          (setq lsp-ui-doc-enable nil
                lsp-ui-doc-position 'at-point
                lsp-ui-doc-max-width 120
                lsp-ui-doc-max-height 15)
        '';
    };

    lsp-ui-flycheck = {
      enable = true;
      after = [ "flycheck" "lsp-ui" ];
    };

    lsp-completion = {
      enable = true;
      after = [ "lsp-mode" ];
      config = ''
          (setq lsp-completion-enable-additional-text-edit nil)
        '';
    };

    lsp-diagnostics = {
      enable = true;
      after = [ "lsp-mode" ];
    };

    lsp-mode = {
      enable = true;
      command = [ "lsp" ];
      after = [ "company" "flycheck" ];
      hook = [ "(lsp-mode . lsp-enable-which-key-integration)" ];
      bindLocal = {
        lsp-mode-map = {
          "C-c r r" = "lsp-rename";
          "C-c r f" = "lsp-format-buffer";
          "C-c r g" = "lsp-format-region";
          "C-c r a" = "lsp-execute-code-action";
          "C-c f r" = "lsp-find-references";
        };
      };
      init = ''
          (setq lsp-keymap-prefix "C-c l")
        '';
      config = ''
          (setq lsp-diagnostics-provider :flycheck
                lsp-eldoc-render-all nil
                lsp-headerline-breadcrumb-enable nil
                lsp-modeline-code-actions-enable nil
                lsp-modeline-diagnostics-enable nil
                lsp-modeline-workspace-status-enable nil)
          (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
        '';
    };

    lsp-treemacs = {
      enable = true;
      command = ["lsp-treemacs-errors-list"];
    };

    company = {
      enable = true;
      extraConfig = ''
        :bind (("M-/" . company-complete)
               :map company-active-map
               ("C-p" . company-select-previous)
               ("C-n" . company-select-next)
               ("<tab>" . company-complete-common-or-cycle))
        :custom
        (company-idle-delay 0)
        (company-echo-delay 0)
        (company-minimum-prefix-length 0)
        (company-tooltip-limit 12)
        (company-tooltip-align-annotations t)
        (company-show-numbers t)
        (company-dabbrev-downcase nil)
        (company-dabbrev-ignore-case t)
      '';
    };

    company-lsp = {
      enable = true;
      after = ["company-mode"];
      config = ''
  (company-lsp-cache-candidates nil)
  (company-lsp-async t)
  (company-lsp-enable-recompletion t)
'';
    };

    dap-mode = {
      enable = true;
      after = ["lsp-mode"];
      config = ''
        (dap-mode t)
        ;;(dap-ui-mode t)
      '';
    };
  };
}
