{ pkgs, ... }:

let
  #custom-plugins = pkgs.callPackage ./custom-plugins.nix {
  #inherit (pkgs.vimUtils) buildVimPlugin;
  #inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;
  #inherit pkgs;
  #};

  myVimPlugins = [
    pkgs.vimPlugins.dhall-vim
    pkgs.vimPlugins.emmet-vim
    pkgs.vimPlugins.multiple-cursors
    pkgs.vimPlugins.nerdcommenter
    pkgs.vimPlugins.nerdtree
    pkgs.vimPlugins.nvim-treesitter
    pkgs.vimPlugins.rainbow_parentheses-vim
    pkgs.vimPlugins.rose-pine
    pkgs.vimPlugins.tabular
    pkgs.vimPlugins.telescope-nvim
    pkgs.vimPlugins.lualine-nvim
    pkgs.vimPlugins.lualine-lsp-progress
    pkgs.vimPlugins.nvim-web-devicons
    pkgs.vimPlugins.vim-css-color
    pkgs.vimPlugins.vim-devicons
    pkgs.vimPlugins.vim-easy-align
    pkgs.vimPlugins.vim-easymotion
    pkgs.vimPlugins.vim-fish
    pkgs.vimPlugins.vim-fugitive
    pkgs.vimPlugins.vim-gitgutter
    pkgs.vimPlugins.vim-javascript
    pkgs.vimPlugins.vim-markdown
    pkgs.vimPlugins.vim-nix
    pkgs.vimPlugins.vim-repeat
    pkgs.vimPlugins.vim-rhubarb
    pkgs.vimPlugins.vim-sensible
    pkgs.vimPlugins.vim-surround
  ];

  wrapLuaConfig = str: ''
    lua << EOF
    ${str}
    EOF
  '';

  treesitterConfig = wrapLuaConfig (builtins.readFile ./treesitter.lua);
  lualineConfig = wrapLuaConfig (builtins.readFile ./lualine.lua);
  lspConfig = wrapLuaConfig (builtins.readFile ./lsp.lua);
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
      + fugitiveConfig + lualineConfig + lspConfig;
  };
}
