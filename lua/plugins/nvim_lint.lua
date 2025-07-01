return {
  "mfussenegger/nvim-lint",
  config = function(lint, _)
    lint.linters_by_ft = {
      bash = { "shellcheck" },
      css = { "stylelint" },
      html = { "stylelint" },
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      markdown = { "markdownlint" },
      scss = { "stylelint" },
      sh = { "shellcheck" },
      svelte = { "stylelint" },
      -- NOTE: json is already handled by jsonls
      -- NOTE: yaml is already handled by yamlls
      -- NOTE: toml is already handled by taplo
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      vue = { "stylelint" },
      python = { "mypy" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        -- try_lint without arguments runs the linters defined in `linters_by_ft`
        -- for the current filetype
        require("lint").try_lint()

        -- You can call `try_lint` with a linter name or a list of names to always
        -- run specific linters, independent of the `linters_by_ft` configuration
        require("lint").try_lint "codespell"
      end,
    })
  end,
}
