return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  keys = {
    { "<leader>f", "<cmd> FZF<cr>", desc = "Find files" },
    { "<leader>r", "<cmd> FzfLua live_grep<cr>", desc = "Grep word in all files" },
  },
}
