{ pkgs, ... }:

{
  programs.emacs.init.usePackage = {
    rust-mode.enable = true;

    lsp-rust = {
      enable = true;
      extraPackages = [
        pkgs.rust-analyzer
      ];
      defer = true;
      hook = [ "(rust-mode . lsp-deferred)" ];
    };

  };
}
