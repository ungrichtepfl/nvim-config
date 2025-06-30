return {
  "ibhagwan/fzf-lua",
  dependencies = { "echasnovski/mini.icons" },
  opts = {},
  keys = {
    { "<leader>f", "<cmd> FZF<cr>", desc = "Find files" },
    { "<leader>r", "<cmd> FzfLua live_grep<cr>", desc = "Grep word in all files" },
  },
}
