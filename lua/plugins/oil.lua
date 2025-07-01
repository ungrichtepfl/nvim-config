return {
  {
    "stevearc/oil.nvim",
    opts = {
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _) return name == ".." end,
      },
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      win_options = {
        signcolumn = "yes:2",
      },
      git = {
        mv = function(_, _) return true end,
      },
    },
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    keys = { { "<leader>e", ":Oil<cr>", desc = "Toggle Oil" } },
  },
  {
    "refractalize/oil-git-status.nvim",
    dependencies = {
      "stevearc/oil.nvim",
    },
    config = true,
  },
}
