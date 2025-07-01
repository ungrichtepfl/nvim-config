return {
  "ibhagwan/fzf-lua",
  dependencies = { "echasnovski/mini.icons" },
  opts = {
    "hide", -- To have a better resume
  },
  keys = {
    { "<leader>f", "<cmd> FZF<cr>", desc = "Find files" },
    { "<leader>g", "<cmd> FzfLua live_grep<cr>", desc = "Grep word in all files" },
    { "<leader>r", "<cmd> FzfLua resume<cr>", desc = "Resume fzf picker" },
  },
  init = function() require("fzf-lua").register_ui_select() end,
}
