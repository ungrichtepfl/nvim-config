require "chrigi.options"
require "chrigi.keymaps"
require "chrigi.plugins"
require "chrigi.colorscheme"
require "chrigi.treesitter"
require "chrigi.cmp"
require "chrigi.neodev"
require "chrigi.lsp"
require "chrigi.telescope"
require "chrigi.autopairs"
require "chrigi.comment"
require "chrigi.gitsigns"
require "chrigi.nvim-tree"
require "chrigi.bufferline"
require "chrigi.toggleterm"
require "chrigi.lualine"
require "chrigi.project"
require "chrigi.impatient"
require "chrigi.indentline"
require "chrigi.alpha"
require "chrigi.dap" -- Needs to be after lsp as soon as manson is used
require "chrigi.todo-comments"
require "chrigi.trouble"
require "chrigi.whichkey"
require "chrigi.neogen"
require "chrigi.git_conflict"
require "chrigi.autocommands"
require "chrigi.lightbulb"
require "chrigi.notify"
require "chrigi.illuminate"
require "chrigi.dressing"
require "chrigi.better_escape"
require "chrigi.refactoring"
require "chrigi.surround"
require "chrigi.diffview"
require "chrigi.scrollbar" -- needs to be after gitsigns
require "chrigi.lsp_signature"
require "chrigi.pretty-fold"
require "chrigi.copilot"
require "chrigi.no_neck_pain"

-- FIXME: Hack from https://github.com/OmniSharp/omnisharp-roslyn/issues/2483#issuecomment-1546721190
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local function toSnakeCase(str) return string.gsub(str, "%s*[- ]%s*", "_") end

    if client.name == "omnisharp" then
      local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers
      for i, v in ipairs(tokenModifiers) do
        tokenModifiers[i] = toSnakeCase(v)
      end
      local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes
      for i, v in ipairs(tokenTypes) do
        tokenTypes[i] = toSnakeCase(v)
      end
    end
  end,
})
