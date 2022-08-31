local status_ok, mason = pcall(require, "mason")
if not status_ok then
  vim.notify("'mason' not found.")
	return
end

local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok then
  vim.notify("'mason-lspconfig' not found.")
	return
end

local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  vim.notify("'lspconfig' not found")
	return
end

local servers = {
  "jsonls",
  "pyright",
  "sumneko_lua",
  "bashls",
  "clangd", -- C/C++
  "cmake",
  "dockerls",
  "hls", -- Haskell
  "marksman", -- Markdown
  "rust_analyser",
  "yamlls",
  "elmls",
  "taplo", -- TOML
  "lemminx", -- "XML"
}

mason.setup()
mason_lspconfig.setup({
  ensure_installed = servers
})

local lspconfig = require("lspconfig")

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
local on_attach = require("chrigi.lsp.handlers").on_attach
local capabilities = require("chrigi.lsp.handlers").capabilities

for _, server in ipairs(servers) do
  local opts = {
		on_attach = on_attach,
    capabilities = capabilities
  }
	local server_status_ok, server_opts = pcall(require, "chrigi.lsp.settings." .. server)
  if server_status_ok then
	  opts = vim.tbl_deep_extend("force", server_opts, opts)
  end

  lspconfig[server].setup(opts)
end
