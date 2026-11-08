return {
  "3rd/image.nvim",
  ft = "markdown",
  enabled = function() return vim.env.ZELLIJ == nil end, -- cannot place images inside zellij (3rd/image.nvim#161)
  build = false, -- magick_cli needs no lua rock
  opts = {
    backend = "ueberzug", -- alacritty has no kitty graphics or sixel support
    -- Default, set explicitly because build = false depends on it: it calls the installed ImageMagick
    -- CLI, while magick_rock needs the ImageMagick dev package and a LuaRocks build
    processor = "magick_cli",
  },
}
