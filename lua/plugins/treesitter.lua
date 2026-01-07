return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local ensure_installed = {
        "arduino",
        "asm",
        "bash",
        "c",
        "c_sharp",
        "cmake",
        "cpp",
        "css",
        "diff",
        "doxygen",
        "elm",
        "git_rebase",
        "gitcommit",
        "gitignore",
        "go",
        "gomod",
        "haskell",
        "html",
        "java",
        "javascript",
        "json",
        "json5",
        "latex",
        "llvm",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "matlab",
        "nasm",
        "nix",
        "python",
        "query",
        "regex",
        "rst",
        "rust",
        "slint",
        "sql",
        "ssh_config",
        "toml",
        "tsx",
        "typescript",
        "udev",
        "vim",
        "vimdoc",
        "vue",
        "xml",
        "yaml",
        "zig",
      }
      if #ensure_installed > 0 then
        local nts = require "nvim-treesitter"
        nts.install(ensure_installed)

        -- all the installed parsers
        local parsers = nts.get_installed()

        vim.api.nvim_create_autocmd({ "FileType" }, {
          pattern = parsers,
          callback = function(event)
            local bufnr = event.buf
            vim.treesitter.start(bufnr)
          end,
        })
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    branch = "main",
    opts = {
      select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        -- You can choose the select mode (default is charwise 'v')
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'V', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
          ["@parameter.outer"] = "v", -- charwise
          ["@function.outer"] = "V", -- linewise
          ["@class.outer"] = "<c-v>", -- blockwise
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * selection_mode: eg 'v'
        -- and should return true of false
        include_surrounding_whitespace = false,
      },
      move = {
        -- whether to set jumps in the jumplist
        set_jumps = true,
      },
    },
    lazy = false,
    config = function(opts, _)
      require("nvim-treesitter-textobjects").setup(opts)
      vim.keymap.set(
        "n",
        "gs",
        function() require("nvim-treesitter-textobjects.swap").swap_next "@parameter.inner" end,
        { desc = "Swap with next parameter in function" }
      )
      vim.keymap.set(
        "n",
        "gS",
        function() require("nvim-treesitter-textobjects.swap").swap_previous "@parameter.inner" end,
        { desc = "Swap with previous parameter in function" }
      )

      local select_keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["aa"] = { "@parameter.outer", "textobjects" },
        ["ia"] = { "@parameter.inner", "textobjects" },
        ["am"] = { "@function.outer", "textobjects" },
        ["im"] = { "@function.inner", "textobjects" },
        ["an"] = { "@class.outer", "textobjects" },
        ["in"] = { "@class.inner", "textobjects" },
        ["ao"] = { "@conditional.outer", "textobjects" },
        ["io"] = { "@conditional.inner", "textobjects" },
        ["af"] = { "@loop.outer", "textobjects" },
        ["if"] = { "@loop.inner", "textobjects" },
        ["as"] = { "@local.scope", "locals" },
      }

      for k, v in pairs(select_keymaps) do
        local desc = "ts-textobjects: select " .. v[1]
        if type(v[1]) == "table" then
          desc = desc .. table.concat(v[1], " ,")
        else
          desc = desc .. v[1]
        end
        vim.keymap.set(
          { "x", "o" },
          k,
          function() require("nvim-treesitter-textobjects.select").select_textobject(v[1], v[2]) end,
          { desc = desc }
        )
      end

      local move_keymaps = {
        goto_next_start = {
          ["]a"] = { "@parameter.inner", "textobjects" },
          ["]m"] = { "@function.outer", "textobjects" },
          ["]n"] = { "@class.outer", "textobjects" },
          ["]o"] = { "@conditional.outer", "textobjects" },
          ["]f"] = { "@loop.outer", "textobjects" },
        },
        goto_next_end = {
          ["]A"] = { "@parameter.inner", "textobjects" },
          ["]M"] = { "@function.outer", "textobjects" },
          ["]N"] = { "@class.outer", "textobjects" },
          ["]O"] = { "@conditional.outer", "textobjects" },
          ["]F"] = { "@loop.outer", "textobjects" },
        },
        goto_previous_start = {
          ["[a"] = { "@parameter.inner", "textobjects" },
          ["[m"] = { "@function.outer", "textobjects" },
          ["[n"] = { "@class.outer", "textobjects" },
          ["[o"] = { "@conditional.outer", "textobjects" },
          ["[f"] = { "@loop.outer", "textobjects" },
        },
        goto_previous_end = {
          ["[A"] = { "@parameter.inner", "textobjects" },
          ["[M"] = { "@function.outer", "textobjects" },
          ["[N"] = { "@class.outer", "textobjects" },
          ["[O"] = { "@conditional.outer", "textobjects" },
          ["[F"] = { "@loop.outer", "textobjects" },
        },
        goto_next = {
          -- Start or end whichever is closer
        },
        goto_previous = {
          -- Start or end whichever is closer
        },
      }

      for fn, maps in pairs(move_keymaps) do
        for k, v in pairs(maps) do
          local desc = "ts-textobjects: " .. fn .. " "
          if type(v[1]) == "table" then
            desc = desc .. table.concat(v[1], " ,")
          else
            desc = desc .. v[1]
          end
          vim.keymap.set(
            { "n", "x", "o" },
            k,
            function() require("nvim-treesitter-textobjects.move")[fn](v[1], v[2]) end,
            { desc = desc }
          )
        end
      end

      local ts_repeat_move = require "nvim-treesitter-textobjects.repeatable_move"

      -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })

      -- HACK: workaround for https://github.com/nvim-treesitter/nvim-treesitter-textobjects/issues/775
      -- thanks @seandewar
      local function make_repeate(keys)
        if keys then vim.cmd(("normal! %d%s"):format(vim.v.count1, vim.keycode(keys))) end
      end
      local function repeat_last_move()
        local keys = ts_repeat_move["repeat_last_move"]()
        return make_repeate(keys)
      end
      local function repeat_last_move_opposite()
        local keys = ts_repeat_move["repeat_last_move_opposite"]()
        return make_repeate(keys)
      end

      if require("config.utils").is_swiss_keyboard() then vim.keymap.set({ "n", "x", "o" }, "ö", repeat_last_move) end
      vim.keymap.set({ "n", "x", "o" }, ";", repeat_last_move)
      vim.keymap.set({ "n", "x", "o" }, ",", repeat_last_move_opposite)

      -- NOTE: Uncomment as soon as it works
      -- -- vim way: ; goes to the direction you were moving.
      -- if require("config.utils").is_swiss_keyboard() then
      --   vim.keymap.set({ "n", "x", "o" }, "ö", ts_repeat_move.repeat_last_move)
      -- end
      -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
      -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
    keys = {
      { "gC", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Go to context." },
    },
    opts = {
      multiline_threshold = 1, -- show only one line for a context otherwise it gets messy
    },
  },
  {
    "windwp/nvim-ts-autotag",
    opts = {},
    lazy = false,
  },
}
