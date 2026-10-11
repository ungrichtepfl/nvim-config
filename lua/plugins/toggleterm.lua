local KEYMAP_PREFIX = "<leader>T"

return {
  "akinsho/toggleterm.nvim",
  specs = { { "folke/which-key.nvim", opts = { spec = { { KEYMAP_PREFIX, group = "terminal" } } } } },
  version = "*",
  cmd = "ToggleTerm",
  keys = {
    {
      "<c-t>",
      desc = "Open toggle term terminal",
    },
    {
      "<leader>x",
      '<cmd>2TermExec go_back=0 cmd="%:p"<cr>',
      mode = { "n" },
      desc = "Run current file",
    },
    {
      KEYMAP_PREFIX .. "T",
      "<cmd>ToggleTerm direction=tab<cr>",
      mode = { "n" },
      desc = "Open toggle term terminal tab",
    },
    {
      KEYMAP_PREFIX .. "f",
      "<cmd>ToggleTerm direction=float<cr>",
      mode = { "n" },
      desc = "Open toggle term terminal floating",
    },
    {
      KEYMAP_PREFIX .. "h",
      "<cmd>ToggleTerm direction=horizontal<cr>",
      mode = { "n" },
      desc = "Open toggle term terminal horizontally",
    },
    {
      KEYMAP_PREFIX .. "v",
      "<cmd>ToggleTerm direction=vertical<cr>",
      mode = { "n" },
      desc = "Open toggle term terminal vertically",
    },
  },
  opts = {
    shade_terminals = false, -- Do not make them look differently
    open_mapping = [[<c-t>]],
  },
}
