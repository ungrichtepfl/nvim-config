local keymap = vim.keymap.set

-- SWISS KEYBOARD --
keymap("n", "ü", "[", { remap = true })
keymap("n", "¨", "]", { remap = true })

--- Toggle Terminal ---
keymap({ "n", "t" }, "<leader>t", require("config.usercommands").toggle_terminal, { desc = "Toggle Terminal" })

-- Sourcing & Running --
keymap("n", "<leader>x", "<cmd>bo split | terminal %:p<CR>", { desc = "Run current file" }) -- TODO: Feed in toggle terminal command of above
keymap("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Source current file" })

-- Insert --
keymap("i", "<C-l>", "<C-o>x", { desc = "Delete one character forwards" })
keymap("i", "<C-$>", "<C-o>d$", { desc = "Delete to end of line" })

-- Normal --
keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Switch to next buffer" })
keymap("n", "<S-h>", "<cmd>bprev<CR>", { desc = "Switch to previous buffer" })
keymap("n", "<C-n><C-j>", "<cmd>cnext<CR>", { desc = "Switch to next quickfix item" })
keymap("n", "<C-n><C-k>", "<cmd>cprev<CR>", { desc = "Switch to previous quickfix item" })
keymap("n", "<C-n><C-c>", "<cmd>cclose<CR>", { desc = "Close quickfix list" })
keymap("n", "<C-n><C-o>", "<cmd>copen<CR>", { desc = "Open quickfix list" })

keymap("n", "<leader>s", "<cmd>nohlsearch<CR>", { desc = "No Highlight" })
keymap("n", "<leader>w", ":w<CR>", { desc = "Write file" })
keymap("n", "<leader>W", ":w!<CR>", { desc = "Write file forced" })
keymap("n", "<leader>Q", ":q!<CR>", { desc = "Quit window forced" })

-- Visual --
-- Stay in indent mode
keymap("v", ">", ">gv", { desc = "Stay in indent mode right" })
keymap("v", "<", "<gv", { desc = "Stay in indent mode left" })

-- Move text up and down
keymap("v", "<S-j>", ":move .+1<CR>==", { desc = "Move text up" })
keymap("v", "<S-k>", ":move .-2<CR>==", { desc = "Move text down" })
keymap("v", "p", '"_dP', { desc = "Leave previous yank in buffer" })

-- Visual Block --
-- Move text up and down
keymap("x", "<S-j>", ":move '>+1<CR>gv-gv", { desc = "Move text up" })
keymap("x", "<S-k>", ":move '<-2<CR>gv-gv", { desc = "Move text down" })

-- Terminal --
keymap("t", "<leader><ESC>", "<C-\\><C-n>", { desc = "Leave Terminal Mode" })
