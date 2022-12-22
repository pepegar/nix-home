{ pkgs, ... }:

let
  custom-plugins = pkgs.callPackage ./custom-plugins.nix {
    inherit (pkgs.vimUtils) buildVimPlugin;
  };

  plugins = pkgs.vimPlugins // custom-plugins;

  overriddenPlugins = with pkgs; [ ];

  myVimPlugins = with plugins;
    [
      asyncrun-vim # run async commands, show result in quickfix window
      cmp-buffer
      cmp-cmdline
      cmp-nvim-lsp
      cmp-path
      cmp-vsnip
      ctrlsf-vim # edit file in place after searching with ripgrep
      dhall-vim # Syntax highlighting for Dhall lang
      emmet-vim
      fzf-hoogle # search hoogle with fzf
      fzf-vim # fuzzy finder
      multiple-cursors # Multiple cursors selection, etc
      neomake # run programs asynchronously and highlight errors
      nerdcommenter # code commenter
      nerdtree # tree explorer
      nord-vim
      nvim-cmp
      nvim-lspconfig
      quickfix-reflector-vim # make modifications right in the quickfix window
      rainbow_parentheses-vim # for nested parentheses
      tabular
      tender-vim # a clean dark theme
      vim-airline # bottom status bar
      vim-airline-themes
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
      vim-vsnip
    ] ++ overriddenPlugins;
in {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
    plugins = myVimPlugins;
    extraConfig = ''
      " basic config {{{
      set hidden
      set ignorecase
      set mouse=a
      set cursorline
      set expandtab
      let mapleader=" "

      nnoremap ; :

      nnoremap <down> <C-W><C-J>
      nnoremap <up> <C-W><C-K>
      nnoremap <right> <C-W><C-L>
      nnoremap <left> <C-W><C-H>

      nnoremap <leader>ag :Ag<cr>

      nnoremap <C-p> :FZF<cr>
      let $FZF_DEFAULT_COMMAND='ag -g ""'

      " if hidden is not set, TextEdit might fail.
      set hidden

      " Some servers have issues with backup files, see #649
      set nobackup
      set nowritebackup

      " You will have bad experience for diagnostic messages when it's default 4000.
      set updatetime=300

      " don't give |ins-completion-menu| messages.
      set shortmess+=c

      " always show signcolumns
      set signcolumn=yes

      map <C-n> :NERDTreeToggle<CR>
      " }}}
      " fzf {{{
      nnoremap <C-p> :Files<cr>
      nnoremap <C-b> :Buffers<cr>
      nnoremap <C-g> :Commits<cr>
      " }}}
      " appearance {{{
      set termguicolors
      set encoding=UTF-8
      set foldmethod=marker
      set relativenumber

      syntax on

      lua vim.cmd('colorscheme nord')
      " }}}
      " folding {{{
      nnoremap <tab> za
      " }}}
      " Git {{{
      nnoremap <leader>gs :Git<cr>
      " }}}
      " Markdown {{{
      au FileType markdown vmap <Leader><Bslash> :EasyAlign*<Bar><Enter>
      " }}}
      " js {{{
      augroup javascript_folding
          au!
          au FileType javascript setlocal foldmethod=syntax
      augroup END

      set conceallevel=1

      autocmd FileType javascript setlocal ts=2 sts=2 sw=2
      " }}}
      " Haskell {{{
      autocmd FileType haskell setlocal ts=2 sts=2 sw=2
      " }}}
      " Scala {{{
      au BufRead,BufNewFile *.sbt set filetype=scala
      " }}}
      " Nvim-lspconfig {{{
      lua << EOF
      require'lspconfig'.pyright.setup{}
      require'lspconfig'.metals.setup{}
      require'lspconfig'.rls.setup{}
      require'lspconfig'.rnix.setup{}
      EOF


      nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
      nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
      nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
      nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
      nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
      nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
      " }}}
      " completions {{{
      set completeopt=menu,menuone,noselect

      lua <<EOF
        -- Setup nvim-cmp.
        local cmp = require'cmp'

        cmp.setup({
          snippet = {
            expand = function(args)
              vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            end,
          },
          mapping = {
            ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
            ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
            ['<C-e>'] = cmp.mapping({
              i = cmp.mapping.abort(),
              c = cmp.mapping.close(),
            }),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
          },
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'vsnip' }, -- For vsnip users.
            -- { name = 'luasnip' }, -- For luasnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
          }, {
            { name = 'buffer' },
          })
        })

        -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline('/', {
          sources = {
            { name = 'buffer' }
          }
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
          sources = cmp.config.sources({
            { name = 'path' }
          }, {
            { name = 'cmdline' }
          })
        })
      EOF
      " }}}
    '';
  };
}
