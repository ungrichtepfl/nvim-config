local status_ok_dap, _ = pcall(require, "dap")
if not status_ok_dap then
	vim.notify("'dap' plugin not found.")
	return
end

local status_ok_dapui, dapui = pcall(require, "dapui")
if not status_ok_dapui then
	vim.notify("'dapui' plugin not found.")
	return
end

dapui.setup()

local dap_servers = { "dap-python" }
for _, dap_server in ipairs(dap_servers) do
	require("chrigi.dap.dap-servers." .. dap_server)
end
