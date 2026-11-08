local util = require "config.search.util"

local M = {}

M.NOTIFICATIONS_URL = "https://github.com/notifications"
-- Search URL copied from the browser
local PR_SEARCH_URL = "https://github.com/search?q=%s&type=pullrequests"

-- How a notification subject is labelled once its state is known, and the color
-- the state gets.
local SUBJECT_LABEL = { PullRequest = "PR", Issue = "Issue" }
local STATE_COLOR = { merged = "magenta", open = "green", closed = "red", draft = "grey" }

-- Read threads are not grey: almost all inbox threads are read
function M.state_color(item) return STATE_COLOR[item.state] or "yellow" end

M.REPO_PREVIEW = util.pipe_through_renderer("gh repo view {1}", util.MARKDOWN_RENDERERS)
-- `{1}` is `owner/repo#<number>`, the issues endpoint also serves pull requests
M.ISSUE_PREVIEW = util.pipe_through_renderer(
  [[gh api "repos/$(echo {1} | sed 's|#|/issues/|')" --jq '.title, "", .body' 2>/dev/null ]]
    .. [[|| echo 'no preview for this subject']],
  util.MARKDOWN_RENDERERS
)

function M.repos(owner)
  return function(query, on_items)
    local cmd = {
      "gh",
      "search",
      "repos",
      "--owner",
      owner,
      "--limit",
      tostring(util.RESULT_LIMIT),
      "--sort",
      "updated",
      "--json",
      "fullName,description,url",
    }
    if query ~= "" then table.insert(cmd, query) end
    util.run_and_parse(cmd, function(stdout)
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

local function notification_status(item)
  local label = item.state and (SUBJECT_LABEL[item.kind] .. " " .. item.state) or item.kind
  return (item.unread and "* " or "") .. label
end

-- GitHub's API cannot tell Inbox and Done threads apart
-- (https://github.com/orgs/community/discussions/50224), so threads marked done here are
-- stored with their `updated_at`. New activity changes `updated_at` and the thread shows up again.
local DONE_THREADS_FILE = vim.fn.stdpath "state" .. "/github-notifications-done.json"

local done_cache

--- @return table<string, string> thread id -> the `updated_at` it was done at
local function read_done_threads()
  if not done_cache then
    done_cache = {}
    local ok, lines = pcall(vim.fn.readfile, DONE_THREADS_FILE)
    if ok then
      local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
      if decoded_ok and type(decoded) == "table" then done_cache = decoded end
    end
  end
  return done_cache
end

local function write_done_threads(done)
  done_cache = done
  local ok, err = pcall(vim.fn.writefile, { vim.json.encode(done) }, DONE_THREADS_FILE)
  if not ok then vim.notify("Could not write " .. DONE_THREADS_FILE .. ": " .. tostring(err), vim.log.levels.ERROR) end
end

local function remember_done(thread, updated)
  local done = read_done_threads()
  if done[thread] == updated then return end
  done[thread] = updated
  write_done_threads(done)
end

local function is_done(item) return not item.unread and read_done_threads()[item.thread] == item.updated end

local function add_pr_and_issue_states(items, on_items)
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
  -- Not through `run_and_parse`: if this fails, the list still shows, just without states
  vim.system({ "gh", "api", "graphql", "-f", "query=" .. query }, { text = true }, function(res)
    vim.schedule(function()
      local ok, decoded = pcall(vim.json.decode, res.stdout)
      local data = ok and type(decoded) == "table" and decoded.data or nil
      for alias, item in pairs(targets) do
        local repo = type(data) == "table" and data[alias] or nil
        local node = type(repo) == "table" and repo.issueOrPullRequest or nil
        if type(node) == "table" and type(node.state) == "string" then
          item.state = node.isDraft == true and "draft" or node.state:lower()
          item.status = notification_status(item)
        end
      end
      on_items(items)
    end)
  end)
end

function M.notifications(_, on_items)
  -- `all=true` is every thread GitHub still keeps, read ones included.
  local cmd = {
    "gh",
    "api",
    "--paginate",
    "/notifications?all=true",
    "--jq",
    ".[] | [.id, (.unread | tostring), .updated_at, .subject.type, "
      .. ".repository.full_name, .subject.title, .subject.url] | @tsv",
  }
  util.run_and_parse(cmd, function(stdout)
    local items, seen = {}, {}
    for _, line in ipairs(vim.split(stdout, "\n", { trimempty = true })) do
      local fields = vim.split(line, "\t", { plain = true })
      if #fields == 7 then
        local thread, unread, updated, kind, repo, title, api_url = unpack(fields)
        seen[thread] = true
        local number = api_url:match "/(%d+)$"
        -- API url -> web url
        local url =
          api_url:gsub("^https://api%.github%.com/repos/", "https://github.com/"):gsub("/pulls/(%d+)$", "/pull/%1")
        local item = {
          id = number and (repo .. "#" .. number) or repo,
          repo = repo,
          number = number,
          kind = kind,
          text = title,
          thread = thread,
          unread = unread == "true",
          updated = updated,
          url = url,
        }
        item.status = notification_status(item) -- the state is folded in later
        if not is_done(item) then table.insert(items, item) end
      end
    end
    -- Forget done threads GitHub no longer lists. Only after a successful fetch,
    -- otherwise all done threads would show up again.
    if next(seen) then
      local pruned, changed = {}, false
      for thread, updated in pairs(read_done_threads()) do
        if seen[thread] then
          pruned[thread] = updated
        else
          changed = true
        end
      end
      if changed then write_done_threads(pruned) end
    end
    return items
  end, function(items) add_pr_and_issue_states(items, on_items) end)
end

function M.mark_threads_done(items, on_failure)
  for _, item in ipairs(items) do
    if item.thread then
      vim.system(
        { "gh", "api", "--method", "DELETE", "/notifications/threads/" .. item.thread },
        { text = true },
        function(res)
          vim.schedule(function()
            if res.code ~= 0 then
              vim.notify(
                string.format("Could not mark %s done: %s", item.id, vim.trim(util.strip_ansi(res.stderr))),
                vim.log.levels.ERROR
              )
              on_failure(item)
            else
              remember_done(item.thread, item.updated)
              vim.notify("Marked notification done: " .. item.id)
            end
          end)
        end
      )
    end
  end
end

function M.my_open_pull_requests(query, on_items)
  local cmd = {
    "gh",
    "search",
    "prs",
    "--author",
    "@me",
    "--state",
    "open",
    "--limit",
    tostring(util.RESULT_LIMIT),
    "--sort",
    "updated",
    "--json",
    "repository,number,title,url,isDraft",
  }
  if query ~= "" then table.insert(cmd, query) end
  util.run_and_parse(cmd, function(stdout)
    local ok, found = pcall(vim.json.decode, stdout)
    if not ok or type(found) ~= "table" then return {} end
    local items = {}
    for _, pr in ipairs(found) do
      local repo = (pr.repository or {}).nameWithOwner
      if repo and pr.number then
        local state = pr.isDraft and "draft" or "open"
        table.insert(items, {
          -- `owner/repo#number`, the id format the GitHub previews read
          id = repo .. "#" .. pr.number,
          repo = repo,
          number = tostring(pr.number),
          kind = "PullRequest",
          state = state,
          status = SUBJECT_LABEL.PullRequest .. " " .. state,
          text = pr.title or "",
          url = pr.url,
        })
      end
    end
    return items
  end, on_items)
end

-- Same filter as `my_open_pull_requests`, in GitHub's web search syntax
function M.my_open_pull_requests_url(query)
  return PR_SEARCH_URL:format(util.urlencode(vim.trim("is:pr is:open author:@me " .. query)))
end

-- Subject types octo can preview, with octo's names
local OCTO_KIND = { Issue = "issue", PullRequest = "pull_request", Discussion = "discussion", Release = "release" }

function M.octo_previewer_entry(item)
  local kind = OCTO_KIND[item.kind]
  if not (kind and item.repo and item.number) then return nil end
  return { value = item.number, repo = item.repo, kind = kind, ordinal = item.id }
end

-- The previewer keeps `entries`, so update that table in place
function M.octo_previewer(entries)
  -- Loads octo and its setup, which the previewer needs
  if not pcall(require, "octo") then return nil end
  local ok, previewers = pcall(require, "octo.pickers.fzf-lua.previewers")
  if not ok then return nil end

  -- A new class per call, so patching it is safe. It does not check for missing entries.
  local previewer = previewers.notifications(entries, {})
  local populate = previewer.populate_preview_buf
  function previewer:populate_preview_buf(entry_str)
    if entries[entry_str] then return populate(self, entry_str) end
    local buf = self:get_tmp_buffer()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "no preview for this subject" })
    self:set_preview_buf(buf)
    self:update_border(entry_str)
  end
  return previewer
end

return M
