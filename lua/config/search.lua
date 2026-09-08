-- Search GitHub, Jira, Confluence and Google behind a single `PREFIX`.
-- Pickers (`sources`) work without any plugin: they fall back to `vim.ui.input`
-- + `vim.ui.select`, and use fzf-lua when it is installed. Entries that only
-- open a URL in the browser live in `links`.

local PREFIX = "<leader>j"

local JIRA_SERVER = "https://scewosw.atlassian.net"
local CONFLUENCE_SERVER = JIRA_SERVER .. "/wiki"
-- Taken from the Atlassian notification page's address bar: the notification
-- inbox has neither a documented URL nor a public API.
local JIRA_NOTIFICATIONS =
  "https://home.atlassian.com/o/340bf104-3ba2-4426-adda-528ed9bc1728/notifications?cloudId=6f8cc0c8-4809-40a4-8303-db00047cf75d"
local GOOGLE_SEARCH = "https://www.google.com/search?q=%s"
local GITHUB_NOTIFICATIONS = "https://github.com/notifications"
-- Both taken from the address bar of a search run in the browser.
local CONFLUENCE_SEARCH = CONFLUENCE_SERVER .. "/search?text=%s&product=confluence"
local JIRA_SEARCH = JIRA_SERVER .. "/issues?jql=%s"
local GITHUB_USER = "ungrichtepfl"
local GITHUB_ORG = "Scewo"
local LIMIT = 100

-- NOTE: jira-cli always wraps stdout in a `tabwriter` with '\t' as pad char, so a
--  tab delimiter gets extra alignment tabs appended. A delimiter without any tab
--  leaves the line as a single (unpadded) cell, hence the ASCII unit separator.
local SEP = "\31"

local function strip_ansi(s) return (s:gsub("\27%[[%d;]*m", "")) end

--- Percent-encode everything outside the RFC 3986 unreserved set.
local function urlencode(s)
  return (s:gsub("[^%w%-%.%_%~]", function(c) return string.format("%%%02X", string.byte(c)) end))
end

-- Lucene operators inside a `~` value; turned into separators so that a
-- term like "UT-053" is searched for as its two parts instead of tripping the
-- query parser. Jira and Confluence take the same operators.
local LUCENE_SPECIAL = '[+%-&|!(){}%[%]^"~*?:\\/]'

--- Split the search text into Lucene terms.
local function terms_of(query)
  local terms = {}
  for word in query:gsub(LUCENE_SPECIAL, " "):gmatch "%S+" do
    table.insert(terms, word)
  end
  return terms
end

--- Join `terms` into a prefix-matching query, "" when there are none.
--- NOTE: Jira's and Confluence's `~` both match whole words and AND the terms,
---  so "tool" finds nothing until it becomes "tool*": it does not even match
---  "toolbox" (checked against both).
local function prefixed(terms) return #terms > 0 and (table.concat(terms, "* ") .. "*") or "" end

--- Run `cmd` and hand its stdout to `parse`, then the parsed items to `on_items`.
--- @param cmd string[]
--- @param parse fun(stdout: string): table[]
--- @param on_items fun(items: table[])
--- @param stdin string? written to the process' stdin, which is then closed
local function run(cmd, parse, on_items, stdin)
  -- NOTE: every bail-out has to reach `on_items`, or the fzf reload it feeds
  --  waits for a pipe that is never closed and the picker hangs on "loading".
  if vim.fn.executable(cmd[1]) == 0 then
    vim.notify(cmd[1] .. " is not installed", vim.log.levels.ERROR)
    on_items {}
    return
  end
  vim.system(cmd, { text = true, stdin = stdin }, function(res)
    vim.schedule(function()
      local items = parse(res.stdout)
      -- NOTE: jira-cli exits 1 for an empty result just as it does for a failure,
      --  so its message is the only signal. It is a weak one: a bad token and even
      --  invalid JQL are all reported as "No result found", so a broken Jira query
      --  shows up here as an empty picker. gh and curl report their errors properly.
      if #items == 0 and res.code ~= 0 and not res.stderr:find("No result found", 1, true) then
        vim.notify(string.format("%s failed: %s", cmd[1], vim.trim(strip_ansi(res.stderr))), vim.log.levels.ERROR)
        on_items {}
        return
      end
      on_items(items)
    end)
  end)
end

