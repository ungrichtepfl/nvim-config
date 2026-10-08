return {
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = false,
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _) return name == ".." end,
      },
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      win_options = {
        signcolumn = "yes:2", -- NOTE: Only needed when refractalize/oil-git-status.nvim is used
      },
      git = {
        mv = function(_, _) return not require("config.utils").is_jj_root() end,
      },
    },
    dependencies = { { "echasnovski/mini.icons", opts = {} }, "folke/snacks.nvim" },
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    keys = { { "<leader>e", "<cmd>Oil<cr>", desc = "Toggle Oil" } },
    init = function()
      vim.api.nvim_create_autocmd("User", { -- Enable renaming with lsp
        pattern = "OilActionsPost",
        callback = function(event)
          if event.data.actions.type == "move" then
            require("snacks").rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
          end
        end,
      })

      -- Quickfix only reuses a window with a normal buffer (buftype="") and splits otherwise,
      -- so close oil once a file from quickfix got its own split next to it
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = vim.api.nvim_create_augroup("_oil_qf", { clear = true }),
        callback = function()
          if vim.bo.buftype ~= "" or vim.fn.getwinvar(vim.fn.winnr "#", "&buftype") ~= "quickfix" then return end
          local current_win = vim.api.nvim_get_current_win()
          local wins = vim.api.nvim_tabpage_list_wins(0)
          for _, win in ipairs(wins) do
            if win ~= current_win and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then return end
          end
          for _, win in ipairs(wins) do
            if win ~= current_win and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "oil" then
              vim.api.nvim_win_close(win, true)
            end
          end
        end,
      })
    end,
  },
  {
    "benomahony/oil-git.nvim",
    dependencies = { "stevearc/oil.nvim" },
    enabled = false, -- FIXME: Cursore is weirdly blinking
    opts = {
      highlights = {
        OilGitModified = { fg = "#ff0000" }, -- Custom colors
      },
    },
  },
  {
    "refractalize/oil-git-status.nvim",
    dependencies = {
      "stevearc/oil.nvim",
    },
    enabled = true,
    opts = {
      show_ignored = true, -- show files that match gitignore with !!
      symbols = {
        index = {
          ["!"] = "", -- Ignored (not tracked and in .gitignore)
          ["?"] = "", -- Untracked
          ["A"] = "", -- Added (A for added)
          ["C"] = "", -- Copied
          ["D"] = "", -- Deleted
          ["M"] = "", -- Modified
          ["R"] = "", -- Renamed
          ["T"] = "", -- Type change (maybe symbolic link?)
          ["U"] = "", -- Unmerged
          [" "] = " ", -- Clean / nothing
        },
        working_tree = {
          ["!"] = "", -- Ignored (not tracked and in .gitignore)
          ["?"] = "", -- Untracked
          ["A"] = "", -- Added in working tree
          ["C"] = "", -- Copied
          ["D"] = "", -- Deleted
          ["M"] = "", -- Modified
          ["R"] = "", -- Renamed
          ["T"] = "", -- Type changed
          ["U"] = "", -- Unmerged
          [" "] = " ", -- Clean
        },
      },
    },
  },
}
