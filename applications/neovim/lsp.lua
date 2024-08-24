local lspzero = require("lsp-zero")

lspzero.preset("recommended")

lspzero.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, opts)
	vim.keymap.set("n", "gi", require("telescope.builtin").lsp_implementations, opts)
	vim.keymap.set("n", "gt", require("telescope.builtin").lsp_type_definitions, opts)
	vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, opts)

	vim.opt.signcolumn = "yes"
end)

lspzero.setup()

local lsp = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lsp.hls.setup({ capabilities = capabilities })
lsp.rust_analyzer.setup({ capabilities = capabilities })
lsp.lua_ls.setup({
	capabilities = capabilities,
	on_init = function(client)
		local path = client.workspace_folders[1].name
		if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
			return
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				version = "LuaJIT",
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		})
	end,
	settings = {
		Lua = {},
	},
})
lsp.pyright.setup({ capabilities = capabilities })
lsp.tsserver.setup({ capabilities = capabilities })
lsp.ruff.setup({
	init_options = {
		settings = {
			args = {},
		},
	},
})
