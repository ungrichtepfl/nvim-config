return {
  "lewis6991/gitsigns.nvim",
  opts = {
    attach_to_untracked = true,
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
      map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk" })
      map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })

      map(
        "v",
        "<leader>hs",
        function() gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
        { desc = "Stage selected hunk" }
      )

      map(
        "v",
        "<leader>hr",
        function() gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
        { desc = "Reset selected hunk" }
      )

      map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage buffer" })
      map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset buffer" })
      map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
      map("n", "<leader>hi", gitsigns.preview_hunk_inline, { desc = "Inline hunk preview" })

      map("n", "<leader>hb", function() gitsigns.blame_line { full = true } end, { desc = "Git blame (full line)" })

      map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff against index" })

      map("n", "<leader>hD", function() gitsigns.diffthis "~" end, { desc = "Diff against last commit" })

      map("n", "<leader>hQ", function() gitsigns.setqflist "all" end, { desc = "Populate quickfix list (all hunks)" })

      map("n", "<leader>hq", gitsigns.setqflist, { desc = "Populate quickfix list (visible hunks)" })

      ----------------------------------------------------------------------
      -- Toggles
      ----------------------------------------------------------------------
      map("n", "<leader>ht", gitsigns.toggle_current_line_blame, { desc = "Toggle blame line" })
      map("n", "<leader>hw", gitsigns.toggle_word_diff, { desc = "Toggle word diff" })

      ----------------------------------------------------------------------
      -- Text object
      ----------------------------------------------------------------------
      map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "Git hunk text object" })
    end,
  },
}