-- Atlassian's REST APIs take the same basic auth as jira-cli: the account e-mail
-- from its config plus the API token from `$JIRA_API_TOKEN`. The token is handed
-- to curl through `-K -` (a config file on stdin) to keep it out of the argv.
local JIRA_CONFIG = vim.fn.expand "~/.config/.jira/.config.yml"

local login_cache
local function atlassian_login()
  if login_cache == nil then
    login_cache = false
    for _, line in ipairs(vim.fn.readfile(JIRA_CONFIG)) do
      local login = line:match "^login:%s*(%S+)"
      if login then
        login_cache = login
        break
      end
    end
  end
  return login_cache or nil
end

--- @return string? curl config for `-K -`, nil if the credentials are incomplete
local function atlassian_curl_config()
  local login, token = atlassian_login(), vim.env.JIRA_API_TOKEN
  if not login then
    vim.notify("No `login:` found in " .. JIRA_CONFIG, vim.log.levels.ERROR)
    return nil
  end
  if not token or token == "" then
    vim.notify("$JIRA_API_TOKEN is not set", vim.log.levels.ERROR)
    return nil
  end
  return string.format('user = "%s:%s"\n', login, token)
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
    --  AND-s it onto `--jql`, so both can be combined (`--debug` prints the
    --  JQL it ends up sending).
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
    local search_text = prefixed(terms_of(query))
    if search_text ~= "" then table.insert(cmd, search_text) end
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

--- The Jira issue navigator url for one of the pickers above, so that the
--- browser opens on the same project, filter and search text.
--- @param project string project key
--- @param jql string the picker's extra JQL
local function issues_web(project, jql)
  return function(query)
    local clauses = { string.format('project = "%s"', project) }
    if jql ~= "" then table.insert(clauses, jql) end
    local search_text = prefixed(terms_of(query))
    if search_text ~= "" then table.insert(clauses, string.format('text ~ "%s"', search_text)) end
    return JIRA_SEARCH:format(urlencode(table.concat(clauses, " AND ")))
  end
end

--- Query Confluence pages over the whole site.
local function pages()
  return function(query, on_items)
    local config = atlassian_curl_config()
    if not config then
      on_items {}
      return
    end
    -- NOTE: `siteSearch` is the field Confluence's own search box uses: it ranks
    --  by relevance and matches partial words by itself, where `text` matches
    --  whole words only and returns them in index order (which buried the page
    --  named after the query). It is absent from the CQL field reference at
    --  https://developer.atlassian.com/cloud/confluence/cql-fields/, so it is
    --  undocumented, not unsupported - verified against the site, but it could
    --  change without notice.
    local search_text = table.concat(terms_of(query), " ")
    local cql = search_text ~= "" and string.format('type=page AND siteSearch~"%s"', search_text)
      or "type=page ORDER BY lastmodified DESC"
    local url = string.format("%s/rest/api/search?cql=%s&limit=%d", CONFLUENCE_SERVER, urlencode(cql), LIMIT)
    run({ "curl", "-fsS", "-K", "-", url }, function(stdout)
      local ok, res = pcall(vim.json.decode, stdout)
      if not ok or type(res) ~= "table" or type(res.results) ~= "table" then return {} end
      local items = {}
      for _, result in ipairs(res.results) do
        local content = result.content or {}
        if content.id then
          table.insert(items, {
            -- NOTE: `result.title` can carry the search highlight markers, the
            --  content's own title never does.
            id = content.id,
            status = (result.resultGlobalContainer or {}).title or "",
            text = content.title or "",
            -- NOTE: `result.url` is relative to `_links.base`, which is the
            --  server plus the `/wiki` context path.
            url = CONFLUENCE_SERVER .. (result.url or ""),
          })
        end
      end
      return items
    end, on_items, config)
  end
end

-- How a notification subject is labelled once its state is known, and the color
-- the state gets. A read thread stays grey, so the color doubles as the
-- read/unread marker.
local SUBJECT_LABEL = { PullRequest = "PR", Issue = "Issue" }
local STATE_COLOR = { merged = "magenta", open = "green", closed = "red", draft = "grey" }

