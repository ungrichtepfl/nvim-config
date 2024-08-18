-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)
-- Use a protected call so we don't error out on first use
local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  vim.notify "Plugin manager 'lazy' is not installed"
  return
end

-- Install your plugins here
lazy.setup {
  -- useful APIs
  { "nvim-lua/popup.nvim" }, -- An implementation of the Popup API from vim in Neovim
  { "nvim-lua/plenary.nvim" }, -- Useful lua functions used ny lots of plugins
  { "kyazdani42/nvim-web-devicons" },
  -- neovim lua language server
  {
    "folke/neodev.nvim",
    config = function() require "config.neodev" end,
  },
  -- better Bdelete
  { "famiu/bufdelete.nvim" },
  -- make lua vim startup time faster
  {
    "lewis6991/impatient.nvim",
    config = function() require "config.impatient" end,
  },
  -- autopairs integrates with treesitter and cmp
  {
    "windwp/nvim-autopairs",
    config = function() require "config.autopairs" end,
  },
  -- directory manager
  {
    "stevearc/oil.nvim",
    opts = {
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, bufnr) return name == ".." end,
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  -- bufferline
  {
    "akinsho/bufferline.nvim",
    dependencies = "kyazdani42/nvim-web-devicons",
    config = function() require "config.bufferline" end,
  },
  -- lualine
  {
    "nvim-lualine/lualine.nvim",
    config = function() require "config.lualine" end,
  },
  -- smart guess indent
  {
    "nmac427/guess-indent.nvim",
    config = function() require("guess-indent").setup {} end,
  },
  -- indent-blanklines
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function() require "config.indentline" end,
  },
  -- alpha (nice startup greeter},
  {
    "goolord/alpha-nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function() require "config.alpha" end,
  },
  -- whichkey
  {
    "folke/which-key.nvim",
    opts = {
      notify = false, -- don't warn if there are issues with the keymaps
    },
    config = function() require "config.whichkey" end,
  },
  -- multicursors
  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvimtools/hydra.nvim",
    },
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "v", "n" },
        "<Leader>M",
        "<cmd>MCstart<cr>",
        desc = "Create a selection for selected text or word under the cursor",
      },
    },
  },
  -- todo-comments
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    opts = {},
  },
  -- trouble
  -- Lua
  {
    "folke/trouble.nvim",
    dependencies = "kyazdani42/nvim-web-devicons",
    config = function() require "config.trouble" end,
  },

  -- Colorschemes
  { "lunarvim/colorschemes", lazy = true },
  { "folke/tokyonight.nvim", lazy = true },
  {
    "zenbones-theme/zenbones.nvim",
    dependencies = "rktjmp/lush.nvim",
    lazy = true,
  },
  { "briones-gabriel/darcula-solid.nvim", lazy = true, dependencies = "rktjmp/lush.nvim" },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },

  -- cmp plugins
  {
    "hrsh7th/nvim-cmp",
    config = function() require "config.cmp" end,
  }, -- The completion plugin
  {
    "hrsh7th/cmp-buffer",
    dependencies = "hrsh7th/nvim-cmp",
  }, -- buffer completions
  {
    "hrsh7th/cmp-path",
    dependencies = "hrsh7th/nvim-cmp",
  }, -- path completions
  {
    "hrsh7th/cmp-cmdline",
    dependencies = "hrsh7th/nvim-cmp",
  }, -- cmdline completions
  {
    "saadparwaiz1/cmp_luasnip",
    dependencies = "hrsh7th/nvim-cmp",
  }, -- snippet completions
  {
    "hrsh7th/cmp-nvim-lsp",
    dependencies = "hrsh7th/nvim-cmp",
  },
  {
    "hrsh7th/cmp-nvim-lua",
    dependencies = "hrsh7th/nvim-cmp",
  },

  -- snippets
  { "L3MON4D3/LuaSnip", build = "make install_jsregexp" }, --snippet engine
  { "rafamadriz/friendly-snippets" }, -- a bunch of snippets to use

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function() require "config.lsp" end,
  }, -- enable LSP
  {
    "williamboman/mason.nvim",
    dependencies = "neovim/nvim-lspconfig",
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = "neovim/nvim-lspconfig",
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = "neovim/nvim-lspconfig",
  },
  {
    "mfussenegger/nvim-lint",
    config = function() require "config.lint" end,
  },
  {
    "mhartington/formatter.nvim",
    config = function() require "config.formatter" end,
  },
  {
    "RubixDev/mason-update-all",
    dependencies = "neovim/nvim-lspconfig",
  },
  {
    "b0o/schemastore.nvim",
    dependencies = "neovim/nvim-lspconfig",
  },
  {
    "MrcJkb/haskell-tools.nvim",
    version = "^4", -- Recommended
    lazy = false, -- This plugin is already lazy
    dependencies = { "neovim/nvim-lspconfig", "mfussenegger/nvim-dap" },
    config = function() require "config.haskell_tools" end,
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    dependencies = "neovim/nvim-lspconfig",
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    lazy = false, -- This plugin is already lazy
    dependencies = { "neovim/nvim-lspconfig", "mfussenegger/nvim-dap" },
    config = function() require "config.rustaceanvim" end,
  },

  -- DAP
  {
    "mfussenegger/nvim-dap",
    dependencies = { "neovim/nvim-lspconfig", "Joakker/lua-json5" },
    config = function() require "config.dap" end,
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = "mfussenegger/nvim-dap",
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio", "folke/neodev.nvim" },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = "mfussenegger/nvim-dap",
  },
  {
    "nvim-telescope/telescope-dap.nvim",
    dependencies = "nvim-telescope/telescope.nvim",
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    -- commit = "533c7fb",
    dependencies = "nvim-lua/plenary.nvim",
    config = function() require "config.telescope" end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",

    dependencies = "nvim-telescope/telescope.nvim",
  },
  -- additionally install fd-find, ripgrep
  {
    "nvim-telescope/telescope-media-files.nvim",
    dependencies = "nvim-telescope/telescope.nvim",
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = function() require("nvim-treesitter.install").update { with_sync = true } end,
    config = function() require "config.treesitter" end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function() require("ts_context_commentstring").setup { enable_autocmd = false } end,
  }, -- to make context aware comments
  {
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },

  -- Comments
  {
    "numToSTr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function() require "config.comment" end,
  }, -- easily comment stuff

  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    config = function() require "config.gitsigns" end,
    -- version = 'release' -- To use the latest release
  },

  -- Toggleterm
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function() require "config.toggleterm" end,
  },

  -- Projects
  {
    "ahmedkhalf/project.nvim",
    config = function() require "config.project" end,
    dependencies = "nvim-telescope/telescope.nvim",
  },

  -- Add docstrings:
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function() require "config.neogen" end,
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },

  -- resolve git conflicts:
  { "https://gitlab.com/yorickpeterse/nvim-pqf.git" },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    dependencies = "https://gitlab.com/yorickpeterse/nvim-pqf.git",
    config = function() require "config.git_conflict" end,
  },

  -- Code actions:
  {
    "aznhe21/actions-preview.nvim",
    config = function()
      require("actions-preview").setup {
        telescope = {
          sorting_strategy = "ascending",
          layout_strategy = "vertical",
          layout_config = {
            width = 0.8,
            height = 0.9,
            prompt_position = "top",
            preview_cutoff = 20,
            preview_height = function(_, _, max_lines) return max_lines - 15 end,
          },
        },
      }
    end,
  },

  -- lightbulb for code actions:
  {
    "kosayoda/nvim-lightbulb",
    config = function() require "config.lightbulb" end,
    -- dependencies = "antoinemadec/FixCursorHold.nvim",
  },
  -- nicer notifications:
  {
    "rcarriga/nvim-notify",
    dependencies = "nvim-telescope/telescope.nvim",
    config = function() require "config.notify" end,
  },

  -- illuminate same variable:
  {
    "RRethy/vim-illuminate",
    config = function() require "config.illuminate" end,
  },

  -- UI enhancer
  {
    "stevearc/dressing.nvim",
    config = function() require "config.dressing" end,
  },

  -- better escape for jk mappings
  {

    "max397574/better-escape.nvim",
    config = function() require "config.better_escape" end,
  },

  -- refactoring
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function() require "config.refactoring" end,
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  -- surround stuff
  {
    "kylechui/nvim-surround",
    version = "*",
    config = function() require "config.surround" end,
  },

  -- git diffview
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function() require "config.diffview" end,
  },
  {
    "isakbm/gitgraph.nvim",
    dependencies = { "sindrets/diffview.nvim" },
    opts = {
      hooks = {
        -- Check diff of a commit
        on_select_commit = function(commit)
          vim.notify("DiffviewOpen " .. commit.hash .. "^!")
          vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
        end,
        -- Check diff from commit a -> commit b
        on_select_range_commit = function(from, to)
          vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
          vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
        end,
      },
    },
    keys = {
      {
        "<leader>gG",
        function() require("gitgraph").draw({}, { all = true, max_count = 5000 }) end,
        desc = "GitGraph - Draw",
      },
    },
  },

  -- nice scrollbar
  {
    "petertriho/nvim-scrollbar",
    dependencies = { "kevinhwang91/nvim-hlslens", "lewis6991/gitsigns.nvim" },
    config = function() require "config.scrollbar" end,
  },
  {
    "ray-x/lsp_signature.nvim",
    dependencies = "neovim/nvim-lspconfig",
    config = function() require "config.lsp_signature" end,
  },
  -- nicer folds
  {
    -- "anuvyklack/pretty-fold.nvim",
    "bbjornstad/pretty-fold.nvim", -- fork that works with nvim 0.10
    config = function() require "config.pretty-fold" end,
  },

  -- Github copilot
  {
    "github/copilot.vim",
    config = function() require "config.copilot" end,
  },

  -- Center window
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    config = function() require "config.no_neck_pain" end,
  },

  -- VSCode Tasks
  {
    "Joakker/lua-json5",
    build = "./install.sh",
  },
  {
    "EthanJWright/vs-tasks.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "Joakker/lua-json5",
    },
    config = function() require("vstask").setup { json_parser = require("json5").parse } end,
  },
  -- zig
  -- {
  --   "ziglang/zig.vim",
  -- },
}
