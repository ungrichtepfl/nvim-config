-- vim.cmd "colorscheme default"

local colorscheme = "tokyonight"

local status_ok_color_plug, color_plug = pcall(require, colorscheme)
if not status_ok_color_plug then vim.notify("Colorscheme plugin" .. colorscheme .. " not found") end

color_plug.setup {
  style = "night",
}

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)

if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found")
  return
end
