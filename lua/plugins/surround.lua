return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  opts = {},
  keys = {
    {
      "<C-g><C-s>", -- Easier keymap
      "<C-g>S",
      mode = "i",
      remap = true,
    },
  },
}
