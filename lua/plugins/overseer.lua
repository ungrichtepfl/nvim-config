return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerRun",
    "OverseerToggle",
  },
  keys = {
    {
      "<leader>rt",
      "<cmd>OverseerRun<cr>",
      desc = "See all Overseer tasks",
    },
    {
      "<leader>rr",
      "<cmd>OverseerToggle<cr>",
      desc = "Toggle Overseer",
    },
  },
  opts = {},
}
