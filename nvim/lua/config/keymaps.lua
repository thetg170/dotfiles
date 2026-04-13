local keymap = vim.keymap.set

keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })
keymap("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
