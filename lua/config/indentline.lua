local status_ok, indent_blankline = pcall(require, "ibl")
if not status_ok then
  vim.notify "'indent_blankline' plugin not found."
  return
end

indent_blankline.setup {}
