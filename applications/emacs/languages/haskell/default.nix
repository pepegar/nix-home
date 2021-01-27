{ ... }:

{
  programs.emacs.init.usePackage = {
    lsp-haskell = {
      enable = true;
      defer = true;
      hook = [''
        (haskell-mode . lsp-deferred)
      ''];
    };

    haskell-mode = {
      enable = true;
      mode = [
        ''("\\.hs\\'" . haskell-mode)''
        ''("\\.hsc\\'" . haskell-mode)''
        ''("\\.c2hs\\'" . haskell-mode)''
        ''("\\.cpphs\\'" . haskell-mode)''
        ''("\\.lhs\\'" . haskell-literate-mode)''
      ];
      hook = [ "(haskell-mode . subword-mode)" ];
      config = ''
        (setq tab-width 2)

        (setq haskell-process-log t
              haskell-notify-p t)

        (setq haskell-process-args-cabal-repl
              '("--ghc-options=+RTS -M500m -RTS -ferror-spans -fshow-loaded-modules"))
      '';
    };

    haskell-cabal = {
      enable = true;
      mode = [ ''("\\.cabal\\'" . haskell-cabal-mode)'' ];
      bindLocal = {
        haskell-cabal-mode-map = {
          "C-c C-c" = "haskell-process-cabal-build";
          "C-c c" = "haskell-process-cabal";
          "C-c C-b" = "haskell-interactive-bring";
        };
      };
    };

    haskell-doc = {
      enable = true;
      command = [ "haskell-doc-current-info" ];
    };
  };
}
