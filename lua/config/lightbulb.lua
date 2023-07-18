local status_ok, lightbulb = pcall(require, "nvim-lightbulb")
if not status_ok then vim.notify "'nvim-lightbulb' plugin not found" end

lightbulb.setup {
  autocmd = {
    enabled = true,
  },
}
