return {
  {
    event = "VeryLazy",
    "neovim/nvim-lspconfig", -- NOTE: Data only repo
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    lazy = true,
    -- TODO: Setup keymaps if needed
  },
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
  {
    -- Adds vim namespace to lua, makes writing configs much nicer:
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "mrcjkb/rustaceanvim",
    version = "*",
    lazy = false, -- This plugin is already lazy
    keys = {
      {
        "K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
        function() vim.cmd.RustLsp { "hover", "actions" } end,
        ft = "rust",
      },
    },
  },
  {
    "mrcjkb/haskell-tools.nvim",
    version = "*",
    lazy = false, -- This plugin is already lazy
    keys = {
      {
        "<space>lHs",
        function() require("haskell-tools").hoogle.hoogle_signature() end,
        ft = { "haskell", "cabal" },
        desc = "Hoogle: Search type signature under cursor",
      },
      {
        "<space>lHe",
        function() require("haskell-tools").lsp.buf_eval_all() end,
        ft = { "haskell", "cabal" },
        desc = "Haskell: Evaluate all code snippets",
      },
      {
        "<leader>lHr",
        function() require("haskell-tools").repl.toggle() end,
        ft = { "haskell", "cabal" },
        desc = "REPL: Toggle GHCi for package",
      },
      {
        "<leader>lHrb",
        function() require("haskell-tools").repl.toggle(vim.api.nvim_buf_get_name(0)) end,
        ft = { "haskell", "cabal" },
        desc = "REPL: Toggle GHCi for current buffer",
      },
      {
        "<leader>lHrq",
        function() require("haskell-tools").repl.quit() end,
        ft = { "haskell", "cabal" },
        desc = "REPL: Quit GHCi session",
      },
    },
  },
  {
    "Civitasv/cmake-tools.nvim",
    event = "VeryLazy",
    opts = {
      cmake_compile_commands_options = {
        action = "none",
      },
      cmake_executor = {
        name = "quickfix",
      },
      cmake_runner = {
        name = "toggleterm",
        opts = {
          direction = "horizontal", -- 'vertical' | 'horizontal' | 'tab' | 'float'
          close_on_exit = false, -- whether close the terminal when exit
        },
      },
    },
  },
}
