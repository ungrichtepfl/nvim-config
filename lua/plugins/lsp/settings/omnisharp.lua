-- Add the following snipped to ~/.omnisharp/omnisharp.json:
-- {
--   "RoslynExtensionsOptions": {
--     "enableDecompilationSupport": true
--   }
-- }

local status_ok, omnisharp_ext = pcall(require, "omnisharp_extended")
local handlers = {}
if status_ok then handlers = {
  ["textDocument/definition"] = omnisharp_ext.handler,
} end

local pid = vim.fn.getpid()

return {
  handlers = handlers,
  cmd = {
    "omnisharp",
    "--languageserver",
    "--hostPID",
    tostring(pid),
  },
}
