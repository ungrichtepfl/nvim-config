return {
  {
    "github/copilot.vim",
    lazy = false, -- NOTE: Somehow it does not work work if lazy loaded
    keys = {
      { "<leader>ii", "<cmd>Copilot enable<cr>", desc = "Restart and enable Copilot" },
      { "<leader>id", "<cmd>Copilot disable<cr>", desc = "Disable Copilot" },
      {
        "<C-j>",
        'copilot#Accept("\\<CR>")',
        expr = true,
        replace_keycodes = false,
        mode = "i",
        desc = "Accept Copilot Suggestion",
      },
      { "<C-h>", "<Plug>(copilot-suggest)", mode = "i", desc = "Trigger Copilot Suggestion" },
      { "<C-l>", "<Plug>(copilot-accept-line)", mode = "i", desc = "Accept Copilot Suggestion Line" },
      { "<C-k>", "<Plug>(copilot-accept-word)", mode = "i", desc = "Accept Copilot Suggestion Word" },
      { "<A-j>", "<Plug>(copilot-next)", mode = "i", desc = "Next Copilot Suggestion" },
      { "<A-k>", "<Plug>(copilot-previous)", mode = "i", desc = "Previous Copilot Suggestion" },
    },
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_enabled = false
    end,
  },
}
