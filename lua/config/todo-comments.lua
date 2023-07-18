local status_ok, todo_commments = pcall(require, "todo-comments")
if not status_ok then
  vim.notify "'todo-comments' plugin not found."
  return
end

todo_commments.setup {
  -- keywords recognized as todo comments
  keywords = {
    FIX = {
      icon = " ", -- icon used for the sign, and in search results
      color = "error", -- can be a hex color, or a named color (see below)
      alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "fixme", "fixit" }, -- a set of other keywords that all map to this FIX keywords
      -- signs = false, -- configure signs for some keywords individually
    },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE", "OPTIMISE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
  },
  -- highlighting of the line containing the todo comment
  highlight = {
    pattern = [[.*<(KEYWORDS)(\s|:)]], -- pattern or table of patterns, used for highlightng (vim regex)
    comments_only = true,
  },
  search = {
    -- regex that will be used to match keywords.
    -- don't replace the (KEYWORDS) placeholder
    -- pattern = [[\b(KEYWORDS):]], -- ripgrep regex
    pattern = [[\b(KEYWORDS):?\b]], -- match without the extra colon. You'll likely get false positives
  },
}
