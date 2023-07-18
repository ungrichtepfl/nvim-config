local status_ok, notify = pcall(require, "notify")
if not status_ok then
  vim.notify "'notify' plugin not found."
  return
end

notify.setup {
  level = vim.log.levels.DEBUG,
  stages = "fade",
  timeout = 500,
}

local tele_status_ok, telescope = pcall(require, "telescope")
if not tele_status_ok then
  vim.notify "'telescope' plugin not found."
  return
end

telescope.load_extension "notify"
