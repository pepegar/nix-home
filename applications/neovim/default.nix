{ pkgs, ... }:

let
  custom-plugins = pkgs.callPackage ./custom-plugins.nix {
    inherit (pkgs.vimUtils) buildVimPlugin;
    inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;
    inherit pkgs;
  };

  myVimPlugins = [
    custom-plugins.LuaSnip
    custom-plugins.lsp-zero
    custom-plugins.mason-lspconfig-nvim
    custom-plugins.mason-nvim
    pkgs.vimPlugins.cmp-buffer
    pkgs.vimPlugins.cmp-nvim-lsp
    pkgs.vimPlugins.cmp-nvim-lua
    pkgs.vimPlugins.cmp-path
    pkgs.vimPlugins.cmp_luasnip
    pkgs.vimPlugins.dhall-vim
    pkgs.vimPlugins.emmet-vim
    pkgs.vimPlugins.friendly-snippets
    pkgs.vimPlugins.multiple-cursors
    pkgs.vimPlugins.nerdcommenter
    pkgs.vimPlugins.nerdtree
    pkgs.vimPlugins.nvim-cmp
    pkgs.vimPlugins.nvim-lspconfig
    pkgs.vimPlugins.nvim-treesitter
    pkgs.vimPlugins.rainbow_parentheses-vim
    pkgs.vimPlugins.rose-pine
    pkgs.vimPlugins.tabular
    pkgs.vimPlugins.telescope-nvim
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
  lspZeroConfig = wrapLuaConfig (builtins.readFile ./lsp-zero.lua);
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
      + lspZeroConfig + fugitiveConfig;
  };
}
