return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = "ToggleTerm",
  keys = {
    {
      "<c-t>",
      "<cmd>ToggleTerm<cr>",
      mode = { "n", "t", "i" },
      desc = "Open toggle term terminal",
    },
  },
  opts = {
    shade_terminals = false, -- Do not make them look differently
  },
}
