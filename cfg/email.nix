{ pkgs, config, ... }:

{
  accounts.email.accounts.fastmail = {
    primary = true;

    address = "pepe@pepegar.com";
    passwordCommand = "${pkgs.pass}/bin/pass email/fastmail";
    realName = "Pepe Garcia";
    userName = "pepe@pepegar.com";

    imap = {
      host = "imap.fastmail.com";
      port = 993;
      tls.enable = true;
    };

    smtp = {
      host = "smtp.fastmail.com";
      port = 465;
      tls.enable = true;
    };

    mbsync = {
      enable = true;
      create = "maildir";
      expunge = "both";
      flatten = ".";
      patterns = [ "*" "!.*" ];

      extraConfig.local = {
        Subfolders = "Verbatim";
      };
    };

    msmtp = {
      enable = true;
    };
  };

  programs = {
    mbsync.enable = true;
    msmtp.enable = true;
  };

  services.mbsync.enable = true;
}
