return {
  "ibhagwan/fzf-lua",
  dependencies = { "echasnovski/mini.icons" },
  opts = {
    {
      "hide", -- To have a better resume
    },
  },
  keys = {
    { "<leader>f", "<cmd> FzfLua files<cr>", desc = "Find files" },
    { "<leader>g", "<cmd> FzfLua live_grep<cr>", desc = "Grep word in all files" },
    { "<leader>r", "<cmd> FzfLua resume<cr>", desc = "Resume fzf picker" },
    { "<leader>b", "<cmd> FzfLua buffers<cr>", desc = "List of all open buffers" },
    { "[i", "<cmd> FzfLua grep_cword<cr>", desc = "Grep for word under cursor" },
    { "[I", "<cmd> FzfLua grep_cWORD<cr>", desc = "Grep for WORD under cursor" },
  },
  init = function() require("fzf-lua").register_ui_select() end,
}
