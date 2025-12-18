return {
  "akinsho/toggleterm.nvim",
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
      "<leader>TT",
      "<cmd>ToggleTerm direction=tab<cr>",
      mode = { "n" },
      desc = "Open toggle term terminal tab",
    },
    {
      "<leader>Tf",
      "<cmd>ToggleTerm direction=float<cr>",
      mode = { "n" },
      desc = "Open toggle term terminal floating",
    },
    {
      "<leader>Th",
      "<cmd>ToggleTerm direction=horizontal<cr>",
      mode = { "n" },
      desc = "Open toggle term terminal horizontally",
    },
    {
      "<leader>Tv",
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
