local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
  vim.notify "'nvim-tree' plugin not found."
  return
end

local status_ok_web, web_devicons = pcall(require, "nvim-web-devicons")
if status_ok_web then
  -- Problem with default icon for text files
  web_devicons.set_icon {
    txt = { icon = "" },
    xlsx = { icon = "" },
  }
end

nvim_tree.setup {
  on_attach = require("config.nvim-tree-on-attach").on_attach,
  disable_netrw = true,
  diagnostics = {
    enable = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  },
  view = {
    side = "left",
  },
  renderer = {
    root_folder_modifier = ":t",
    highlight_git = true,
    icons = {
      glyphs = {
        default = "",
        symlink = "",
        git = {
          unstaged = "",
          staged = "S",
          unmerged = "",
          renamed = "➜",
          deleted = "",
          untracked = "U",
          ignored = "◌",
        },
        folder = {
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
        },
      },
    },
  },
  -- projects plugin support:
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true,
    ignore_list = {},
  },
}
