local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
  vim.notify "'gitsigns' plugings not found."
  return
end

gitsigns.setup {
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "契" },
    topdelete = { text = "契" },
    changedelete = { text = "▎" },
  },
}

vim.api.nvim_set_hl(0, "GitSignsAdd", { link = "GitSignsAdd" })
vim.api.nvim_set_hl(0, "GitSignsAddLn", { link = "GitSignsAddLn" })
vim.api.nvim_set_hl(0, "GitSignsAddNr", { link = "GitSignsAddNr" })
vim.api.nvim_set_hl(0, "GitSignsChange", { link = "GitSignsChange" })
vim.api.nvim_set_hl(0, "GitSignsChangeLn", { link = "GitSignsChangeLn" })
vim.api.nvim_set_hl(0, "GitSignsChangeNr", { link = "GitSignsChangeNr" })
vim.api.nvim_set_hl(0, "GitSignsChangedelete", { link = "GitSignsChange" })
vim.api.nvim_set_hl(0, "GitSignsChangedeleteLn", { link = "GitSignsChangeLn" })
vim.api.nvim_set_hl(0, "GitSignsChangedeleteNr", { link = "GitSignsChangeNr" })
vim.api.nvim_set_hl(0, "GitSignsDelete", { link = "GitSignsDelete" })
vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { link = "GitSignsDeleteLn" })
vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { link = "GitSignsDeleteNr" })
vim.api.nvim_set_hl(0, "GitSignsTopdelete", { link = "GitSignsDelete" })
vim.api.nvim_set_hl(0, "GitSignsTopdeleteLn", { link = "GitSignsDeleteLn" })
vim.api.nvim_set_hl(0, "GitSignsTopdeleteNr", { link = "GitSignsDeleteNr" })
