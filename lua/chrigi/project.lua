local status_ok, project = pcall(require, "project_nvim")
if not status_ok then
	vim.notify("'project_vim' plugin not found.")
	return
end
project.setup({
	-- detection_methods = { "lsp", "pattern" }, -- NOTE: lsp detection will get annoying with multiple langs in one project
	detection_methods = { "pattern" },
})

local tele_status_ok, telescope = pcall(require, "telescope")
if not tele_status_ok then
	vim.notify("'telescope' plugin not found.")
	return
end

telescope.load_extension("projects")
