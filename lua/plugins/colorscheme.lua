return {
  "webhooked/kanso.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    -- load the colorscheme here
    vim.cmd [[colorscheme kanso-zen]]
  end,
}
