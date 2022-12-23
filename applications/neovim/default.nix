{ pkgs, ... }:

let
  myVimPlugins = with pkgs.vimPlugins; [
    telescope-nvim
    nvim-treesitter
    rose-pine
    dhall-vim # Syntax highlighting for Dhall lang
    emmet-vim
    multiple-cursors # Multiple cursors selection, etc
    nerdcommenter # code commenter
    nerdtree # tree explorer
    rainbow_parentheses-vim # for nested parentheses
    tabular
    vim-css-color # preview css colors
    vim-devicons # dev icons shown in the tree explorer
    vim-easy-align # alignment plugin
    vim-easymotion # highlights keys to move quickly
    vim-fish # fish shell highlighting
    vim-fugitive # git plugin
    vim-javascript
    vim-markdown
    vim-nix # nix support (highlighting, etc)
    vim-repeat # repeat plugin commands with (.)
    vim-rhubarb
    vim-scala # scala plugin
    vim-sensible
    vim-surround # quickly edit surroundings (brackets, html tags, etc)
    vim-tmux # syntax highlighting for tmux conf file and more
  ];

  wrapLuaConfig = str: ''
    lua << EOF
    ${str}
    EOF
  '';

  treesitterConfig = wrapLuaConfig (builtins.readFile ./treesitter.lua);
  telescopeConfig = wrapLuaConfig (builtins.readFile ./telescope.lua);
  basicsConfig = wrapLuaConfig (builtins.readFile ./basics.lua);
  fugitiveConfig = wrapLuaConfig (builtins.readFile ./fugitive.lua);
in {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    plugins = myVimPlugins;
    extraConfig = basicsConfig + treesitterConfig + telescopeConfig
      + fugitiveConfig;
  };
}
