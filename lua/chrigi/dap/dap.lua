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

local status_ok_virtual_text, virtual_text = pcall(require, "nvim-dap-virtual-text")
if not status_ok_virtual_text then
	vim.notify("'nvim-dap-virtual-text' plugin not found.")
	return
end

virtual_text.setup()
dapui.setup()

local dap_servers = { "dap-python" }
for _, dap_server in ipairs(dap_servers) do
	require("chrigi.dap.dap-servers." .. dap_server)
end
