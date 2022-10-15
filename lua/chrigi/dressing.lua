local status_ok, dressing = pcall(require, "dressing")

if not status_ok then
  vim.notify "'dressing' plugin not found."
  return
end

dressing.setup {
  input = {
    default_prompt = "➤ ",
    winhighlight = "Normal:Normal,NormalNC:Normal",
  },
  select = {
    builtin = { winhighlight = "Normal:Normal,NormalNC:Normal" },
  },
}
