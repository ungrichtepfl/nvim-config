return {
  "folke/snacks.nvim",
  opts = {
    input = {}, -- Nicer input
    bigfile = {}, -- Do not launch lsp and treesitter on bigfiles
    quickfile = {}, -- Load file as quickly as possible
    dashboard = {
      preset = {
        keys = {
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        {
          section = "recent_files",
          cwd = true,
          align = "center",
        },
        {
          section = "keys",
          align = "center",
          padding = 3,
        },
        { section = "startup" },
      },
    },
  },
}
