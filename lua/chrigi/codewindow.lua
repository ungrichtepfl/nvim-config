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
local status_ok_tele, telescope = pcall(require, "telescope")
if not status_ok_tele then
  vim.notify "'telescope' plugin not found."
  return
end

telescope.load_extension "refactoring"
