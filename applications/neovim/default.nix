{ pkgs, ... }:


{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    extraPython3Packages = (ps: with ps; [ python-language-server ]);
    package = pkgs.neovim-unwrapped;
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
      vim-easy-align
      vim-javascript
      nerdtree
      nerdcommenter
      emmet-vim
      fzf-vim
      vim-nix
      coc-nvim
    ];

    extraConfig = ''
      " basic config {{{
      set hidden
      let mapleader=" "
      set mouse=a
      
      set expandtab
      
      nnoremap <down> <C-W><C-J>
      nnoremap <up> <C-W><C-K>
      nnoremap <right> <C-W><C-L>
      nnoremap <left> <C-W><C-H>
      
      nnoremap <leader>ev :vsplit ~/.config/nvim/init.vim<cr>
      nnoremap <leader>ag :Ag<cr>
      
      nnoremap <C-p> :FZF<cr>
      let $FZF_DEFAULT_COMMAND='ag -g ""'
      
      " if hidden is not set, TextEdit might fail.
      set hidden
      
      " Some servers have issues with backup files, see #649
      set nobackup
      set nowritebackup
      
      " Better display for messages
      set cmdheight=2
      
      " You will have bad experience for diagnostic messages when it's default 4000.
      set updatetime=300
      
      " don't give |ins-completion-menu| messages.
      set shortmess+=c
      
      " always show signcolumns
      set signcolumn=yes
      
      map <C-n> :NERDTreeToggle<CR>



      inoremap " ""<left>
      inoremap \' \'\'<left>
      inoremap ` ``<left>
      inoremap ( ()<left>
      inoremap [ []<left>
      inoremap { {}<left>
      inoremap {<CR> {<CR>}<ESC>O
      inoremap {;<CR> {<CR>};<ESC>O
      " }}}
      " ctrlp {{{
      let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']
      " }}}
      " appearance {{{
      set encoding=UTF-8
      
      set foldmethod=marker
      
      if strftime('%H') >= 7 && strftime('%H') < 19
        set background=light
        let g:airline_theme='snow_light'
      
      else
        set background=dark
        let g:airline_theme='snow_dark'
      endif
      colorscheme snow
      
      set relativenumber
      " }}}
      " folding {{{
      nnoremap <tab> za
      " }}}
      " Git {{{
      nnoremap <leader>gs :Gstatus<cr>
      " }}}
      " Markdown {{{
      au FileType markdown vmap <Leader><Bslash> :EasyAlign*<Bar><Enter>
      " }}}
      " coc.nvim {{{

      " Use tab for trigger completion with characters ahead and navigate.
      " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
      inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
      
      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction
      
      " Use <c-space> to trigger completion.
      inoremap <silent><expr> <c-space> coc#refresh()
      
      " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
      " Coc only does snippet and additional edit on confirm.
      inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
      
      " Use `[g` and `]g` to navigate diagnostics
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)
      
      " Remap keys for gotos
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)
      
      " Use K to show documentation in preview window
      nnoremap <silent> K :call <SID>show_documentation()<CR>
      
      function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
          execute 'h '.expand('<cword>')
        else
          call CocAction('doHover')
        endif
      endfunction
      
      " Highlight symbol under cursor on CursorHold
      autocmd CursorHold * silent call CocActionAsync('highlight')
      
      " Remap for rename current word
      nmap <leader>rn <Plug>(coc-rename)
      
      " Remap for format selected region
      xmap <leader>f  <Plug>(coc-format-selected)
      nmap <leader>f  <Plug>(coc-format-selected)
      
      augroup mygroup
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
      augroup end
      
      " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
      xmap <leader>a  <Plug>(coc-codeaction-selected)
      nmap <leader>a  <Plug>(coc-codeaction-selected)
      
      " Remap for do codeAction of current line
      nmap <leader>ac  <Plug>(coc-codeaction)
      " Fix autofix problem of current line
      nmap <leader>qf  <Plug>(coc-fix-current)
      
      " Create mappings for function text object, requires document symbols feature of languageserver.
      xmap if <Plug>(coc-funcobj-i)
      xmap af <Plug>(coc-funcobj-a)
      omap if <Plug>(coc-funcobj-i)
      omap af <Plug>(coc-funcobj-a)
      
      " Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
      nmap <silent> <C-d> <Plug>(coc-range-select)
      xmap <silent> <C-d> <Plug>(coc-range-select)
      
      " Use `:Format` to format current buffer
      command! -nargs=0 Format :call CocAction('format')
      
      " Use `:Fold` to fold current buffer
      command! -nargs=? Fold :call     CocAction('fold', <f-args>)
      
      " use `:OR` for organize import of current buffer
      command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
      
      " Add status line support, for integration with other plugin, checkout `:h coc-status`
      set statusline^=%{coc#status()}%{get(b:,'coc_current_function',\'\')}
      
      " Using CocList
      " Show all diagnostics
      nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
      " Manage extensions
      nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
      " Show commands
      nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
      " Find symbol of current document
      nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
      " Search workspace symbols
      nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
      " Do default action for next item.
      nnoremap <silent> <space>j  :<C-u>CocNext<CR>
      " Do default action for previous item.
      nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
      " Resume latest coc list
      nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
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
      '';
  };
}
