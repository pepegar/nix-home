{...}: {

  imports = [
    ./nix
    ./scala
    ./python
    ./org
  ];

  programs.emacs.init.usePackage = {

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
      command = ["lsp-ui-mode"];
      extraConfig = ''
       :custom
       (lsp-ui-doc-enable t)
       (lsp-ui-doc-include-signture t)
       (lsp-ui-doc-position 'top)
       (lsp-ui-sideline-enable nil)
     '';
    };

    lsp-mode = {
      enable = true;
      hook = [
        "(lsp-mode . lsp-enable-which-key-integration)"
      ];
      command = ["lsp"];
      extraConfig = ''
        :custom
        (lsp-prefer-flymake t)
        (lsp-enable-snippet nil)
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
