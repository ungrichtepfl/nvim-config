local util = require "config.search.util"

local M = {}

--- @class Picker
--- @field title string
--- @field picker_title? string overrides `title` on the picker window only
--- @field query fun(query: string, on_items: fun(items: table[], explained?: boolean))
--- @field preview? string|fun(): string?
--- @field octo? boolean use octo's previewer and add an action to open the item in octo
--- @field no_input? boolean
--- @field with_nth? string fzf `--with-nth`, the preview still sees the hidden fields
--- @field yank_id? boolean
--- @field color? fun(item: table): string? `ansi_codes` name for the status column
--- @field google_search? string url template of a Google search with the same query
--- @field mark_done? fun(items: table[], on_failure: fun(item: table))
--- @field web? string|fun(query: string): string page of the results, `%s` is the query

--- @param colorize fun(status: string, item: table): string
--- @return string[] lines, table<string, table> by_line
local function format_aligned_lines(items, colorize)
  local width = vim.api.nvim_strwidth
  local id_width, status_width = 0, 0
  for _, item in ipairs(items) do
    id_width = math.max(id_width, width(item.id))
    if item.status then status_width = math.max(status_width, width(item.status)) end
  end

  local lines, by_line = {}, {}
  for _, item in ipairs(items) do
    local parts = { item.id .. string.rep(" ", id_width - width(item.id)) }
    if item.status then
      local status = item.status .. string.rep(" ", status_width - width(item.status))
      table.insert(parts, colorize and colorize(status, item) or status)
    end
    if item.text ~= "" then table.insert(parts, item.text) end
    local line = vim.trim(table.concat(parts, "  "))
    table.insert(lines, line)
    -- fzf returns lines without ANSI codes
    by_line[util.strip_ansi(line)] = item
  end
  return lines, by_line
end

local function open_item_url(item)
  if item then vim.ui.open(item.url) end
end

--- @param picker Picker
local function show_fzf_picker(fzf, picker, query, items)
  local github = require "config.search.github"
  local ansi = require("fzf-lua.utils").ansi_codes
  local state = { query = query, by_line = {}, dismissed = {}, octo_entries = {} }

  -- Called again by fzf on every `reload`
  local contents = function(fzf_cb)
    local feed = function(list)
      -- GitHub still lists a thread for a moment after it was marked done
      local visible = {}
      for _, item in ipairs(list) do
        if not (item.thread and state.dismissed[item.thread]) then table.insert(visible, item) end
      end
      local lines, by_line = format_aligned_lines(
        visible,
        function(status, item) return ansi[picker.color and picker.color(item) or "yellow"](status) end
      )
      state.by_line = by_line
      -- cleared in place: the octo previewer keeps this table
      for line in pairs(state.octo_entries) do
        state.octo_entries[line] = nil
      end
      for line, item in pairs(by_line) do
        state.octo_entries[line] = github.octo_previewer_entry(item)
      end
      for _, line in ipairs(lines) do
        fzf_cb(line)
      end
      fzf_cb() -- closes the pipe, fzf considers the list complete
    end
    if items then
      local first = items
      items = nil
      feed(first)
    else
      picker.query(state.query, feed)
    end
  end

  -- fzf-lua builds the header from the action headers
  local actions = {
    ["default"] = function(selected)
      for _, line in ipairs(selected) do
        open_item_url(state.by_line[line])
      end
    end,
    ["ctrl-y"] = {
      fn = function(selected)
        local values = {}
        for _, line in ipairs(selected) do
          local item = state.by_line[line]
          if item then table.insert(values, picker.yank_id and item.id or item.url) end
        end
        if #values == 0 then return end
        vim.fn.setreg("+", table.concat(values, "\n"))
        vim.notify("Copied to clipboard: " .. table.concat(values, ", "))
      end,
      header = picker.yank_id and "yank the words" or "yank the URLs",
    },
    -- `field_index = "{q}"` passes the typed query as `selected[1]`
    ["alt-r"] = {
      fn = function(selected) state.query = selected[1] or "" end,
      field_index = "{q}",
      reload = true,
      header = "re-query",
    },
  }
  if picker.web then
    -- The query of the results, not the prompt text (which only filters)
    actions["alt-o"] = {
      fn = function() util.open_url(picker.web, state.query) end,
      header = "open the web page",
    }
  end
  if picker.google_search then
    actions["ctrl-g"] = {
      fn = function() util.open_url(picker.google_search, state.query) end,
      header = "search Google instead",
    }
  end
  if picker.octo then
    actions["ctrl-o"] = {
      fn = function(selected)
        for _, line in ipairs(selected) do
          local item = state.by_line[line]
          if item then require("config.utils").open_github(item.url) end
        end
      end,
      header = "open in octo",
    }
  end
  if picker.mark_done then
    -- `reload` keeps the picker open, `noclose` alone leaves a dead terminal
    actions["ctrl-x"] = {
      fn = function(selected)
        local marked = {}
        for _, line in ipairs(selected) do
          local item = state.by_line[line]
          if item and item.thread then
            state.dismissed[item.thread] = true
            table.insert(marked, item)
          end
        end
        picker.mark_done(marked, function(item) state.dismissed[item.thread] = nil end)
      end,
      reload = true,
      header = "mark done",
    }
  end
  local previewer = picker.octo and github.octo_previewer(state.octo_entries) or nil
  fzf.fzf_exec(contents, {
    prompt = "> ",
    previewer = previewer,
    fzf_opts = {
      ["--ansi"] = true,
      ["--multi"] = true,
      ["--preview"] = not previewer and (type(picker.preview) == "function" and picker.preview() or picker.preview)
        or nil,
      ["--with-nth"] = picker.with_nth,
    },
    winopts = { title = " " .. (picker.picker_title or picker.title) .. " ", title_pos = "center" },
    -- Disable ctrl-q so it cannot open every entry (`false` would fall back to fzf's abort)
    keymap = { fzf = { ["ctrl-q"] = "ignore" } },
    actions = actions,
  })
end

--- @param picker Picker
local function show_select_picker(picker, items)
  local lines, by_line = format_aligned_lines(items, nil)
  vim.ui.select(lines, { prompt = picker.title .. ">" }, function(selected) open_item_url(by_line[selected]) end)
end

--- @param picker Picker
function M.open(picker)
  local run_query = function(text)
    local query = vim.trim(text)
    picker.query(query, function(items, explained)
      if #items == 0 then
        -- No "No results" after an error that was already shown
        if not explained then vim.notify("No results for " .. picker.title, vim.log.levels.WARN) end
        return
      end
      local ok, fzf = pcall(require, "fzf-lua")
      if ok then
        show_fzf_picker(fzf, picker, query, items)
      else
        show_select_picker(picker, items)
      end
    end)
  end
  if picker.no_input then
    run_query ""
  else
    vim.ui.input({ prompt = picker.title .. ": " }, function(input)
      if input == nil then return end -- Cancelled
      run_query(input)
    end)
  end
end

return M
