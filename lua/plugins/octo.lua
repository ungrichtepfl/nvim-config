local KEYMAP_PREFIX = "<leader>H"

return {
  "pwntester/octo.nvim",
  specs = { { "folke/which-key.nvim", opts = { spec = { { KEYMAP_PREFIX, group = "GitHub" } } } } },
  cmd = "Octo",
  opts = {
    use_local_fs = true,
    picker = "fzf-lua",
    picker_config = {
      use_emojis = true,
    },
    -- bare Octo command opens picker of commands
    enable_builtin = true,
  },
  keys = {
    {
      KEYMAP_PREFIX .. "i",
      "<CMD>Octo issue list<CR>",
      desc = "List GitHub Issues",
    },
    {
      KEYMAP_PREFIX .. "p",
      "<CMD>Octo pr list<CR>",
      desc = "List GitHub PullRequests",
    },
    {
      KEYMAP_PREFIX .. "d",
      "<CMD>Octo discussion list<CR>",
      desc = "List GitHub Discussions",
    },
    {
      KEYMAP_PREFIX .. "n",
      "<CMD>Octo notification list<CR>",
      desc = "List GitHub Notifications",
    },
    {
      KEYMAP_PREFIX .. "s",
      function() require("octo.utils").create_base_search_command { include_current_repo = true } end,
      desc = "Search GitHub",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- "ibhagwan/fzf-lua",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
  },
}
