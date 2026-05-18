local is_jj_repo = vim.fn.system("jj root 2>/dev/null"):match "^/" ~= nil

return {
  { "NeogitOrg/neogit", enabled = not is_jj_repo },
  { "refractalize/oil-git-status.nvim", enabled = not is_jj_repo },

  {
    "NicolasGB/jj.nvim",
    enabled = is_jj_repo,
    dependencies = {
      "sindrets/diffview.nvim", -- used as diff backend
      "folke/snacks.nvim", -- for pickers
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
      { "<leader>vv", function() require("jj.cmd").log() end, desc = "JJ log" },
      { "<leader>vd", function() require("jj.cmd").describe() end, desc = "JJ describe" },
      { "<leader>vc", function() require("jj.cmd").commit() end, desc = "JJ commit (describe + new)" },
      { "<leader>vp", function() require("jj.cmd").push() end, desc = "JJ push" },
      { "<leader>vf", function() require("jj.cmd").fetch() end, desc = "JJ fetch" },
      { "<leader>vq", "<cmd>J split<cr>", desc = "JJ split" },
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
    enabled = is_jj_repo,
    cmd = { "DiffEditor" },
    dependencies = { "MunifTanjim/nui.nvim", "echasnovski/mini.icons" },
    opts = {
      keys = {
        global = {
          focus_tree = { "<leader>b" },
          accept = { "<C-C><C-C>", "<leader><Cr>" },
        },
        diff = {
          prev_hunk = { "[c" },
          next_hunk = { "]c" },
        },
      },
    },
  },
}
