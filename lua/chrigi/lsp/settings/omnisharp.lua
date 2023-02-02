-- Add the following snipped to ~/.omnisharp/omnisharp.json:
-- {
--   "RoslynExtensionsOptions": {
--     "enableDecompilationSupport": true
--   }
-- }

local status_ok, omnisharp_ext = pcall(require, "omnisharp_extended")
if not status_ok then
  vim.notify "Plugin 'omnisharp-extended' is not installed"
  return
end

local pid = vim.fn.getpid()

return {
  handlers = {
    ["textDocument/definition"] = omnisharp_ext.handler,
  },
  cmd = {
    "omnisharp",
    "--languageserver",
    "--hostPID",
    tostring(pid),
  },
}
