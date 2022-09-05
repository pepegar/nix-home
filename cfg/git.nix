{ pkgs, ... }:

{
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Pepe García";
    userEmail = "pepe@pepegar.com";

    extraConfig = {
      github = { user = "pepegar"; };

      alias = {
        lg =
          "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };

      ghq.root = "~/projects";

      init.defaultBranch = "main";

      rerere.enabled = true;
    };
  };
}
