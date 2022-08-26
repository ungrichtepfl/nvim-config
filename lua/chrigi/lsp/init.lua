local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  vim.notify("'lspconfig' not found")
	return
end

require("chrigi.lsp.lsp-installer")
require("chrigi.lsp.handlers").setup()
