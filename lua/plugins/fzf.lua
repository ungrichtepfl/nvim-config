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
          vim.fn.system { "jj", "restore", "--", file }
          vim.notify("Restored: " .. file, vim.log.levels.INFO)
        end
      end,
      reload = true,
      header = "restore",
    },
  }
  actions = vim.tbl_deep_extend("force", require("fzf-lua").defaults.actions.files, actions)

  -- NOTE: `_fzf_nth_devicons` makes fzf-lua set `--delimiter` to `utils.nbsp` and
  --  `--nth=-1..`, so the icons are display only: they're excluded from the fuzzy
  --  matching and `path.entry_to_file` strips them back off for the file actions.
  local opts = {
    file_icons = true,
    color_icons = true,
    _fzf_nth_devicons = true,
    preview = "jj diff --color=always --no-pager -- {-1}",
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
    keymap = {
      builtin = {
        true,
        ["<C-j>"] = "preview-down",
        ["<C-k>"] = "preview-up",
        ["<C-d>"] = "preview-page-down",
        ["<C-u>"] = "preview-page-up",
      },
      fzf = {
        true,
        ["ctrl-d"] = "preview-page-down",
        ["ctrl-u"] = "preview-page-up",
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
