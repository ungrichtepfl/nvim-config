return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        lazy = false, 
        config = function(_, _)
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
            require'nvim-treesitter'.install (ensure_installed)
            -- TODO: How can I enable it for all the installed ones?
            -- Enable treesitter for all filetypes:
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(details)
                    local bufnr = details.buf
                    if not pcall(vim.treesitter.start, bufnr) then -- try to start treesitter which enables syntax highlighting
                        return
                    end
                    vim.bo[bufnr].syntax = "on" -- Use regex based syntax-highlighting as fallback as some plugins might need it
                    vim.wo.foldlevel = 99
                    vim.wo.foldmethod = "expr"
                    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Use treesitter for folds
                    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" -- Use treesitter for indentation
                end,
})
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = {"nvim-treesitter/nvim-treesitter"},
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
                    ['@parameter.outer'] = 'v', -- charwise
                    ['@function.outer'] = 'V', -- linewise
                    ['@class.outer'] = '<c-v>', -- blockwise
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
        config = function(_, opts)
            require("nvim-treesitter-textobjects").setup(opts)

            local select = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")
            local swap = require("nvim-treesitter-textobjects.swap")
            local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

            -- SELECTION --
            vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end,
                { desc = "Select around function" })
            vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end,
                { desc = "Select inside function" })
            vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer", "textobjects") end,
                { desc = "Select around class" })
            vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner", "textobjects") end,
                { desc = "Select inside class" })
            vim.keymap.set({ "x", "o" }, "as", function() select.select_textobject("@local.scope", "locals") end,
                { desc = "Select scope" })

            -- SWAP --
            vim.keymap.set("n", "<leader>ap", function() swap.swap_next("@parameter.inner") end,
                { desc = "Swap next parameter" })
            vim.keymap.set("n", "<leader>aP", function() swap.swap_previous("@parameter.outer") end,
                { desc = "Swap previous parameter" })

            -- MOVE (Umlaut-friendly) --
            vim.keymap.set({ "n", "x", "o" }, "üm", function() move.goto_next_start("@function.outer", "textobjects") end,
                { desc = "Next function start" })
            vim.keymap.set({ "n", "x", "o" }, "ää", function() move.goto_next_start("@class.outer", "textobjects") end,
                { desc = "Next class start" })
            vim.keymap.set({ "n", "x", "o" }, "üo", function() move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects") end,
                { desc = "Next loop start" })
            vim.keymap.set({ "n", "x", "o" }, "üs", function() move.goto_next_start("@local.scope", "locals") end,
                { desc = "Next scope start" })
            vim.keymap.set({ "n", "x", "o" }, "üz", function() move.goto_next_start("@fold", "folds") end,
                { desc = "Next fold start" })

            vim.keymap.set({ "n", "x", "o" }, "üM", function() move.goto_next_end("@function.outer", "textobjects") end,
                { desc = "Next function end" })
            vim.keymap.set({ "n", "x", "o" }, "äc", function() move.goto_next_end("@class.outer", "textobjects") end,
                { desc = "Next class end" })

            vim.keymap.set({ "n", "x", "o" }, "öm", function() move.goto_previous_start("@function.outer", "textobjects") end,
                { desc = "Previous function start" })
            vim.keymap.set({ "n", "x", "o" }, "öö", function() move.goto_previous_start("@class.outer", "textobjects") end,
                { desc = "Previous class start" })

            vim.keymap.set({ "n", "x", "o" }, "öM", function() move.goto_previous_end("@function.outer", "textobjects") end,
                { desc = "Previous function end" })
            vim.keymap.set({ "n", "x", "o" }, "öc", function() move.goto_previous_end("@class.outer", "textobjects") end,
                { desc = "Previous class end" })

            -- CONDITIONAL --
            vim.keymap.set({ "n", "x", "o" }, "üd", function() move.goto_next("@conditional.outer", "textobjects") end,
                { desc = "Next conditional" })
            vim.keymap.set({ "n", "x", "o" }, "öd", function() move.goto_previous("@conditional.outer", "textobjects") end,
                { desc = "Previous conditional" })

            -- Repeat move with ; and ,
            vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next,
                { expr = true, desc = "Repeat last move forward" })
            vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous,
                { expr = true, desc = "Repeat last move backward" })

            -- Make f/F/t/T repeatable
            vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr,
                { expr = true, desc = "Find next char (repeatable)" })
            vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr,
                { expr = true, desc = "Find previous char (repeatable)" })
            vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr,
                { expr = true, desc = "Till next char (repeatable)" })
            vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr,
                { expr = true, desc = "Till previous char (repeatable)" })
        end,
    }
}
