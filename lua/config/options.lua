---- LEADER KEYS ----
vim.g.mapleader = " "
vim.g.maplocalleader = "-"

---- Default colorscheme ----
vim.cmd.colorscheme "habamax"

----  GENERAL OPTIONS ------
vim.o.scrolloff = 8 -- Show at least X lines above the cursor
vim.o.sidescrolloff = 8 --Show at least X columns left and right to the cursor
vim.o.cursorline = true -- highlight the current line
vim.o.number = true -- keymap numbered lines
vim.o.relativenumber = true -- keymap relative numbered lines
vim.o.hlsearch = false -- Do not highlight all searches
-- vim.o.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.o.mouse = "a" -- Fully allow mouse
-- { insert X spaces instead of tab:
vim.o.tabstop = 2 -- Width of a tab character
vim.o.shiftwidth = 2 -- Indent width for >>, <<, etc.
vim.o.softtabstop = 2 -- Insert X spaces when pressing <Tab>
vim.o.expandtab = true -- Convert tabs to spaces
vim.o.autoindent = true -- Copy indent from current line
vim.o.smartindent = true -- Smart indent based on code syntax
-- }
vim.o.nrformats = "bin,hex" -- ctrl-x and ctrl-a behaviour
vim.o.completeopt = "menuone,noselect,fuzzy" -- How completion should work
vim.o.wildmode = "longest:full,full" -- Prioritize exact matches
vim.o.wildignore = vim.o.wildignore .. "*.o,*.obj,*.pyc,*.class*.jar"
vim.o.history = 200 -- How many commands should be remembered
vim.o.writebackup = false -- Do not write a backup file for the current unsaved bufferchanges
vim.o.undofile = true -- enable persistent undo
vim.o.swapfile = false -- If a swapfile is used
vim.o.timeoutlen = 300 -- time to wait for a mapped sequence to complete (in milliseconds)
vim.o.signcolumn = "yes" -- always show the sign column, otherwise it would shift the text each time (diagnostics, etc.)
vim.o.pumheight = 10 -- Otherwise the popup windows are too big
vim.o.synmaxcol = 300 -- Only highlight a line with less then X columns
vim.o.updatetime = 300 -- default is 4000ms (4 seconds), so 300ms is much snappier (triggers Curserhold)
vim.o.timeoutlen = 500 -- Wait milliseconds for mapped secence to complete
vim.o.ttimeoutlen = 0 -- Milliseconds to wait for a key code sequence to complete
vim.o.iskeyword = vim.o.iskeyword .. ",-" -- What characters are considered as a "word"
vim.o.path = vim.o.path .. ",**" -- Such that "find" also considers subdirectories
vim.o.splitbelow = true -- New window will be opened below
vim.o.splitright = true -- New window will be on the right side
vim.o.foldmethod = "expr" -- Use foldexpr as fold
vim.o.foldexpr = "nvim_treesitter#foldexpr()" -- Which foldexpr to use
vim.o.foldlevel = 99 -- Do not start folded in
-- Performance improvements
vim.o.maxmempattern = 20000 -- Increase memory for regex matches
----
