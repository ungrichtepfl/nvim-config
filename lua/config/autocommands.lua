local general_settings = vim.api.nvim_create_augroup("_general_settings", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = general_settings,
  pattern = "*",
  callback = function() vim.highlight.on_yank { higroup = "Search", timeout = 200 } end,
})

-- q to close certain buffers
vim.api.nvim_create_autocmd("FileType", {
  group = general_settings,
  pattern = { "qf", "help", "man", "lspinfo", "vim" },
  callback = function() vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true }) end,
})

-- Disable auto-comment on newline (leave here as maybe I want it on some ft in the future)
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = general_settings,
  pattern = "*",
  -- c: auto-wrap comments
  -- r: auto-insert comment leader on <CR>
  -- o: auto-insert comment leader on o/O
  callback = function() vim.opt_local.formatoptions:remove { "c", "r", "o" } end,
})

-- Make buffers not listed
vim.api.nvim_create_autocmd("FileType", {
  group = general_settings,
  pattern = "qf",
  callback = function() vim.opt_local.buflisted = false end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = general_settings,
  callback = require("config.utils").goto_last_edited,
})

-- Set filetype-specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = general_settings,
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = general_settings,
  pattern = { "c", "cpp", "rust", "javascript", "typescript", "json", "html", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

local mail_group = vim.api.nvim_create_augroup("_mail", { clear = true })

-- No wrapping during mail
vim.api.nvim_create_autocmd("FileType", {
  group = mail_group,
  pattern = "mail",
  callback = function()
    -- No wrapping
    vim.opt_local.textwidth = 0
    vim.opt_local.wrapmargin = 0
    -- t – Auto-wrap text using textwidth
    -- a – Auto formatting
    vim.opt_local.formatoptions:remove { "t", "a" }
    vim.opt_local.spell = true
  end,
})

local git_group = vim.api.nvim_create_augroup("_git", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = git_group,
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

local markdown_group = vim.api.nvim_create_augroup("_markdown", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = markdown_group,
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- NOTE: Uncomment if window positions are weird
-- local resize_group = vim.api.nvim_create_augroup("_auto_resize", { clear = true })
-- vim.api.nvim_create_autocmd("VimResized", {
--   group = resize_group,
--   pattern = "*",
--   callback = function()
--     vim.cmd("tabdo wincmd =")
--   end,
-- })

vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("_custom_term_open", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})
