{ pkgs, ...}:

{
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Pepe García";
    userEmail = "pepe@pepegar.com";

    signing = {
      key = "6230C44BA0B0FF6608D87F2CC4165E53FFD5B1C6";
      signByDefault = true;
    };

    extraConfig = {
      github = {
        user = "pepegar";
      };
    };
  };
}
