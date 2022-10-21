local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  vim.notify "'null-ls' plugin not found."
  return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
local hover = null_ls.builtins.hover

null_ls.setup {
  debug = false,
  sources = {
    -- jovascript
    formatting.prettier.with { extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } },
    -- lua:
    formatting.stylua,
    -- python:
    formatting.isort,
    formatting.yapf,
    -- formatting.black,
    diagnostics.flake8,
    diagnostics.pylint,
    -- Haskell
    formatting.stylish_haskell,
    -- yaml:
    formatting.yamlfmt,
    diagnostics.yamllint,
    -- elm:
    formatting.elm_format,
    -- cpp/c:
    diagnostics.cpplint,
    formatting.clang_format,
    -- shell:
    diagnostics.shellcheck,
    hover.printenv,
    formatting.beautysh,
    formatting.shellharden,
  },
}

local status_ok, mason_null_ls = pcall(require, "mason-null-ls")

if not status_ok then
  vim.notify '"mason-null-ls" plugin not found.'
  return
end

mason_null_ls.setup {
  -- ensures that all null-ls sources are installed.
  automatic_installation = false,
}
