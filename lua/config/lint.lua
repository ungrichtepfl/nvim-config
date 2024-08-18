local status_ok, lint = pcall(require, "lint")

if not status_ok then
  vim.notify "Missing lint plugin. Please install 'mfussenegger/nvim-lint'"
  return
end

lint.linters_by_ft = {
  css = { "stylelint" },
  html = { "stylelint" },
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  json = { "jsonlint" },
  markdown = { "markdownlint" },
  scss = { "stylelint" },
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  svelte = { "stylelint" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  vue = { "stylelint" },
  yaml = { "yamllint" },
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
