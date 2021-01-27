{ ... }: {

  programs.emacs.init.usePackage = {
    scala-mode = {
      enable = true;
      mode = [ ''"\\.s\\(cala\\|bt\\)$"'' ];
      extraConfig = ''
        :custom
        (scala-indent:align-forms t)
        (scala-indent:align-parameters t)
        (scala-indent:indent-value-expression t)
        (scala-indent:default-run-on-strategy)
        (scala-indent:operator-strategy)
      '';
    };

    sbt-mode = {
      enable = true;
      after = [ "scala-mode" ];
      command = [ "sbt-start" "sbt-command" ];
      config = ''
        (substitute-key-definition
         'minibuffer-complete-word
         'self-insert-command
         minibuffer-local-completion-map)
      '';
    };

    lsp-metals.enable = true;
  };

}
