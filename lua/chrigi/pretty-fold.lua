local status_ok, pretty_fold = pcall(require, "pretty-fold")

if not status_ok then
  vim.notify "'pretty-fold' plugin not found."
  return
end
pretty_fold.setup()
