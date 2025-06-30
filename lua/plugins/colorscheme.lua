return {
  "webhooked/kanso.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    compile = true,
  },
  build = ":KansoCompile",
  init = function()
    -- load the colorscheme here
    vim.cmd [[colorscheme kanso-zen]]
  end,
}
