local util = require "config.search.util"

local M = {}

M.GOOGLE_SEARCH_URL = "https://www.google.com/search?q=%s"
M.DUCKDUCKGO_SEARCH_URL = "https://duckduckgo.com/?q=%s"
local DDGR_MAX_RESULTS = 25

-- DuckDuckGo (ddgr) because Google's search API is closed to new users
function M.duckduckgo_results(query, on_items)
  if query == "" then
    on_items {}
    return
  end
  if vim.fn.executable "ddgr" == 0 then
    util.open_url(M.GOOGLE_SEARCH_URL, query)
    on_items({}, true)
    return
  end
  -- `--json` also stops ddgr from waiting for input
  util.run_and_parse({ "ddgr", "--json", "--num", tostring(DDGR_MAX_RESULTS), query }, function(stdout)
    local ok, found = pcall(vim.json.decode, stdout)
    if not ok or type(found) ~= "table" then return {} end
    local items = {}
    for _, result in ipairs(found) do
      if result.url then
        table.insert(items, {
          id = result.url,
          status = result.url:match "^%a+://([^/]+)" or "",
          text = result.title or "",
          url = result.url,
        })
      end
    end
    return items
  end, on_items)
end

function M.preview_cmd()
  -- Do not let a slow site block the preview
  local timeout_prefix = vim.fn.executable "timeout" == 1 and "timeout 10 " or ""
  -- w3m renders whole pages better than pandoc
  if vim.fn.executable "w3m" == 1 then return timeout_prefix .. [[w3m -dump -cols "${FZF_PREVIEW_COLUMNS:-80}" {1}]] end
  if vim.fn.executable "curl" == 1 and vim.fn.executable "pandoc" == 1 then
    return util.pipe_through_renderer(
      string.format(
        [[%scurl -fsSL {1} | pandoc -f html -t %s --columns="${FZF_PREVIEW_COLUMNS:-80}"]],
        timeout_prefix,
        util.PANDOC_MARKDOWN_FORMAT
      ),
      util.FIXED_WIDTH_RENDERERS
    )
  end
  return nil
end

return M
