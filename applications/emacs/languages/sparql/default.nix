{ ... }: {
  programs.emacs.init.usePackage = {
    sparql-mode = {
      enable = true;
      mode = [ ''"\\.sparql$"'' ''"\\.rq$"'' ];
    };
  };
}
