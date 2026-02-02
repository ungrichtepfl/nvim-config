return {
  "rcarriga/nvim-notify",
  opts = {
    level = vim.log.levels.DEBUG,
    stages = "fade",
    timeout = 5000,
    max_width = function() return math.floor(vim.api.nvim_win_get_width(0) / 2) end,
    render = "wrapped-compact",
  },
  enabled = function() return vim.env.COLORTERM == "truecolor" or vim.env.TERM == "xterm-truecolor" end,
  config = function(_, opts)
    local notify = require "notify"
    notify.setup(opts)
    vim.o.termguicolors = true
    vim.notify = notify
  end,
}
