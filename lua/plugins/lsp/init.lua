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
  ---------------------------------
  --------- AUTOCOMPLETION --------
  ---------------------------------
  {
    "saghen/blink.cmp",
    -- optional: provides snippets for the snippet source
    dependencies = { { "rafamadriz/friendly-snippets" }, { "echasnovski/mini.icons" } },

    -- use a release tag to download pre-built binaries
    version = "1.*",
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = { preset = "default" },
      signature = { enabled = false },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = {
        documentation = { auto_show = false },
        menu = {
          draw = {
            components = {
              -- Use mini.icons
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              kind = {
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          path = {
            opts = {
              get_cwd = function(_) -- Use cwd for path completions and not buffer directory
                return vim.fn.getcwd()
              end,
            },
          },
        },
      },

      -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
      -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
      --
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
