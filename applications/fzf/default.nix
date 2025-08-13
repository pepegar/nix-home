{...}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.zsh = {initContent = builtins.readFile ./fzf-config.sh;};
}
