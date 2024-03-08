local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(install_path) then
  LAZY_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    install_path,
  }
  print "Installing lazy. Close and reopen Neovim..."
end
vim.opt.rtp:prepend(install_path)

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
  { "moll/vim-bbye" },
  -- make lua vim startup time faster
  {
    "lewis6991/impatient.nvim",
    config = function() require "config.impatient" end,
  },
  -- autopairs
  {
    "windwp/nvim-autopairs",
    config = function() require "config.autopairs" end,
  }, -- autopairs integrates with treesitter and cmp
  -- nvimtree
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = {
      "kyazdani42/nvim-web-devicons", -- optional, for file icons
    },
    config = function() require "config.nvim-tree" end,
    -- version = "nighly" -- optional, updates every week
  },
  -- bufferline
  {
    "akinsho/bufferline.nvim",
    version = "v2.*",
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
    config = function() require "config.whichkey" end,
  },
  -- vim-visual-multi
  { "mg979/vim-visual-multi" },
  -- todo-comments
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function() require "config.todo-comments" end,
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
  { "L3MON4D3/LuaSnip", build = "make install_jsregexp"}, --snippet engine
  { "rafamadriz/friendly-snippets" }, -- a bunch of snippets to use

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function() require "config.lsp" end,
  }, -- enable LSP
  -- use "williamboman/nvim-lsp-installer" -- simple to use language server installer NOT MAINTAINED ANYMORE
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
    "jayp0521/mason-null-ls.nvim",
    dependencies = "neovim/nvim-lspconfig",
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
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    branch = "2.x.x",
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    dependencies = "neovim/nvim-lspconfig",
  },

  {
    "simrat39/rust-tools.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
  },

  -- DAP
  {
    "mfussenegger/nvim-dap",
    dependencies = "neovim/nvim-lspconfig",
    config = function() require "config.dap" end,
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = "mfussenegger/nvim-dap",
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
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
    "mrjones2014/nvim-ts-rainbow",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    dependencies = "nvim-treesitter/nvim-treesitter",
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
    "weilbith/nvim-code-action-menu",
    cmd = "CodeActionMenu",
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
    "anuvyklack/pretty-fold.nvim",
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
    "EthanJWright/vs-tasks.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
  -- zig
  -- {
  --   "ziglang/zig.vim",
  -- },
}

if LAZY_BOOTSTRAP then require("lazy").sync() end
