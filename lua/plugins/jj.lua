local is_jj_repo = require("config.utils").is_jj_root()

return {
  { "NeogitOrg/neogit", enabled = not is_jj_repo },
  { "refractalize/oil-git-status.nvim", enabled = not is_jj_repo },

  {
    "NicolasGB/jj.nvim",
    enabled = is_jj_repo,
    dependencies = {
      "sindrets/diffview.nvim", -- used as diff backend
      "folke/snacks.nvim", -- for pickers
    },
    opts = {
      diff = {
        backend = "diffview",
      },
      editor = {
        auto_insert = true,
      },
      cmd = {
        describe = {
          editor = {
            keymaps = {
              close = { "q" },
            },
          },
        },
      },
    },
    keys = {
      { "<leader>vs", function() require("jj.cmd").status() end, desc = "JJ status" },
      { "<leader>vl", function() require("jj.cmd").log { limit = 200 } end, desc = "JJ log" },
      { "<leader>vd", function() require("jj.cmd").describe() end, desc = "JJ describe" },
      { "<leader>vc", function() require("jj.cmd").commit() end, desc = "JJ commit (describe + new)" },
      { "<leader>vp", function() require("jj.cmd").push() end, desc = "JJ push" },
      { "<leader>vf", function() require("jj.cmd").fetch() end, desc = "JJ fetch" },
      { "<leader>vb", function() require("jj.cmd").bookmark_move() end, desc = "JJ move bookmark" },
      { "<leader>vq", "<cmd>J split<cr>", desc = "JJ split" },
    },
    config = function(_, opts)
      require("jj").setup(opts)

      -- jj.nvim wipes its buffers on close (q) and before re-running a command (e.g. log refresh
      -- after `n`) and relies on that closing the window. When the only other window holds an
      -- unlisted buffer (e.g. snacks dashboard), the window survives as an empty buffer instead,
      -- so close it up front
      local function close_wins(buf)
        if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
        for _, win in ipairs(vim.fn.win_findbuf(buf)) do
          if #vim.api.nvim_tabpage_list_wins(0) > 1 then vim.api.nvim_win_close(win, true) end
        end
      end

      local terminal = require "jj.ui.terminal"
      local run = terminal.run
      terminal.run = function(...)
        close_wins(terminal.state.buf)
        return run(...)
      end

      local buffer = require "jj.core.buffer"
      local close = buffer.close
      buffer.close = function(buf, ...)
        close_wins(buf)
        return close(buf, ...)
      end
    end,
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "jjdescription",
        callback = function(args)
          vim.keymap.set({ "i" }, "<C-C><C-C>", "<cmd>wq<cr><esc>", { buffer = args.buf, desc = "Write and close" })
        end,
      })
    end,
  },

  -- Interactive hunk/line picker for jj split/squash --interactive
  -- Configured as jj's diff-editor via ~/.config/jj/config.toml:
  --   [ui]
  --   diff-editor = ["nvim", "-c", "DiffEditor $left $right $output"]
  --   diff-instructions = false
  -- Then use :J split  or  <C-s> from the jj.nvim log buffer to invoke it.
  {
    "julienvincent/hunk.nvim",
    enabled = is_jj_repo,
    cmd = { "DiffEditor" },
    dependencies = { "MunifTanjim/nui.nvim", "echasnovski/mini.icons" },
    opts = {
      keys = {
        global = {
          focus_tree = { "<leader>b" },
          accept = { "<C-C><C-C>", "<leader><Cr>" },
        },
        diff = {
          prev_hunk = { "[c" },
          next_hunk = { "]c" },
        },
      },
    },
  },
}
