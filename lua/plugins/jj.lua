return {
  -- Disable git-specific plugins
  { "NeogitOrg/neogit", enabled = false },
  { "refractalize/oil-git-status.nvim", enabled = false },

  {
    "NicolasGB/jj.nvim",
    dependencies = {
      "sindrets/diffview.nvim", -- used as diff backend
      "folke/snacks.nvim",      -- for pickers
    },
    opts = {
      diff = {
        backend = "diffview",
      },
      editor = {
        auto_insert = true,
      },
    },
    keys = {
      { "<leader>vs", function() require("jj.cmd").status() end, desc = "JJ status" },
      { "<leader>vl", function() require("jj.cmd").log() end, desc = "JJ log" },
      { "<leader>vc", function() require("jj.cmd").commit() end, desc = "JJ commit (describe + new)" },
      { "<leader>vpu", function() require("jj.cmd").push() end, desc = "JJ push" },
      { "<leader>vpl", function() require("jj.cmd").fetch() end, desc = "JJ fetch" },
      { "<leader>vq", function() vim.cmd("terminal jj squash -i") end, desc = "JJ squash interactive" },
    },
  },

  -- Interactive hunk/line picker for jj split/squash --interactive
  -- Configured as jj's diff-editor via ~/.config/jj/config.toml:
  --   [ui]
  --   diff-editor = ["nvim", "-c", "DiffEditor $left $right $output"]
  --   diff-instructions = false
  -- Then use :J split  or  <C-s> from the jj.nvim log buffer to invoke it.
  {
    "julienvincent/hunk.nvim",
    cmd = { "DiffEditor" },
    dependencies = { "MunifTanjim/nui.nvim", "echasnovski/mini.icons" },
    opts = {},
  },
}
