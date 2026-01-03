local vault_path = vim.fn.expand "~" .. "/Notes"

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
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
    -- Optional
    "ibhagwan/fzf-lua",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "personal",
        path = vault_path,
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
      pattern = vault_path .. "/*.md",
      callback = function() vim.wo[0][0].conceallevel = 2 end,
      desc = "Set conceallevel=2 for markdown in vault",
    })
  end,
}
