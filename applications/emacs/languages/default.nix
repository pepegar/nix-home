{ ... }: {

  imports = [
    ./haskell
    ./html
    ./kotlin
    ./markdown
    ./nix
    ./python
    ./restclient
    ./rust
    ./scala
    ./sparql
    ./yaml
  ];

  programs.emacs.init.usePackage = {

    rainbow-delimiters = {
      enable = true;
      hook = [ "(prog-mode . rainbow-delimiters-mode)" ];
    };

    smartparens.enable = true;
    smartparens.config = "(require 'smartparens-config)";

    yasnippet = {
      enable = true;
      defer = true;
      hook = [ "(after-init . yas-global-mode)" ];
    };

    yasnippet-snippets = {
      enable = true;
      after = [ "yasnippet" ];
    };

    flycheck = {
      enable = true;
      bind = {
        "M-n" = "flycheck-next-error";
        "M-p" = "flycheck-previous-error";
      };
      init = ''(setq ispell-program-name "aspell")'';
      config =
        "\n      (require 'pkg-info)\n      (global-flycheck-mode t)\n      ";
    };

    lsp-headerline = {
      enable = true;
      command = [ "lsp-headerline-breadcrumb-mode" ];
    };

    lsp-modeline = {
      enable = true;
      command = [ "lsp-modeline-workspace-status-mode " ];
    };

    lsp-mode = {
      enable = true;
      command = [ "lsp" "lsp-deferred" ];
      init = ''
        (setq lsp-keymap-prefix "C-c l")
      '';
      after = [ "company" "flycheck" ];
      hook = [
        "(lsp-mode . lsp-enable-which-key-integration)"
        "(lsp-mode . lsp-lens-mode)"
        "(scala-mode . lsp-deferred)"
        "(haskell-mode . lsp-deferred)"
        "(rust-mode . lsp-deferred)"
        "(kotlin-mode . lsp-deferred)"
        "(nix-mode . lsp)"
      ];
      config = ''
        (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
      '';
      bindLocal = {
        lsp-mode-map = {
          "C-c r r" = "lsp-rename";
          "C-c r f" = "lsp-format-buffer";
          "C-c r g" = "lsp-format-region";
          "C-c r a" = "lsp-execute-code-action";
          "C-c f r" = "lsp-find-references";
        };
      };
      extraConfig = ''
        :custom
        (lsp-prefer-flymake t)
        (lsp-diagnostics-provider :flycheck)
        (lsp-prefer-flymake nil)
        (lsp-file-watch-threshold 30000)
      '';
    };

    lsp-ui = {
      enable = true;
      command = [ "lsp-ui-mode" ];
      bindLocal = {
        lsp-mode-map = {
          "C-c r d" = "lsp-ui-doc-glance";
          "C-c f s" = "lsp-ui-find-workspace-symbol";
        };
      };
      extraConfig = ''
        :custom
        (lsp-ui-doc-enable t)
        (lsp-ui-doc-include-signture t)
        (lsp-ui-doc-position 'top)
        (lsp-ui-sideline-enable nil)
      '';
    };

    lsp-ui-flycheck = {
      enable = true;
      after = [ "flycheck" "lsp-ui" ];
    };

    lsp-diagnostics = {
      enable = true;
      after = [ "lsp-mode" ];
    };

    lsp-completion = {
      enable = true;
      after = [ "lsp-mode" ];
    };

    lsp-treemacs = {
      enable = true;
      after = [ "lsp-mode" ];
      command = [ "lsp-treemacs-errors-list" ];
    };

    swift-mode = {
      enable = true;
      mode = [ ''("\\.swift\\'" . swift-mode)'' ];
    };

    company = {
      enable = true;
      hook = [ "(after-init . global-company-mode)" ];
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

    company-capf = {
      enable = true;
      after = [ "company-mode" ];
      command = [ "company-capf" ];
    };

    company-lsp = {
      enable = true;
      after = [ "company-mode" "lsp-mode" ];
      config = ''
        (company-lsp-cache-candidates nil)
        (company-lsp-async t)
        (company-lsp-enable-recompletion t)
      '';
    };

    dap-mode = {
      enable = true;
      after = [ "lsp-mode" "dap-ui" "dap-mouse" ];
      command = [ "dap-mode" "dap-auto-configure-mode" ];
      config = ''
        (dap-auto-configure-mode)
      '';
    };

    dap-ui = {
      enable = true;
      command = [ "dap-ui-mode" ];
      config = ''
        (dap-ui-mode t)
      '';
    };

    dap-mouse = {
      enable = true;
      config = ''
        (dap-tooltip-mode t)
      '';
    };

    jsonnet-mode = {
      enable = true;
      mode = [ ''("\\.jsonnet\\'" . jsonnet-mode)'' ];
    };

    go-mode = {
      enable = true;
      mode = [ ''"\\.go\\'"'' ];
      hook = [ "(go-mode . lsp-deferred)" ];
    };

    dap-go.enable = true;

  };
}
