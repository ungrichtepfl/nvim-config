local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  vim.notify "Plugin manager 'packer' is not installed"
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function() return require("packer.util").float { border = "rounded" } end,
  },
  snapshot_path = fn.stdpath "config" .. "/packer-snapshots",
}

-- Install your plugins here
return packer.startup(function(use)
  -- My plugins here
  use "wbthomason/packer.nvim" -- Have packer manage itself

  -- useful APIs
  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
  use "kyazdani42/nvim-web-devicons"
  -- neovim lua language server
  use "folke/neodev.nvim"
  -- better Bdelete
  use "moll/vim-bbye"
  -- make lua vim startup time faster
  use "lewis6991/impatient.nvim"
  -- autopairs
  use "windwp/nvim-autopairs" -- autopairs integrates with treesitter and cmp
  -- nvimtree
  use {
    "kyazdani42/nvim-tree.lua",
    requires = {
      "kyazdani42/nvim-web-devicons", -- optional, for file icons
    },
    -- tag = "nighly" -- optional, updates every week
  }
  -- bufferline
  use { "akinsho/bufferline.nvim", tag = "v2.*", requires = "kyazdani42/nvim-web-devicons" }
  -- lualine
  use "nvim-lualine/lualine.nvim"
  -- indent-blanklines
  use "lukas-reineke/indent-blankline.nvim"
  -- alpha (nice startup greeter)
  use { "goolord/alpha-nvim", requires = { "kyazdani42/nvim-web-devicons" } }
  -- whichkey
  use "folke/which-key.nvim"
  -- vim-visual-multi
  use "mg979/vim-visual-multi"
  -- todo-comments
  use { "folke/todo-comments.nvim", requires = "nvim-lua/plenary.nvim" }
  -- trouble
  -- Lua
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
  }

  -- Colorschemes
  use "lunarvim/colorschemes"
  use "folke/tokyonight.nvim"

  -- cmp plugins
  use "hrsh7th/nvim-cmp" -- The completion plugin
  use "hrsh7th/cmp-buffer" -- buffer completions
  use "hrsh7th/cmp-path" -- path completions
  use "hrsh7th/cmp-cmdline" -- cmdline completions
  use "saadparwaiz1/cmp_luasnip" -- snippet completions
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-nvim-lua"

  -- snippets
  use "L3MON4D3/LuaSnip" --snippet engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  -- LSP
  use "neovim/nvim-lspconfig" -- enable LSP
  -- use "williamboman/nvim-lsp-installer" -- simple to use language server installer NOT MAINTAINED ANYMORE
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"
  use "jose-elias-alvarez/null-ls.nvim"
  use "jayp0521/mason-null-ls.nvim"
  use "RubixDev/mason-update-all"
  -- DAP
  use "mfussenegger/nvim-dap"
  use "mfussenegger/nvim-dap-python"
  use "rcarriga/nvim-dap-ui"
  use "theHamsta/nvim-dap-virtual-text"
  use "nvim-telescope/telescope-dap.nvim"

  -- Telescope
  use {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    requires = "nvim-lua/plenary.nvim",
  }
  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  }
  -- additionally install fd-find, ripgrep
  use "nvim-telescope/telescope-media-files.nvim"

  -- Treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = function() require("nvim-treesitter.install").update { with_sync = true } end,
  }
  use "nvim-treesitter/nvim-treesitter-context"
  use "p00f/nvim-ts-rainbow"
  use "JoosepAlviste/nvim-ts-context-commentstring" -- to make context aware comments
  use "windwp/nvim-ts-autotag"

  -- Comments
  use { "numToSTr/Comment.nvim", requires = { "JoosepAlviste/nvim-ts-context-commentstring" } } -- easily comment stuff

  -- Gitsigns
  use {
    "lewis6991/gitsigns.nvim",
    -- tag = 'release' -- To use the latest release
  }

  -- Toggleterm
  use { "akinsho/toggleterm.nvim", tag = "*" }

  -- Projects
  use "ahmedkhalf/project.nvim"

  -- Add docstrings:
  use {
    "danymat/neogen",
    requires = "nvim-treesitter/nvim-treesitter",
    -- Uncomment next line if you want to follow only stable versions
    -- tag = "*"
  }

  -- resolve git conflics:
  use { "https://gitlab.com/yorickpeterse/nvim-pqf.git" }
  use { "akinsho/git-conflict.nvim", tag = "*", requires = "https://gitlab.com/yorickpeterse/nvim-pqf.git" }

  -- Code actions:
  use {
    "weilbith/nvim-code-action-menu",
    cmd = "CodeActionMenu",
  }

  -- lightbulb for code actions:
  use {
    "kosayoda/nvim-lightbulb",
    -- requires = "antoinemadec/FixCursorHold.nvim",
  }
  -- nicer notifications:
  use "rcarriga/nvim-notify"

  -- illuminate same variable:
  use "RRethy/vim-illuminate"

  -- UI enhancer
  use "stevearc/dressing.nvim"

  -- better escape for jk mappings
  use "max397574/better-escape.nvim"

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then require("packer").sync() end
end)
