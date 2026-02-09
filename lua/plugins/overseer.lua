return {
  "stevearc/overseer.nvim",
  cmd = {
    "OverseerRun",
    "OverseerToggle",
  },
  keys = {
    {
      "<leader>r",
      "<cmd>OverseerRun<cr>",
      desc = "See all Overseer tasks",
    },
    {
      "<A-r>",
      "<cmd>OverseerToggle<cr>",
      desc = "Toggle Overseer",
    },
  },
  opts = {
    component_aliases = {
      default = {
        "on_exit_set_status",
        { "on_complete_notify", statuses = { "SUCCESS", "FAILURE" } },
        { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
        { "on_output_quickfix", close = true, open_on_exit = "failure" },
      },
    },
  },
}
