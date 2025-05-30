local status_ok, mason = pcall(require, "mason")
if not status_ok then
  vim.notify "'mason' plugin not found."
  return
end

local status_ok_manson_lspconf, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok_manson_lspconf then
  vim.notify "'mason-lspconfig' plugin not found."
  return
end

local status_ok_lsp_conf, _ = pcall(require, "lspconfig")
if not status_ok_lsp_conf then
  vim.notify "'lspconfig' plugin not found."
  return
end

local servers = {
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
  -- "remark_ls", -- Markdown
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
}

mason.setup()
-- needs to be after manson setup:
mason_lspconfig.setup {
  ensure_installed = servers,
  automatic_enable = false, -- They are anabled below.
}

-- servers not installed by mason-lspconfig
servers = vim.tbl_deep_extend("force", servers, {
  "hls", -- Haskell, installed by ghcup
  "rust_analyzer", -- Installed by rustup
  "ruff", -- install locally to be sure which version is used
})

local lspconfig = require "lspconfig"

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
local on_attach = require("config.lsp.handlers").on_attach
local capabilities = require("config.lsp.handlers").capabilities

for _, server in ipairs(servers) do
  if server == "rust_analyzer" then
    status_ok, _ = pcall(require, "rustaceanvim")
    if status_ok then
      -- Don't load rust_analyzer if rustaceanvim is loaded
      goto continue
    end
  end
  if server == "hls" then
    status_ok, _ = pcall(require, "haskell-tools")
    if status_ok then
      -- Don't load haskell_language_server if haskell_tools is loaded
      goto continue
    end
  end
  local opts = {
    on_attach = on_attach,
    capabilities = capabilities,
  }
  local server_status_ok, server_opts = pcall(require, "config.lsp.settings." .. server)
  if server_status_ok then opts = vim.tbl_deep_extend("force", server_opts, opts) end
  -- needs to be after manson and manson_lspconfig
  lspconfig[server].setup(opts)
  ::continue::
end
