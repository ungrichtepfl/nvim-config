local status_ok, better_escape = pcall(require, "better_escape")
if not status_ok then
  vim.notify "'better_escape' plugin not found."
  return
end

better_escape.setup {}
