return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      -- Only one of these is needed.
      "ibhagwan/fzf-lua", -- optional
    },
    keys = {
      {
        "<leader>vs",
        "<cmd>Neogit<cr>",
        desc = "Show git status",
      },
      {
        "<leader>vc",
        "<cmd>Neogit commit<cr>",
        desc = "Git commit",
      },
      {
        "<leader>vpl",
        "<cmd>Neogit pull<cr>",
        desc = "Git pull",
      },
      {
        "<leader>vpu",
        "<cmd>Neogit push<cr>",
        desc = "Git push",
      },
      {
        "<leader>vl",
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
    keys = {
      {
        "<leader>vq",
        "<cmd>DiffviewClose<cr>",
        desc = "Close Diffview",
      },
      {
        "<leader>vo",
        "<cmd>DiffviewOpen<cr>", -- NOTE: Use :tabclose to close (see keymaps)
        desc = "Open Diffview",
      },
    },
  },
  { "tpope/vim-fugitive" },
}
