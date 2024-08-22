local status_ok, harpoon = pcall(require, "harpoon")
if not status_ok then
  vim.notify "Harpoon not found"
  return
end

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-x>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-d>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():next() end)
