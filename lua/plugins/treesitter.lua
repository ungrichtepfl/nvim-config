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
            keys = {
                -- SELECTION
                { "af", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects") end, mode = { "x", "o" }, desc = "Select around function" },
                { "if", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects") end, mode = { "x", "o" }, desc = "Select inside function" },
                { "ac", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects") end, mode = { "x", "o" }, desc = "Select around class" },
                { "ic", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects") end, mode = { "x", "o" }, desc = "Select inside class" },
                { "as", function() require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals") end, mode = { "x", "o" }, desc = "Select scope" },

                -- SWAP
                { "<leader>ap", function() require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner") end, mode = "n", desc = "Swap next parameter" },
                { "<leader>aP", function() require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.outer") end, mode = "n", desc = "Swap previous parameter" },

                -- MOVE (Umlaut-friendly)
                { "üm", function() require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Next function start" },
                { "ää", function() require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Next class start" },
                { "üo", function() require("nvim-treesitter-textobjects.move").goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects") end, mode = { "n", "x", "o" }, desc = "Next loop start" },
                { "üs", function() require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals") end, mode = { "n", "x", "o" }, desc = "Next scope start" },
                { "üz", function() require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds") end, mode = { "n", "x", "o" }, desc = "Next fold start" },
                { "üM", function() require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Next function end" },
                { "äc", function() require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Next class end" },
                { "öm", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Previous function start" },
                { "öö", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Previous class start" },
                { "öM", function() require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Previous function end" },
                { "öc", function() require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Previous class end" },

                -- CONDITIONAL
                { "üd", function() require("nvim-treesitter-textobjects.move").goto_next("@conditional.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Next conditional" },
                { "öd", function() require("nvim-treesitter-textobjects.move").goto_previous("@conditional.outer", "textobjects") end, mode = { "n", "x", "o" }, desc = "Previous conditional" },

                -- REPEATABLE MOVE
                { ";", function() return require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_next() end, expr = true, mode = { "n", "x", "o" }, desc = "Repeat last move forward" },
                { ",", function() return require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_previous() end, expr = true, mode = { "n", "x", "o" }, desc = "Repeat last move backward" },

                -- BUILTIN F/T
                { "f", function() return require("nvim-treesitter-textobjects.repeatable_move").builtin_f_expr() end, expr = true, mode = { "n", "x", "o" }, desc = "Find next char (repeatable)" },
                { "F", function() return require("nvim-treesitter-textobjects.repeatable_move").builtin_F_expr() end, expr = true, mode = { "n", "x", "o" }, desc = "Find previous char (repeatable)" },
                { "t", function() return require("nvim-treesitter-textobjects.repeatable_move").builtin_t_expr() end, expr = true, mode = { "n", "x", "o" }, desc = "Till next char (repeatable)" },
                { "T", function() return require("nvim-treesitter-textobjects.repeatable_move").builtin_T_expr() end, expr = true, mode = { "n", "x", "o" }, desc = "Till previous char (repeatable)" },
            },       
        }
    },
    {"nvim-treesitter/nvim-treesitter-context",
        dependencies = {"nvim-treesitter/nvim-treesitter"},
        opts = {},
    }

}
