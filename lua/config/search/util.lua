local M = {}

M.RESULT_LIMIT = 100

-- Plain markdown without the divs and spans of Confluence macros, grid tables for multi-line cells
M.PANDOC_MARKDOWN_FORMAT = "markdown-raw_html-fenced_divs-bracketed_spans-native_divs-native_spans"
  .. "-header_attributes-link_attributes-inline_code_attributes-simple_tables-multiline_tables"

function M.strip_ansi(s) return (s:gsub("\27%[[%d;]*m", "")) end

function M.urlencode(s)
  return (s:gsub("[^%w%-%.%_%~]", function(c) return string.format("%%%02X", string.byte(c)) end))
end

--- @param url string|fun(query: string): string template with `%s` for the query, or a function returning the url
function M.open_url(url, query)
  if type(url) == "function" then
    vim.ui.open(url(query or ""))
    return
  end
  vim.ui.open(url:find "%%s" and url:format(M.urlencode(query or "")) or url)
end

--- @param cmd string[]
--- @param parse fun(stdout: string): table[]
--- @param on_items fun(items: table[], explained?: boolean) `explained`: the user
---  was already told why the list is empty
--- @param stdin string? written to the process' stdin, which is then closed
function M.run_and_parse(cmd, parse, on_items, stdin)
  -- Always call `on_items`, the caller waits for it
  if vim.fn.executable(cmd[1]) == 0 then
    vim.notify(cmd[1] .. " is not installed", vim.log.levels.ERROR)
    on_items({}, true)
    return
  end
  vim.system(cmd, { text = true, stdin = stdin }, function(res)
    vim.schedule(function()
      local items = parse(res.stdout)
      -- jira-cli also exits 1 when nothing is found
      if #items == 0 and res.code ~= 0 and not res.stderr:find("No result found", 1, true) then
        vim.notify(string.format("%s failed: %s", cmd[1], vim.trim(M.strip_ansi(res.stderr))), vim.log.levels.ERROR)
        on_items({}, true)
        return
      end
      on_items(items)
    end)
  end)
end

-- The preview pane is not a tty, so colors must be forced
local RENDERERS = {
  -- `--ansi`: no image drawing in the pane, `--local`: no image downloads
  mdcat = [[mdcat --ansi --local --columns "${FZF_PREVIEW_COLUMNS:-80}" -]],
  glow = [[glow - -s dark -w "${FZF_PREVIEW_COLUMNS:-80}"]],
  bat = [[bat --color=always --style=plain --paging=never --language md ]]
    .. [[--terminal-width "${FZF_PREVIEW_COLUMNS:-80}"]],
}

-- mdcat looks best in a narrow pane. mdcat and glow rewrap text, which breaks
-- fixed-width output (jira-cli, pandoc grid tables), so that uses bat.
M.MARKDOWN_RENDERERS = { "mdcat", "glow", "bat" }
M.FIXED_WIDTH_RENDERERS = { "bat" }

-- The parentheses matter, `a || b | bat` would pipe only `b`
function M.pipe_through_renderer(cmd, preferred)
  for _, name in ipairs(preferred) do
    if vim.fn.executable(name) == 1 then return "( " .. cmd .. " ) | " .. RENDERERS[name] end
  end
  return cmd
end

return M
