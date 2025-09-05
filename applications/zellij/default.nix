{pkgs, ...}: {
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh.shellAliases = with pkgs; {
    zr = "${zellij}/bin/zellij run -- $@";
    zrf = "${zellij}/bin/zellij run -f -- $@";
  };
}
