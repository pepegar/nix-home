{
  config,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
  };

  home.file."${config.xdg.configHome}/nvim/init.lua".source = lib.mkForce ./init.lua;
  home.file."${config.xdg.configHome}/nvim/lua" = {
    source = ./lua;
    recursive = true;
  };
}
