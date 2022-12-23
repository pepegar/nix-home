require'nvim-treesitter.configs'.setup {
        ensure_installed = { "help", "javascript", "typescript", "kotlin", "lua", "rust", "nix", "haskell" },
        parser_install_dir = "~/.config/nvim-treesitter",

        sync_install = false,

        auto_install = true,

        highlight = {
                enable = true,

                additional_vim_regex_highlighting = false,
        },
}
vim.opt.runtimepath:append("~/.config/nvim-treesitter")
