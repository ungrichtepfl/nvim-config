local M = {}

-- Toggle Terminal --
local term_state = {
  win = -1,
  buf = -1,
}

local function create_split_terminal(buf)

  -- Open split and switch to it
  vim.cmd("belowright split")

  local win = vim.api.nvim_get_current_win()

  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_win_set_buf(win, buf)
  else
    buf = vim.api.nvim_create_buf(false, true) -- [listed, scratch]
    vim.api.nvim_win_set_buf(win, buf)
    vim.cmd("term") -- spawn terminal
    vim.bo[buf].buflisted = false
  end

  vim.cmd("startinsert")

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

return M
