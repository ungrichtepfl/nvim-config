return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
  cmd = "RenderMarkdown",
  ft = "markdown",
  opts = {
    enabled = false,
    completions = { blink = { enabled = true } },
    -- Look similar to glow: compact blocks instead of full-width bars
    heading = {
      width = "block",
      left_pad = 1,
      right_pad = 1,
      icons = {},
      border = true,
    },
    code = {
      width = "block",
      right_pad = 1,
    },
    pipe_table = { preset = "round" },
    -- Keep the cursor line rendered too; the raw text shows only in insert mode
    anti_conceal = { enabled = false },
    -- Narrow glyphs: ● and ○ are drawn wider than one cell and cover the space after them
    bullet = { icons = { "•", "◦" } },
    win_options = {
      -- Wrapped list lines start under the item text; the list pattern comes from the markdown ftplugin
      breakindent = { default = vim.o.breakindent, rendered = true },
      breakindentopt = { default = vim.o.breakindentopt, rendered = "list:-1" },
    },
  },
}
