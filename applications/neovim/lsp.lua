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

	install_root_dir = "~/.config/nvim/",
})
