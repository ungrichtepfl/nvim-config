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
        if require("config.utils").is_jj_root_cached() then
          local conflicts = {}
          for _, line in ipairs(vim.fn.systemlist "jj resolve --list 2>/dev/null") do
            local file = line:match "^(%S+)"
            if file then conflicts[file] = true end
          end

          local function extract_file(sel)
            local plain = sel:gsub("\27%[[%d;]*m", "")
            plain = plain:gsub("^⚡", "")
            return plain:match "^%S+%s+(.-)%s*$"
          end

          require("fzf-lua").fzf_exec(function(fzf_cb)
            local lines =
              vim.fn.systemlist [[jj diff --summary --color=always 2>/dev/null | sed 's|{[^{]* => \([^}]*\)}|\1|g']]
            for _, line in ipairs(lines) do
              local plain = line:gsub("\27%[[%d;]*m", "")
              local file = plain:match "^%S+%s+(.+)$"
              if file and conflicts[file] then
                fzf_cb("⚡" .. line)
              else
                fzf_cb(line)
              end
            end
            fzf_cb()
          end, {
            prompt = "JJ Status> ",
            fzf_opts = {
              ["--ansi"] = true,
              ["--preview-window"] = "right:60%",
            },
            preview = "jj diff --color=always -- {2}",
            actions = {
              ["default"] = function(selected)
                if not selected or #selected == 0 then return end
                local file = extract_file(selected[1])
                if file then vim.cmd("edit " .. vim.fn.fnameescape(file)) end
              end,
              ["ctrl-v"] = function(selected)
                if not selected or #selected == 0 then return end
                local file = extract_file(selected[1])
                if file then vim.cmd("vsplit " .. vim.fn.fnameescape(file)) end
              end,
              ["ctrl-s"] = function(selected)
                if not selected or #selected == 0 then return end
                local file = extract_file(selected[1])
                if file then vim.cmd("split " .. vim.fn.fnameescape(file)) end
              end,
              ["ctrl-x"] = function(selected)
                if not selected or #selected == 0 then return end
                local file = extract_file(selected[1])
                if not file then return end
                vim.fn.system("jj restore -- " .. vim.fn.shellescape(file))
                vim.notify("Restored: " .. file, vim.log.levels.INFO)
              end,
            },
          })
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
