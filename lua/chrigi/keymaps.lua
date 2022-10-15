local function opts(desc) return { noremap = true, silent = true, desc = desc } end

local term_opts = { silent = true }

-- Shorten function name
--[[ local keymap = vim.api.nvim_set_keymap ]]
local keymap = vim.keymap.set

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts "")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts "Go to left window")
keymap("n", "<C-j>", "<C-w>j", opts "Go to lower window")
keymap("n", "<C-k>", "<C-w>k", opts "Go to upper window")
keymap("n", "<C-l>", "<C-w>l", opts "Go to right window")

-- Resize with arrowskey
keymap("n", "<A-Up>", ":resize +2<CR>", opts "Resize horizontal plus")
keymap("n", "<A-Down>", ":resize -2<CR>", opts "Resize horizontal minus")
keymap("n", "<A-Left>", ":vertical resize -2<CR>", opts "Resize vertical minus")
keymap("n", "<A-Right>", ":vertical resize +2<CR>", opts "Resize vertical plus")

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts "Go to next buffer")
keymap("n", "<S-h>", ":bprevious<CR>", opts "Go to previous buffer")

-- Saving/Closing
keymap("n", "<C-s>", ":w<CR>", opts "Save file")

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts "Change to normal mode")

-- Visual --
-- Stay in indent mode
keymap("v", ">", ">gv", opts "Stay in indent mode right")
keymap("v", "<", "<gv", opts "Stay in indent mode left")

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts "Move text up")
keymap("v", "<A-k>", ":m .-2<CR>==", opts "Move text down")
keymap("v", "p", '"_dP', opts "Leave previous yank in buffer")

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts "Move text up")
keymap("x", "K", ":move '<-2<CR>gv-gv", opts "Move text down")
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts "Move text up")
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts "Move text down")

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
