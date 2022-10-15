local status_ok_dap, dap = pcall(require, "dap")
if not status_ok_dap then
  vim.notify "'dap' plugin not found."
  return
end

-- TODO: Check out mason-dap (https://github.com/jayp0521/mason-nvim-dap.nvim)

--load from .vscode/launch.json files
require("dap.ext.vscode").load_launchjs()

local dap_servers = { "dap-python" }
for _, dap_server in ipairs(dap_servers) do
  require("chrigi.dap.dap-servers." .. dap_server)
end

local status_ok_virtual_text, virtual_text = pcall(require, "nvim-dap-virtual-text")
if not status_ok_virtual_text then
  vim.notify "'nvim-dap-virtual-text' plugin not found."
else
  virtual_text.setup()
end

local status_ok_dapui, dapui = pcall(require, "dapui")
if not status_ok_dapui then
  vim.notify "'dapui' plugin not found."
  return
end

dapui.setup()

-- automatic startup and shutdown:
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
