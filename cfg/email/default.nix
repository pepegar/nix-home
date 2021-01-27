{ pkgs, ... }:

let
  gpgKey = "BC10F5DA684B5E5978B836CCB32204E4B8C00747";
in {
  programs.mbsync = {
    enable = true;
  };

  programs.msmtp = {
    enable = true;
  };

  accounts.email = {
    maildirBasePath = "Mail";
    # certificatesFile = "${builtins.getEnv "HOME"}/.nix-profile/etc/ssl/certs/ca-bundle.crt";

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
          key = gpgKey;
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
          key = gpgKey;
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
