{ pkgs, ... }:

{
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    verbose = true;
    sshKeys = ["80E02EE85A7D07C506F2D5AE512234A2490E6842"];

    extraConfig = ''
      allow-emacs-pinentry
      allow-loopback-pinentry
    '';

  };
}
