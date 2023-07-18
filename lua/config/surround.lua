local status_ok, surround = pcall(require, "nvim-surround")

if not status_ok then
  vim.notify "'nvim-surround' plugin not found."
  return
end

surround.setup {}
