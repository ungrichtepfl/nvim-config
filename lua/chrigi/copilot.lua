vim.cmd [[imap <silent> <C-j> <Plug>(copilot-next)]]
vim.cmd [[imap <silent> <C-k> <Plug>(copilot-previous)]]
vim.cmd [[imap <silent> <C-\> <Plug>(copilot-dismiss)]]
vim.cmd [[imap <silent><script><expr> <C-a> copilot#Accept("\<CR>")]]
vim.cmd [[let g:copilot_no_tab_map = v:true]]
