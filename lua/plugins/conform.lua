return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "grf",
      function() require("conform").format { async = true } end,
      desc = "Format buffer",
    },
  },
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      toml = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return {} -- Handled by ruff lsp
        else
          return { "isort", "black" }
        end
      end,
      sh = {
        "beautysh",
      },
      zsh = {
        "beautysh",
      },
      bash = {
        "beautysh",
      },
      c = { "clang-format" },
      cpp = { "clang-format" },
      -- Use the "*" filetype to run formatters on all filetypes.
      ["*"] = {},
      -- Use the "_" filetype to run formatters on filetypes that don't
      -- have other formatters configured.
      ["_"] = { "trim_whitespace" },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Set up format-on-save
    format_on_save = function()
      -- return { timeout_ms = 500 }
      return nil
    end,
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
