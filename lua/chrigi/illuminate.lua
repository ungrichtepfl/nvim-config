local status_ok, illuminate = pcall(require, "illuminate")

if not status_ok then
  vim.notify "'illuminate' plugin not found."
  return
end

illuminate.configure {
  delay = 120,
  filetypes_denylist = {
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