--- Look the state of every pull request and issue up in one GraphQL request and
--- fold it into the items' status column.
--- @param items table[] parsed notifications, annotated in place
--- @param on_items fun(items: table[])
local function with_states(items, on_items)
  local fields, targets = {}, {}
  for i, item in ipairs(items) do
    local owner, name, number = item.id:match "^(.-)/(.-)#(%d+)$"
    if owner and SUBJECT_LABEL[item.kind] then
      local alias = "n" .. i
      targets[alias] = item
      -- `issueOrPullRequest` covers both, `state` is OPEN|CLOSED|MERGED.
      table.insert(
        fields,
        string.format(
          '%s: repository(owner: "%s", name: "%s") '
            .. "{ issueOrPullRequest(number: %s) "
            .. "{ ... on PullRequest { state isDraft } ... on Issue { state } } }",
          alias,
          owner,
          name,
          number
        )
      )
    end
  end
  if #fields == 0 then return on_items(items) end
  local query = "query {" .. table.concat(fields, " ") .. "}"
  -- NOTE: deliberately not through `run`: a failing state lookup should still
  --  leave the notification list usable, only without the states.
  vim.system({ "gh", "api", "graphql", "-f", "query=" .. query }, { text = true }, function(res)
    vim.schedule(function()
      local ok, decoded = pcall(vim.json.decode, res.stdout)
      local data = ok and type(decoded) == "table" and decoded.data or nil
      for alias, item in pairs(targets) do
        local repo = type(data) == "table" and data[alias] or nil
        local node = type(repo) == "table" and repo.issueOrPullRequest or nil
        if type(node) == "table" and type(node.state) == "string" then
          item.state = node.isDraft == true and "draft" or node.state:lower()
          item.status = SUBJECT_LABEL[item.kind] .. " " .. item.state
        end
      end
      on_items(items)
    end)
  end)
end

--- Query the unread GitHub notifications, ignoring the search text.
local function notifications()
  return function(_, on_items)
    -- NOTE: this is the web UI's "Unread" tab, not its Inbox. The REST API has
    --  no notion of the Done state when listing (only `all`, `participating`,
    --  `since`, `before`), and a thread marked done is also marked read, so
    --  `all=true` returns Inbox + Done with nothing to tell them apart.
    --  See https://docs.github.com/en/rest/activity/notifications.
    local cmd = {
      "gh",
      "api",
      "--paginate",
      "/notifications",
      "--jq",
      ".[] | [.id, (.unread | tostring), .subject.type, .repository.full_name, .subject.title, .subject.url] | @tsv",
    }
    run(cmd, function(stdout)
      local items = {}
      for _, line in ipairs(vim.split(stdout, "\n", { trimempty = true })) do
        local fields = vim.split(line, "\t", { plain = true })
        if #fields == 6 then
          local thread, unread, kind, repo, title, api_url = unpack(fields)
          local number = api_url:match "/(%d+)$"
          -- NOTE: the API url differs from the web url only in the host and in
          --  `pulls` -> `pull` (checked against the `.html_url` of a PR).
          local url =
            api_url:gsub("^https://api%.github%.com/repos/", "https://github.com/"):gsub("/pulls/(%d+)$", "/pull/%1")
          table.insert(items, {
            id = number and (repo .. "#" .. number) or repo,
            kind = kind,
            status = kind, -- replaced by "<label> <state>" once known
            text = title,
            thread = thread,
            unread = unread == "true",
            url = url,
          })
        end
      end
      return items
    end, function(items) with_states(items, on_items) end)
  end
end

-- `statusCategory != Done` is exactly "neither Done nor Cancelled": those two are
-- the only Done-category statuses in SOF.
local MINE_OPEN = "assignee = currentUser() AND statusCategory != Done"
local NOT_ARCHIVED = "status != Archive"
local ANY = ""

local GH_PREVIEW = "gh repo view {1}"
local JIRA_PREVIEW = "jira issue view --plain {1}"
-- `{1}` is `owner/repo#<number>`. The REST issues endpoint serves both issues and
-- pull requests, so no per-subject-type dispatch is needed; other subject types
-- (commits, releases, ...) have no such endpoint and fall through to the message.
local GH_NOTIFY_PREVIEW =
  [[gh api "repos/$(echo {1} | sed 's|#|/issues/|')" --jq '.title, "", .body' 2>/dev/null || echo 'no preview for this subject']]

--- `{1}` is the page id, hidden from the display by `with_nth`.
--- NOTE: fzf substitutes a placeholder as a single-quoted word, so the url has to
---  close its double quotes around `{1}`: inside them the quotes would stay
---  literal and Confluence answers 404 for the malformed content id.
local function confluence_preview()
  local login = atlassian_login()
  if not login then return nil end
  -- `$JIRA_API_TOKEN` is expanded by the preview shell, not by us, so the token
  -- never lands in an argv.
  return string.format(
    [[printf 'user = "%s:%%s"\n' "$JIRA_API_TOKEN" | curl -fsS -K - ]]
      .. [["%s/rest/api/content/"{1}"?expand=body.view" ]]
      .. [[| jq -r '.body.view.value' | pandoc -f html -t plain --columns="${FZF_PREVIEW_COLUMNS:-80}"]],
    login,
    CONFLUENCE_SERVER
  )
