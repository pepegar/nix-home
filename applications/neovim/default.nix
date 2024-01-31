{ pkgs, ... }:

let
  custom-plugins = pkgs.callPackage ./custom-plugins.nix {
    inherit (pkgs.vimUtils) buildVimPlugin;
    inherit pkgs;
  };

  myVimPlugins = [
    pkgs.vimPlugins.octo-nvim
    pkgs.vimPlugins.emmet-vim
    pkgs.vimPlugins.multiple-cursors
    pkgs.vimPlugins.nerdcommenter
    pkgs.vimPlugins.nerdtree
    pkgs.vimPlugins.nvim-autopairs
    (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins:
      with plugins; [
        haskell
        javascript
        jsonnet
        kotlin
        lua
        nix
        python
        swift
        typescript
        yaml
        markdown
        html
      ]))
    custom-plugins.golden-size
    pkgs.vimPlugins.rose-pine
    pkgs.vimPlugins.tabular
    pkgs.vimPlugins.telescope-nvim
    custom-plugins.telescope-ghq
    pkgs.vimPlugins.telescope-frecency-nvim
    pkgs.vimPlugins.telescope-fzy-native-nvim
    pkgs.vimPlugins.trouble-nvim
    pkgs.vimPlugins.gitsigns-nvim
    pkgs.vimPlugins.lualine-nvim
    pkgs.vimPlugins.lualine-lsp-progress
    pkgs.vimPlugins.nvim-web-devicons
    pkgs.vimPlugins.rainbow-delimiters-nvim
    pkgs.vimPlugins.undotree
    pkgs.vimPlugins.vim-css-color
    pkgs.vimPlugins.vim-css-color
    pkgs.vimPlugins.vim-easy-align
    pkgs.vimPlugins.vim-easymotion
    pkgs.vimPlugins.vim-fish
    pkgs.vimPlugins.vim-fugitive
    pkgs.vimPlugins.vim-nix
    pkgs.vimPlugins.vim-repeat
    pkgs.vimPlugins.vim-rhubarb
    pkgs.vimPlugins.vim-sensible
    pkgs.vimPlugins.vim-surround

    custom-plugins.lsp-zero
    pkgs.vimPlugins.nvim-lspconfig
    custom-plugins.mason-nvim
    custom-plugins.mason-lspconfig-nvim
    pkgs.vimPlugins.nvim-cmp
    pkgs.vimPlugins.cmp-buffer
    pkgs.vimPlugins.cmp-path
    pkgs.vimPlugins.cmp_luasnip
    pkgs.vimPlugins.cmp-nvim-lsp
    pkgs.vimPlugins.cmp-nvim-lua
    custom-plugins.LuaSnip
    pkgs.vimPlugins.friendly-snippets
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
  #indentConfig = wrapLuaConfig (builtins.readFile ./indent.lua);
  autopairsConfig = wrapLuaConfig (builtins.readFile ./autopairs.lua);
  gitsignsConfig = wrapLuaConfig (builtins.readFile ./gitsigns.lua);
  troubleConfig = wrapLuaConfig (builtins.readFile ./trouble.lua);
  undotreeConfig = wrapLuaConfig (builtins.readFile ./undotree.lua);
  goldenSizeConfig = wrapLuaConfig (builtins.readFile ./golden-size.lua);
  octoConfig = wrapLuaConfig (builtins.readFile ./octo.lua);
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
      + fugitiveConfig + lualineConfig + lspConfig + autopairsConfig
      + gitsignsConfig + troubleConfig + undotreeConfig + goldenSizeConfig
      + octoConfig;
  };
}
