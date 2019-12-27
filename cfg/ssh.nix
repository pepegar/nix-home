{ pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    compression = true;
    matchBlocks = let
      packHost = name : {
        hostname = "${name}-bastion01.packitos.com";
        port = 22822;
        user = "packdev";
      }; in {

        # all these require VPN
        xteam = packHost "xteamqa";
        fraggle = packHost "fraggleteamqa";
        lemmings = packHost "lemmingsteamqa";
        gremlin = packHost "gremlin";

        keychain = {
          host = "*";
          extraOptions = {
            "UseKeychain"    = "yes";
            "AddKeysToAgent" = "yes";
            "IgnoreUnknown"  = "UseKeychain";
          };
        };
      };
  };
}
