{config, ...}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
  };

  home.file."${config.xdg.configHome}/nvim/init.lua".source = ./init.lua;
  home.file."${config.xdg.configHome}/nvim/lua" = {
    source = ./lua;
    recursive = true;
  };
}
