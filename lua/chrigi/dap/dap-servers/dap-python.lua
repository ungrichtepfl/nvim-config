local status_ok, dap_python = pcall(require, "dap-python")
if not status_ok then
	vim.notify("'dap-python' plugin not found.")
	return
end

dap_python.setup("~/.virtualenvs/debugpy/bin/python") -- pip install depubpy

table.insert(require("dap").configurations.python, {
	type = "python",
	request = "launch",
	name = "Scewo Integration Tests Wheelchair Floor",
	program = "${file}",
	justMyCode = false,
	args = {
		"--ip",
		"192.168.0.100",
	},
	env = {
		API_HARDWARE_CONFIGURATION = "FLOOR",
		API_NAME = "FLOOR",
	},
})
