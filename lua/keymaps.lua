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
-- Resize with arrowskey
keymap("n", "<C-Up>", ":resize +2<CR>", opts "Resize horizontal plus")
keymap("n", "<C-Down>", ":resize -2<CR>", opts "Resize horizontal minus")
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts "Resize vertical minus")
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts "Resize vertical plus")

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts "Go to next buffer")
keymap("n", "<S-h>", ":bprevious<CR>", opts "Go to previous buffer")

-- Saving/Closing
keymap("n", "<C-s>", ":w<CR>", opts "Save file")

-- Open link
keymap("n", "gx", [[ <CMD>execute '!xdg-open ' .. shellescape(expand('<cfile>'), v:true)<CR> ]], opts "Open link")

-- Change word with backslash --
keymap("n", "<BS>", "ciw", opts "Change word with backslash")

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
