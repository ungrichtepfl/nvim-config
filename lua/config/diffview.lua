local status_ok, diffview = pcall(require, "diffview")

if not status_ok then
  vim.notify "'diffview' plugin not found."
  return
end

diffview.setup {}
