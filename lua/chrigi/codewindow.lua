local status_ok, codewindow = pcall(require, "codewindow")
if not status_ok then
  vim.notify "'codewindow' plugin not found."
  return
end

codewindow.setup {
  exclude_filetypes = {
    "dirvish",
    "fugitive",
    "alpha",
    "NvimTree",
    "packer",
    "neogitstatus",
    "Trouble",
    "lir",
    "Outline",
    "spectre_panel",
    "toggleterm",
    "DressingSelect",
    "TelescopePrompt",
  },
}
