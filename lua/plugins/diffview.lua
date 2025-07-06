return {
  "sindrets/diffview.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>m",
      "<cmd>DiffviewOpen<cr>", -- NOTE: Use :tabclose to close (see keymaps)
      desc = "Open Diffview",
    },
  },
}
