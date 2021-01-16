{...}: {

  imports = [
    ./nix
    ./scala
    ./python
  ];

  programs.emacs.init.usePackage = {

    smartparens.enable = true;
    smartparens.config = "(require 'smartparens-config)";

    flycheck.enable = true;
    flycheck.config = ''
      (require 'pkg-info)
    '';

    company = {
      enable = true;
      extraConfig = ''
        :general
        (:keymaps 'company-active-map
          "C-n" 'company-select-next
          "C-p" 'company-select-previous)
      '';
    };

    yasnippet.enable = true;
    yasnippet.defer = true;

    lsp-ui = {
      enable = true;
      config = ''
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-include-signture t)
  (lsp-ui-doc-position 'top)
  (lsp-ui-sideline-enable nil)
'';
      command = ["lsp-ui-mode"];
    };


    lsp-mode = {
      enable = true;
      hook = [
        "(lsp-mode . lsp-enable-which-key-integration)"
      ];
      command = ["lsp"];
    };

    lsp-treemacs = {
      enable = true;
      command = ["lsp-treemacs-errors-list"];
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

  };
}
