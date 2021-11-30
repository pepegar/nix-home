{ pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = { initExtra = builtins.readFile ./zshrc; };
}
