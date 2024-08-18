local status_ok_ts, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok_ts then
  vim.notify "'nvim-treesitter' plugin not installed."
  return
end

configs.setup {
  ensure_installed = {
    "arduino",
    "asm",
    "bash",
    "c",
    "c_sharp",
    "cmake",
    "cpp",
    "css",
    "diff",
    "doxygen",
    "elm",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "go",
    "gomod",
    "haskell",
    "html",
    "java",
    "javascript",
    "json",
    "json5",
    "latex",
    "llvm",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "matlab",
    "nasm",
    "nix",
    "python",
    "query",
    "regex",
    "rst",
    "rust",
    "sql",
    "ssh_config",
    "toml",
    "tsx",
    "typescript",
    "udev",
    "vim",
    "vimdoc",
    "vue",
    "xml",
    "yaml",
    "zig",
  },
  sync_install = false,
  ignore_install = { "" }, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "" }, -- list of language that will be disabled
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true, disable = { "" } },
  -- ts-rainbow plugin extension:
  rainbow = {
    enable = true,
    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
    -- colors = {}, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
  },
  -- autopairs plugin (better integration, but optional):
  autopairs = {
    enable = true,
  },
  -- nvim-ts-context-commentstring plugin:
  contex_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
  -- nvim-ts-autotag plugin:
  autotag = {
    enable = true,
  },
  -- textobjects plugin:
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        -- You can also use captures from other query groups like `locals.scm`
        ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ["@parameter.outer"] = "v", -- charwise
        ["@function.outer"] = "V", -- linewise
        ["@class.outer"] = "<c-v>", -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true or false
      include_surrounding_whitespace = true,
    },
  },
}

-- vim.opt.foldmethod     = 'expr'
-- vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
---WORKAROUND
vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufNew", "BufNewFile", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("TS_FOLD_WORKAROUND", {}),
  callback = function()
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  end,
})
---ENDWORKAROUND

local status_ts_context, ts_context = pcall(require, "treesitter-context")
if not status_ts_context then
  vim.notify "'treesitter_context' plugin not found."
  return
end

ts_context.setup()
