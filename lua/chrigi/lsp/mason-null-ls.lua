local status_ok, mason_null_ls = pcall(require, "mason-null-ls")

if not status_ok then
	vim.notify('"mason-null-ls" plugin not found.')
end

mason_null_ls.setup()
