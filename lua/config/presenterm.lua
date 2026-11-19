--- Helpers to write and preview presenterm slides.
local M = {}

local function notify_error(message) vim.notify(message, vim.log.levels.ERROR, { title = "presenterm" }) end

---@param dir string
---@return boolean
local function has_makefile(dir)
  for _, name in ipairs { "GNUmakefile", "makefile", "Makefile" } do
    if vim.uv.fs_stat(vim.fs.joinpath(dir, name)) then return true end
  end
  return false
end

---@param slides_path string
---@return string[]? cmd
---@return string? error
local function preview_command(slides_path)
  if has_makefile(vim.fs.dirname(slides_path)) then
    if vim.fn.executable "make" == 0 then return nil, "make is not installed" end
    return { "make" }
  end
  if vim.fn.executable "presenterm" == 0 then return nil, "presenterm is not installed" end
  return { "presenterm", slides_path }
end

local function set_toggle_preview_keymap(keymap_buf, slides_buf)
  vim.keymap.set(
    { "n", "t" },
    "<C-ö>",
    function() M.toggle_preview(slides_buf) end,
    { buffer = keymap_buf, desc = "Toggle presenterm preview" }
  )
end

---Pick a presenterm comment command (<!-- pause -->, ...) and insert it after the cursor.
function M.insert_comment_command()
  if vim.fn.executable "presenterm" == 0 then
    notify_error "presenterm is not installed"
    return
  end
  vim.system({ "presenterm", "--list-comment-commands" }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        notify_error("presenterm --list-comment-commands failed: " .. (result.stderr or ""))
        return
      end
      local commands = vim.split(vim.trim(result.stdout), "\n", { trimempty = true })
      vim.ui.select(commands, { prompt = "presenterm> " }, function(command)
        if command then vim.api.nvim_put({ command }, "c", true, true) end
      end)
    end)
  end)
end

---@param preview_buf integer
local function open_preview_window(preview_buf)
  vim.api.nvim_open_win(preview_buf, true, { split = "right", win = vim.api.nvim_get_current_win() })
end

---@param slides_buf integer
local function start_preview(slides_buf)
  local slides_path = vim.api.nvim_buf_get_name(slides_buf)
  local cmd, err = preview_command(slides_path)
  if not cmd then
    notify_error(err)
    return
  end

  local preview_buf = vim.api.nvim_create_buf(false, false)
  local function delete_preview_buf()
    if vim.api.nvim_buf_is_valid(preview_buf) then vim.api.nvim_buf_delete(preview_buf, { force = true }) end
  end
  vim.bo[preview_buf].bufhidden = "hide"
  set_toggle_preview_keymap(preview_buf, slides_buf)
  vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", { buffer = preview_buf, desc = "Window commands" })
  vim.b[slides_buf].presenterm_preview_buf = preview_buf
  open_preview_window(preview_buf)
  vim.fn.jobstart(cmd, {
    term = true,
    cwd = vim.fs.dirname(slides_path),
    on_exit = function(_, code)
      -- 129 is SIGHUP, which Neovim sends when the terminal buffer is deleted or Neovim quits
      if code ~= 0 and code ~= 129 then notify_error(table.concat(cmd, " ") .. " exited with code " .. code) end
      delete_preview_buf()
    end,
  })
  vim.api.nvim_create_autocmd("BufUnload", {
    buffer = slides_buf,
    once = true,
    callback = delete_preview_buf,
    desc = "Stop the presenterm preview together with its slides",
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = preview_buf,
    command = "startinsert",
    desc = "Send keys to presenterm when entering the preview",
  })
  vim.cmd.startinsert()
end

---Show or hide a live preview of the slides in `buf` in a terminal split on the right.
---It runs `make` if the folder of the slides has a Makefile, else presenterm.
---Hiding keeps the preview running, so it stays on the current slide. presenterm reloads the slides on every save.
---@param buf integer
function M.toggle_preview(buf)
  local preview_buf = vim.b[buf].presenterm_preview_buf
  if not (preview_buf and vim.api.nvim_buf_is_valid(preview_buf)) then
    start_preview(buf)
    return
  end
  local preview_win = vim.fn.bufwinid(preview_buf)
  if preview_win == -1 then
    open_preview_window(preview_buf)
  else
    vim.api.nvim_win_hide(preview_win)
  end
end

---Run the preview of the slides in `buf` in a floating zellij pane.
---Unlike the terminal of Neovim, zellij passes images on to the terminal, so they are not drawn as ascii blocks.
---@param buf integer
function M.open_preview_in_zellij(buf)
  if not vim.env.ZELLIJ then
    notify_error "Neovim does not run inside zellij"
    return
  end
  local slides_path = vim.api.nvim_buf_get_name(buf)
  local cmd, err = preview_command(slides_path)
  if not cmd then
    notify_error(err)
    return
  end
  -- The zellij pane does not get the PATH of Neovim, so tools that the slides run (e.g. d2) are not found
  -- without passing it on.
  local zellij_cmd = vim.list_extend(
    { "zellij", "run", "--floating", "--cwd", vim.fs.dirname(slides_path), "--", "env", "PATH=" .. vim.env.PATH },
    cmd
  )
  vim.system(zellij_cmd, { text = true }, function(result)
    if result.code ~= 0 then
      vim.schedule(function() notify_error("zellij run failed: " .. (result.stderr or "")) end)
    end
  end)
end

---Set the keymaps to write and preview the slides in `buf`.
---@param buf integer
function M.set_keymaps(buf)
  vim.keymap.set(
    "n",
    "<localleader>c",
    M.insert_comment_command,
    { buffer = buf, desc = "Insert presenterm comment command" }
  )
  vim.keymap.set(
    "n",
    "<localleader>z",
    function() M.open_preview_in_zellij(buf) end,
    { buffer = buf, desc = "Open presenterm preview in a zellij pane" }
  )
  set_toggle_preview_keymap(buf, buf)
end

return M
