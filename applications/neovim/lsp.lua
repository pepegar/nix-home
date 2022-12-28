local lsp = require("lsp-zero")
require("lsp-zero").setup({
	lsp.preset("recommended"),
})

require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},

	install_root_dir = "/Users/pepegarcia/.config/nvim/",
})
