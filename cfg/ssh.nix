{ lib, pkgs, ... }:

let
  inherit (builtins) listToAttrs flatten;
  packHost = name: {
    hostname = "${name}-bastion01.packitos.com";
    port = 22822;
    user = "packdev";
    identityFile = "~/.ssh/packlink";
  };
  localForward = name: domain: port:
    packHost name // {
      extraOptions = {
        LocalForward = "localhost:${port} ${domain}:${port}";
        RequestTTY = "no";
      };
    };
  packHostTunnelConsul = name: localForward name "consul.service.consul" "8500";
  packHostTunnelMongo = name: localForward name "mongo.service.consul" "27017";
  packHostTunnelMysql = name: localForward name "percona.service.consul" "3306";
  packHostTunnelRedis = name: localForward name "redis.service.consul" "6379";
  blocksPerHost = [
    {
      name = (x: x);
      fn = packHost;
    }
    {
      name = (x: x + "-consul");
      fn = packHostTunnelConsul;
    }
    {
      name = (x: x + "-mongo");
      fn = packHostTunnelMongo;
    }
    {
      name = (x: x + "-mysql");
      fn = packHostTunnelMysql;
    }
    {
      name = (x: x + "-redis");
      fn = packHostTunnelRedis;
    }
  ];
  environments = [ "xteamqa" "fraggleteamqa" "ops" "gremlin" "lemmingsteamqa" ];
  blocks = (listToAttrs ((lib.flatten (map (env:
    (map (b: {
      name = b.name env;
      value = b.fn env;
    }) blocksPerHost)) environments)) ++ [{
      name = "keychain";
      value = {
        host = "*";
        extraOptions = {
          "UseKeychain" = "yes";
          "AddKeysToAgent" = "yes";
          "IgnoreUnknown" = "UseKeychain";
        };
      };
    }]));
in {
  programs.ssh = {
    enable = true;
    compression = true;
    matchBlocks = blocks;
  };
}
