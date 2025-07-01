local keymap = vim.keymap.set

-- SWISS KEYBOARD --
keymap("n", "ü", "[", { remap = true })
keymap("n", "ü", "[", { remap = true })

--- Toggle Terminal ---
keymap({ "n", "t" }, "<C-t>", require("config.usercommands").toggle_terminal, { desc = "Toggle Terminal" })

-- Sourcing & Running --
keymap("n", "<leader>x", "<cmd>split | terminal ./%<CR>", { desc = "Run current file" })
keymap("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Source current file" })

-- Insert --
keymap("i", "<C-d>", "<C-o>x", { desc = "Delete one character forwards" })

-- Normal --
keymap("n", "<leader>sh", "<cmd>nohlsearch<CR>", { desc = "No Highlight" })
keymap("n", "<S-l>", ":bnext<CR>", { desc = "Switch to next buffer" })
keymap("n", "<S-h>", ":bprev<CR>", { desc = "Switch to previous buffer" })

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

-- Terminal --
keymap("t", "<leader><ESC>", "<C-\\><C-n>", { desc = "Leave Terminal Mode" })
