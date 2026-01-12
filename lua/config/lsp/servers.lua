---@type table<string, string|boolean>
---A mapping of LSP server names to their corresponding Mason package names. If false don't install it in Mason.
local servers = {
  angularls = "angular-language-server",
  arduino_language_server = "arduino-language-server",
  asm_lsp = "asm-lsp",
  bashls = "bash-language-server",
  bitbake_language_server = false, -- Does not exists in Mason
  clangd = "clangd", -- C/C++
  cmake = "cmake-language-server",
  cssls = "css-lsp",
  dockerls = "dockerfile-language-server",
  elmls = "elm-language-server",
  gopls = "gopls",
  hls = "haskell-language-server",
  html = "html-lsp",
  jsonls = "json-lsp",
  lemminx = "lemminx", -- "XML"
  lua_ls = "lua-language-server",
  marksman = "marksman", -- Markdown
  omnisharp = "omnisharp", -- C#/dotnet
  pyright = "pyright",
  ruff = "ruff",
  rust_analyzer = "rust-analyzer",
  slint_lsp = "slint-lsp",
  taplo = "taplo", -- TOML
  ts_ls = "typescript-language-server",
  yamlls = "yaml-language-server",
  zls = "zls",
}
return servers
