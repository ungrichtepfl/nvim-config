local util = require "config.search.util"

local M = {}

-- No API, the result page is parsed
local RHYME_SERVER = "https://www.reimemaschine.de/"
M.SEARCH_URL = RHYME_SERVER .. "reim_suchen.php?search=%s&language=de"

local SECTION_COLOR = { rated = "green", suggested = "yellow", ending = "grey" }

function M.color(item) return SECTION_COLOR[item.kind] end

--- @return { kind: string, label: string }? nil for the words rated as not rhyming
local function rhyme_section(heading)
  if heading:find("NICHT", 1, true) then return nil end
  if heading:find("bewertet:", 1, true) then return { kind = "rated", label = "bewertet" } end
  if heading:find("vorgeschlagen", 1, true) then return { kind = "suggested", label = "vorgeschlagen" } end
  local ending = heading:match 'auf "([^"]+)" enden'
  if ending then return { kind = "ending", label = "-" .. ending } end
  return nil
end

function M.query(query, on_items)
  if query == "" then
    on_items {}
    return
  end
  -- Never request the vote links on the page, a GET on them changes the site's data
  util.run_and_parse({ "curl", "-fsS", M.SEARCH_URL:format(util.urlencode(query)) }, function(stdout)
    local items, seen = {}, { [vim.fn.tolower(query)] = true }
    -- Everything before the first heading is navigation, not results.
    local chunks = vim.split(stdout, "<h3>", { plain = true })
    for i = 2, #chunks do
      local section = rhyme_section(chunks[i]:match "^[^<]*")
      if section then
        for href, word in chunks[i]:gmatch '<a href="([^"]+)" title="Was reimt sich auf ([^"]+)"' do
          -- The site lists a word once per spelling, e.g. "Wonne" and "wonne".
          local key = vim.fn.tolower(word)
          if not seen[key] then
            seen[key] = true
            table.insert(items, {
              id = word,
              kind = section.kind,
              status = section.label,
              text = "",
              url = RHYME_SERVER .. href,
            })
          end
        end
      end
    end
    return items
  end, on_items)
end

return M
