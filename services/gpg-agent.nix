{ pkgs, ... }:

{
  services.gpg-agent = {
    enable = true;
    verbose = true;

    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';

  };
}
