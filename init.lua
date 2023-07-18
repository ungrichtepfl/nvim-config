require "chrigi.options"
require "chrigi.keymaps"
require "chrigi.plugins"
require "chrigi.colorscheme"
require "chrigi.autocommands"

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
