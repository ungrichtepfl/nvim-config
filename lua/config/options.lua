---- LEADER KEYS ----
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

----  GENERAL OPTIONS ------
vim.opt.scrolloff = 8 -- Show at least X lines above the cursor
vim.opt.sidescrolloff = 8 --Show at least X columns left and right to the cursor
vim.opt.cursorline = true -- highlight the current line
vim.opt.number = true -- set numbered lines
vim.opt.relativenumber = true -- set relative numbered lines
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.opt.mouse = "a" -- Fully allow mouse
-- { insert X spaces instead of tab:
vim.opt.tabstop = 4 -- Width of a tab character
vim.opt.shiftwidth = 4 -- Indent width for >>, <<, etc.
vim.opt.softtabstop = 4 -- Insert 4 spaces when pressing <Tab>
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.autoindent = true -- Copy indent from current line
vim.opt.smartindent = true -- Smart indent based on code syntax
-- }
vim.opt.nrformats = "bin,hex,alpha" -- ctrl-x and ctrl-a behaviour
vim.opt.wildmode = "longest:full,full" -- Prioritize exact matches
vim.opt.history = 200 -- How many commands should be remembered
vim.opt.undofile = true -- enable persistent undo
vim.opt.swapfile = false -- If a swapfile is used
vim.opt.timeoutlen = 300 -- time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.signcolumn = "yes" -- always show the sign column, otherwise it would shift the text each time (diagnostics, etc.)
vim.opt.pumheight = 10 -- Otherwise the popup windows are too big
vim.o.updatetime = 300 -- default is 4000ms (4 seconds), so 300ms is much snappier (triggers Curserhold)
----
