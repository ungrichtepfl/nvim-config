local KEYMAP_PREFIX = "<leader>i"

return {
  {
    "folke/sidekick.nvim",
    specs = { { "folke/which-key.nvim", opts = { spec = { { KEYMAP_PREFIX, group = "AI" } } } } },
    event = "VeryLazy",
    opts = {
      nes = { enabled = false },
      cli = {
        mux = {
          backend = "zellij",
          enabled = true,
        },
        tools = {
          ollama = {
            cmd = { "ollama", "launch", "pi" },
          },
        },
      },
    },
    keys = {
      {
        "<c-j>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<c-j>" -- fallback to normal tab
          end
        end,
        expr = true,
        mode = { "i", "n" },
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function() require("sidekick.cli").toggle { focus = true } end,
        desc = "Sidekick Toggle",
        mode = { "n", "t", "i", "x" },
      },
      {
        KEYMAP_PREFIX .. "e",
        "<cmd>Sidekick nes toggle<cr>",
        desc = "Sidekick Toggle NES",
      },
      {
        KEYMAP_PREFIX .. "i",
        "<cmd>Sidekick nes update<cr>",
        desc = "Sidekick Show NES Suggestions",
      },
      {
        KEYMAP_PREFIX .. "s",
        function() require("sidekick.cli").select() end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = "Select CLI",
      },
      {
        KEYMAP_PREFIX .. "d",
        function() require("sidekick.cli").close() end,
        desc = "Detach a CLI Session",
      },
      {
        KEYMAP_PREFIX .. "t",
        function() require("sidekick.cli").send { msg = "{this}" } end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        KEYMAP_PREFIX .. "f",
        function() require("sidekick.cli").send { msg = "{file}" } end,
        desc = "Send File",
      },
      {
        KEYMAP_PREFIX .. "v",
        function() require("sidekick.cli").send { msg = "{selection}" } end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        KEYMAP_PREFIX .. "p",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
}
