return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
  cmd = "RenderMarkdown",
  ft = "markdown",
  opts = {
    enabled = false,
    completions = { blink = { enabled = true } },
  },
}
