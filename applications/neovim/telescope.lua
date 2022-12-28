local builtin = require("telescope.builtin")

vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<C-b>", builtin.buffers, {})
vim.keymap.set("n", "<C-k>", builtin.commands, {})
vim.keymap.set("n", "<leader>ag", builtin.live_grep, {})

require("telescope").load_extension("ghq")
require("telescope").load_extension("fzy_native")
