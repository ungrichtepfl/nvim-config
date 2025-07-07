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
  keymap("n", "ü", "[", { remap = true })
  keymap("n", "¨", "]", { remap = true })
  keymap("n", "ö", ";", { remap = true })
  keymap("n", "é", ",", { remap = true })
  keymap("n", "gö", "g;")
  keymap("n", "gé", "g,")
end

--- Toggle Terminal ---
keymap({ "n", "t" }, "<a-t>", require("config.usercommands").toggle_terminal, { desc = "Toggle Terminal" })

--- Sourcing & Running ---
keymap("n", "<leader>x", "<cmd>bo split | terminal %:p<CR><cmd>startinsert!<CR>", { desc = "Run current file" }) -- TODO: Feed in toggle terminal command of above
keymap("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Source current file" })

--- Keymaps ---
keymap({ "n", "x" }, "gy", '"+y', { desc = "Copy to system clipboard" })
keymap("n", "gp", '"+p', { desc = "Paste from system clipboard" })
-- Paste in Visual with `P` to not copy selected text (`:h v_P`):
keymap("x", "gp", '"+P', { desc = "Paste from system clipboard" })

--- Diagnostics ---
vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump {
    count = -1,
    float = true, -- Show diagnostics by default
  }
end, { desc = "Go to next diagnostics" })
vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump {
    count = 1,
    float = true, -- Show diagnostics by default
  }
end, { desc = "Go to previous diagnostics" })

-- Insert and Command --
keymap({ "i", "c" }, "<C-l>", "<C-o>x", { desc = "Delete one character forwards" })
keymap({ "i", "c" }, "<C-$>", "<C-o>d$", { desc = "Delete to end of line" })
keymap({ "i", "c" }, "<A-h>", "<Left>", { desc = "Move cursor left" })
keymap({ "i", "c" }, "<A-l>", "<Right>", { desc = "Move cursor right" })

-- Normal --
-- Resize with arrowskey
keymap("n", "<A-Up>", ":resize +1<CR>", { desc = "Resize horizontal plus" })
keymap("n", "<A-Down>", ":resize -1<CR>", { desc = "Resize horizontal minus" })
keymap("n", "<A-Left>", ":vertical resize -1<CR>", { desc = "Resize vertical minus" })
keymap("n", "<A-Right>", ":vertical resize +1<CR>", { desc = "Resize vertical plus" })

keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Switch to next buffer" })
keymap("n", "<S-h>", "<cmd>bprev<CR>", { desc = "Switch to previous buffer" })
keymap("n", "<A-j>", "<cmd>cnext<CR>", { desc = "Switch to next quickfix item" })
keymap("n", "<A-k>", "<cmd>cprev<CR>", { desc = "Switch to previous quickfix item" })
keymap("n", "<A-q>", "<cmd>cclose<CR>", { desc = "Close quickfix list" })
keymap("n", "<A-o>", "<cmd>cwindow<CR>", { desc = "Open quickfix list" })

keymap("n", "<leader>s", "<cmd>nohlsearch<CR>", { desc = "No Highlight" })
keymap("n", "<leader>w", ":w<CR>", { desc = "Write file" })
keymap("n", "<leader>W", ":w!<CR>", { desc = "Write file forced" })
keymap("n", "<leader>c", "<C-w>c", { desc = "Close window" })
keymap("n", "<leader>Q", ":conf q<CR>", { desc = "Close window with confirmation" })

keymap("n", "<c-t><c-t>", ":tabclose<CR>", { desc = "Close a tabpage." })

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
