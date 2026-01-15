local keymap = vim.keymap.set
local utils = require "config.utils"

--          Mode  | Norm | Ins | Cmd | Vis | Sel | Opr | Term | Lang | ~
-- Command        +------+-----+-----+-----+-----+-----+------+------+ ~
-- [nore]map      | yes  |  -  |  -  | yes | yes | yes |  -   |  -   |
-- n[nore]map     | yes  |  -  |  -  |  -  |  -  |  -  |  -   |  -   |
-- [nore]map!     |  -   | yes | yes |  -  |  -  |  -  |  -   |  -   |
-- i[nore]map     |  -   | yes |  -  |  -  |  -  |  -  |  -   |  -   |
-- c[nore]map     |  -   |  -  | yes |  -  |  -  |  -  |  -   |  -   |
-- v[nore]map     |  -   |  -  |  -  | yes | yes |  -  |  -   |  -   |
-- x[nore]map     |  -   |  -  |  -  | yes |  -  |  -  |  -   |  -   |
-- s[nore]map     |  -   |  -  |  -  |  -  | yes |  -  |  -   |  -   |
-- o[nore]map     |  -   |  -  |  -  |  -  |  -  | yes |  -   |  -   |
-- t[nore]map     |  -   |  -  |  -  |  -  |  -  |  -  | yes  |  -   |
-- l[nore]map     |  -   | yes | yes |  -  |  -  |  -  |  -   | yes  |

-- SWISS KEYBOARD --
if utils.is_swiss_keyboard() then
  keymap({ "n", "v", "i", "t" }, "<C-ü>", "<ESC>")
  keymap({ "c" }, "<C-ü>", "<C-C>")
  keymap({ "t" }, "<C-ü><C-ü>", "<C-\\><C-n>")
  keymap({ "i", "c" }, "<A-ü>", "[", { remap = true })
  keymap({ "i", "c" }, "<A-¨>", "]", { remap = true })
  keymap({ "i", "c" }, "<A-ä>", "{", { remap = true })
  keymap({ "i", "c" }, "<A-$>", "}", { remap = true })
  keymap({ "n", "x" }, "gö", "g;")
  keymap({ "n", "x" }, "ö", ";")
  keymap({ "n", "x" }, "ü", "[", { remap = true })
  keymap({ "n", "x" }, "¨", "]", { remap = true })
end

-- Make ESC more ergonomic
keymap({ "i" }, "jk", "<ESC>")
keymap({ "c" }, "jk", "<C-C>")

--- Toggle Terminal ---
keymap({ "n", "t", "i" }, "<C-t>", utils.toggle_terminal, { desc = "Toggle Terminal" })

--- Sourcing & Running ---
keymap("n", "<leader>x", "<cmd>bo split | terminal %:p<CR><cmd>startinsert!<CR>", { desc = "Run current file" }) -- TODO: Feed in toggle terminal command of above
keymap("n", "<leader><leader>x", ":!source %<CR>", { desc = "Source current file" })
keymap("n", "<leader><leader>v", ":so<cr>", { desc = "Source current vim config file" })

