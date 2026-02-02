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
      "<c-b>",
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
        { "on_output_quickfix", open_on_match = true },
      },
    },
  },
}
