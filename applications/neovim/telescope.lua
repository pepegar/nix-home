local builtin = require("telescope.builtin")

vim.keymap.set("n", "<C-p>g", builtin.git_files, {})
vim.keymap.set("n", "<C-p>h", builtin.find_files, {})
vim.keymap.set("n", "<C-b>", builtin.buffers, {})
vim.keymap.set("n", "<C-k>", builtin.commands, {})
vim.keymap.set("n", "<M-x>", builtin.commands, {})
vim.keymap.set("n", "<leader>ag", builtin.live_grep, {})
vim.keymap.set("n", "<leader>gb", builtin.git_branches, {})

require("telescope").load_extension("ghq")
require("telescope").load_extension("fzy_native")

require("telescope").setup({
	defaults = {
		mappings = {
			n = {
				["<c-d>"] = require("telescope.actions").delete_buffer,
			},
			i = {
				["<c-d>"] = require("telescope.actions").delete_buffer,
			},
		},
	},
})
