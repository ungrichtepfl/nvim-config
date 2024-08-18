local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
  vim.notify "'null-ls' plugin not found."
  return
end

local diagnostics = null_ls.builtins.diagnostics

null_ls.setup {
  debug = false,
  sources = {
    -- NOTE: No good alternative for linting the whole project with mypy.
    --       Use nvim-lint or nvim-formatter instead as null-ls is deprecated.
    diagnostics.mypy.with { extra_args = { "--ignore-missing-imports" } },
  },
}
