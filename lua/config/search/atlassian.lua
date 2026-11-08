local util = require "config.search.util"

local M = {}

local JIRA_SERVER = "https://scewosw.atlassian.net"
local CONFLUENCE_SERVER = JIRA_SERVER .. "/wiki"
-- No API for the notifications, URL copied from the browser
M.JIRA_NOTIFICATIONS_URL =
  "https://home.atlassian.com/o/340bf104-3ba2-4426-adda-528ed9bc1728/notifications?cloudId=6f8cc0c8-4809-40a4-8303-db00047cf75d"
-- Search URLs copied from the browser
M.CONFLUENCE_SEARCH_URL = CONFLUENCE_SERVER .. "/search?text=%s&product=confluence"
local JIRA_SEARCH_URL = JIRA_SERVER .. "/issues?jql=%s"

M.MINE_OPEN = "assignee = currentUser() AND statusCategory != Done"
M.NOT_ARCHIVED = "status != Archive"
M.NO_FILTER = ""

-- jira-cli pads tab-separated columns with extra tabs, so use the ASCII unit separator
local JIRA_COLUMN_SEP = "\31"

-- Lucene special characters, replaced by spaces so that e.g. "UT-053" does not break the query
local LUCENE_SPECIAL = '[+%-&|!(){}%[%]^"~*?:\\/]'

local function lucene_terms(query)
  local terms = {}
  for word in query:gsub(LUCENE_SPECIAL, " "):gmatch "%S+" do
    table.insert(terms, word)
  end
  return terms
end

-- `~` only matches whole words, so "tool" becomes "tool*"
local function to_prefix_query(terms) return #terms > 0 and (table.concat(terms, "* ") .. "*") or "" end

-- Same login as jira-cli. The token goes to curl on stdin (`-K -`), so it is not in the argv
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

function M.jira_issues(project, jql)
  return function(query, on_items)
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
      "0:" .. util.RESULT_LIMIT,
      "--plain",
      "--no-headers",
      "--columns",
      "KEY,STATUS,SUMMARY",
      "--delimiter",
      JIRA_COLUMN_SEP,
    }
    local search_text = to_prefix_query(lucene_terms(query))
    if search_text ~= "" then table.insert(cmd, search_text) end
    util.run_and_parse(cmd, function(stdout)
      local items = {}
      for _, line in ipairs(vim.split(stdout, "\n", { trimempty = true })) do
        local fields = vim.split(line, JIRA_COLUMN_SEP, { plain = true })
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

function M.jira_issues_url(project, jql)
  return function(query)
    local clauses = { string.format('project = "%s"', project) }
    if jql ~= "" then table.insert(clauses, jql) end
    local search_text = to_prefix_query(lucene_terms(query))
    if search_text ~= "" then table.insert(clauses, string.format('text ~ "%s"', search_text)) end
    return JIRA_SEARCH_URL:format(util.urlencode(table.concat(clauses, " AND ")))
  end
end

function M.confluence_pages(query, on_items)
  local config = atlassian_curl_config()
  if not config then
    on_items({}, true)
    return
  end
  -- `siteSearch` (undocumented) is what Confluence's search box uses: unlike `text`
  -- it sorts by relevance and matches parts of words
  local search_text = table.concat(lucene_terms(query), " ")
  local cql = search_text ~= "" and string.format('type=page AND siteSearch~"%s"', search_text)
    or "type=page ORDER BY lastmodified DESC"
  local url =
    string.format("%s/rest/api/search?cql=%s&limit=%d", CONFLUENCE_SERVER, util.urlencode(cql), util.RESULT_LIMIT)
  util.run_and_parse({ "curl", "-fsS", "-K", "-", url }, function(stdout)
    local ok, res = pcall(vim.json.decode, stdout)
    if not ok or type(res) ~= "table" or type(res.results) ~= "table" then return {} end
    local items = {}
    for _, result in ipairs(res.results) do
      local content = result.content or {}
      if content.id then
        table.insert(items, {
          -- `result.title` can contain highlight markers
          id = content.id,
          status = (result.resultGlobalContainer or {}).title or "",
          text = content.title or "",
          -- `result.url` is relative to `/wiki`
          url = CONFLUENCE_SERVER .. (result.url or ""),
        })
      end
    end
    return items
  end, on_items, config)
end

-- Remove jira-cli's indent and trailing spaces, otherwise bat does not see markdown
M.JIRA_PREVIEW = util.pipe_through_renderer(
  [==[jira issue view --plain {1} | sed -e 's/[[:space:]]*$//' -e 's/^  //']==],
  util.FIXED_WIDTH_RENDERERS
)

-- fzf inserts `{1}` single-quoted, so it must stay outside the double quotes
function M.confluence_preview_cmd()
  local login = atlassian_login()
  -- The body is HTML, unreadable without pandoc
  if not login or vim.fn.executable "pandoc" == 0 or vim.fn.executable "jq" == 0 then return nil end
  -- The preview shell expands `$JIRA_API_TOKEN`, so the token is not in an argv
  return util.pipe_through_renderer(
    string.format(
      [[printf 'user = "%s:%%s"\n' "$JIRA_API_TOKEN" | curl -fsS -K - ]]
        .. [["%s/rest/api/content/"{1}"?expand=body.view" ]]
        .. [[| jq -r '.body.view.value' ]]
        .. string.format([[| pandoc -f html -t %s --columns="${FZF_PREVIEW_COLUMNS:-80}"]], util.PANDOC_MARKDOWN_FORMAT),
      login,
      CONFLUENCE_SERVER
    ),
    util.FIXED_WIDTH_RENDERERS
  )
end

return M
