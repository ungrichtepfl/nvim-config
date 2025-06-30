return {
  "webhooked/kanso.nvim",
  lazy = false,
  priority = 5000,
  init = function()
    -- load the colorscheme here
    vim.cmd [[colorscheme kanso-zen]]
  end,
}
