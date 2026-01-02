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
  keys = {
    -- reset keymaps for diagnostics
    {
      "[d",
      function()
        vim.diagnostic.jump {
          count = -1,
          float = false,
        }
      end,
      desc = "Go to next diagnostics",
    },
    {
      "]d",
      function()
        vim.diagnostic.jump {
          count = 1,
          float = false,
        }
      end,
      desc = "Go to previous diagnostics",
    },
  },
  init = function()
    vim.diagnostic.config { virtual_text = false } -- needs to be disabled
  end,
}
