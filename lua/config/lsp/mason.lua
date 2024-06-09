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

local status_ok_update_all, mason_update_all = pcall(require, "mason-update-all")
if not status_ok_update_all then vim.notify '"mason-update-all" plugin not found.' end

mason_update_all.setup()

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
  "rust_analyzer",
  "yamlls",
  "elmls",
  "taplo", -- TOML
  "lemminx", -- "XML"
  "tsserver",
  "html",
  "cssls",
  "angularls",
  "omnisharp", -- C#/dotnet
}

mason.setup()
-- needs to be after manson setup:
mason_lspconfig.setup {
  ensure_installed = servers,
}

local lspconfig = require "lspconfig"

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
local on_attach = require("config.lsp.handlers").on_attach
local capabilities = require("config.lsp.handlers").capabilities

local status_ok_rt, rt = pcall(require, "rust-tools")
if not status_ok_rt then vim.notify "'rust-tools' plugin not found." end

for _, server in ipairs(servers) do
  if server == "rust_analyzer" and status_ok_rt then
    rt.setup {
      server = {
        on_attach = on_attach,
        capabilities = capabilities,
      },
      dap = {
        adapter = {
          command = "lldb-vscode-10",
        },
      },
    }
  else
    local opts = {
      on_attach = on_attach,
      capabilities = capabilities,
    }
    local server_status_ok, server_opts = pcall(require, "config.lsp.settings." .. server)
    if server_status_ok then opts = vim.tbl_deep_extend("force", server_opts, opts) end
    -- needs to be after manson and manson_lspconfig
    lspconfig[server].setup(opts)
  end
end
