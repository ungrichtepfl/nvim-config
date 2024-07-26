local function rustaceanvim_settings()
  local opts = {
    server = {
      capabilities = require("config.lsp.handlers").capabilities,
      on_attach = require("config.lsp.handlers").on_attach,
    },
  }

  local status_ok, server_settings = pcall(require, "config.lsp.settings.rust_analyzer")
  if status_ok then
    local server_opts = vim.tbl_deep_extend("force", opts.server, { default_settings = server_settings.settings })
    opts.server = server_opts
  end

  return opts
end

vim.g.rustaceanvim = rustaceanvim_settings
