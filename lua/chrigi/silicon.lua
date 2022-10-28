local status_ok, silicon = pcall(require, "silicon")

if not status_ok then
  vim.notify "'silicon' plugin not found."
  return
end

require("silicon").setup {
  font = "JetBrainsMono Nerd Font Mono=16",
  line_number = true,
  tab_width = 2,
  round_corner = false,
  window_controls = false,
}
