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
      packHostTunnelConsul = name : packHost name // {
        extraOptions = {
          "LocalForward" = "localhost:8500 consul.service.consul:8500";
        };
      };
      packHostTunnelMongo = name : packHost name // {
        extraOptions = {
          "LocalForward" = "localhost:27017 mongo.service.consul:27017";
        };
      };
    in {
        # all these require VPN
        ops = packHost "ops";
        xteam = packHost "xteamqa";
        fraggle = packHost "fraggleteamqa";
        lemmings = packHost "lemmingsteamqa";
        gremlin = packHost "gremlin";
        ops-mongo = packHostTunnelMongo "ops";
        xteam-mongo = packHostTunnelMongo "xteamqa";
        fraggle-mongo = packHostTunnelMongo "fraggleteamqa";
        lemmings-mongo = packHostTunnelMongo "lemmingsteamqa";
        gremlin-mongo = packHostTunnelMongo "gremlin";
        ops-consul = packHostTunnelConsul "ops";
        xteam-consul = packHostTunnelConsul "xteamqa";
        fraggle-consul = packHostTunnelConsul "fraggleteamqa";
        lemmings-consul = packHostTunnelConsul "lemmingsteamqa";
        gremlin-consul = packHostTunnelConsul "gremlin";

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
