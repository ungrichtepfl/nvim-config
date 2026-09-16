local CONFLICT = "⚡"

local function jj_status()
  -- NOTE: the output below is hard to parse as they use spaces as separators, so we will just match the beginning of each line to find out if there is a conflict
  -- $ jj resolve --list --no-pager --no-color 2>/dev/null
  -- zsh/hell you      2-sided conflict
  -- zsh/zshrc.luke    2-sided conflict
  local conflicts = {}
  for _, line in ipairs(vim.fn.systemlist "jj resolve --list --no-pager --color=never 2>/dev/null") do
    table.insert(conflicts, line)
  end
  local function has_conflic(file)
    for _, line in ipairs(conflicts) do
      if line:startswith(file) then return true end
    end
    return false
  end
  -- $ jj diff --summary --no-pager 2>/dev/null
  -- R {INSTALL.md => ini}
  -- M zsh/hell you
  -- M zsh/zshrc.luke
  -- NOTE: the gsub reduces a rename to the name it ends up with:
  -- R ini
  -- M zsh/hell you
  -- M zsh/zshrc.luke
  local status = {}
  local lines = vim.fn.systemlist "jj diff --summary --no-pager --color=never 2>/dev/null"
  for _, line in ipairs(lines) do
    local status_type, file = line:gsub("{[^{]* => ([^}]*)}", "%1"):match "^(%S+)%s+(.-)%s*$"
    if file then
      if has_conflic(file) then status_type = CONFLICT end
      status[file] = status_type
    end
  end
  return status
end

local function fzf_status()
  local actions = {
    ["ctrl-x"] = {
      fn = function(selected, ops)
        for _, entry in ipairs(selected) do
          local file = require("fzf-lua.path").entry_to_file(entry, ops).path
          vim.fn.system { "jj", "restore", "--", string.format('file:"%s"', file) }
          vim.notify("Restored: " .. file, vim.log.levels.INFO)
        end
      end,
      reload = true,
      header = "restore",
    },
  }
  -- NOTE: `config.globals` and not `fzf.defaults`: the latter is the static table
  --  from `defaults.lua` that `setup()` never touches, the former is a lazy view
  --  that merges the setup options over it.
  actions = vim.tbl_deep_extend("force", require("fzf-lua").config.globals.actions.files, actions)

  -- NOTE: `_fzf_nth_devicons` makes fzf-lua set `--delimiter` to `utils.nbsp` and
  --  `--nth=-1..`, so the icons are display only: they're excluded from the fuzzy
  --  matching and `path.entry_to_file` strips them back off for the file actions.
  local opts = {
    file_icons = true,
    color_icons = true,
    _fzf_nth_devicons = true,
    -- NOTE: jj parses positional args as filesets, so paths containing meta
    --  characters (`%`, `(`, ...) must be wrapped in `file:"..."`. fzf replaces
    --  {-1} with a single-quoted string, so the quotes concatenate into one word.
    preview = [[jj diff --color=always --no-pager -- 'file:"'{-1}'"']],
    fzf_opts = { ["--multi"] = true }, -- needed for ctrl-q
    actions = actions,
    winopts = { title = " JJ Status ", title_pos = "center" },
  }

  require("fzf-lua").fzf_exec(function(fzf_cb)
    local status = jj_status() -- NOTE: Must be in the callback for reloading to work

    local fzf_utils = require "fzf-lua.utils"
    local fzf_git_icons = require("fzf-lua.config").globals.git.icons
    local make_entry = require "fzf-lua.make_entry"
    for file, status_type in pairs(status) do
      local git_icon = fzf_git_icons[status_type]
      local prefix = git_icon and fzf_utils.ansi_codes[git_icon.color or "dark_grey"](git_icon.icon) .. " "
        or fzf_utils.ansi_codes["red"](status_type) -- if not a git icon it is the merge conflict mod
      fzf_cb(prefix .. fzf_utils.nbsp .. make_entry.file(file, opts))
    end
    fzf_cb()
  end, opts)
end

