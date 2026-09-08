-- Search GitHub repositories and Jira issues behind a `<leader>I` prefix.
-- Works without any plugin: falls back to `vim.ui.input` + `vim.ui.select`.
-- When fzf-lua is installed it is used as the picker instead.

local JIRA_SERVER = "https://scewosw.atlassian.net"
local GITHUB_USER = "ungrichtepfl"
local GITHUB_ORG = "Scewo"
local LIMIT = 100

-- NOTE: jira-cli always wraps stdout in a `tabwriter` with '\t' as pad char, so a
--  tab delimiter gets extra alignment tabs appended. A delimiter without any tab
--  leaves the line as a single (unpadded) cell, hence the ASCII unit separator.
local SEP = "\31"

local function strip_ansi(s) return (s:gsub("\27%[[%d;]*m", "")) end

--- Run `cmd` and hand its stdout to `parse`, then the parsed items to `on_items`.
--- @param cmd string[]
--- @param parse fun(stdout: string): table[]
--- @param on_items fun(items: table[])
local function run(cmd, parse, on_items)
  if vim.fn.executable(cmd[1]) == 0 then
    vim.notify(cmd[1] .. " is not installed", vim.log.levels.ERROR)
    return
  end
  vim.system(cmd, { text = true }, function(res)
    vim.schedule(function()
      local items = parse(res.stdout)
      -- NOTE: jira-cli exits 1 for an empty result just as it does for a failure,
      --  so its message is the only signal. It is a weak one: a bad token and even
      --  invalid JQL are all reported as "No result found", so a broken Jira query
      --  shows up here as an empty picker. gh does report its errors properly.
      if #items == 0 and res.code ~= 0 and not res.stderr:find("No result found", 1, true) then
        vim.notify(string.format("%s failed: %s", cmd[1], vim.trim(strip_ansi(res.stderr))), vim.log.levels.ERROR)
        return
      end
      on_items(items)
    end)
  end)
end

--- Query GitHub repositories of a single owner.
--- @param owner string user or organization login
local function repos(owner)
  return function(query, on_items)
    -- NOTE: the `--json` field names are the ones `gh search repos --help` lists.
    local cmd = {
      "gh",
      "search",
      "repos",
      "--owner",
      owner,
      "--limit",
      tostring(LIMIT),
      "--sort",
      "updated",
      "--json",
      "fullName,description,url",
    }
    if query ~= "" then table.insert(cmd, query) end
    run(cmd, function(stdout)
      local ok, found = pcall(vim.json.decode, stdout)
      if not ok or type(found) ~= "table" then return {} end
      local items = {}
      for _, repo in ipairs(found) do
        table.insert(items, { id = repo.fullName, text = repo.description or "", url = repo.url })
      end
      return items
    end, on_items)
  end
end

--- Query Jira issues of a single project.
--- @param project string project key
--- @param jql string extra JQL, AND-ed with the search text by jira-cli
local function issues(project, jql)
  return function(query, on_items)
    -- NOTE: jira-cli turns a positional argument into `text ~ "<query>"` and
    --  AND-s it onto `--jql`, so both can be combined.
    local cmd = {
      "jira",
      "issue",
      "list",
      "--project",
      project,
      "--jql",
      jql,
      "--order-by",
      "updated",
      "--paginate",
      "0:" .. LIMIT,
      "--plain",
      "--no-headers",
      "--columns",
      "KEY,STATUS,SUMMARY",
      "--delimiter",
      SEP,
    }
    if query ~= "" then table.insert(cmd, query) end
    run(cmd, function(stdout)
      local items = {}
      for _, line in ipairs(vim.split(stdout, "\n", { trimempty = true })) do
        local fields = vim.split(line, SEP, { plain = true })
        if #fields == 3 then
          table.insert(items, {
            id = fields[1],
            status = fields[2],
            text = fields[3],
            url = JIRA_SERVER .. "/browse/" .. fields[1],
          })
        end
      end
      return items
    end, on_items)
  end
