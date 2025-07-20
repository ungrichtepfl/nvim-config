return {
  "sindrets/diffview.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "DiffviewOpen",
  keys = {
    {
      "<leader>vc",
      "<cmd>DiffviewClose<cr>",
      desc = "Close Diffview",
    },
    {
      "<leader>vo",
      "<cmd>DiffviewOpen<cr>", -- NOTE: Use :tabclose to close (see keymaps)
      desc = "Open Diffview",
    },
  },
}
