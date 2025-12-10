{lib, ...}:
with lib; {
  programs.emacs.init.usePackage = {
    nix-mode = {
      enable = true;
      mode = [''"\\.nix\\'"''];
    };

    company-nixos-options = {
      enable = true;
      command = ["company-nixos-options"];
      after = ["company"];
      config = ''
        (add-to-list 'company-backends 'company-nixos-options)
      '';
    };

    smartparens.hook = ["(nix-mode . smartparens-mode)"];
    smartparens.config = mkAfter ''
      (sp-with-modes 'nix-mode
        (sp-local-pair "[ " " ]")
        (sp-local-pair "{ " " }")
        (sp-local-pair "( " " )"))
    '';
  };
}
