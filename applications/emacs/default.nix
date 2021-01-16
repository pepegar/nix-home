{ pkgs, ... }:

let
  nurNoPkgs = import (import ../../nix/sources.nix).nur { };
in {
  imports = [
    nurNoPkgs.repos.rycee.hmModules.emacs-init
    ./core.nix
    ./packages.nix
    ./languages
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

      ;; Set up fonts early.
      (set-face-attribute 'default
                          nil
                          :height 120
                          :family "PragmataPro Mono Liga")
      (set-face-attribute 'variable-pitch
                          nil
                          :family "DejaVu Sans")
      '';
    };
  };
}
