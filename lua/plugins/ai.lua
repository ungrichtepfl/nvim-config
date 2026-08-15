return {
  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    -- HACK: OSC 52 copies from the CLI's :terminal buffer reach the xclip provider as one
    -- list item, and jobsend() turns the newlines into NULs, so only the first line lands.
    -- Fixed by neovim/neovim#41097, unreleased as of v0.12.4; drop this once nvim has it.
    -- Paste stays on xclip: alacritty's `osc52 = "OnlyCopy"` never answers a read query.
    config = function(_, opts)
      local osc52 = require "vim.ui.clipboard.osc52"
      vim.g.clipboard = {
        name = "osc52-copy-xclip-paste",
        copy = { ["+"] = osc52.copy "+", ["*"] = osc52.copy "*" },
        paste = {
          ["+"] = { "xsel", "-o", "-b" },
          ["*"] = { "xsel", "-o", "-p" },
        },
      }
      require("sidekick").setup(opts)
    end,
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
        "<leader>ie",
        "<cmd>Sidekick nes toggle<cr>",
        desc = "Sidekick Toggle NES",
      },
      {
        "<leader>ii",
        "<cmd>Sidekick nes update<cr>",
        desc = "Sidekick Show NES Suggestions",
      },
      {
        "<leader>is",
        function() require("sidekick.cli").select() end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = "Select CLI",
      },
      {
        "<leader>id",
        function() require("sidekick.cli").close() end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>it",
        function() require("sidekick.cli").send { msg = "{this}" } end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>if",
        function() require("sidekick.cli").send { msg = "{file}" } end,
        desc = "Send File",
      },
      {
        "<leader>iv",
        function() require("sidekick.cli").send { msg = "{selection}" } end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ip",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
}