--- owner/repo of the `origin` remote, resolved offline from the remote url
local function github_repo(cwd)
  local url = vim.fn.systemlist { "git", "-C", cwd, "remote", "get-url", "origin" }
  if vim.v.shell_error ~= 0 or not url[1] then return nil end
  return url[1]:gsub("%.git$", ""):match "github%.com[:/](.+)$"
end

-- NOTE: "list pull requests associated with a commit" returns the merged PR that
--  introduced the commit (squash merges included) or the open PRs containing it:
--  https://docs.github.com/en/rest/commits/commits#list-pull-requests-associated-with-a-commit
local function pr_number(nwo, sha)
  local out = vim.fn.systemlist {
    "gh",
    "api",
    string.format("repos/%s/commits/%s/pulls", nwo, sha),
    "--jq",
    ".[0].number",
  }
  if vim.v.shell_error ~= 0 then return nil, table.concat(out, "\n") end
  return tonumber(out[1])
end

local function open_pr(nwo, selected, browser)
  if not nwo then
    vim.notify("No github.com `origin` remote", vim.log.levels.WARN)
    return
  end
  local sha = require("fzf-lua.utils").strip_ansi_coloring(selected[1]):match "^%x+"
  local number, err = pr_number(nwo, sha)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  elseif not number then
    vim.notify("No pull request found for " .. sha, vim.log.levels.WARN)
  else
    require("config.utils").open_github(
      string.format("https://github.com/%s/pull/%d", nwo, number),
      { browser = browser }
    )
  end
end

