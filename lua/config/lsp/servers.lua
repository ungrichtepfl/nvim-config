---@type table<string, string|boolean>
---A mapping of LSP server names to their corresponding Mason package names.
local servers = {
  angularls = "angular-language-server",
  arduino_language_server = "arduino-language-server",
  asm_lsp = "asm-lsp",
  bashls = "bash-language-server",
  clangd = false, -- C/C++
  cmake = "cmake-language-server",
  cssls = "css-lsp",
  dockerls = "dockerfile-language-server",
  elmls = "elm-language-server",
  gopls = false,
  hls = "haskell-language-server",
  html = "html-lsp",
  jsonls = "json-lsp",
  lemminx = false, -- "XML"
  lua_ls = "lua-language-server",
  marksman = false, -- Markdown
  omnisharp = false, -- C#/dotnet
  pyright = false,
  -- remark_ls=false, -- Markdown
  ruff = false,
  rust_analyzer = "rust-analyzer",
  slint_lsp = "slint-lsp",
  taplo = false, -- TOML
  ts_ls = "typescript-language-server",
  yamlls = "yaml-language-server",
  zls = false,
}
return servers
