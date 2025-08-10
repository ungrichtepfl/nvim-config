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
      '<cmd>TermExec cmd="%:p"<cr>',
      mode = { "n" },
      desc = "Run current file",
    },
    {
      "<leader>tt",
      "<cmd>ToggleTerm direction=tab<cr>",
      mode = { "n", "t" },
      desc = "Open toggle term terminal tab",
    },
    {
      "<leader>tf",
      "<cmd>ToggleTerm direction=float<cr>",
      mode = { "n", "t" },
      desc = "Open toggle term terminal floating",
    },
    {
      "<leader>th",
      "<cmd>ToggleTerm direction=horizontal<cr>",
      mode = { "n", "t" },
      desc = "Open toggle term terminal horizontally",
    },
    {
      "<leader>tv",
      "<cmd>ToggleTerm direction=vertical<cr>",
      mode = { "n", "t" },
      desc = "Open toggle term terminal vertically",
    },
  },
  opts = {
    shade_terminals = false, -- Do not make them look differently
    open_mapping = [[<c-t>]],
  },
}
