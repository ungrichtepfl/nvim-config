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

---Run `cmd` so that it gets `signal` when the program that started it dies.
---Ending a zellij session kills Neovim and the panes without a hangup, so without this the preview keeps running.
---@param signal string
---@param cmd string[]
---@return string[]
local function stop_with_parent(signal, cmd)
  if vim.fn.executable "setpriv" == 0 then
    vim.notify(
      "setpriv is not installed: the preview keeps running if Neovim or zellij is killed",
      vim.log.levels.WARN,
      { title = "presenterm" }
    )
    return cmd
  end
  return vim.list_extend({ "setpriv", "--pdeathsig", signal, "--" }, cmd)
end

---@param slides_path string
---@return string[]? cmd
---@return string? error
local function preview_command(slides_path)
  if has_makefile(vim.fs.dirname(slides_path)) then
    if vim.fn.executable "make" == 0 then return nil, "make is not installed" end
    -- make ends its children only on SIGTERM. On SIGHUP it keeps waiting for presenterm.
    return stop_with_parent("TERM", { "make" })
  end
  if vim.fn.executable "presenterm" == 0 then return nil, "presenterm is not installed" end
  return stop_with_parent("HUP", { "presenterm", slides_path })
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

---Stop a running terminal job together with every process it started.
---@param job integer
local function stop_job_with_children(job)
  if vim.fn.jobwait({ job }, 0)[1] ~= -1 then return end -- already ended
  -- `make` starts presenterm as a child, so stopping only the job would leave presenterm running. A terminal job
  -- leads its own process group, so the negative pid reaches all of them.
  local _, err, err_name = vim.uv.kill(-vim.fn.jobpid(job), "sigterm")
  if err and err_name ~= "ESRCH" then notify_error("cannot stop the preview: " .. err) end
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
  local job = vim.fn.jobstart(cmd, {
    term = true,
    cwd = vim.fs.dirname(slides_path),
    on_exit = function(_, code)
      -- 129 is SIGHUP, which Neovim sends when the terminal buffer is deleted or Neovim quits.
      -- 143 is SIGTERM from stop_job_with_children.
      if code ~= 0 and code ~= 129 and code ~= 143 then
        notify_error(table.concat(cmd, " ") .. " exited with code " .. code)
      end
      delete_preview_buf()
    end,
  })
  if job <= 0 then
    notify_error("cannot start " .. table.concat(cmd, " ") .. " (jobstart returned " .. job .. ")")
    delete_preview_buf()
    return
  end
  local function stop_preview()
    stop_job_with_children(job)
    delete_preview_buf()
  end
  vim.api.nvim_create_autocmd("BufUnload", {
    buffer = slides_buf,
    once = true,
    callback = stop_preview,
    desc = "Stop the presenterm preview together with its slides",
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = function() stop_job_with_children(job) end,
    desc = "Stop the presenterm preview when Neovim quits",
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

---@param args string[]
---@return string? stdout
---@return string? error
local function run_zellij(args)
  local result = vim.system(vim.list_extend({ "zellij" }, args), { text = true }):wait()
  if result.code ~= 0 then return nil, "zellij " .. table.concat(args, " ") .. " failed: " .. (result.stderr or "") end
  return result.stdout
end

---@param pane_id string as printed by `zellij run`, e.g. "terminal_5"
---@return boolean? exists
---@return string? error
local function zellij_pane_exists(pane_id)
  local stdout, err = run_zellij { "action", "list-panes", "--json" }
  if not stdout then return nil, err end
  local ok, panes = pcall(vim.json.decode, stdout)
  if not ok then return nil, "cannot read the output of zellij action list-panes: " .. panes end
  local number = tonumber(pane_id:match "^terminal_(%d+)$")
  for _, pane in ipairs(panes) do
    if pane.id == number and not pane.is_plugin then return true end
  end
  return false
end

---@param slides_path string
---@return string? pane_id
---@return string? error
local function start_preview_in_zellij(slides_path)
  local cmd, err = preview_command(slides_path)
  if not cmd then return nil, err end
  -- The zellij pane does not get the PATH of Neovim, so tools that the slides run (e.g. d2) are not found
  -- without passing it on.
  local stdout, run_err = run_zellij(vim.list_extend({
    "run",
    "--close-on-exit",
    "--direction",
    "right",
    "--cwd",
    vim.fs.dirname(slides_path),
    "--",
    "env",
    "PATH=" .. vim.env.PATH,
  }, cmd))
  if not stdout then return nil, run_err end
  return vim.trim(stdout)
end

---Close the zellij pane of a preview, which ends the presenterm in it.
---@param pane_id string
local function close_zellij_pane(pane_id)
  local exists, err = zellij_pane_exists(pane_id)
  if err then
    notify_error(err)
    return
  end
  if not exists then return end
  local _, close_err = run_zellij { "action", "close-pane", "--pane-id", pane_id }
  if close_err then notify_error(close_err) end
end

---Show or hide a preview of the slides in `buf` in a zellij pane to the right of Neovim.
---Unlike the terminal of Neovim, zellij passes images on to the terminal, so they are not drawn as ascii blocks.
---zellij cannot hide a pane, so hiding makes the pane of Neovim fullscreen. The preview keeps running behind it.
---@param buf integer
function M.toggle_preview_in_zellij(buf)
  if not vim.env.ZELLIJ then
    notify_error "Neovim does not run inside zellij"
    return
  end
  local pane_id = vim.b[buf].presenterm_zellij_pane
  local exists, exists_err = false, nil
  if pane_id then
    exists, exists_err = zellij_pane_exists(pane_id)
  end
  if exists_err then
    notify_error(exists_err)
    return
  end

  if exists then
    local _, toggle_err = run_zellij { "action", "toggle-fullscreen", "--pane-id", vim.env.ZELLIJ_PANE_ID }
    if toggle_err then notify_error(toggle_err) end
    return
  end
  local new_pane_id, start_err = start_preview_in_zellij(vim.api.nvim_buf_get_name(buf))
  if not new_pane_id then
    notify_error(start_err)
    return
  end
  vim.b[buf].presenterm_zellij_pane = new_pane_id
  -- Hiding only makes Neovim fullscreen, so the pane must be closed explicitly, or it keeps running unseen.
  vim.api.nvim_create_autocmd("BufUnload", {
    buffer = buf,
    once = true,
    callback = function() close_zellij_pane(new_pane_id) end,
    desc = "Close the presenterm zellij pane together with its slides",
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = function() close_zellij_pane(new_pane_id) end,
    desc = "Close the presenterm zellij pane when Neovim quits",
  })
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
    function() M.toggle_preview_in_zellij(buf) end,
    { buffer = buf, desc = "Toggle presenterm preview in a zellij pane" }
  )
  set_toggle_preview_keymap(buf, buf)
end

return M
