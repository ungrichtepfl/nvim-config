return {
  "rcarriga/nvim-notify",
  opts = {
    level = vim.log.levels.DEBUG,
    stages = "fade",
    timeout = 500,
  },
  enabled = function() return vim.env.COLORTERM == "truecolor" or vim.env.TERM == "xterm-truecolor" end,
  init = function()
    vim.opt.termguicolors = true
    vim.notify = require "notify"
  end,
}
