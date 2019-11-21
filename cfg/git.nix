{ pkgs, ...}:

{
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Pepe García";
    userEmail = "pepe@pepegar.com";

    extraConfig = {
      github = {
        user = "pepegar";
      };
    };
  };
}
