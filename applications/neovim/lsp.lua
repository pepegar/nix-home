local lspzero = require("lsp-zero")

lspzero.preset("recommended")

lspzero.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, opts)
	vim.keymap.set("n", "gi", require("telescope.builtin").lsp_implementations, opts)
	vim.keymap.set("n", "gt", require("telescope.builtin").lsp_type_definitions, opts)
	vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts)
	--vim.keymap.set("n", 'K', vim.lsp.buf.hover(), opts)
	--vim.keymap.set('n', '<C-n>', vim.lsp.diagnostic.goto_next(), opts)
	--vim.keymap.set('n', '<C-p>', vim.lsp.diagnostic.goto_prev(), opts)

	vim.opt.signcolumn = "yes"
end)

lspzero.setup()

local lsp = require("lspconfig")

lsp.hls.setup({})
lsp.rust_analyzer.setup({})
