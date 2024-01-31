{ pkgs, ... }:

{
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Pepe García";
    userEmail = "pepe@pepegar.com";
    difftastic.enable = true;

    extraConfig = {
      github = { user = "pepegar"; };

      alias = {
        lg =
          "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        ignore =
          "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";

        br =
          "branch --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) %(color:green)(%(committerdate:relative)) [%(authorname)]' --sort=-committerdate";
      };

      ghq.root = "~/projects";

      init.defaultBranch = "main";

      rerere.enabled = true;

      push.autoSetupRemote = true;
    };

    signing = {
      key = "BC10F5DA684B5E5978B836CCB32204E4B8C00747";
      signByDefault = true;
    };
  };
}
