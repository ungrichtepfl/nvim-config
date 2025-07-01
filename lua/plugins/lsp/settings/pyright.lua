local settings

if vim.fn.executable "ruff" == 1 then
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },

    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { "*" },
      },
    },
  }
else
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "off",
      },
    },
  }
end

return {
  settings = settings,
}
