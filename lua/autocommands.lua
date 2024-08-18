-- autocmd! remove all autocommands, if entered under a group it will clear that group
vim.cmd [[
  augroup _general_settings
    autocmd!
    autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR>
    autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Search', timeout = 200})
    autocmd BufWinEnter * :set formatoptions-=cro
    autocmd FileType qf set nobuflisted
  augroup end

  augroup _git
    autocmd!
    autocmd FileType gitcommit setlocal wrap
    autocmd FileType gitcommit setlocal spell
  augroup end

  augroup _markdown
    autocmd!
    autocmd FileType markdown setlocal wrap
    autocmd FileType markdown setlocal spell
  augroup end

  augroup _auto_resize
    autocmd!
    autocmd VimResized * tabdo wincmd =
  augroup end

  augroup _alpha
    autocmd!
    autocmd User AlphaReady set showtabline=0 | autocmd BufUnload <buffer> set showtabline=2
  augroup end

  augroup _dap
    autocmd!
    autocmd FileType dap-repl lua require('dap.ext.autocompl').attach()
  augroup end
]]

-- Autocommand to open fex.nvim when starting Neovim with a directory
local status_ok, _ = pcall(require, "fex")
if status_ok then
  vim.api.nvim_create_autocmd("BufEnter", {
    nested = true,
    callback = function()
      local directory = vim.fn.isdirectory(vim.fn.expand "%")
      if directory == 1 then vim.cmd "Fex" end
    end,
  })
end
