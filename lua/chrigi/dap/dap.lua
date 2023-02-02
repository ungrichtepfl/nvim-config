local status_ok_dap, dap = pcall(require, "dap")
if not status_ok_dap then
  vim.notify "'dap' plugin not found."
  return
end

-- TODO: Check out mason-dap (https://github.com/jayp0521/mason-nvim-dap.nvim)

--load from .vscode/launch.json files
require("dap.ext.vscode").load_launchjs()

local dap_servers = { "dap-python", "dap-lldb", "dap-rust", "csharp" }
for _, dap_server in ipairs(dap_servers) do
  require("chrigi.dap.dap-servers." .. dap_server).setup()
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

dapui.setup {
  expand_lines = true,
  icons = { expanded = "", collapsed = "", circular = "" },
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.33 },
        { id = "breakpoints", size = 0.17 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 0.33,
      position = "right",
    },
    {
      elements = {
        { id = "repl", size = 0.45 },
        { id = "console", size = 0.55 },
      },
      size = 0.27,
      position = "bottom",
    },
  },
  floating = {
    max_height = 0.9,
    max_width = 0.5, -- Floats will be treated as percentage of your screen.
    border = vim.g.border_chars, -- Border style. Can be 'single', 'double' or 'rounded'
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
}

vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })

-- automatic startup and shutdown:
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
