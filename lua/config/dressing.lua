local status_ok, dressing = pcall(require, "dressing")

if not status_ok then
  vim.notify "'dressing' plugin not found."
  return
end

dressing.setup {
  input = {
    default_prompt = "➤ ",
    win_options = { winhighlight = "Normal:Normal,NormalNC:Normal" },
  },
  select = {
    builtin = { win_options = { winhighlight = "Normal:Normal,NormalNC:Normal" } },
  },
}