end

--- Pickers. `preview` may be a function returning the command (or nil for none),
--- `no_input` skips the query prompt, `with_nth` hides leading display fields,
--- `color` picks the `ansi_codes` name for an item's status column and `web` is
--- the page the picker itself came from: a template with an optional `%s` for
--- the query, or a function turning the query into the url.
local sources = {
  G = { title = "GitHub " .. GITHUB_USER, preview = GH_PREVIEW, query = repos(GITHUB_USER) },
  g = { title = "GitHub " .. GITHUB_ORG, preview = GH_PREVIEW, query = repos(GITHUB_ORG) },
  j = {
    title = "Jira SOF (mine, open)",
    preview = JIRA_PREVIEW,
    query = issues("SOF", MINE_OPEN),
    web = issues_web("SOF", MINE_OPEN),
  },
  a = { title = "Jira SOF (all)", preview = JIRA_PREVIEW, query = issues("SOF", ANY), web = issues_web("SOF", ANY) },
  r = {
    title = "Jira REQ",
    preview = JIRA_PREVIEW,
    query = issues("REQ", NOT_ARCHIVED),
    web = issues_web("REQ", NOT_ARCHIVED),
  },
  t = {
    title = "Jira TP",
    preview = JIRA_PREVIEW,
    query = issues("TP", NOT_ARCHIVED),
    web = issues_web("TP", NOT_ARCHIVED),
  },
  f = {
    title = "Jira FMEA",
    preview = JIRA_PREVIEW,
    query = issues("FMEA", NOT_ARCHIVED),
    web = issues_web("FMEA", NOT_ARCHIVED),
  },
  c = {
    title = "Confluence",
    preview = confluence_preview,
    query = pages(),
    with_nth = "2..",
    web = CONFLUENCE_SEARCH,
  },
  n = {
    title = "GitHub notifications (unread)",
    preview = GH_NOTIFY_PREVIEW,
    query = notifications(),
    no_input = true,
    can_mark_done = true,
    web = GITHUB_NOTIFICATIONS,
    color = function(item)
      if not item.unread then return "grey" end
      return STATE_COLOR[item.state] or "yellow"
    end,
  },
}

--- Keymaps that only open a URL. A `%s` in `url` makes the keymap prompt for
--- text and substitute it percent-encoded.
local links = {
  o = { title = "Google", url = GOOGLE_SEARCH },
  N = { title = "Jira notifications", url = JIRA_NOTIFICATIONS },
}

--- Pad every entry into aligned `id [status] text` lines.
--- @param colorize fun(status: string, item: table): string
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
      table.insert(parts, colorize and colorize(status, item) or status)
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

--- Open a page in the browser. `url` is either a template whose `%s` receives
--- the percent-encoded `query`, or a function building the whole url from it.
local function open_url(url, query)
  if type(url) == "function" then
    vim.ui.open(url(query or ""))
    return
  end
  vim.ui.open(url:find "%%s" and url:format(urlencode(query or "")) or url)
end

--- Mark GitHub notification threads as done, removing them from the inbox.
--- @param items table[] notifications to dismiss
--- @param on_failure fun(item: table) called when GitHub refused the delete
local function mark_done(items, on_failure)
  for _, item in ipairs(items) do
    if item.thread then
      vim.system(
        { "gh", "api", "--method", "DELETE", "/notifications/threads/" .. item.thread },
        { text = true },
        function(res)
          vim.schedule(function()
            if res.code ~= 0 then
              vim.notify(
                string.format("Could not mark %s done: %s", item.id, vim.trim(strip_ansi(res.stderr))),
                vim.log.levels.ERROR
              )
              on_failure(item)
            else
              vim.notify("Marked notification done: " .. item.id)
            end
          end)
        end
      )
    end
  end
end

