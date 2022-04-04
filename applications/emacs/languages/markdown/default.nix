{ pkgs, ... }:
let font = "PragmataPro Mono Liga";
in {
  programs.emacs.init.usePackage = {
    markdown-mode = {
      enable = true;
      config = ''
        ; (defun md-reset-face (face)
        ;   (let* ((font-name "${font}")
        ;          (font-size "12")
        ;          (font-str (concat font-name "-" font-size)))
        ;     (set-face-attribute face nil
        ;                         :font font-str
        ;                         :inherit 'fixed-pitch
        ;                         :weight 'light)))
        ; (md-reset-face 'markdown-code-face)
        ; (md-reset-face 'markdown-language-keyword-face)
        ; (md-reset-face 'markdown-pre-face)

        (setq
           markdown-command "${pkgs.pandoc}/bin/pandoc"
           markdown-fontify-code-blocks-natively t)
      '';
    };

    pandoc-mode = {
      enable = true;
      after = [ "markdown-mode" ];
    };

  };

}
