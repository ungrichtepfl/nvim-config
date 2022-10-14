local status_ok_ts, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok_ts then
	vim.notify("'nvim-treesitter' plugin not installed.")
	return
end

configs.setup({
	ensure_installed = "all",
	sync_install = false,
	ignore_install = { "" }, -- List of parsers to ignore installing
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "" }, -- list of language that will be disabled
		additional_vim_regex_highlighting = true,
	},
	indent = { enable = true, disable = { "" } },
	-- ts-rainbow plugin extension:
	rainbow = {
		enable = true,
		-- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
		extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
		max_file_lines = nil, -- Do not enable for files with more than n lines, int
		-- colors = {}, -- table of hex strings
		-- termcolors = {} -- table of colour name strings
	},
	-- autopairs plugin (better integration, but optional):
	autopairs = {
		enable = true,
	},
	-- nvim-ts-context-commentstring plugin:
	contex_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
})

-- vim.opt.foldmethod     = 'expr'
-- vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
---WORKAROUND
vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufNew", "BufNewFile", "BufWinEnter" }, {
	group = vim.api.nvim_create_augroup("TS_FOLD_WORKAROUND", {}),
	callback = function()
		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
	end,
})
---ENDWORKAROUND

local status_ts_context, ts_context = pcall(require, "treesitter-context")
if not status_ts_context then
	vim.notify("'treesitter_context' plugin not found.")
	return
end

ts_context.setup()
