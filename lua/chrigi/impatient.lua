local status_ok, impatient = pcall(require, "impatient")
if not status_ok then
	vim.notify("'impatient' plugin not found.")
	return
end

impatient.enable_profile()
