return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  opts = {
    picker = "fzf-lua",
    picker_config = {
      use_emojis = true,
    },
    -- bare Octo command opens picker of commands
    enable_builtin = true,
  },
  keys = {
    {
      "<leader>Hi",
      "<CMD>Octo issue list<CR>",
      desc = "List GitHub Issues",
    },
    {
      "<leader>Hp",
      "<CMD>Octo pr list<CR>",
      desc = "List GitHub PullRequests",
    },
    {
      "<leader>Hd",
      "<CMD>Octo discussion list<CR>",
      desc = "List GitHub Discussions",
    },
    {
      "<leader>Hn",
      "<CMD>Octo notification list<CR>",
      desc = "List GitHub Notifications",
    },
    {
      "<leader>Hs",
      function() require("octo.utils").create_base_search_command { include_current_repo = true } end,
      desc = "Search GitHub",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
    "nvim-tree/nvim-web-devicons",
  },
}
