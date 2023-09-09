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

local function open_nvim_tree(data)
  local IGNORED_FT = {
    "markdown",
    "startify",
    "alpha",
    "dashboard",
  }

  -- buffer is a real file on the disk
  local real_file = vim.fn.filereadable(data.file) == 1

  -- buffer is directory
  local directory = vim.fn.isdirectory(data.file) == 1

  -- buffer is a [No Name]
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

  if directory then
    if not no_name and not directory then return end

    -- change to the directory
    if directory then vim.cmd.cd(data.file) end

    -- open the tree
    require("nvim-tree.api").tree.open()
  else
    -- &ft
    local filetype = vim.bo[data.buf].ft

    -- only files please
    if not real_file and not no_name then return end

    -- skip ignored filetypes
    if vim.tbl_contains(IGNORED_FT, filetype) then return end

    -- open the tree but don't focus it
    require("nvim-tree.api").tree.toggle { focus = false }
  end
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
