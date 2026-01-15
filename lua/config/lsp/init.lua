------------------------------------------
--------------- DIAGNOSTICS --------------
------------------------------------------
vim.diagnostic.config {
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  float = {
    style = "minimal",
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
  },
}
------------------------------------------
----------------- ON ATTACH --------------
------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    ------------------------------------------
    ----------------- KEYMAPS ---------------
    ------------------------------------------
    -- - 'omnifunc' is set to |vim.lsp.omnifunc()|, use |i_CTRL-X_CTRL-O| to trigger
    --   completion.
    -- - 'tagfunc' is set to |vim.lsp.tagfunc()|. This enables features like
    --   go-to-definition, |:tjump|, and keymaps like |CTRL-]|, |CTRL-W_]|,
    --   |CTRL-W_}| to utilize the language server.
    -- - 'formatexpr' is set to |vim.lsp.formatexpr()|, so you can format lines via
    --   |gq| if the language server supports it.
    --   - To opt out of this use |gw| instead of gq, or clear 'formatexpr' on |LspAttach|.
    -- - |K| is mapped to |vim.lsp.buf.hover()| unless |'keywordprg'| is customized or
    --   a custom keymap for `K` exists.
    -- - "grn" is mapped in Normal mode to |vim.lsp.buf.rename()|
    -- - "gra" is mapped in Normal and Visual mode to |vim.lsp.buf.code_action()|
    -- - "grr" is mapped in Normal mode to |vim.lsp.buf.references()|
    -- - "gri" is mapped in Normal mode to |vim.lsp.buf.implementation()|
    -- - "gO" is mapped in Normal mode to |vim.lsp.buf.document_symbol()|
    -- - CTRL-S is mapped in Insert mode to |vim.lsp.buf.signature_help()|
    vim.keymap.set(
      "i",
      "<C-S>",
      function() vim.lsp.buf.signature_help { border = "rounded" } end,
      { desc = "Show signature help", buffer = bufnr }
    )
    vim.keymap.set(
      "n",
      "K",
      function() vim.lsp.buf.hover { border = "rounded" } end,
      { desc = "Show hover information", buffer = bufnr }
    )
    vim.keymap.set("n", "grc", function() vim.lsp.codelens.run() end, {
      desc = "Run codelens actions",
      buffer = bufnr,
    })
    vim.keymap.set("n", "gD", function() vim.lsp.buf.declarations() end, { desc = "Go to declaration", buffer = bufnr })
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definitions() end, { desc = "Go to definition", buffer = bufnr })

    ------------------------------------------
    ----------------- AUTOCOMANDS ------------
    ------------------------------------------

    -- Only enable if the LSP supports documentHighlight
    if client and client.supports_method "textDocument/documentHighlight" then
      local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false }) -- TODO: Check if clear = false is correct

      vim.api.nvim_create_autocmd("CursorHold", {
        group = group,
        buffer = bufnr,
        callback = function() vim.lsp.buf.document_highlight() end,
      })

      vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = bufnr,
        callback = function() vim.lsp.buf.clear_references() end,
      })
    end
    -- Fire AfterLspAttach patter usr command for other to change keymaps
    vim.api.nvim_exec_autocmds("User", {
      pattern = "AfterLspAttach",
      data = {
        client_id = args.data.client_id,
        buf = bufnr,
      },
      modeline = false,
    })
  end,
})

------------------------------------------
----------------- SERVERS ----------------
------------------------------------------

-- Additional manual settings:
local capabilities = { -- specify your own
}

for server, _ in pairs(require "config.lsp.servers") do
  -- CONFIG

  local opts = {
    capabilities = capabilities,
  }
  local server_status_ok, server_opts = pcall(require, "config.lsp.settings." .. server)
  if server_status_ok then opts = vim.tbl_deep_extend("force", opts, server_opts) end
  vim.lsp.config(server, opts)

  -- ENABLE

  if server == "rust_analyzer" then
    local installed = require("lazy.core.config").plugins["rustaceanvim"]
    if installed then
      -- Don't load rust_analyzer if rustaceanvim is loaded
      goto continue
    end
  end
  if server == "haskell-language-server" then
    local installed = require("lazy.core.config").plugins["haskell-tools.nvim"]
    if installed then
      -- Don't load haskell_language_server if haskell_tools is loaded
      goto continue
    end
  end
  vim.lsp.enable(server)
  ::continue::
end
