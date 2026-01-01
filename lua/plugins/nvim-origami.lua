return {
  {
    "chrisgrieser/nvim-origami",
    opts = {
      foldtext = {
        lineCount = {
          template = "󰁂 %d",
        },
      },
      foldKeymaps = {
        setup = false, -- modifies `h`, `l`, and `$`
      },
    },
    init = function()
      -- disable vim's auto-folding for it to work properly:
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
    end,
  },
}
