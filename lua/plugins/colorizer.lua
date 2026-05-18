return {
  "catgoose/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = {
    buftypes = { "*", "!terminal", "!prompt", "!nofile" },
  },
}
