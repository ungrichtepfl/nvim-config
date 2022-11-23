local status_ok, lsp_signature = pcall(require, "lsp_signature")

if not status_ok then
  vim.notify "'lsp_signature' plugin not found."
  return
end

lsp_signature.setup {}
