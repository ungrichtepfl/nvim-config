return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "arduino_language_server",
      "asm_lsp",
      "gopls",
      "jsonls",
      "pyright",
      "lua_ls",
      "bashls",
      "clangd", -- C/C++
      "cmake",
      "dockerls",
      "marksman", -- Markdown
      "yamlls",
      "elmls",
      "taplo", -- TOML
      "lemminx", -- "XML"
      "ts_ls",
      "html",
      "cssls",
      "angularls",
      "omnisharp", -- C#/dotnet
      "zls",
    },
  },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
  },
}
