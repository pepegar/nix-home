{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;

    history = {
      expireDuplicatesFirst = true;
      extended = true;
      save = 100000;
      size = 100000;
    };

    defaultKeymap = "emacs";

    oh-my-zsh = {
      enable = true;
      plugins = ["git"];
      theme = "powerlevel9k/powerlevel9k";
      custom = "$HOME/.oh-my-zsh/custom";
    };

    localVariables = {
      POWERLEVEL9K_PROMPT_ON_NEWLINE = true;
      POWERLEVEL9K_PROMPT_ADD_NEWLINE = true;
      POWERLEVEL9K_SHORTEN_STRATEGY = "truncate_middle";
      POWERLEVEL9K_VCS_SHORTEN_LENGTH = 4;
      POWERLEVEL9K_VCS_SHORTEN_MIN_LENGTH = 11;
      POWERLEVEL9K_VCS_SHORTEN_STRATEGY = "truncate_middle";
      POWERLEVEL9K_VCS_SHORTEN_DELIMITER = "..";
    };

    plugins = [
      {
        name = "z";
        file = "z.sh";
        src = pkgs.fetchFromGitHub {
          owner = "rupa";
          repo = "z";
          rev = "v1.9";
          sha256 = "1h0yk0sbv9d571sfkg97wi5q06cpxnhnvh745dlpazpgqi1vb1a8";
        };
      }
    ];
  };

  home.file.".oh-my-zsh/custom/themes/powerlevel9k" = {
    source = ../../powerlevel9k;
    recursive = true;
  };
}
