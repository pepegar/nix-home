{...}: {
  programs.zellij = {
    enable = false;
  };

  home.file.".config/zellij/config.kdl".source = ./config.kdl;
}
