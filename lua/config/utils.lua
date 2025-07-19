local M = {}

-- Toggle Terminal --
local term_state = {
  win = -1,
  buf = -1,
}

local function create_split_terminal(buf)
  -- Open split and switch to it
  vim.cmd "belowright split"

  local win = vim.api.nvim_get_current_win()

  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_win_set_buf(win, buf)
  else
    buf = vim.api.nvim_create_buf(false, true) -- [listed, scratch]
    vim.api.nvim_win_set_buf(win, buf)
    vim.cmd "term" -- spawn terminal
    vim.bo[buf].buflisted = false
  end

  vim.cmd "startinsert"

  return { buf = buf, win = win }
end

M.toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(term_state.win) then
    local id = create_split_terminal(term_state.buf)
    term_state.win = id.win
    term_state.buf = id.buf
  else
    vim.api.nvim_win_hide(term_state.win)
    term_state.win = -1
  end
end

-- My own [harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) implementation

local harpoon = {
  index = "J",
}

local function update_index()
  if harpoon.index == "H" then
    harpoon.index = "J"
  elseif harpoon.index == "J" then
    harpoon.index = "K"
  elseif harpoon.index == "K" then
    harpoon.index = "H"
  end
end

local function goto_last_edited()
  local mark = vim.api.nvim_buf_get_mark(0, ".")
  local lcount = vim.api.nvim_buf_line_count(0)
  if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
end

M.goto_mark = function(mark)
  vim.cmd("'" .. mark)
  goto_last_edited()
end

M.add_mark = function()
  vim.cmd("normal m" .. harpoon.index)
  vim.notify("Added mark: " .. harpoon.index)
  update_index()
end

M.goto_last_edited = goto_last_edited

return M
