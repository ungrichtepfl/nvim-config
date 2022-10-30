local M = {}

M.setup = function()
  local dap = require "dap"

  dap.configurations.rust = {
    require("chrigi.dap.dap-servers.dap-lldb").lldb_config,
  }
end

return M
