-- vim.cmd "colorscheme default"

-- local colorscheme = "darcula-solid"
-- local colorscheme = "tokyonight"
-- local colorscheme = "darcula"
local colorscheme = "nightfox"
-- local colorscheme = "terafox"

if colorscheme == "tokyonight" then
  local status_ok_color_plug, color_plug = pcall(require, colorscheme)
  if status_ok_color_plug then color_plug.setup {
    style = "night",
  } end
end

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)

if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found")
  return
end
