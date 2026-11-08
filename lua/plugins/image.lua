return {
  "3rd/image.nvim",
  ft = "markdown",
  build = false,
  opts = {
    backend = "kitty",
    -- Default, set explicitly because build = false depends on it: it calls the installed ImageMagick
    -- CLI, while magick_rock needs the ImageMagick dev package and a LuaRocks build
    processor = "magick_cli",
  },
}
