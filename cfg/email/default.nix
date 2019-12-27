{ pkgs, ... }:

{
  programs.mbsync = {
    enable = true;
  };

  programs.msmtp = {
    enable = true;
  };

  accounts.email = {
    maildirBasePath = "Mail";
    certificatesFile = "${builtins.getEnv "HOME"}/.nix-profile/etc/ssl/certs/ca-bundle.crt";

    accounts = {
      pepegar = {
        address = "pepe@pepegar.com";
        imap = {
          host = "mail.messagingengine.com";
          tls = {
            enable = true;
          };
        };
        smtp = {
          host = "mail.messagingengine.com";
          tls = {
            enable = true;
          };
        };
        gpg = {
          key = "A67385A8096851A724F21B995C5CABCB80FE4C7F";
          signByDefault = true;
        };
        mbsync = {
          enable = true;
          create = "maildir";
        };
        maildir.path = "pepegar";
        msmtp.enable = true;
        notmuch.enable = true;
        primary = true;
        realName = "Pepe García";
        passwordCommand = "${pkgs.pass}/bin/pass email/fastmail";
        userName = "pepe@pepegar.com";
      };

      fortysevendeg = {
        address = "pepe.garcia@47deg.com";
        flavor = "gmail.com";
        imap = {
          tls = {
            enable = true;
          };
        };
        smtp = {
          tls = {
            enable = true;
          };
        };
        gpg = {
          key = "A67385A8096851A724F21B995C5CABCB80FE4C7F";
          signByDefault = true;
        };
        mbsync = {
          enable = true;
          create = "maildir";
        };
        maildir.path = "47deg";
        msmtp.enable = true;
        notmuch.enable = true;
        primary = false;
        realName = "Pepe García";
        passwordCommand = "${pkgs.pass}/bin/pass email/47deg";
        userName = "pepe.garcia@47deg.com";
      };
    };
  };

  home.file.".gnus.el".source = ./gnus.el;
}
