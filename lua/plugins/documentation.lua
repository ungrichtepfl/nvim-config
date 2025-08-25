return {
  {
    "kkoomen/vim-doge",
    cmd = "DogeGenerate",
    lazy = false, -- Already lazy on filetypes
    build = [[:call doge#install()]],
    keys = {
      {
        "<leader><leader>d",
        "<Plug>(doge-generate)",
        desc = "Generate documentation",
      },
    },
    init = function() vim.g.doge_enable_mappings = 0 end,
  },
}
