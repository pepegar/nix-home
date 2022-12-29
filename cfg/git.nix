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
        ignore =
          "!gi() { curl -sL https://www.toptal.com/developers/gitignore/api/$@ ;}; gi";
      };

      ghq.root = "~/projects";

      init.defaultBranch = "main";

      rerere.enabled = true;

      user.signingkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQcERc9nlqCFCr5qTufWYBeAmkSKdnlf0ZdmKqFNAvX";

      gpg.format = "ssh";

      "gpg \"ssh\"" = {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };

      commit.gpgsign = true;

    };
  };
}
