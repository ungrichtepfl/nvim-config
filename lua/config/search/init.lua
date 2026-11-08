local atlassian = require "config.search.atlassian"
local github = require "config.search.github"
local search_picker = require "config.search.picker"
local rhymes = require "config.search.rhymes"
local util = require "config.search.util"
local web = require "config.search.web"

local KEYMAP_PREFIX = "<leader>j"
local GITHUB_USER = "ungrichtepfl"
local GITHUB_ORG = "Scewo"

--- @type table<string, Picker>
local pickers = {
  G = { title = "GitHub " .. GITHUB_USER, preview = github.REPO_PREVIEW, query = github.repos(GITHUB_USER) },
  g = { title = "GitHub " .. GITHUB_ORG, preview = github.REPO_PREVIEW, query = github.repos(GITHUB_ORG) },
  j = {
    title = "Jira SOF (mine, open)",
    preview = atlassian.JIRA_PREVIEW,
    query = atlassian.jira_issues("SOF", atlassian.MINE_OPEN),
    web = atlassian.jira_issues_url("SOF", atlassian.MINE_OPEN),
  },
  a = {
    title = "Jira SOF (all)",
    preview = atlassian.JIRA_PREVIEW,
    query = atlassian.jira_issues("SOF", atlassian.NO_FILTER),
    web = atlassian.jira_issues_url("SOF", atlassian.NO_FILTER),
  },
  r = {
    title = "Jira REQ",
    preview = atlassian.JIRA_PREVIEW,
    query = atlassian.jira_issues("REQ", atlassian.NOT_ARCHIVED),
    web = atlassian.jira_issues_url("REQ", atlassian.NOT_ARCHIVED),
  },
  t = {
    title = "Jira TP",
    preview = atlassian.JIRA_PREVIEW,
    query = atlassian.jira_issues("TP", atlassian.NOT_ARCHIVED),
    web = atlassian.jira_issues_url("TP", atlassian.NOT_ARCHIVED),
  },
  f = {
    title = "Jira FMEA",
    preview = atlassian.JIRA_PREVIEW,
    query = atlassian.jira_issues("FMEA", atlassian.NOT_ARCHIVED),
    web = atlassian.jira_issues_url("FMEA", atlassian.NOT_ARCHIVED),
  },
  c = {
    title = "Confluence",
    preview = atlassian.confluence_preview_cmd,
    query = atlassian.confluence_pages,
    with_nth = "2..",
    web = atlassian.CONFLUENCE_SEARCH_URL,
  },
  w = {
    title = "Web search",
    picker_title = "Web search (DuckDuckGo)",
    preview = web.preview_cmd,
    query = web.duckduckgo_results,
    with_nth = "2..",
    web = web.DUCKDUCKGO_SEARCH_URL,
    google_search = web.GOOGLE_SEARCH_URL,
  },
  R = {
    title = "Reime",
    picker_title = "Reime (reimemaschine.de)",
    query = rhymes.query,
    web = rhymes.SEARCH_URL,
    yank_id = true,
    color = rhymes.color,
  },
  p = {
    title = "GitHub PRs (mine, open)",
    preview = github.ISSUE_PREVIEW,
    query = github.my_open_pull_requests,
    octo = true,
    no_input = true,
    web = github.my_open_pull_requests_url,
    color = github.state_color,
  },
  n = {
    title = "GitHub notifications (inbox)",
    preview = github.ISSUE_PREVIEW,
    query = github.notifications,
    octo = true,
    no_input = true,
    mark_done = github.mark_threads_done,
    web = github.NOTIFICATIONS_URL,
    color = github.state_color,
  },
}

-- Keymaps that only open a URL, a `%s` in it prompts for the query
local links = {
  N = { title = "Jira notifications", url = atlassian.JIRA_NOTIFICATIONS_URL },
}

local function open_link(link)
  if not link.url:find "%%s" then
    util.open_url(link.url)
    return
  end
  vim.ui.input({ prompt = link.title .. ": " }, function(query)
    if query == nil or vim.trim(query) == "" then return end
    util.open_url(link.url, vim.trim(query))
  end)
end

for key, picker in pairs(pickers) do
  vim.keymap.set(
    "n",
    KEYMAP_PREFIX .. key,
    function() search_picker.open(picker) end,
    { desc = "Search " .. picker.title }
  )
end

for key, link in pairs(links) do
  vim.keymap.set("n", KEYMAP_PREFIX .. key, function() open_link(link) end, { desc = "Open " .. link.title })
end
