return {
  {
    "chrisgrieser/nvim-origami",
    event = "VeryLazy",
    opts = {
      autoFold = {
        enabled = false, -- FIXME: Generates an error in oil.nvim if true
      },
      foldKeymaps = {
        setup = false, -- modifies `h` and `l`
      },
      foldtext = {
        lineCount = {
          template = "󰁂 %d",
        },
      },
    },

    init = function()
      -- disable vim's auto-folding:
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
    end,
  },
}
