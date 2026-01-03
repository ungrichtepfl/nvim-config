return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  -- optional: provides snippets for the snippet source
  dependencies = { { "rafamadriz/friendly-snippets" }, { "echasnovski/mini.icons" } },

  -- use a release tag to download pre-built binaries
  version = "*",
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
      ["<C-j>"] = { "scroll_documentation_down", "fallback" },
      ["<C-k>"] = { "scroll_documentation_up", "fallback" },
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
          columns = { { "kind_icon" }, { "label", "label_description" }, { "source_name" } },
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
      default = { "snippets", "lsp", "buffer", "path" },
      per_filetype = {
        vim = { inherit_defaults = true, "cmdline" },
      },
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
}
