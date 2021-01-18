{...}:

{
  programs.emacs.init.usePackage = {
    rust-mode.enable = true;

    lsp-rust = {
      enable = true;
      defer = true;
      hook = [
        ''
            (rust-mode . (lambda ()
                           (direnv-update-environment)
                           (lsp)))
          ''
      ];
    };

  };
}
