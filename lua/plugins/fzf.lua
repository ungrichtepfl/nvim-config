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
    { "<leader>om", "<cmd> FzfLua marks<cr>", desc = "List of all marks" },
    { "<leader>op", "<cmd> FzfLua manpages<cr>", desc = "List all manpages" },
    { "<leader>oc", "<cmd> FzfLua commands<cr>", desc = "List vim commands" },
    { "<leader>oh", "<cmd> FzfLua command_history<cr>", desc = "Show command history" },
    { "<leader>ot", "<cmd> FzfLua filetypes<cr>", desc = "List available filetypes" },
    { "<leader>ogc", "<cmd> FzfLua git_commits<cr>", desc = "List git commits" },
    { "<leader>ogC", "<cmd> FzfLua git_bcommits<cr>", desc = "List git commits of the buffer" },
    { "<leader>ogs", "<cmd> FzfLua git_status<cr>", desc = "Show git status" },
    { "<leader>ogb", "<cmd> FzfLua git_branches<cr>", desc = "List git branches" },
    { "[w", "<cmd> FzfLua grep_cword<cr>", desc = "Grep for word under cursor" },
    { "[W", "<cmd> FzfLua grep_cWORD<cr>", desc = "Grep for WORD under cursor" },
  },
  init = function() require("fzf-lua").register_ui_select() end,
}
