local status_ok, neodev = pcall(require, "neodev")
if not status_ok then
  vim.notify("'neodev' plugin not installed.")
  return
end
neodev.setup()
