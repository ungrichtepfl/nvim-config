local function haskell_tools_settings()
  local opts = {
    hls = {
      capabilities = require("config.lsp.handlers").capabilities,
      on_attach = require("config.lsp.handlers").on_attach,
    },
  }

  local status_ok, server_settings = pcall(require, "config.lsp.settings.haskell_language_server")
  if status_ok then
    local hls_opts = vim.tbl_deep_extend("force", opts.hls, { default_settings = server_settings.settings })
    opts.hls = hls_opts
  end

  return opts
end

vim.g.haskell_tools = haskell_tools_settings
