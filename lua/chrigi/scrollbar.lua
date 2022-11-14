local status_ok, scrollbar = pcall(require, "scrollbar")

if not status_ok then
  vim.notify "'scrollbar' plugin not found."
  return
end

scrollbar.setup()

local status_ok_hlslens, _ = pcall(require, "hlslens")

if not status_ok_hlslens then
  vim.notify "'hlslens' plugin not found."
else
  require("scrollbar.handlers.search").setup {}
end

local status_ok_gitsigns, _ = pcall(require, "gitsigns")

if not status_ok_gitsigns then
  vim.notify "'gitsigns' plugin not found."
else
  require("scrollbar.handlers.gitsigns").setup()
end
