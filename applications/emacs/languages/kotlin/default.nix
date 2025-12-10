{...}: {
  programs.emacs.init.usePackage = {
    kotlin-mode = {
      enable = true;
      mode = [''("\\.kt\\'" . kotlin-mode)'' ''("\\.kts\\'" . kotlin-mode)''];
    };

    gradle-mode.enable = true;
  };
}
