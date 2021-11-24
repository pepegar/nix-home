{ pkgs, ...}:

{
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Pepe García";
    userEmail = "pepe@pepegar.com";

    signing = {
      gpgPath = "${pkgs.gnupg}/bin/gpg";
      key = "B32204E4B8C00747";
      signByDefault = true;
    };

    extraConfig = {
      github = {
        user = "pepegar";
      };

      alias = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };

      ghq.root = "~/projects";

      rerere.enabled = true;
    };
  };
}
