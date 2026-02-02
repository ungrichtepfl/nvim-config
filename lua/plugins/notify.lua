return {
  "rcarriga/nvim-notify",
  dependencies = { "ibhagwan/fzf-lua" },
  opts = {
    level = vim.log.levels.DEBUG,
    stages = "fade",
    timeout = 5000,
    max_width = function() return math.floor(vim.api.nvim_win_get_width(0) / 2) end,
    render = "wrapped-compact",
  },
  enabled = function() return vim.env.COLORTERM == "truecolor" or vim.env.TERM == "xterm-truecolor" end,
  keys = {
    {
      "<leader>n",
      function()
        local notify = require "notify"
        local history = notify.history()
        if #history == 0 then
          vim.notify("No notifications", vim.log.levels.INFO)
          return
        end

        -- Build reverse lookup: level number -> level name
        local level_names = {}
        for name, num in pairs(vim.log.levels) do
          level_names[num] = name
        end

        -- ANSI colors for each level
        local level_colors = {
          TRACE = "\27[90m", -- gray
          DEBUG = "\27[36m", -- cyan
          INFO = "\27[32m", -- green
          WARN = "\27[33m", -- yellow
          ERROR = "\27[31m", -- red
          OFF = "\27[90m", -- gray
        }
        local reset = "\27[0m"
        local dim = "\27[90m"

        local entries = {}
        local notifications = {}
        for i = #history, 1, -1 do
          local n = history[i]
          local level = level_names[n.level] or tostring(n.level)
          local color = level_colors[level] or ""
          local time = os.date("%H:%M:%S", n.time)
          local message = table.concat(n.message, " "):gsub("\n", " ")
          local icon = ({ TRACE = "󰠠", DEBUG = "", INFO = "", WARN = "", ERROR = "" })[level] or "󰎟"
          -- prefix each entry with a numeric id and a tab so we can reliably
          -- find the notification when fzf returns the selected line
          local id = #entries + 1
          local display = string.format("%s%s%s %s%s %-5s%s %s", dim, time, reset, color, icon, level, reset, message)
          table.insert(entries, string.format("%04d\t%s", id, display))
          table.insert(notifications, n)
        end

        require("fzf-lua").fzf_exec(entries, {
          prompt = " Notifications❯ ",
          fzf_opts = { ["--ansi"] = true },
          -- show a preview in the builtin previewer by returning a string
          preview = function(selected)
            if not selected or #selected == 0 then return "" end
            local sel = selected[1]
            local id = sel:match "^(%d+)"
            if not id then return "" end
            local idx = tonumber(id)
            if not idx or idx < 1 or idx > #notifications then return "" end
            local n = notifications[idx]
            local level = level_names[n.level] or tostring(n.level)
            local time = os.date("%Y-%m-%d %H:%M:%S", n.time)
            local lines = { "Time:  " .. time, "Level: " .. level, "", "Message:", string.rep("─", 40) }
            for _, line in ipairs(n.message) do
              table.insert(lines, line)
            end
            return table.concat(lines, "\n")
          end,
          actions = {
            ["enter"] = function(selected)
              if not selected or #selected == 0 then return end
              -- selected contains the raw line returned by fzf, parse the id we
              -- prefixed earlier ("0001\t...") so we can index into
              -- notifications reliably even if the display contains ANSI codes
              local sel = selected[1]
              local id = sel:match "^(%d+)"
              if not id then return end
              local idx = tonumber(id)
              if not idx or idx < 1 or idx > #notifications then return end

              local n = notifications[idx]
              local level = level_names[n.level] or tostring(n.level)
              local time = os.date("%Y-%m-%d %H:%M:%S", n.time)

              vim.schedule(function()
                local buf = vim.api.nvim_create_buf(false, true)
                local lines = {
                  "Time:  " .. time,
                  "Level: " .. level,
                  "",
                  "Message:",
                  string.rep("─", 40),
                }
                for _, line in ipairs(n.message) do
                  table.insert(lines, line)
                end
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                vim.bo[buf].modifiable = false
                vim.bo[buf].buftype = "nofile"
                vim.bo[buf].bufhidden = "wipe"
                vim.api.nvim_set_current_buf(buf)
                vim.keymap.set("n", "q", "<cmd>bdelete<cr>", { buffer = buf, silent = true })
              end)
            end,
          },
        })
      end,
      desc = "Show notifications",
    },
  },
  config = function(_, opts)
    local notify = require "notify"
    notify.setup(opts)
    vim.o.termguicolors = true
    vim.notify = notify
  end,
}
