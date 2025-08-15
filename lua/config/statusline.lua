local default_statusline_autogroup = vim.api.nvim_create_augroup("_default_statusline", { clear = true })

-- Git branch function
local function git_branch()
  local branch = vim.fn.system "git branch --show-current 2>/dev/null | tr -d '\n'"
  if branch ~= "" then return "  " .. branch .. " " end
  return ""
end

-- File type with icon
local function file_type()
  local ft = vim.bo.filetype
  local icons = {
    lua = "[LUA]",
    python = "[PY]",
    javascript = "[JS]",
    html = "[HTML]",
    css = "[CSS]",
    json = "[JSON]",
    markdown = "[MD]",
    vim = "[VIM]",
    sh = "[SH]",
  }

  if ft == "" then return "  " end

  return (icons[ft] or ft)
end

-- File size
local function file_size()
  local size = vim.fn.getfsize(vim.fn.expand "%")
  if size < 0 then return "" end
  if size < 1024 then
    return size .. "B "
  elseif size < 1024 * 1024 then
    return string.format("%.1fK", size / 1024)
  else
    return string.format("%.1fM", size / 1024 / 1024)
  end
end

-- Mode indicators with icons
local function mode_icon()
  local mode = vim.fn.mode()
  local modes = {
    n = "NORMAL",
    no = "N-PENDING",
    v = "VISUAL",
    V = "V-LINE",
    [""] = "V-BLOCK",
    s = "SELECT",
    S = "S-LINE",
    [""] = "S-BLOCK",
    i = "INSERT",
    ic = "INSERT",
    R = "REPLACE",
    Rv = "V-REPLACE",
    c = "COMMAND",
    cv = "EX",
    ce = "NORMAL",
    r = "PROMPT",
    rm = "MORE",
    ["r?"] = "CONFIRM",
    ["!"] = "SHELL",
    t = "TERMINAL",
  }
  return modes[mode] or ("  " .. mode:upper())
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size

vim.cmd [[
  highlight StatusLineBold gui=bold cterm=bold
]]

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
  vim.o.showmode = false
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = default_statusline_autogroup,
    callback = function()
      -- TODO: Change to vim.bo in the future
      vim.wo[0][0].statusline = table.concat {
        "  ",
        "%#StatusLineBold#",
        "%{v:lua.mode_icon()}",
        "%#StatusLine#",
        " │ %f %h%m%r",
        "%{v:lua.git_branch()}",
        " │ ",
        "%{v:lua.file_type()}",
        " | ",
        "%{v:lua.file_size()}",
        "%=", -- Right-align everything after this
        "%l:%c  %P ", -- Line:Column and Percentage
      }
    end,
  })
  vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = default_statusline_autogroup,
    callback = function() vim.wo[0][0].statusline = "  %f %h%m%r │ %{v:lua.file_type()} | %=  %l:%c   %P " end,
  })
end

setup_dynamic_statusline()
