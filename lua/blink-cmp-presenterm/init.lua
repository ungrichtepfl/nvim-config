--- blink.cmp source for presenterm comment commands (<!-- pause -->, <!-- column: 0 -->, ...).
--- The command list comes from `presenterm --list-comment-commands`, so it matches the installed version.
--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

function source.new()
  local self = setmetatable({}, { __index = source })
  --- @type string[]?
  self.commands = nil
  return self
end

---Command name to match against while typing, e.g. "column_layout" for "<!-- column_layout: [1, 2] -->"
---@param command string
---@return string
local function command_name(command) return command:match "^<!%-%-%s*([%w_]+)" or command end

---Turn the example value into a snippet placeholder: "<!-- new_lines: 2 -->" -> "<!-- new_lines: ${1:2} -->"
---@param command string
---@return string
local function to_snippet(command)
  local escaped = command:gsub("[%$}\\]", "\\%0")
  return (escaped:gsub(": (.-) %-%->$", ": ${1:%1} -->"))
end

---@param context blink.cmp.Context
---@param commands string[]
---@return lsp.CompletionItem[]
local function build_items(context, commands)
  local line, col = context.cursor[1] - 1, context.cursor[2]
  local start_col = context.bounds.start_col - 1
  -- Replace an already typed "<!--" as well, so it is not doubled
  local typed_opening = context.line:sub(1, start_col):match "<!%-%-%s*$"
  if typed_opening then start_col = start_col - #typed_opening end

  return vim.tbl_map(function(command)
    return {
      label = command,
      filterText = command_name(command),
      kind = require("blink.cmp.types").CompletionItemKind.Snippet,
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
      textEdit = {
        newText = to_snippet(command),
        range = { start = { line = line, character = start_col }, ["end"] = { line = line, character = col } },
      },
    }
  end, commands)
end

function source:get_completions(context, callback)
  if self.commands then
    callback { items = build_items(context, self.commands), is_incomplete_backward = false, is_incomplete_forward = false }
    return
  end
  if vim.fn.executable "presenterm" == 0 then
    vim.notify("presenterm is not installed", vim.log.levels.ERROR, { title = "blink-cmp-presenterm" })
    callback { items = {} }
    return
  end

  local job = vim.system({ "presenterm", "--list-comment-commands" }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(
          "presenterm --list-comment-commands failed: " .. (result.stderr or ""),
          vim.log.levels.ERROR,
          { title = "blink-cmp-presenterm" }
        )
        callback { items = {} }
        return
      end
      self.commands = vim.split(vim.trim(result.stdout), "\n", { trimempty = true })
      callback { items = build_items(context, self.commands), is_incomplete_backward = false, is_incomplete_forward = false }
    end)
  end)
  return function() job:kill "sigterm" end
end

return source
