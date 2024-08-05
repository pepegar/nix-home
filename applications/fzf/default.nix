{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.zsh = { initExtra = builtins.readFile ./zshrc; };
}
