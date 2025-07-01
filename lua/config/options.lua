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
-- insert X spaces instead of tab:
vim.opt.tabstop = 4 -- Width of a tab character
vim.opt.shiftwidth = 4 -- Indent width for >>, <<, etc.
vim.opt.softtabstop = 4 -- Insert 4 spaces when pressing <Tab>
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.autoindent = true -- Copy indent from current line
vim.opt.smartindent = true -- Smart indent based on code syntax
--
vim.opt.nrformats = "bin,hex,alpha" -- ctrl-x and ctrl-a behaviour
vim.opt.wildmode = "full" -- Make autocomplete in command mode more like zsh
vim.opt.history = 200 -- How many commands should be remembered
vim.opt.undofile = true -- enable persistent undo
vim.opt.swapfile = false -- If a swapfile is used
vim.opt.timeoutlen = 300  -- time to wait for a mapped sequence to complete (in milliseconds)
----
