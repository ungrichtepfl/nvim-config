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

return {
  {
    "neovim/nvim-lspconfig", -- NOTE: Data only repo
    event = { "BufReadPre", "BufNewFile" },
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
          vim.keymap.set("n", "K", function() vim.lsp.buf.hover { border = "rounded" } end, { buffer = args.buf })
          vim.keymap.set(
            "i",
            "<C-S>",
            function() vim.lsp.buf.signature_help { border = "rounded" } end,
            { buffer = args.buf }
          )
          vim.keymap.set("n", "K", function() vim.lsp.buf.hover { border = "rounded" } end, { buffer = args.buf })
          vim.keymap.set("n", "grc", function() vim.lsp.codelens.run() end, {
            desc = "Run codelens actions",
            buffer = args.buf,
          })

          vim.keymap.set(
            "n",
            "gD",
            function() require("fzf-lua").lsp_declarations() end,
            { desc = "Go to declaration", buffer = args.buf }
          )
          vim.keymap.set(
            "n",
            "gd",
            function() require("fzf-lua").lsp_definitions() end,
            { desc = "Go to definition", buffer = args.buf }
          )
          vim.keymap.set(
            "n",
            "grr",
            function() require("fzf-lua").lsp_references() end,
            { desc = "Go to definition", buffer = args.buf }
          )
          vim.keymap.set(
            "n",
            "gri",
            function() require("fzf-lua").lsp_implementations() end,
            { desc = "Go to implementations", buffer = args.buf }
          )
          vim.keymap.set(
            "n",
            "gO",
            function() require("fzf-lua").lsp_document_symbols() end,
            { desc = "Show document symbols", buffer = args.buf }
          )
          vim.keymap.set(
            "n",
            "<leader>wd",
            function() require("fzf-lua").lsp_document_diagnostics() end,
            { desc = "Workspace diagnostic", buffer = args.buf }
          )
          vim.keymap.set(
            "n",
            "<leader>wD",
            function() require("fzf-lua").lsp_workspace_diagnostics() end,
            { desc = "Workspace diagnostic", buffer = args.buf }
          )

          ------------------------------------------
          ----------------- AUTOCOMANDS ------------
          ------------------------------------------

          -- Only enable if the LSP supports documentHighlight
          if client and client.supports_method "textDocument/documentHighlight" then
            local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })

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
        end,
      })

      ------------------------------------------
      ----------------- SERVERS ----------------
      ------------------------------------------
      local all_servers = vim.tbl_deep_extend("force", auto_installed_servers, manual_installed_servers)
      -- Additional manual settings:
      for _, server in ipairs(all_servers) do
        local capabilities = {} -- specify your own
        capabilities = vim.lsp.protocol.make_client_capabilities(capabilities) -- Includes the one from nvim per default
        local opts = {
          capabilities = capabilities,
        }
        local server_status_ok, server_opts = pcall(require, "plugins.lsp.settings." .. server)
        if server_status_ok then
          opts = vim.tbl_deep_extend("force", server_opts, opts)
          vim.lsp.config(server, opts)
        end
      end

      -- Manually enable servers:
      for _, server in ipairs(manual_installed_servers) do
        if server == "rust_analyzer" then
          local installed = require("lazy.core.config").plugins["rustaceanvim"]
          if installed then
            -- Don't load rust_analyzer if rustaceanvim is loaded
            goto continue
          end
        end
        if server == "hls" then
          local installed = require("lazy.core.config").plugins["haskell-tools.nvim"]
          if installed then
            -- Don't load haskell_language_server if haskell_tools is loaded
            goto continue
          end
        end
        vim.lsp.enable(server)
        ::continue::
      end
    end,
    dependencies = {
      { "b0o/schemastore.nvim" },
      {
        "Hoffs/omnisharp-extended-lsp.nvim",
        -- TODO: Setup keymaps if needed
      },
      {
        "saghen/blink.cmp", -- For capabibilies
      },
    },
  },
  -- LSP and DAP tools
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = auto_installed_servers,
    },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
  },
  { "mason-org/mason.nvim", cmd = "Mason", opts = {} },
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
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false, -- This plugin is already lazy
    keys = {
      {
        "K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
        function() vim.cmd.RustLsp { "hover", "actions" } end,
        ft = "rust",
      },
    },
  },
  {
    "mrcjkb/haskell-tools.nvim",
    version = "^6",
    lazy = false, -- This plugin is already lazy
    keys = {
      {
        "<space>lHs",
        function() require("haskell-tools").hoogle.hoogle_signature() end,
        ft = { "haskell", "cabal" },
        desc = "Hoogle: Search type signature under cursor",
      },
      {
        "<space>lHe",
        function() require("haskell-tools").lsp.buf_eval_all() end,
        ft = { "haskell", "cabal" },
        desc = "Haskell: Evaluate all code snippets",
      },
      {
        "<leader>lHr",
        function() require("haskell-tools").repl.toggle() end,
        ft = { "haskell", "cabal" },
        desc = "REPL: Toggle GHCi for package",
      },
      {
        "<leader>lHrb",
        function() require("haskell-tools").repl.toggle(vim.api.nvim_buf_get_name(0)) end,
        ft = { "haskell", "cabal" },
        desc = "REPL: Toggle GHCi for current buffer",
      },
      {
        "<leader>lHrq",
        function() require("haskell-tools").repl.quit() end,
        ft = { "haskell", "cabal" },
        desc = "REPL: Quit GHCi session",
      },
    },
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      files = {
        git_icons = true,
        -- NOTE: using rg with sortr=modified displays recently modified files at the
        --  top of the fzf input file list. Using the --tiebreak=index prefers
        --  the files on top of the list.
        --  CAVEAT: rg now runs SINGLE THREADED!
        cmd = [[rg --files --color=never --hidden --files -g "!.git" --sortr=modified]],
        fzf_opts = {
          ["--tiebreak"] = "index",
        },
      },
      keymap = {
        builtin = {
          true,
          ["<M-j>"] = "preview-down",
          ["<M-k>"] = "preview-up",
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
        fzf = {
          true,
          ["ctrl-d"] = "preview-page-down",
          ["ctrl-u"] = "preview-page-up",
          ["ctrl-q"] = "select-all+accept",
        },
      },
    },
    cmd = "FzfLua",
    keys = {
      { "<leader>f", "<cmd> FzfLua files<cr>", desc = "Find files" },
      { "<leader>g", "<cmd> FzfLua live_grep<cr>", desc = "Grep word in all files" },
      { "<leader>b", "<cmd> FzfLua buffers<cr>", desc = "List of all open buffers" },
      { "<leader>s", "<cmd> FzfLua git_status<cr>", desc = "Show git status" },
      { "<leader>om", "<cmd> FzfLua marks<cr>", desc = "List of all marks" },
      { "<leader>op", "<cmd> FzfLua manpages<cr>", desc = "List all manpages" },
      { "<leader>oc", "<cmd> FzfLua commands<cr>", desc = "List vim commands" },
      { "<leader>oh", "<cmd> FzfLua command_history<cr>", desc = "Show command history" },
      { "<leader>ot", "<cmd> FzfLua filetypes<cr>", desc = "List available filetypes" },
      { "<leader>ogc", "<cmd> FzfLua git_commits<cr>", desc = "List git commits" },
      { "<leader>ogC", "<cmd> FzfLua git_bcommits<cr>", desc = "List git commits of the buffer" },
      { "<leader>ogb", "<cmd> FzfLua git_branches<cr>", desc = "List git branches" },
      { "[w", "<cmd> FzfLua grep_cword<cr>", desc = "Grep for word under cursor" },
      { "[W", "<cmd> FzfLua grep_cWORD<cr>", desc = "Grep for WORD under cursor" },
    },
    config = function(_, opts)
      local fzf = require "fzf-lua"
      fzf.setup(opts)
      fzf.register_ui_select()
    end,
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
      keymap = {
        preset = "default",
        ["<C-z>"] = { "show_and_insert", "select_and_accept", "fallback" }, -- Nicer for swiss keyboard
        ["<C-y>"] = { "show_and_insert", "select_and_accept" },
      },
      signature = { enabled = false }, -- Ctrl-s is enough
      cmdline = {
        keymap = {
          preset = "cmdline",
          ["<C-z>"] = { "show_and_insert", "select_and_accept", "fallback" }, -- Nicer for swiss keyboard
          ["<C-y>"] = { "show_and_insert", "select_and_accept" },
        },
        sources = function()
          local type = vim.fn.getcmdtype()
          -- Search forward and backward
          if type == "/" or type == "?" then return { "buffer" } end
          -- Commands
          if type == ":" or type == "@" then return { "cmdline", "path", "buffer" } end
          return {}
        end,
      },
      -- (Default) Only show the documentation popup when manually triggered
      completion = {
        documentation = { auto_show = false },
        menu = {
          auto_show = false,
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", "source_name" } },
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
        default = { "buffer", "path", "snippets", "lsp" },
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
      fuzzy = {
        implementation = "prefer_rust_with_warning",
        sorts = { -- This config prioritizes exact matches
          "exact",
          -- defaults
          "score",
          "sort_text",
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
