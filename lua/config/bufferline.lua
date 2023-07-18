local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  vim.notify "'bufferline' plugin not found."
  return
end

bufferline.setup {
  options = {
    close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
    right_mouse_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
    buffer_close_icon = "",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    offsets = {
      {
        filetype = "NvimTree",
        text = "", -- | function ,
        text_align = "left", -- | "center" | "right"
        separator = true,
      },
    },
    color_icons = true, -- | false, -- whether or not to add the filetype icon highlights
    show_buffer_icons = true, -- | false, -- disable filetype icons for buffers
    show_buffer_close_icons = true, -- | false,
    show_buffer_default_icon = true, -- | false, -- whether or not an unrecognised filetype should show a default icon
    show_close_icon = true, -- | false,
    show_tab_indicators = true, -- | false,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    -- can also be a table containing 2 custom separators
    -- [focused and unfocused]. eg: { '|', '|' }
    separator_style = "thin", -- | "slant" | "thick" | { 'any', 'any' },
  },
}
