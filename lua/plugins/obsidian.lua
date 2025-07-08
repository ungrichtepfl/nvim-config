local vault_path = vim.fn.expand "~" .. "/Notes"

return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    -- refer to `:h file-pattern` for more examples
    "BufReadPre "
      .. vault_path
      .. "/*.md",
    "BufNewFile " .. vault_path .. "/*.md",
  },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
    -- Optional
    "ibhagwan/fzf-lua",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = vault_path,
      },
    },
    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ["gf"] = {
        action = function() return require("obsidian").util.gf_passthrough() end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle check-boxes.
      ["<leader>nc"] = {
        action = function() return require("obsidian").util.toggle_checkbox() end,
        opts = { buffer = true, desc = "Toggle checkboxes." },
      },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ["<cr>"] = {
        action = function() return require("obsidian").util.smart_action() end,
        opts = { buffer = true, expr = true, desc = "Smart obsidian action" },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
      pattern = vault_path .. "/*.md",
      callback = function() vim.opt_local.conceallevel = 2 end,
      desc = "Set conceallevel=2 for markdown in vault",
    })
  end,
}
