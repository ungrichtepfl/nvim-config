local vault_path = vim.fn.expand "~" .. "/Notes/"

return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
  cmd = "RenderMarkdown",
  ft = "markdown",
  opts = {
    preset = "obsidian",
    -- Render only the Obsidian vault; obsidian.nvim skips its own UI when this plugin is installed
    ignore = function(buf) return not vim.startswith(vim.api.nvim_buf_get_name(buf), vault_path) end,
    completions = { blink = { enabled = true } },
  },
}
