---- LEADER KEYS ----
vim.g.mapleader = " "
vim.g.maplocalleader = " "
---- Default colorscheme ----
vim.cmd.colorscheme "habamax"

----  GENERAL OPTIONS ------
vim.opt.scrolloff = 8 -- Show at least X lines above the cursor
vim.opt.sidescrolloff = 8 --Show at least X columns left and right to the cursor
vim.opt.cursorline = true -- highlight the current line
vim.opt.number = true -- keymap numbered lines
vim.opt.relativenumber = true -- keymap relative numbered lines
-- vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.opt.mouse = "a" -- Fully allow mouse
-- { insert X spaces instead of tab:
vim.opt.tabstop = 2 -- Width of a tab character
vim.opt.shiftwidth = 2 -- Indent width for >>, <<, etc.
vim.opt.softtabstop = 2 -- Insert X spaces when pressing <Tab>
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.autoindent = true -- Copy indent from current line
vim.opt.smartindent = true -- Smart indent based on code syntax
-- }
vim.opt.nrformats = "bin,hex" -- ctrl-x and ctrl-a behaviour
vim.opt.completeopt = "menuone,noselect,fuzzy" -- How completion should work
vim.opt.wildmode = "longest:full,full" -- Prioritize exact matches
vim.opt.wildignore:append { "*.o", "*.obj", "*.pyc", "*.class", "*.jar" }
vim.opt.history = 200 -- How many commands should be remembered
vim.opt.writebackup = false -- Do not write a backup file for the current unsaved bufferchanges
vim.opt.undofile = true -- enable persistent undo
vim.opt.swapfile = false -- If a swapfile is used
vim.opt.timeoutlen = 300 -- time to wait for a mapped sequence to complete (in milliseconds)
vim.opt.signcolumn = "yes" -- always show the sign column, otherwise it would shift the text each time (diagnostics, etc.)
vim.opt.pumheight = 10 -- Otherwise the popup windows are too big
vim.opt.synmaxcol = 300 -- Only highlight a line with less then X columns
vim.opt.updatetime = 300 -- default is 4000ms (4 seconds), so 300ms is much snappier (triggers Curserhold)
vim.opt.timeoutlen = 500 -- Wait milliseconds for mapped secence to complete
vim.opt.ttimeoutlen = 0 -- Milliseconds to wait for a key code sequence to complete
vim.opt.iskeyword:append "-" -- What characters are considered as a "word"
vim.opt.path:append "**" -- Such that "find" also considers subdirectories
vim.opt.splitbelow = true -- New window will be opened below
vim.opt.splitright = true -- New window will be on the right side
vim.opt.foldmethod = "expr" -- Use foldexpr as fold
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- Which foldexpr to use
vim.opt.foldlevel = 99 -- Do not start folded in
vim.opt.diffopt:append "linematch:60" -- As recommended in help
-- Performance improvements
vim.opt.maxmempattern = 20000 -- Increase memory for regex matches
----
