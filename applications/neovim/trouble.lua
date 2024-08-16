require("trouble").setup({})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics toggle<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>xd", "<cmd>Trouble document_diagnostics toggle<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", { silent = true, noremap = true })
vim.keymap.set("n", "gR", "<cmd>Trouble lsp_references toggle<cr>", { silent = true, noremap = true })
