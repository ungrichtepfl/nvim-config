local status_ok, refactoring = pcall(require, "refactoring")
if not status_ok then
  vim.notify "'refactoring' plugin not found."
  return
end

refactoring.setup {}