--- Resolve a buffer line range to the commit/file/range it originates from.
--- NOTE: `git log -L` resolves its range against a *revision*, never against the
---  working tree, so on a modified buffer an untranslated range is either out of
---  bounds ("file has only N lines") or, worse, silently reports the history of an
---  unrelated line. `git blame --contents -` blames the buffer as it is right now
---  and its porcelain header gives us the line number in the commit it came from.
local function blame_origin(git_root, relfile, first, last)
  local out = vim.fn.systemlist({
    "git",
    "-C",
    git_root,
    "-c",
    "core.quotepath=false",
    "blame",
    "--porcelain",
    "--contents",
    "-",
    "-L",
    string.format("%d,%d", first, last),
    "--",
    relfile,
  }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
  if vim.v.shell_error ~= 0 then return nil, table.concat(out, "\n") end

  -- porcelain group header: "<sha> <line in commit> <line in buffer> <lines in group>"
  local sha, srcline, nlines = out[1]:match "^(%x+)%s+(%d+)%s+%d+%s+(%d+)"
  if not sha then return nil, "unexpected `git blame --porcelain` output: " .. (out[1] or "") end
  if sha:match "^0+$" then return nil end -- not committed yet

  local count = math.min(tonumber(nlines), last - first + 1)
  local file = relfile
  for _, line in ipairs(out) do
    local name = line:match "^filename (.+)$"
    if name then
      file = name
      break
    end
  end
  return {
    sha = sha,
    file = file,
    first = tonumber(srcline),
    last = tonumber(srcline) + count - 1,
    -- the range spills into an older commit, only the first group is listed
    truncated = count < last - first + 1,
  }
end

--- Picker over every commit that touched the current line (or the visual range).
local function fzf_line_history()
  local fzf = require "fzf-lua"
  local fzf_path = require "fzf-lua.path"
  -- NOTE: `config.globals` (unlike `fzf.defaults`) is the table `setup()` merges
  --  into, so the entry format, pager and actions borrowed from `git_bcommits`
  --  below follow both the upstream defaults and any user override of them.
  local bcommits = fzf.config.globals.git.bcommits

  if #vim.api.nvim_buf_get_name(0) == 0 then
    vim.notify("Line history is not available for unnamed buffers", vim.log.levels.WARN)
    return
  end

  local opts = { cwd = fzf_path.git_root({ cwd = vim.fn.expand "%:p:h" }, true) }
  local git_root = fzf_path.git_root(opts)
  if not git_root then return end

  local first, last = vim.fn.line ".", vim.fn.line "."
  if vim.fn.mode():match "^[vV\22]" then
    first, last = vim.fn.line "v", vim.fn.line "."
    if first > last then
      first, last = last, first
    end
  end

  local origin, err = blame_origin(git_root, fzf_path.relative_to(vim.fn.expand "%:p", git_root), first, last)
  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return
  elseif not origin then
    vim.notify(string.format("Line %d-%d is not committed yet", first, last), vim.log.levels.WARN)
    return
  elseif origin.truncated then
    vim.notify("Range spans several commits, listing the first one only", vim.log.levels.WARN)
  end
  local nwo = github_repo(git_root)

  -- NOTE: `git blame` only reports the *last* commit that touched a line, `git log -L`
  --  walks the full history of a line range instead. `--no-patch` reduces each commit
  --  to a single entry line, matching the bcommits entry format.
  local cmd = string.format(
    [[git log -L %d,%d:%s %s --no-patch --color=always --pretty=format:"%s"]],
    origin.first,
    origin.last,
    require("fzf-lua.libuv").shellescape(origin.file),
    origin.sha,
    bcommits.cmd:match [[%-%-pretty=format:"(.-)"]]
  )

  -- NOTE: both previews are plain shell commands bound to fzf's `change-preview`,
  --  so nothing hits the network until <A-p> is pressed: the commit preview is
  --  fully offline, the PR preview shells out to `gh`.
  local pager = type(bcommits.preview_pager) == "function" and bcommits.preview_pager() or bcommits.preview_pager
  local preview_commit = "git show --color=always {1}" .. (pager and " | " .. pager or "")
  local preview_pr = nwo
    and string.format(
      [[sh -c 'n=$(gh api repos/%s/commits/"$1"/pulls --jq ".[0].number" 2>/dev/null); ]]
        .. [[if [ -n "$n" ]; then GH_FORCE_TTY=$FZF_PREVIEW_COLUMNS gh pr view --repo %s "$n"; ]]
        .. [[else echo "no pull request found for $1"; fi' sh {1}]],
      nwo,
      nwo
    )

  opts.preview = preview_commit
  opts.fzf_opts = vim.deepcopy(bcommits.fzf_opts)
  opts.keymap = {
    fzf = {
      ["alt-c"] = string.format("change-preview(%s)", preview_commit),
      ["alt-p"] = preview_pr and string.format("change-preview(%s)", preview_pr) or nil,
    },
  }
  opts.actions = vim.tbl_deep_extend("force", bcommits.actions, {
    ["alt-o"] = { fn = function(selected) open_pr(nwo, selected) end },
    ["alt-b"] = { fn = function(selected) open_pr(nwo, selected, true) end },
  })
  opts.winopts = { title = string.format(" Line History %d-%d ", first, last), title_pos = "center" }
  opts.header = ":: <A-p> PR description | <A-c> commit | <A-o> open PR | <A-b> PR in browser"

  fzf.fzf_exec(cmd, opts)
end

return {
  "ibhagwan/fzf-lua",
  dependencies = { "echasnovski/mini.icons" },
  event = "VeryLazy", -- Needed for ui select to work properly
  opts = {
    files = {
      git_icons = true,
      -- NOTE: using rg with sortr=modified displays recently modified files at the
      --  top of the fzf input file list. Using the --tiebreak=index prefers
      --  the files on top of the list.
      --  CAVEAT: rg now runs SINGLE THREADED!
      cmd = [[rg --files --color=never --hidden --files -g "!.git" --sortr=modified]],
      fzf_opts = {
        ["--tiebreak"] = "index",
      },
    },
    fzf_opts = {
      ["--cycle"] = true, -- wrap around at both ends of the result list
    },
    keymap = {
      -- NOTE: the preview binds are needed in both tables: 'builtin' is only
      --  mapped for the lua previewer, pickers with a native previewer (git
      --  status, jj status) never see it and get the key from fzf instead.
      builtin = {
        true,
        ["<C-j>"] = "preview-down",
        ["<C-k>"] = "preview-up",
        ["<M-j>"] = "preview-half-page-down",
        ["<M-k>"] = "preview-half-page-up",
      },
      fzf = {
        true,
        ["ctrl-j"] = "preview-down",
        ["ctrl-k"] = "preview-up",
        ["alt-j"] = "preview-half-page-down",
        ["alt-k"] = "preview-half-page-up",
        ["ctrl-q"] = "select-all+accept",
      },
    },
    winopts = {
      on_create = function()
        vim.keymap.set("t", "<C-r>", [['<C-\><C-N>"'.nr2char(getchar()).'pi']], { expr = true, buffer = true })
      end,
    },
  },
  cmd = "FzfLua",
  keys = {
    { "<leader>f", "<cmd> FzfLua files<cr>", desc = "Find files" },
    { "<leader>g", "<cmd> FzfLua live_grep<cr>", desc = "Grep word in all files" },
    { "<leader>b", "<cmd> FzfLua buffers<cr>", desc = "List of all open buffers" },
    {
      "<leader>s",
      function()
        if require("config.utils").is_jj_root() then
          fzf_status()
        else
          require("fzf-lua").git_status()
        end
      end,
      desc = "VCS status",
    },
    { "<leader>k", "<cmd> FzfLua keymaps<cr>", desc = "Show keymaps" },
    { "<leader>om", "<cmd> FzfLua marks<cr>", desc = "List of all marks" },
    { "<leader>op", "<cmd> FzfLua manpages<cr>", desc = "List all manpages" },
    { "<leader>oc", "<cmd> FzfLua commands<cr>", desc = "List vim commands" },
    { "<leader>oh", "<cmd> FzfLua command_history<cr>", desc = "Show command history" },
    { "<leader>ot", "<cmd> FzfLua filetypes<cr>", desc = "List available filetypes" },
    { "<leader>ogc", "<cmd> FzfLua git_commits<cr>", desc = "List git commits" },
    { "<leader>ogC", "<cmd> FzfLua git_bcommits<cr>", desc = "List git commits of the buffer" },
    { "<leader>ogb", "<cmd> FzfLua git_branches<cr>", desc = "List git branches" },
    {
      "<leader>ob",
      fzf_line_history,
      mode = { "n", "x" },
      desc = "List git commits touching the current line",
    },
    { "<leader><leader>r", "<cmd> FzfLua resume<cr>", desc = "List git branches" },
    { "[w", "<cmd> FzfLua grep_cword<cr>", desc = "Grep for word under cursor" },
    { "[W", "<cmd> FzfLua grep_cWORD<cr>", desc = "Grep for WORD under cursor" },
  },
  config = function(_, opts)
    local fzf = require "fzf-lua"
    fzf.setup(opts)
    fzf.register_ui_select()

    local group = vim.api.nvim_create_augroup("FzfLuaAfterLsp", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "AfterLspAttach",
      callback = function(args)
        local buf = args.data.buf
        vim.keymap.set(
          "n",
          "gD",
          function() require("fzf-lua").lsp_declarations() end,
          { desc = "Go to declaration", buffer = buf }
        )
        vim.keymap.set(
          "n",
          "gd",
          function() require("fzf-lua").lsp_definitions() end,
          { desc = "Go to definition", buffer = buf }
        )
        vim.keymap.set(
          "n",
          "grr",
          function() require("fzf-lua").lsp_references() end,
          { desc = "Go to references", buffer = buf }
        )
        vim.keymap.set(
          "n",
          "gri",
          function() require("fzf-lua").lsp_implementations() end,
          { desc = "Go to implementations", buffer = buf }
        )
        vim.keymap.set(
          "n",
          "gO",
          function() require("fzf-lua").lsp_document_symbols() end,
          { desc = "Show document symbols", buffer = buf }
        )
        vim.keymap.set(
          "n",
          "<leader>Dd",
          function() require("fzf-lua").lsp_document_diagnostics() end,
          { desc = "Document diagnostic", buffer = buf }
        )
        vim.keymap.set(
          "n",
          "<leader>Dw",
          function() require("fzf-lua").lsp_workspace_diagnostics() end,
          { desc = "Workspace diagnostic", buffer = buf }
        )
      end,
    })
  end,
}
