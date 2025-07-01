return {
  {
    "neovim/nvim-lspconfig", -- NOTE: Data only repo
    config = function()
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
      ----------------- SERVERS ----------------
      ------------------------------------------
      local mason_lspconfig = require "mason-lspconfig"
      local auto_installed_servers = { -- NOTE: Automatically installed lsp
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
      local manual_installed_servers = { -- NOTE: Manually installed servers
        "hls", -- Haskell, installed by ghcup
        "rust_analyzer", -- Installed by rustup
        "ruff", -- install locally to be sure which version is used
      }
      local all_servers = vim.tbl_deep_extend("force", auto_installed_servers, manual_installed_servers)
      -- Additional manual settings:
      for _, server in ipairs(all_servers) do
        local opts = {}
        local server_status_ok, server_opts = pcall(require, "plugins.lsp.settings." .. server)
        if server_status_ok then
          opts = vim.tbl_deep_extend("force", server_opts, opts)
          vim.lsp.config(server, opts)
        end
      end

      -- Automatically enabled and installed servers
      mason_lspconfig.setup {
        ensure_installed = auto_installed_servers,
      }

      -- Manually enable servers:
      for _, server in ipairs(manual_installed_servers) do
        if server == "rust_analyzer" then
          local status_ok, _ = pcall(require, "rustaceanvim")
          if status_ok then
            -- Don't load rust_analyzer if rustaceanvim is loaded
            goto continue
          end
        end
        if server == "hls" then
          local status_ok, _ = pcall(require, "haskell-tools")
          if status_ok then
            -- Don't load haskell_language_server if haskell_tools is loaded
            goto continue
          end
        end
        vim.lsp.enable(server)
        ::continue::
      end
    end,
    dependencies = {
      {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim", opts = {} },
        -- NOTE: Will be setup above in init function
      },
      {
        "mrcjkb/rustaceanvim",
        version = "^6",
        lazy = false, -- This plugin is already lazy
        -- TODO: Setup keymaps corrently
      },
      {
        "mrcjkb/haskell-tools.nvim",
        version = "^5",
        lazy = false, -- This plugin is already lazy
        -- TODO: Setup keymaps corrently
      },
      {
        "Hoffs/omnisharp-extended-lsp.nvim",
        -- TODO: Setup keymaps if needed
      },
      {
        -- Adds vim namespace to lua, makes writing configs much nicer:
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- See the configuration section for more details
            -- Load luvit types when the `vim.uv` word is found
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
  },
}
