local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
	vim.notify("'nvim-lsp-installer' not found.")
	return
end

local lspconfig = require("lspconfig")

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
local on_attach = require("chrigi.lsp.handlers").on_attach
local capabilities = require("chrigi.lsp.handlers").capabilities

for _, server in ipairs({ "jsonls", "pyright", "sumneko_lua" }) do
	local opts = {
		on_attach = on_attach,
		capabilities = capabilities,
	}
	local server_status_ok, server_opts = pcall(require, "chrigi.lsp.settings." .. server)
	if server_status_ok then
		opts = vim.tbl_deep_extend("force", server_opts, opts)
	end

	lspconfig[server].setup(opts)
end
