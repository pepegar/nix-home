{ pkgs, ... }:


{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    /*extraConfig = builtins.readFile ./config.vim;*/
    plugins = with pkgs.vimPlugins; [
      jedi-vim
      deoplete-nvim
      vim-surround
      vim-fugitive
      vim-rhubarb
      ctrlp
      vim-airline
      haskell-vim
      vim-sensible
/*      ghcid-nvim*/
      vim-javascript
/*      vim-jsx-pretty*/
      nerdcommenter
      emmet-vim
      fzf-vim
/*      vim-rest-console*/
    ];
  };
}
