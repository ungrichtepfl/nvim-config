vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)")
vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)")
vim.keymap.set("i", "<C-\\>", "<Plug>(copilot-dismiss)")
vim.keymap.set("i", "<C-a>", 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false,
})
vim.g.copilot_no_tab_map = true
vim.g.copilot_enabled = false -- Disable by default
