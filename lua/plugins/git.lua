local KEYMAP_PREFIX = "<leader>v"

return {
  {
    "NeogitOrg/neogit",
    specs = {
      {
        "folke/which-key.nvim",
        opts = {
          spec = {
            { KEYMAP_PREFIX, group = "git" },
            { KEYMAP_PREFIX .. "p", group = "pull/push" },
          },
        },
      },
    },
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      -- Only one of these is needed.
      "ibhagwan/fzf-lua", -- optional
    },
    keys = {
      {
        KEYMAP_PREFIX .. "s",
        "<cmd>Neogit<cr>",
        desc = "Show git status",
      },
      {
        KEYMAP_PREFIX .. "c",
        "<cmd>Neogit commit<cr>",
        desc = "Git commit",
      },
      {
        KEYMAP_PREFIX .. "pl",
        "<cmd>Neogit pull<cr>",
        desc = "Git pull",
      },
      {
        KEYMAP_PREFIX .. "pu",
        "<cmd>Neogit push<cr>",
        desc = "Git push",
      },
      {
        KEYMAP_PREFIX .. "l",
        "<cmd>Neogit log<cr>",
        desc = "Git log",
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    opts = {
      file_panel = {
        win_config = {
          position = "left",
          width = math.floor(vim.o.columns / 5),
        },
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "DiffviewOpen",
  },
}