--- Keymaps ---
keymap({ "n", "x" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
keymap({ "n" }, "<leader>Y", '"+Y', { desc = "Copy to system clipboard" })
keymap("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
keymap("n", "<leader>P", '"+P', { desc = "Paste from system clipboard" })
-- Paste in Visual with `P` to not copy selected text (`:h v_P`):
keymap("x", "<leader>p", '"+P', { desc = "Paste from system clipboard" })

--- Diagnostics ---
keymap("n", "[d", function()
  vim.diagnostic.jump {
    count = -1,
    float = true, -- Show diagnostics by default
  }
end, { desc = "Go to next diagnostics" })
keymap("n", "]d", function()
  vim.diagnostic.jump {
    count = 1,
    float = true, -- Show diagnostics by default
  }
end, { desc = "Go to previous diagnostics" })

-- Insert and Command --
keymap({ "i" }, "<C-e>", "<End>", { desc = "Go to end of line" })
keymap({ "c" }, "<A-e>", "<End>", { desc = "Go to end of line" }) -- C-e already taken in command
keymap({ "i" }, "<C-a>", "<Home>", { desc = "Go to beginning of line" })
keymap({ "c" }, "<A-a>", "<Home>", { desc = "Go to beginning of line" })
keymap({ "i", "c" }, "<C-b>", "<Left>", { desc = "Move cursor backwards" })
keymap({ "i" }, "<C-f>", "<Right>", { desc = "Move cursor forwards" })
keymap({ "c" }, "<A-f>", "<Right>", { desc = "Move cursor forwards" }) -- C-f already taken in command
keymap({ "i", "c" }, "<C-d>", "<Del>", { desc = "Delete one character forward" })
-- <C-o> does not work in command mode
keymap({ "i" }, "<A-b>", "<C-o>b", { desc = "Move cursor back one word" })
keymap({ "i" }, "<A-f>", "<C-o>w", { desc = "Move cursor forward one word" })
keymap({ "i" }, "<C-k>", "<C-o>d$", { desc = "Clear all AFTER cursor" })
keymap({ "i" }, "<A-d>", "<C-o>dw", { desc = "delete the word FROM the cursor" })

-- Normal --
-- Resize with arrowskey
keymap("n", "<A-Up>", ":resize +1<CR>", { silent = true, desc = "Resize horizontal plus" })
keymap("n", "<A-Down>", ":resize -1<CR>", { silent = true, desc = "Resize horizontal minus" })
keymap("n", "<A-Left>", ":vertical resize -1<CR>", { silent = true, desc = "Resize vertical minus" })
keymap("n", "<A-Right>", ":vertical resize +1<CR>", { silent = true, desc = "Resize vertical plus" })

keymap("n", "gm", "<cmd>bm<CR>", { desc = "Go to next modified buffer" })
keymap("n", "<A-q>", "<cmd>cclose<CR>", { desc = "Close quickfix list" })
keymap("n", "<A-o>", "<cmd>copen<CR>", { desc = "Open quickfix list" })

keymap("n", "<C-h>", "<cmd>set hlsearch<CR>", { desc = "Highlight all the searches" })
keymap("n", "<C-l>", "<cmd>set nohlsearch<CR><C-l>", { desc = "Redraw screen and unhighlight" })
keymap("i", "<C-l>", "<cmd>set nohlsearch<CR>", { desc = "Unhighlight" })
-- Taken from help to highlight while searching
vim.cmd [[ 
  augroup vimrc-incsearch-highlight
  autocmd!
  autocmd CmdlineEnter /,\? :set hlsearch
  autocmd CmdlineLeave /,\? :set nohlsearch
  augroup END
]]
keymap("n", "<leader>w", ":w<CR>", { silent = true, desc = "Write file" })
keymap("n", "<leader>W", ":w!<CR>", { silent = true, desc = "Write file forced" })
keymap("n", "<leader>q", ":conf q<CR>", { silent = true, desc = "Close window with confirmation" })
keymap("n", "<leader>c", ":make ", { desc = "Compile file" })
keymap("n", "<leader>f", ":find ", { desc = "Find file" })
keymap("n", "<leader>g", ":vimgrep  **/*<LEFT><LEFT><LEFT><LEFT><LEFT>", { desc = "Find expression" })
keymap("n", "<leader>e", ":Explore<CR>", { silent = true, desc = "Open file explorer" })
-- Copy Full File-Path
keymap("n", "<leader>C", function()
  local path = vim.fn.expand "%:p"
  vim.fn.setreg("+", path)
  vim.notify("Copied path to clipboard: " .. path)
end, { desc = "Copy full file path" })
keymap("n", "<leader>O", function()
  local path = vim.fn.expand "%:p"
  vim.ui.open(path)
  vim.notify("Open file in default program: " .. path)
end, { desc = "Open current file in default application" })
keymap("n", "<a-t><a-t>", ":tabclose<CR>", { silent = true, desc = "Close a tabpage" })
keymap("n", "<a-t><a-n>", function()
  vim.cmd.tabnew()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.files()
  else
    vim.api.nvim_feedkeys(":find ", "n", true)
  end
end, { desc = "Open a new tabpage" })
keymap("n", "<leader><leader>m", "mM", { desc = "Set global mark M" })
keymap("n", "<leader>m", "`M", { desc = "Go to global mark M" })

-- Visual --
-- Stay in indent mode
keymap("x", ">", ">gv", { desc = "Stay in indent mode right" })
keymap("x", "<", "<gv", { desc = "Stay in indent mode left" })
keymap("x", "p", '"_dP', { desc = "Leave previous yank in buffer" }) -- Do not trigger in select mode
-- Move text up and down
keymap("x", "<S-j>", ":move '>+1<CR>gv-gv", { silent = true, desc = "Move text up" })
keymap("x", "<S-k>", ":move '<-2<CR>gv-gv", { silent = true, desc = "Move text down" })

-- Terminal --
keymap("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Leave Terminal Mode" })
