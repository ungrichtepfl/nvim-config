return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
  keys = {
    { "<leader>l", "<cmd>TodoFzfLua<cr>", desc = "See all todo's, fixme's, etc." },
  },
  opts = {
    keywords = {
      FIX = {
        icon = " ", -- icon used for the sign, and in search results
        color = "error", -- can be a hex color, or a named color (see below)
        alt = {
          "FIXME",
          "BUG",
          "FIXIT",
          "ISSUE",
          "fix",
          "fixme",
          "bug",
          "fixit",
          "issue",
          "Fix",
          "Fixme",
          "Bug",
          "Fixit",
          "Issue",
        }, -- a set of other keywords that all map to this FIX keywords
      },
      TODO = { icon = " ", color = "info", alt = { "todo", "Todo" } },
      HACK = { icon = " ", color = "warning", alt = { "hack", "Hack" } },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX", "warn", "warning", "Warn", "Warning" } },
      PERF = {
        icon = " ",
        alt = {
          "OPTIM",
          "PERFORMANCE",
          "OPTIMIZE",
          "optim",
          "performance",
          "optimize",
          "Optim",
          "Performance",
          "Optimize",
        },
      },
      NOTE = { icon = " ", color = "hint", alt = { "INFO", "note", "info", "Info", "Note" } },
      TEST = {
        icon = "⏲ ",
        color = "test",
        alt = {
          "TESTING",
          "PASSED",
          "FAILED",
          "test",
          "testing",
          "passed",
          "failed",
          "Test",
          "Testing",
          "Passed",
          "Failed",
        },
      },
    },
    search = {
      pattern = [[\b(KEYWORDS)\s*(:?|!)]], -- ripgrep regex also check for rust macros
    },
  },
}