local function show_fzf(fzf, source, query, items)
  local ansi = require("fzf-lua.utils").ansi_codes
  local state = { query = query, by_line = {}, dismissed = {} }

  -- Re-fed by fzf on every `reload` action, which is what keeps the window open
  -- on a re-query instead of tearing the picker down and opening a new one.
  local contents = function(fzf_cb)
    local feed = function(list)
      -- Dropped here rather than waiting for GitHub: a thread marked done is
      -- still listed for a moment, so the reload would bring it back.
      local visible = {}
      for _, item in ipairs(list) do
        if not (item.thread and state.dismissed[item.thread]) then table.insert(visible, item) end
      end
      local lines, by_line = format(
        visible,
        function(status, item) return ansi[source.color and source.color(item) or "yellow"](status) end
      )
      state.by_line = by_line
      for _, line in ipairs(lines) do
        fzf_cb(line)
      end
      fzf_cb() -- closes the pipe, fzf considers the list complete
    end
    if items then
      -- The first run reuses what `search` already fetched.
      local first = items
      items = nil
      feed(first)
    else
      source.query(state.query, feed)
    end
  end

  local header = ":: <ctrl-y> to Yank URL | <alt-r> to Re-query"
  local actions = {
    ["default"] = function(selected) open(state.by_line[selected[1]]) end,
    ["ctrl-y"] = function(selected)
      local item = state.by_line[selected[1]]
      if not item then return end
      vim.fn.setreg("+", item.url)
      vim.notify("Copied URL to clipboard: " .. item.url)
    end,
    -- NOTE: a `reload` action with `field_index = "{q}"` hands the typed query to
    --  `fn` as `selected[1]` and then re-runs `contents` in place.
    --  Not `ctrl-r`: `winopts.on_create` in `plugins/fzf.lua` maps it in terminal
    --  mode, so nvim swallows it before fzf ever sees it.
    ["alt-r"] = {
      fn = function(selected) state.query = selected[1] or "" end,
      field_index = "{q}",
      reload = true,
    },
  }
  if source.web then
    header = header .. " | <alt-o> to Open the web page"
    -- `state.query` is the text the listed results were fetched with, not what
    -- is currently typed in the prompt: fzf's own input only filters locally
    -- and is usually empty, `<alt-r>` is what turns it into a new search.
    actions["alt-o"] = function() open_url(source.web, state.query) end
  end
  if source.can_mark_done then
    header = header .. " | <ctrl-x> to mark Done"
    -- NOTE: `reload` is what keeps the picker alive here. `noclose` alone leaves
    --  the window up but fzf has already exited, so it turns into a dead
    --  terminal showing "[Process exited 0]".
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
        mark_done(marked, function(item) state.dismissed[item.thread] = nil end)
      end,
      reload = true,
    }
  end
  fzf.fzf_exec(contents, {
    prompt = "> ",
    fzf_opts = {
      ["--ansi"] = true,
      ["--header"] = header,
      ["--preview"] = type(source.preview) == "function" and source.preview() or source.preview,
      ["--with-nth"] = source.with_nth,
    },
    winopts = { title = " " .. source.title .. " ", title_pos = "center" },
    actions = actions,
  })
end

local function show_builtin(source, items)
  local lines, by_line = format(items, nil)
  vim.ui.select(lines, { prompt = source.title .. ">" }, function(selected) open(by_line[selected]) end)
end

--- @param key string key into `sources`
local function search(key)
  local source = sources[key]
  local go = function(text)
    local query = vim.trim(text)
    source.query(query, function(items)
      if #items == 0 then
        vim.notify("No results for " .. source.title, vim.log.levels.WARN)
        return
      end
      local ok, fzf = pcall(require, "fzf-lua")
      if ok then
        show_fzf(fzf, source, query, items)
      else
        show_builtin(source, items)
      end
    end)
  end
  if source.no_input then
    go ""
  else
    vim.ui.input({ prompt = source.title .. ": " }, function(input)
      if input == nil then return end -- Cancelled
      go(input)
    end)
  end
end

--- @param link table entry of `links`
local function open_link(link)
  if not link.url:find "%%s" then
    open_url(link.url)
    return
  end
  vim.ui.input({ prompt = link.title .. ": " }, function(query)
    if query == nil or vim.trim(query) == "" then return end
    open_url(link.url, vim.trim(query))
  end)
end

for key, source in pairs(sources) do
  vim.keymap.set("n", PREFIX .. key, function() search(key) end, { desc = "Search " .. source.title })
end

for key, link in pairs(links) do
  vim.keymap.set("n", PREFIX .. key, function() open_link(link) end, { desc = "Open " .. link.title })
end
