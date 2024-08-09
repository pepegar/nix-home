require("mason").setup({
	install_root_dir = "/Users/pepe/.config/nvim/",
})

local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, opts)
	vim.keymap.set("n", "gi", require("telescope.builtin").lsp_implementations, opts)
	vim.keymap.set("n", "gt", require("telescope.builtin").lsp_type_definitions, opts)
	vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts)
end)

lsp.setup()
