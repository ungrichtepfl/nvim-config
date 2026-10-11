local KEYMAP_PREFIX = "<leader>h"

return {
  "lewis6991/gitsigns.nvim",
  specs = { { "folke/which-key.nvim", opts = { spec = { { KEYMAP_PREFIX, group = "git hunks" } } } } },
  opts = {
    attach_to_untracked = false,
    on_attach = function(bufnr)
      local gitsigns = require "gitsigns"

      local function map(mode, lhs, rhs, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      ----------------------------------------------------------------------
      -- Navigation between hunks
      ----------------------------------------------------------------------
      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal { "]c", bang = true }
        else
          gitsigns.nav_hunk "next"
        end
      end, { desc = "Next Git hunk" })

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal { "[c", bang = true }
        else
          gitsigns.nav_hunk "prev"
        end
      end, { desc = "Previous Git hunk" })

      ----------------------------------------------------------------------
      -- Actions
      ----------------------------------------------------------------------
      map("n", KEYMAP_PREFIX .. "s", gitsigns.stage_hunk, { desc = "Stage hunk" })
      map("n", KEYMAP_PREFIX .. "r", gitsigns.reset_hunk, { desc = "Reset hunk" })

      map(
        "v",
        KEYMAP_PREFIX .. "s",
        function() gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
        { desc = "Stage selected hunk" }
      )

      map(
        "v",
        KEYMAP_PREFIX .. "r",
        function() gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
        { desc = "Reset selected hunk" }
      )

      map("n", KEYMAP_PREFIX .. "S", gitsigns.stage_buffer, { desc = "Stage buffer" })
      map("n", KEYMAP_PREFIX .. "R", gitsigns.reset_buffer, { desc = "Reset buffer" })
      map("n", KEYMAP_PREFIX .. "p", gitsigns.preview_hunk, { desc = "Preview hunk" })
      map("n", KEYMAP_PREFIX .. "i", gitsigns.preview_hunk_inline, { desc = "Inline hunk preview" })

      map(
        "n",
        KEYMAP_PREFIX .. "b",
        function() gitsigns.blame_line { full = false } end,
        { desc = "Git blame (full line)" }
      )
      map("n", KEYMAP_PREFIX .. "B", function() gitsigns.blame() end, { desc = "Git blame (full line)" })

      map("n", KEYMAP_PREFIX .. "d", gitsigns.diffthis, { desc = "Diff against index" })

      map("n", KEYMAP_PREFIX .. "D", function() gitsigns.diffthis "~" end, { desc = "Diff against last commit" })

      map(
        "n",
        KEYMAP_PREFIX .. "Q",
        function() gitsigns.setqflist "all" end,
        { desc = "Populate quickfix list (all hunks)" }
      )

      map("n", KEYMAP_PREFIX .. "q", gitsigns.setqflist, { desc = "Populate quickfix list (visible hunks)" })

      ----------------------------------------------------------------------
      -- Toggles
      ----------------------------------------------------------------------
      map("n", KEYMAP_PREFIX .. "t", gitsigns.toggle_current_line_blame, { desc = "Toggle blame line" })
      map("n", KEYMAP_PREFIX .. "w", gitsigns.toggle_word_diff, { desc = "Toggle word diff" })

      ----------------------------------------------------------------------
      -- Text object
      ----------------------------------------------------------------------
      map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "Git hunk text object" })
    end,
  },
}
