local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
	vim.notify("'gitsigns' plugings not found.")
	return
end

gitsigns.setup({
	signs = {
		add = { hl = "GitSignsAdd", text = "▎", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
		change = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
		delete = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
		topdelete = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
		changedelete = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
	},
	-- current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
	-- current_line_blame_opts = {
	-- 	delay = 2500,
	--    ignore_whitespace = true
	-- },
})
