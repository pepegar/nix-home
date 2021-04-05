{ ... }: {
  programs.emacs.init.usePackage = {

    web-mode = {
      enable = true;
      mode = [
        ''"\\.html\\'"''
        ''"\\.phtml\\'"''
        ''"\\.tpl\\.php\\'"''
        ''"\\.[agj]sp\\'"''
        ''"\\.as[cp]x\\'"''
        ''"\\.erb\\'"''
        ''"\\.mustache\\'"''
        ''"\\.djhtml\\'"''
      ];
    };

    emmet-mode.enable = true;
  };
}
