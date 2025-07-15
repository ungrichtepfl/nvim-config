return {
  "folke/snacks.nvim",
  opts = {
    input = {}, -- Nicer input
    bigfile = {}, -- Do not launch lsp and treesitter on bigfiles
    quickfile = {}, -- Load file as quickly as possible
    dashboard = {
      sections = {
        { section = "header"},
        { section = "recent_files", align = "center", padding = 3},
        { section = "startup"},
      },
    },
  },
}
