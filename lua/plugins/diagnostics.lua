return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  opts = {
    options = {
      override_open_float = true,
      use_icons_from_diagnostic = true,
      show_all_diags_on_cursorline = true,
    },
  },
  config = function(_, opts)
    require("tiny-inline-diagnostic").setup(opts)
    -- reset keymaps for diagnostics
    vim.keymap.set(
      "n",
      "[d",
      function()
        vim.diagnostic.jump {
          count = -1,
          float = false,
        }
      end,
      { desc = "Go to next diagnostics" }
    )
    vim.keymap.set(
      "n",
      "]d",
      function()
        vim.diagnostic.jump {
          count = 1,
          float = false,
        }
      end,
      { desc = "Go to previous diagnostics" }
    )
    vim.diagnostic.config { virtual_text = false } -- needs to be disabled
  end,
}
