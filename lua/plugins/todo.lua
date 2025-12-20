return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
  keys = {
    { "<leader>l", "<cmd>TodoQuickFix keywords=FIX,TODO,HACK,PERF,TEST<cr>", desc = "See all todo's, fixme's, etc." },
  },
  opts = {
    keywords = {
      FIX = {
        icon = " ", -- icon used for the sign, and in search results
        color = "error", -- can be a hex color, or a named color (see below)
        alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "fix", "fixme", "bug", "fixit", "issue" }, -- a set of other keywords that all map to this FIX keywords
      },
      TODO = { icon = " ", color = "info", alt = { "todo" } },
      HACK = { icon = " ", color = "warning", alt = { "hack" } },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX", "warn", "warning" } },
      PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE", "optim", "performance", "optimize" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO", "note", "info" } },
      TEST = {
        icon = "⏲ ",
        color = "test",
        alt = { "TESTING", "PASSED", "FAILED", "test", "testing", "passed", "failed" },
      },
    },
    search = {
      pattern = [[\b(KEYWORDS)(:|!)]], -- ripgrep regex also check for rust macros
    },
  },
}
