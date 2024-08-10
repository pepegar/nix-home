{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh.initExtra = ''
    eval "$(${pkgs.zellij}/bin/zellij setup --generate-completion zsh | tail -n13)"
  '';

  home.file.".config/zellij/config.kdl".source = ./config.kdl;
}
