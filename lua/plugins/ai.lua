return {
  {
    "supermaven-inc/supermaven-nvim",
    cmd = "SupermavenStart",
    keys = {
      {
        "<leader>ii",
        function() require("supermaven-nvim.api").restart() end,
        desc = "(Re)start inline copilot (supermaven).",
      },

      {
        "<leader>is",
        function() require("supermaven-nvim.api").stop() end,
        desc = "Stop inline copilot (supermaven).",
      },
    },
    opts = {
      keymaps = {
        accept_suggestion = "<C-j>",
        accept_word = "<C-l>",
        clear_suggestion = "<C-h>",
      },
    },
  },
}
