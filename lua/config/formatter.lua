local status_ok, formatter = pcall(require, "formatter")

if not status_ok then
  vim.notify "Missing formatter plugin. Please install 'mhartington/formatter.nvim'"
  return
end

formatter.setup {
  filetype = {
    lua = {
      require("formatter.filetypes.lua").stylua,
    },
    toml = {
      require("formatter.filetypes.toml").prettierd,
    },
    -- NOTE: json is already handled by jsonls
    -- NOTE: yaml is already handled by yamlls
    markdown = {
      require("formatter.filetypes.markdown").prettierd,
    },
    sh = {
      require("formatter.filetypes.sh").beautysh,
    },
    zsh = {
      require("formatter.filetypes.sh").beautysh,
    },
    bash = {
      require("formatter.filetypes.sh").beautysh,
    },
    -- Use the special "*" filetype for defining formatter configurations on
    -- any filetype
    ["*"] = {
      require("formatter.filetypes.any").remove_trailing_whitespace,
    },
  },
}
