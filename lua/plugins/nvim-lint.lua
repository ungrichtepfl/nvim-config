return {
  "mfussenegger/nvim-lint",
  event = "VeryLazy",
  config = function(_, _)
    local lint = require "lint"
    local codespell_config = require("config.utils").codespell_config_path()
    local codespell_args = { "--stdin-single-line", "-" }
    if vim.fn.filereadable(codespell_config) == 1 then
      table.insert(codespell_args, 2, codespell_config)
      table.insert(codespell_args, 2, "--config")
    end
    lint.linters.codespell.args = codespell_args
    lint.linters_by_ft = {
      bash = { "shellcheck" },
      css = { "stylelint" },
      scss = { "stylelint" },
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      sh = { "shellcheck" },
      make = { "checkmake" },
      -- NOTE: json is already handled by jsonls
      -- NOTE: yaml is already handled by yamlls
      -- NOTE: toml is already handled by taplo
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      python = { "mypy" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
      callback = function()
        -- try_lint without arguments runs the linters defined in `linters_by_ft`
        -- for the current filetype
        require("lint").try_lint()

        -- You can call `try_lint` with a linter name or a list of names to always
        -- run specific linters, independent of the `linters_by_ft` configuration
        require("lint").try_lint("codespell", { ignore_errors = true })
      end,
    })
  end,
}
