-- My own [harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) implementation
local utils = require "config.utils"

local mark_state = {
  index = 1,
  marks = { "H", "J", "K", "L" },
  marks_set = {},
}

function mark_state:sync()
  for _, m in ipairs(vim.fn.getmarklist()) do
    for _, mark in ipairs(self.marks) do
      if m.mark:sub(2, 2) == mark then table.insert(self.marks_set, mark) end
    end
  end
end

function mark_state:increase_index()
  self.index = self.index + 1
  if self.index > #self.marks then self.index = 1 end
end

function mark_state:decrease_index()
  self.index = self.index - 1
  if self.index < 1 then self.index = 1 end -- Should not happen
end

local function goto_mark(mark)
  local ok, err = pcall(vim.cmd, "'" .. mark)
  if not ok then
    local msg = err:match ":%s*(E%d+:.+)$" or err
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end
  utils.goto_last_edited()
end

function mark_state:add_mark()
  local mark = self.marks[self.index]
  vim.cmd.normal("m" .. mark)
  if #self.marks_set < #self.marks then table.insert(self.marks_set, mark) end
  self:increase_index()
  vim.notify("Added mark: " .. mark)
end

function mark_state:remove_mark(mark)
  local idx = -1
  for i, m in ipairs(self.marks_set) do
    if m == mark then
      idx = i
      break
    end
  end
  if idx == -1 then
    vim.notify("Mark " .. mark .. " was not set", vim.log.levels.WARN)
    return
  end
  vim.cmd("delmark " .. mark)
  table.remove(self.marks_set, idx)
  self:decrease_index()
  vim.notify("Removed mark " .. mark)
end

function mark_state:show_marks_fzf(fzf)
  local items = {}
  for _, m in ipairs(self.marks_set) do
    local fn = utils.mark_filename(m)
    fn = vim.fn.fnamemodify(fn, ":.")
    if fn then table.insert(items, string.format("%s: %s", m, fn)) end
  end

  fzf.fzf_exec(items, {
    prompt = "Marked Files> ",
    fzf_opts = {
      ["--preview"] = "bat --style=numbers --color=always $(echo {} | sed 's/^\\([A-Za-z]\\): //')",
    },
    actions = {
      ["default"] = function(selected)
        local mark = selected[1]:match "^(%a):"
        if mark then goto_mark(mark) end
      end,
      ["ctrl-d"] = function(selected)
        local mark = selected[1]:match "^(%a):"
        if mark then self:remove_mark(mark) end
      end,
      ["ctrl-a"] = function(_)
        local marks = {}
        for _, m in ipairs(self.marks_set) do -- Make shallow copy
          table.insert(marks, m)
        end
        for _, m in ipairs(marks) do
          self:remove_mark(m)
        end
      end,
    },
  })
end

function mark_state:show_marks()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then self:show_marks_fzf(fzf) end
end

local keymap = vim.keymap.set

keymap("n", "<leader>a", function() mark_state:add_mark() end, { desc = "Add a mark at current cursor position" })
keymap("n", "<C-e>", function() mark_state:show_marks() end, { desc = "Show manually added marks" })
keymap("n", "<A-h>", function() goto_mark "H" end, { desc = "Jump to mark H" })
keymap("n", "<A-j>", function() goto_mark "J" end, { desc = "Jump to mark J" })
keymap("n", "<A-k>", function() goto_mark "K" end, { desc = "Jump to mark K" })
keymap("n", "<A-l>", function() goto_mark "L" end, { desc = "Jump to mark L" })
keymap("n", "<leader>m", "mM", { desc = "Set global mark M" })
keymap("n", "<leader><leader>m", "`M", { desc = "Go to global mark M" })

local marks_group = vim.api.nvim_create_augroup("_marks", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = marks_group,
  callback = function() mark_state:sync() end,
})
