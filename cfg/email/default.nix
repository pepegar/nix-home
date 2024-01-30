{ ... }:

{
  accounts.email = {
    maildirBasePath = "Mail";
    # certificatesFile = "${builtins.getEnv "HOME"}/.nix-profile/etc/ssl/certs/ca-bundle.crt";

    accounts = { pepegar = { address = "pepe@pepegar.com"; }; };
  };

  home.file.".gnus.el".source = ./gnus.el;
}
