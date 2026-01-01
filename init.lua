require "config.options" -- NOTE: Must be loaded first
require "config.keymaps"
require "config.autocommands"
require "config.harpoon"
require "config.statusline"
require "config.lazy" -- Takes care of the plugins
require "config.lsp" -- Loads the lsp config, load after plugins as it needs some optional plugins
