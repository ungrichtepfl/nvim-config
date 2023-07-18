local status_ok, no_neck_pain = pcall(require, "no-neck-pain")

if not status_ok then
  vim.notify "'no-neck-pain' plugin not found"
  return
end

no_neck_pain.setup {
  width = 180,
}
