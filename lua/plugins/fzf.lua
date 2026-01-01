return {
  "ibhagwan/fzf-lua",
  dependencies = { "echasnovski/mini.icons" },
  event = "VeryLazy", -- Needed for ui select to work properly
  opts = {
    files = {
      git_icons = true,
      -- NOTE: using rg with sortr=modified displays recently modified files at the
      --  top of the fzf input file list. Using the --tiebreak=index prefers
      --  the files on top of the list.
      --  CAVEAT: rg now runs SINGLE THREADED!
      cmd = [[rg --files --color=never --hidden --files -g "!.git" --sortr=modified]],
      fzf_opts = {
        ["--tiebreak"] = "index",
      },
    },
    keymap = {
      builtin = {
        true,
        ["<C-j>"] = "preview-down",
        ["<C-k>"] = "preview-up",
        ["<C-d>"] = "preview-page-down",
        ["<C-u>"] = "preview-page-up",
      },
      fzf = {
        true,
        ["ctrl-d"] = "preview-page-down",
        ["ctrl-u"] = "preview-page-up",
        ["ctrl-q"] = "select-all+accept",
      },
    },
  },
  cmd = "FzfLua",
  keys = {
    { "<leader>f", "<cmd> FzfLua files<cr>", desc = "Find files" },
    { "<leader>g", "<cmd> FzfLua live_grep<cr>", desc = "Grep word in all files" },
    { "<leader>b", "<cmd> FzfLua buffers<cr>", desc = "List of all open buffers" },
    { "<leader>s", "<cmd> FzfLua git_status<cr>", desc = "Show git status" },
    { "<leader>s", "<cmd> FzfLua keymaps<cr>", desc = "Show keymaps" },
    { "<leader>om", "<cmd> FzfLua marks<cr>", desc = "List of all marks" },
    { "<leader>op", "<cmd> FzfLua manpages<cr>", desc = "List all manpages" },
    { "<leader>oc", "<cmd> FzfLua commands<cr>", desc = "List vim commands" },
    { "<leader>oh", "<cmd> FzfLua command_history<cr>", desc = "Show command history" },
    { "<leader>ot", "<cmd> FzfLua filetypes<cr>", desc = "List available filetypes" },
    { "<leader>ogc", "<cmd> FzfLua git_commits<cr>", desc = "List git commits" },
    { "<leader>ogC", "<cmd> FzfLua git_bcommits<cr>", desc = "List git commits of the buffer" },
    { "<leader>ogb", "<cmd> FzfLua git_branches<cr>", desc = "List git branches" },
    { "[w", "<cmd> FzfLua grep_cword<cr>", desc = "Grep for word under cursor" },
    { "[W", "<cmd> FzfLua grep_cWORD<cr>", desc = "Grep for WORD under cursor" },
    -- LSP
    { "gD", function() require("fzf-lua").lsp_declarations() end, desc = "Go to declaration" },
    { "gd", function() require("fzf-lua").lsp_definitions() end, desc = "Go to definition" },
    { "grr", function() require("fzf-lua").lsp_references() end, desc = "Go to references" },
    { "gri", function() require("fzf-lua").lsp_implementations() end, desc = "Go to implementations" },
    { "gO", function() require("fzf-lua").lsp_document_symbols() end, desc = "Show document symbols" },
    {
      "<leader>wd",
      function() require("fzf-lua").lsp_document_diagnostics() end,
      desc = "Workspace diagnostic",
    },
    {
      "<leader>wD",
      function() require("fzf-lua").lsp_workspace_diagnostics() end,
      desc = "Workspace diagnostic",
    },
  },
  config = function(_, opts)
    local fzf = require "fzf-lua"
    fzf.setup(opts)
    fzf.register_ui_select()
  end,
}
