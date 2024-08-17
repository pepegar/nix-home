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
    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
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
    pkgs.vimPlugins.nvim-spectre
    pkgs.vimPlugins.neoformat
    pkgs.vimPlugins.oil-nvim
    pkgs.vimPlugins.autoclose-nvim
    pkgs.vimPlugins.nvim-ts-autotag
    pkgs.vimPlugins.neogit

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
  gitsignsConfig = wrapLuaConfig (builtins.readFile ./gitsigns.lua);
  troubleConfig = wrapLuaConfig (builtins.readFile ./trouble.lua);
  undotreeConfig = wrapLuaConfig (builtins.readFile ./undotree.lua);
  neoformatConfig = wrapLuaConfig (builtins.readFile ./neoformat.lua);
  oilConfig = wrapLuaConfig (builtins.readFile ./oil.lua);
  autotagConfig = wrapLuaConfig (builtins.readFile ./autotag.lua);
  autocloseConfig = wrapLuaConfig (builtins.readFile ./autoclose.lua);
  neogitConfig = wrapLuaConfig (builtins.readFile ./neogit.lua);
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
      + lualineConfig + lspConfig + gitsignsConfig + troubleConfig
      + undotreeConfig + neoformatConfig + oilConfig + autotagConfig
      + autocloseConfig + neogitConfig;
  };
}
