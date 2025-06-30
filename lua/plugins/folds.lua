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
    }, -- needed even when using default config

    -- recommended: disable vim's auto-folding
    init = function()
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
    end,
  },
}
