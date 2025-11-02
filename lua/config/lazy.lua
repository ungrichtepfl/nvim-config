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

vim.o.rtp = lazypath .. "," .. vim.o.rtp

-- Setup lazy.nvim
require("lazy").setup {
  git = {
    timeout = 60 * 60, -- For slow networks
  },
  spec = {
    import = "plugins", -- load all plugins in "lua/plugins"
  },
  change_detection = {
    enabled = false,
    notify = false,
  },
}
