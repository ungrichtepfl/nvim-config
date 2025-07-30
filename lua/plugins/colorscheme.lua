local color = "kanso-zen"
-- local color = "tokyonight-moon"
-- local color = "kanagawa-dragon"
-- local color = "iceberg-dark"

return {
  {
    "oahlen/iceberg.nvim",
    lazy = false,
    enabled = color:find "^iceberg" ~= nil,
    priority = 1000,
    init = function()
      -- load the colorscheme here
      vim.cmd.colorscheme(color)
    end,
  },
  {
    "webhooked/kanso.nvim",
    lazy = false,
    enabled = color:find "^kanso" ~= nil,
    priority = 1000,
    opts = {
      compile = true,
    },
    build = ":KansoCompile",
    init = function()
      -- load the colorscheme here
      vim.cmd.colorscheme(color)
    end,
  },
  {
    "folke/tokyonight.nvim",
    enabled = color:find "^tokyonight" ~= nil,
    lazy = false,
    priority = 1000,
    opts = {},
    init = function()
      -- load the colorscheme here
      vim.cmd.colorscheme(color)
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    enabled = color:find "^kanagawa" ~= nil,
    priority = 1000,
    opts = {
      compile = true,
    },
    build = ":KanagawaCompile",
    init = function()
      -- load the colorscheme here
      vim.cmd.colorscheme(color)
    end,
  },
}
