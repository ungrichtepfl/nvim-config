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
local code_actions = null_ls.builtins.code_actions
local completion = null_ls.builtins.completion

null_ls.setup {
  debug = false,
  sources = {
    --spelling:
    diagnostics.codespell,
    formatting.codespell,
    completion.spell,
    diagnostics.misspell,
    -- javascript/markdown/etc:
    -- formatting.prettier_eslint.with {
    --   extra_args = { "--eslint-config-path", "./.eslintrc.json", "--config", "./.prettierrc" },
    -- },
    formatting.prettierd,
    -- JS and TS
    diagnostics.eslint_d,
    code_actions.eslint_d,
    -- Markdown
    diagnostics.markdownlint,
    -- lua:
    formatting.stylua,
    -- python:
    diagnostics.mypy.with { extra_args = { "--ignore-missing-imports" } },
    -- Rust:
    formatting.rustfmt,
    -- Haskell:
    formatting.fourmolu,
    -- yaml:
    -- INFO: yamlls does it already
    -- formatting.yamlfmt,
    -- diagnostics.yamllint,
    -- elm:
    formatting.elm_format,
    -- cpp/c:
    -- diagnostics.cpplint,
    -- formatting.clang_format,
    -- shell:
    diagnostics.shellcheck,
    hover.printenv,
    formatting.beautysh,
    formatting.shellharden,
    -- zig:
    formatting.zigfmt,
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
