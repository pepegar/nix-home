{ pkgs, ... }:

{
  imports = [
    ./core.nix
    ./packages.nix
    ./editing.nix
    ./languages
    ./tools
  ];

  programs.emacs = {
    enable = true;
    init = {
      enable = true;
      recommendedGcSettings = true;
      earlyInit = ''
        ;; Disable some GUI distractions. We set these manually to avoid starting
        ;; the corresponding minor modes.
        (push '(menu-bar-lines . 0) default-frame-alist)
        (push '(tool-bar-lines . nil) default-frame-alist)
        (push '(vertical-scroll-bars . nil) default-frame-alist)

        (defun set-exec-path-from-shell-PATH ()
          "Set up Emacs' `exec-path' and PATH environment variable to match that used by the user's shell.

        This is particularly useful under Mac OSX, where GUI apps are not started from a shell."
          (interactive)
          (let ((path-from-shell (replace-regexp-in-string "[ \t\n]*$" "" (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
            (setenv "PATH" path-from-shell)
            (setq exec-path (split-string path-from-shell path-separator))))

        (set-exec-path-from-shell-PATH)


        ;; Set up fonts early.
        (set-face-attribute 'default
                            nil
                            :height 180
                            :family "Iosevka")
      '';

      prelude = ''
        (global-set-key (kbd "M-g a") "α")
        (global-set-key (kbd "M-g b") "β")
        (global-set-key (kbd "M-g g") "γ")
        (global-set-key (kbd "M-g d") "δ")
        (global-set-key (kbd "M-g e") "ε")
        (global-set-key (kbd "M-g z") "ζ")
        (global-set-key (kbd "M-g h") "η")
        (global-set-key (kbd "M-g q") "θ")
        (global-set-key (kbd "M-g i") "ι")
        (global-set-key (kbd "M-g k") "κ")
        (global-set-key (kbd "M-g l") "λ")
        (global-set-key (kbd "M-g m") "μ")
        (global-set-key (kbd "M-g n") "ν")
        (global-set-key (kbd "M-g x") "ξ")
        (global-set-key (kbd "M-g o") "ο")
        (global-set-key (kbd "M-g p") "π")
        (global-set-key (kbd "M-g r") "ρ")
        (global-set-key (kbd "M-g s") "σ")
        (global-set-key (kbd "M-g t") "τ")
        (global-set-key (kbd "M-g u") "υ")
        (global-set-key (kbd "M-g f") "ϕ")
        (global-set-key (kbd "M-g j") "φ")
        (global-set-key (kbd "M-g c") "χ")
        (global-set-key (kbd "M-g y") "ψ")
        (global-set-key (kbd "M-g w") "ω")
        (global-set-key (kbd "M-g A") "Α")
        (global-set-key (kbd "M-g B") "Β")
        (global-set-key (kbd "M-g G") "Γ")
        (global-set-key (kbd "M-g D") "Δ")
        (global-set-key (kbd "M-g E") "Ε")
        (global-set-key (kbd "M-g Z") "Ζ")
        (global-set-key (kbd "M-g H") "Η")
        (global-set-key (kbd "M-g Q") "Θ")
        (global-set-key (kbd "M-g I") "Ι")
        (global-set-key (kbd "M-g K") "Κ")
        (global-set-key (kbd "M-g L") "Λ")
        (global-set-key (kbd "M-g M") "Μ")
        (global-set-key (kbd "M-g N") "Ν")
        (global-set-key (kbd "M-g X") "Ξ")
        (global-set-key (kbd "M-g O") "Ο")
        (global-set-key (kbd "M-g P") "Π")
        (global-set-key (kbd "M-g R") "Ρ")
        (global-set-key (kbd "M-g S") "Σ")
        (global-set-key (kbd "M-g T") "Τ")
        (global-set-key (kbd "M-g U") "Υ")
        (global-set-key (kbd "M-g F") "Φ")
        (global-set-key (kbd "M-g J") "Φ")
        (global-set-key (kbd "M-g C") "Χ")
        (global-set-key (kbd "M-g Y") "Ψ")
        (global-set-key (kbd "M-g W") "Ω")
      '';
    };
  };
}
