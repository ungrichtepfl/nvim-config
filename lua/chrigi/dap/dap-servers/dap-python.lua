local status_ok, dap_python = pcall(require, "dap-python")
if not status_ok then
	vim.notify("'dap-python' plugin not found.")
	return
end

dap_python.setup("~/.virtualenvs/debugpy/bin/python") -- pip install depubpy

local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- DAO Configurations
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
		FLASK_DEBUG = "0",
		FLASK_ENV = "development",
		API_HARDWARE_CONFIGURATION = "FLOOR",
		API_NAME = "FLOOR",
	},
})

--[[ table.insert(require("dap").configurations.python, { ]]
--[[ 	type = "python", ]]
--[[ 	request = "launch", ]]
--[[   module = "flask", ]]
--[[ 	name = "Flask: Scewo Integration Tests Wheelchair Floor", ]]
--[[ 	args = { ]]
--[[     "run", ]]
--[[     "--no-debugger", ]]
--[[     "--host", ]]
--[[     "0.0.0.0", ]]
--[[     "--debug", ]]
--[[     "False", ]]
--[[ 		"--ip", ]]
--[[ 		"192.168.0.100", ]]
--[[ 	}, ]]
--[[ 	env = { ]]
--[[ 		API_HARDWARE_CONFIGURATION = "FLOOR", ]]
--[[ 		API_NAME = "FLOOR", ]]
--[[     FLASK_DEBUG=0, ]]
--[[     FLASK_APP = "app.py", ]]
--[[     FLASK_ENV = "development" ]]
--[[   }, ]]
--[[   jinja = true, ]]
--[[   justMyCode = false ]]
--[[  }) ]]

table.insert(require("dap").configurations.python, {
	type = "python",
	request = "attach localhost port 5678",
	connect = {
		port = 5678,
		host = "127.0.0.1",
	},
	mode = "remote",
	name = "Container Attach Debug",
	cwd = vim.fn.getcwd(),
	pathMappings = {
		{
			localRoot = function()
				return vim.fn.input("Local code folder > ", vim.fn.getcwd(), "file")
				--"/home/alpha2phi/workspace/alpha2phi/python-apps/ml-yolo/backend", -- Local folder the code lives
			end,
			remoteRoot = function()
				return vim.fn.input("Container code folder > ", "/", "file")
				-- "/fastapi", -- Wherever your Python code lives in the container.
			end,
		},
	},
})
