local M = {}

-- Toggle Terminal --
local term_state = {
  id = {
    win = -1,
    buf = -1,
  },
}

local function create_window(opts)
  opts = opts or {}

  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  end

  local win = vim.api.nvim_open_win(buf, true, {
    split = "below",
    height = 12,
    win = 0,
  })
  return { buf = buf, win = win }
end

M.toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(term_state.id.win) then
    term_state.id = create_window { buf = term_state.id.buf }
    if vim.bo[term_state.id.buf].buftype ~= "terminal" then vim.cmd.term() end
  else
    vim.api.nvim_win_hide(term_state.id.win)
  end
end

return M
