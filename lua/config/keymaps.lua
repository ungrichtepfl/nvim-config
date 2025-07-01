local keymap = vim.keymap.set

-- SWISS KEYBOARD --
keymap("n", "ü", "[", { remap = true })
keymap("n", "¨", "]", { remap = true })

-- Normal --
keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "No Highlight", nowait = true })

-- Visual --
-- Stay in indent mode
keymap("v", ">", ">gv", { desc = "Stay in indent mode right" })
keymap("v", "<", "<gv", { desc = "Stay in indent mode left" })

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", { desc = "Move text up" })
keymap("v", "<A-k>", ":m .-2<CR>==", { desc = "Move text down" })
keymap("v", "p", '"_dP', { desc = "Leave previous yank in buffer" })

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move text up" })
keymap("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move text down" })
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", { desc = "Move text up" })
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", { desc = "Move text down" })
