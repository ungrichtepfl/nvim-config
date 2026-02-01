return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerRun",
    "OverseerToggle",
  },
  keys = {
    {
      "<leader>rr",
      "<cmd>OverseerRun<cr>",
      desc = "See all Overseer tasks",
    },
    {
      "<c-,>",
      "<cmd>OverseerToggle<cr>",
      desc = "Toggle Overseer",
    },
  },
  opts = {
    component_aliases = {
      default = {
        { "open_output", on_start = "always" },
      },
    },
  },
}
