local keymap = vim.keymap.set

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

local function get_keyboard_layout()
  local handle = io.popen "setxkbmap -query"
  if handle then
    local result = handle:read "*a"
    handle:close()
    return result
  end
end

local layout_info = get_keyboard_layout()
if not layout_info or (layout_info and layout_info:match "layout:%s+ch") then
  -- SWISS KEYBOARD --
  keymap({ "i", "c" }, "<A-ü>", "[", { remap = true })
  keymap({ "i", "c" }, "<A-¨>", "]", { remap = true })
  keymap({ "i", "c" }, "<C-ä>", "{", { remap = true })
  keymap({ "i", "c" }, "<C-$>", "}", { remap = true })
  keymap({ "n", "x" }, "ö", ";")
  keymap({ "n", "x" }, "gö", "g;")
  keymap({ "n", "x" }, "ü", "[", { remap = true })
  keymap({ "n", "x" }, "¨", "]", { remap = true })
end

-- Make ESC more ergonomic
keymap({ "i" }, "jk", "<ESC>")
keymap({ "c" }, "jk", "<C-C>")

--- Toggle Terminal ---
keymap({ "n", "t", "i" }, "<C-t>", require("config.utils").toggle_terminal, { desc = "Toggle Terminal" })

--- Sourcing & Running ---
keymap("n", "<leader>x", "<cmd>bo split | terminal %:p<CR><cmd>startinsert!<CR>", { desc = "Run current file" }) -- TODO: Feed in toggle terminal command of above
keymap("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Source current file" })
keymap("n", "<leader><leader>v", ":so<cr>", { desc = "Source current file" })

--- Keymaps ---
keymap({ "n", "x" }, "my", '"+y', { desc = "Copy to system clipboard" })
keymap({ "n" }, "mY", '"+Y', { desc = "Copy to system clipboard" })
keymap("n", "mp", '"+p', { desc = "Paste from system clipboard" })
-- Paste in Visual with `P` to not copy selected text (`:h v_P`):
keymap("x", "mp", '"+P', { desc = "Paste from system clipboard" })

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
keymap({ "i" }, "<C-e>", "<End>", { desc = "Go to end of line" }) -- C-e already taken in command
keymap({ "i", "c" }, "<C-a>", "<Home>", { desc = "Go to beginning of line" })
keymap({ "i", "c" }, "<C-b>", "<Left>", { desc = "Move cursor backwards" })
keymap({ "i", "c" }, "<C-f>", "<Right>", { desc = "Move cursor forwards" })
keymap({ "i", "c" }, "<C-d>", "<Del>", { desc = "Delete one character forward" })
-- <C-o> does not work in command mode
keymap({ "i" }, "<A-b>", "<C-o>b", { desc = "Move cursor back one word" })
keymap({ "i" }, "<A-f>", "<C-o>w", { desc = "Move cursor forward one word" })
keymap({ "i" }, "<C-m>", "<C-o>d$", { desc = "Clear all AFTER cursor" }) -- NOTE: C-k is already taken
keymap({ "i" }, "<A-d>", "<C-o>dw", { desc = "delete the word FROM the cursor" })

-- Normal --
-- Resize with arrowskey
keymap("n", "<A-Up>", ":resize +1<CR>", { desc = "Resize horizontal plus" })
keymap("n", "<A-Down>", ":resize -1<CR>", { desc = "Resize horizontal minus" })
keymap("n", "<A-Left>", ":vertical resize -1<CR>", { desc = "Resize vertical minus" })
keymap("n", "<A-Right>", ":vertical resize +1<CR>", { desc = "Resize vertical plus" })

keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Switch to next buffer" })
keymap("n", "<S-h>", "<cmd>bprev<CR>", { desc = "Switch to previous buffer" })
keymap("n", "<A-n>", "<cmd>cnext<CR>", { desc = "Switch to next quickfix item" })
keymap("n", "<A-p>", "<cmd>cprev<CR>", { desc = "Switch to previous quickfix item" })
keymap("n", "<A-q>", "<cmd>cclose<CR>", { desc = "Close quickfix list" })
keymap("n", "<A-o>", "<cmd>copen<CR>", { desc = "Open quickfix list" })

keymap("n", "<C-l>", "<cmd>nohlsearch<CR><C-l>", { desc = "Redraw screen and unhighlight" })
keymap("i", "<C-l>", "<cmd>nohlsearch<CR>", { desc = "Unhighlight" })
keymap("n", "<leader>w", ":w<CR>", { desc = "Write file" })
keymap("n", "<leader>W", ":w!<CR>", { desc = "Write file forced" })
keymap("n", "<leader>c", "<C-w>c", { desc = "Close window" })
keymap("n", "<leader>q", ":conf q<CR>", { desc = "Close window with confirmation" })
keymap("n", "<leader>f", ":find ", { desc = "Find file" })
keymap("n", "<leader>g", ":vimgrep  **/*<LEFT><LEFT><LEFT><LEFT><LEFT>", { desc = "Find expression" })
keymap("n", "<leader>e", ":Explore<CR>", { desc = "Open file explorer" })
-- Copy Full File-Path
keymap("n", "<leader>pa", function()
  local path = vim.fn.expand "%:p"
  vim.fn.setreg("+", path)
  vim.notify("Copied path to clipboard: " .. path)
end, { desc = "Copy full file path" })
keymap("n", "<a-t><a-t>", ":tabclose<CR>", { desc = "Close a tabpage" })

-- Mark handling
keymap("n", "<leader>a", require("config.utils").add_mark, { desc = "Add a mark at current cursor position" })
keymap("n", "<A-h>", function() require("config.utils").goto_mark "H" end, { desc = "Jump to mark H" })
keymap("n", "<A-j>", function() require("config.utils").goto_mark "J" end, { desc = "Jump to mark J" })
keymap("n", "<A-k>", function() require("config.utils").goto_mark "K" end, { desc = "Jump to mark K" })
keymap("n", "<A-l>", function() require("config.utils").goto_mark "L" end, { desc = "Jump to mark L" })
keymap("n", "<leader>m", "mM", { desc = "Set global mark M" })
keymap("n", "<leader><leader>m", "`M", { desc = "Go to global mark M" })

-- Visual --
-- Stay in indent mode
keymap("x", ">", ">gv", { desc = "Stay in indent mode right" })
keymap("x", "<", "<gv", { desc = "Stay in indent mode left" })
keymap("x", "p", '"_dP', { desc = "Leave previous yank in buffer" }) -- Do not trigger in select mode
-- Move text up and down
keymap("x", "<S-j>", ":move '>+1<CR>gv-gv", { desc = "Move text up" })
keymap("x", "<S-k>", ":move '<-2<CR>gv-gv", { desc = "Move text down" })

-- Terminal --
keymap("t", "<ESC><ESC>", "<C-\\><C-n>", { desc = "Leave Terminal Mode" })
