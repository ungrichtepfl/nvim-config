local status_ok, dap_python = pcall(require, "dap-python")
if not status_ok then
	vim.notify("'dap-python' plugin not found.")
	return
end

dap_python.setup("~/.virtualenvs/debugpy/bin/python") -- pip install depubpy
