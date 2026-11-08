local color = ""
-- color = "ash"
-- color = "iceberg-dark"
-- color = "zen"
color = "kanso-zen"
-- color ="tokyonight-moon"
-- color ="kanagawa-dragon"
-- color = "mellifluous"

return {
  {
    "ramojus/mellifluous.nvim",
    lazy = false,
    enabled = color:find "^mellifluous$" ~= nil,
    priority = 1000,
    init = function() vim.cmd.colorscheme(color) end,
  },
  {
    "bjarneo/ash.nvim",
    lazy = false,
    enabled = color:find "^ash$" ~= nil,
    priority = 1000,
    init = function() vim.cmd.colorscheme(color) end,
  },
  {
    "nendix/zen.nvim",
    lazy = false,
    enabled = color:find "^zen$" ~= nil,
    priority = 1000,
    init = function() vim.cmd.colorscheme(color) end,
  },
  {
    "oahlen/iceberg.nvim",
    lazy = false,
    enabled = color:find "^iceberg" ~= nil,
    priority = 1000,
    init = function() vim.cmd.colorscheme(color) end,
  },
  {
    "webhooked/kanso.nvim",
    lazy = false,
    enabled = color:find "^kanso" ~= nil,
    priority = 1000,
    opts = {
      compile = true,
      overrides = function(colors)
        -- Kanso's own comment style: kept for doc comments, commit messages and oil,
        -- only code comments are orange.
        local kanso_comment = { fg = colors.theme.syn.comment, italic = true }
        return {
          Comment = { fg = colors.palette.yellowSaturated, italic = false },
          ["@comment.documentation"] = kanso_comment,
          ["@lsp.typemod.comment.documentation"] = kanso_comment,
          ["@comment.gitcommit"] = kanso_comment,
          ["@comment.jjdescription"] = kanso_comment,
          gitcommitComment = kanso_comment,
          jjComment = kanso_comment,
          OilEmpty = kanso_comment,
          OilHidden = kanso_comment,
          OilLinkTarget = kanso_comment,
          OilTrashSourcePath = kanso_comment,
          DiagnosticUnnecessary = { fg = colors.theme.syn.comment },
        }
      end,
    },
    build = ":KansoCompile",
    init = function() vim.cmd.colorscheme(color) end,
  },
  {
    "folke/tokyonight.nvim",
    enabled = color:find "^tokyonight" ~= nil,
    lazy = false,
    priority = 1000,
    opts = {},
    init = function() vim.cmd.colorscheme(color) end,
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
    init = function() vim.cmd.colorscheme(color) end,
  },
}
