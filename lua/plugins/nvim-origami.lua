return {
  {
    "chrisgrieser/nvim-origami",
    event = "VeryLazy",
    opts = {
      foldtext = {
        lineCount = {
          template = "󰁂 %d",
        },
      },
    },
    init = function()
      -- disable vim's auto-folding for it to work properly:
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
    end,
  },
}
