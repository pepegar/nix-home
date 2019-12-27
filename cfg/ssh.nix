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
      };
      packHostTunnelMongo = name : packHost name // {
        extraOptions = {
          "LocalForward" = "27017 mongo.service.consul:27017";
        };
      };
    in {
        # all these require VPN
        xteam = packHost "xteamqa";
        fraggle = packHost "fraggleteamqa";
        lemmings = packHost "lemmingsteamqa";
        gremlin = packHost "gremlin";
        xteam-mongo = packHostTunnelMongo "xteamqa";
        fraggle-mongo = packHostTunnelMongo "fraggleteamqa";
        lemmings-mongo = packHostTunnelMongo "lemmingsteamqa";
        gremlin-mongo = packHostTunnelMongo "gremlin";

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
