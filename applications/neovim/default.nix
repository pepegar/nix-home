{ pkgs, ... }:

let
  custom-plugins = pkgs.callPackage ./custom-plugins.nix {
    inherit (pkgs.vimUtils) buildVimPlugin;
    inherit pkgs;
  };

  myVimPlugins = [
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
        typescript
        yaml
        markdown
        html
        kdl
      ]))
    pkgs.vimPlugins.golden-ratio
    pkgs.vimPlugins.rose-pine
    pkgs.vimPlugins.tabular
    pkgs.vimPlugins.telescope-nvim
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
    pkgs.vimPlugins.lsp-zero-nvim
    pkgs.vimPlugins.nvim-lspconfig
    pkgs.vimPlugins.nvim-cmp
    pkgs.vimPlugins.cmp-buffer
    pkgs.vimPlugins.cmp-path
    pkgs.vimPlugins.cmp_luasnip
    pkgs.vimPlugins.cmp-nvim-lsp
    pkgs.vimPlugins.cmp-nvim-lua
    pkgs.vimPlugins.luasnip
    pkgs.vimPlugins.friendly-snippets

    custom-plugins.telescope-ghq
    custom-plugins.kdl
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
  autopairsConfig = wrapLuaConfig (builtins.readFile ./autopairs.lua);
  gitsignsConfig = wrapLuaConfig (builtins.readFile ./gitsigns.lua);
  troubleConfig = wrapLuaConfig (builtins.readFile ./trouble.lua);
  undotreeConfig = wrapLuaConfig (builtins.readFile ./undotree.lua);
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
      + gitsignsConfig + troubleConfig + undotreeConfig;
  };
}