end

-- `statusCategory != Done` is exactly "neither Done nor Cancelled": those two are
-- the only Done-category statuses in SOF.
local MINE_OPEN = "assignee = currentUser() AND statusCategory != Done"
local NOT_ARCHIVED = "status != Archive"

local GH_PREVIEW = "gh repo view {1}"
local JIRA_PREVIEW = "jira issue view --plain {1}"

local sources = {
  m = { title = "GitHub " .. GITHUB_USER, preview = GH_PREVIEW, query = repos(GITHUB_USER) },
  s = { title = "GitHub " .. GITHUB_ORG, preview = GH_PREVIEW, query = repos(GITHUB_ORG) },
  i = { title = "Jira SOF (mine, open)", preview = JIRA_PREVIEW, query = issues("SOF", MINE_OPEN) },
  r = { title = "Jira REQ", preview = JIRA_PREVIEW, query = issues("REQ", NOT_ARCHIVED) },
  t = { title = "Jira TP", preview = JIRA_PREVIEW, query = issues("TP", NOT_ARCHIVED) },
  f = { title = "Jira FMEA", preview = JIRA_PREVIEW, query = issues("FMEA", NOT_ARCHIVED) },
}

--- Pad every entry into aligned `id [status] text` lines.
--- @return string[] lines, table<string, table> by_line
local function format(items, colorize)
  local id_width, status_width = 0, 0
  for _, item in ipairs(items) do
    id_width = math.max(id_width, #item.id)
    if item.status then status_width = math.max(status_width, #item.status) end
  end

  local lines, by_line = {}, {}
  for _, item in ipairs(items) do
    local parts = { item.id .. string.rep(" ", id_width - #item.id) }
    if item.status then
      local status = item.status .. string.rep(" ", status_width - #item.status)
      table.insert(parts, colorize and colorize(status) or status)
    end
    if item.text ~= "" then table.insert(parts, item.text) end
    local line = vim.trim(table.concat(parts, "  "))
    table.insert(lines, line)
    -- NOTE: fzf strips the ANSI codes from what it hands back (`--ansi`), so the
    --  uncolored line is the right lookup key for both pickers.
    by_line[strip_ansi(line)] = item
  end
  return lines, by_line
end

local function open(item)
  if item then vim.ui.open(item.url) end
end

local function show_fzf(fzf, source, items)
  local ansi = require("fzf-lua.utils").ansi_codes
  local lines, by_line = format(items, ansi.yellow)
  fzf.fzf_exec(lines, {
    prompt = "> ",
    fzf_opts = {
      ["--ansi"] = true,
      ["--header"] = ":: <ctrl-y> to Yank URL",
      ["--preview"] = source.preview,
    },
    winopts = { title = " " .. source.title .. " ", title_pos = "center" },
    actions = {
      ["default"] = function(selected) open(by_line[selected[1]]) end,
      ["ctrl-y"] = function(selected)
        local item = by_line[selected[1]]
        if not item then return end
        vim.fn.setreg("+", item.url)
        vim.notify("Copied URL to clipboard: " .. item.url)
      end,
    },
  })
end

local function show_builtin(source, items)
  local lines, by_line = format(items, nil)
  vim.ui.select(lines, { prompt = source.title .. ">" }, function(selected) open(by_line[selected]) end)
end

local function search(key)
  local source = sources[key]
  vim.ui.input({ prompt = source.title .. ": " }, function(query)
    if query == nil then return end -- Cancelled
    source.query(vim.trim(query), function(items)
      if #items == 0 then
        vim.notify("No results for " .. source.title, vim.log.levels.WARN)
        return
      end
      local ok, fzf = pcall(require, "fzf-lua")
      if ok then
        show_fzf(fzf, source, items)
      else
        show_builtin(source, items)
      end
    end)
  end)
end

for key, source in pairs(sources) do
  vim.keymap.set("n", "<leader>I" .. key, function() search(key) end, { desc = "Search " .. source.title })
end
