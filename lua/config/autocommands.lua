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
  callback = function() vim.bo.formatoptions = vim.bo.formatoptions:gsub("c", ""):gsub("r", ""):gsub("o", "") end,
})

-- Make buffers not listed
vim.api.nvim_create_autocmd("FileType", {
  group = general_settings,
  pattern = "qf",
  callback = function() vim.bo.buflisted = false end,
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
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = general_settings,
  pattern = { "c", "cpp", "rust", "javascript", "typescript", "json", "html", "css" },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
  end,
})

local mail_group = vim.api.nvim_create_augroup("_mail", { clear = true })

-- No wrapping during mail
vim.api.nvim_create_autocmd("FileType", {
  group = mail_group,
  pattern = "mail",
  callback = function()
    -- No wrapping
    vim.bo.textwidth = 0
    vim.bo.wrapmargin = 0
    -- t – Auto-wrap text using textwidth
    -- a – Auto formatting
    vim.bo.formatoptions = vim.bo.formatoptions:gsub("t", ""):gsub("a", "")
    vim.wo[0][0].spell = true
    vim.keymap.set( -- FIXME: Somehow neomutt adds another keymap
      "n",
      "<leader>q",
      ":conf q<CR>",
      { buffer = true, silent = true, desc = "Close window with confirmation" }
    )
  end,
})

local git_group = vim.api.nvim_create_augroup("_git", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = git_group,
  pattern = "gitcommit",
  callback = function()
    vim.wo[0][0].wrap = true
    vim.wo[0][0].spell = true
  end,
})

local markdown_group = vim.api.nvim_create_augroup("_markdown", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = markdown_group,
  pattern = "markdown",
  callback = function()
    vim.wo[0][0].wrap = true
    vim.wo[0][0].spell = true
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
    vim.wo[0][0].number = false
    vim.wo[0][0].relativenumber = false
  end,
})
