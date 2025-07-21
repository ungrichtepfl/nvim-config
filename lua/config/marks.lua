-- My own [harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) implementation
local utils = require "config.utils"

local mark_state = {
  version = 0,
  index = 1,
  marks = { "H", "J", "K", "L" },
  marks_set = {},
}

local function get_dir() return vim.fn.stdpath "state" .. "/marks/" end

local function get_file(dir)
  local cwd = vim.fn.getcwd()
  local name = utils.escape_path(cwd)
  return dir .. name .. ".json"
end

function mark_state:load()
  local filepath = get_file(get_dir())
  if vim.fn.filereadable(filepath) == 0 then
    -- File does not exist
    return
  end
  local content = table.concat(vim.fn.readfile(filepath), "\n")
  local ok, state = pcall(vim.json.decode, content)
  if not ok then
    -- File corrupt ignore
    return
  end

  if
    not (
      type(state.version) == "number"
      and type(state.index) == "number"
      and type(state.marks_set) == "table"
      and type(state.marks) == "table"
      and state.index <= #self.marks
    )
  then
    -- Wrong format: ignore
    return
  end

  if state.version ~= self.version then
    -- old version: ignore
    return
  end

  self.index = state.index
  self.marks_set = state.marks_set
  for _, m in ipairs(self.marks) do
    local fn = self.marks_set[m]
    if fn then
      local bufnr = vim.fn.bufadd(vim.fn.expand(fn))
      vim.fn.bufload(bufnr)
      vim.api.nvim_buf_set_mark(bufnr, m, 1, 0, {})
      vim.api.nvim_buf_delete(bufnr, { unload = true })
    else
      vim.cmd("delmark " .. m)
    end
  end
end

function mark_state:save()
  local filedir = get_dir()
  if vim.fn.isdirectory(filedir) == 0 then vim.fn.mkdir(filedir, "p") end
  local to_save = {}
  for k, v in pairs(self) do
    if type(v) == "table" or type(v) == "string" or type(v) == "number" or type(v) == "boolean" then to_save[k] = v end
  end
  local serialized = vim.json.encode(to_save)
  local filepath = get_file(filedir)
  vim.fn.writefile({ serialized }, filepath)
end

function mark_state:increase_index()
  self.index = self.index + 1
  if self.index > #self.marks then self.index = 1 end
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
  local mark = nil
  for _, m in ipairs(self.marks) do
    if self.marks_set[m] == nil then
      mark = m
      break
    end
  end
  if mark == nil then
    mark = self.marks[self.index]
    self:increase_index()
  end

  vim.cmd.normal("m" .. mark)
  self.marks_set[mark] = utils.mark_filename(mark)
  vim.notify("Added mark: " .. mark)
end

function mark_state:remove_mark(mark)
  if self.marks_set[mark] == nil then
    vim.notify("Mark " .. mark .. " was not set", vim.log.levels.WARN)
    return
  end
  vim.cmd("delmark " .. mark)
  self.marks_set[mark] = nil
  self.index = 1 -- Reset as there is space now
  vim.notify("Removed mark " .. mark)
end

function mark_state:show_marks_fzf(fzf, items)
  fzf.fzf_exec(items, {
    prompt = "Marked Files> ",
    fzf_opts = {
      ["--header"] = ":: <ctrl-d> to Delete Mark\n:: <ctrl-a> to Delete ALL Marks",
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
        local marks_set = {}
        for m, fn in pairs(self.marks_set) do -- Make shallow copy
          marks_set[m] = fn
        end
        for m, _ in pairs(marks_set) do
          self:remove_mark(m)
        end
      end,
    },
  })
end

function mark_state:show_marks_builtin(items)
  vim.ui.select(items, {
    prompt = "Marked files>",
  }, function(selected)
    if selected then
      local mark = selected:match "^(%a):"
      if mark then goto_mark(mark) end
    end
  end)
end

function mark_state:show_marks()
  local items = {}
  for m, fn in pairs(self.marks_set) do
    fn = vim.fn.fnamemodify(fn, ":.")
    if fn then table.insert(items, string.format("%s: %s", m, fn)) end
  end
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    self:show_marks_fzf(fzf, items)
  else
    self:show_marks_builtin(items)
  end
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
  callback = function() mark_state:load() end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  group = marks_group,
  callback = function() mark_state:save() end,
})
