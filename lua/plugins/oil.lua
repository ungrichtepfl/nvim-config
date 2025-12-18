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
        mv = function(_, _) return true end,
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
