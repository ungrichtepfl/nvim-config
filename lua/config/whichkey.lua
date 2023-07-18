local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  vim.notify "'which-key' plugin not found."
  return
end

local setup = {
  plugins = {
    spelling = {
      enabled = true,
    },
  },
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },
  window = {
    border = "rounded", -- none, single, double, shadow
  },
  ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
}

local opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
  ["/"] = { '<cmd>lua require("Comment.api").toggle_current_linewise()<CR>', "Comment" },
  ["a"] = { "<cmd>Alpha<cr>", "Alpha" },
  ["b"] = {
    "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>",
    "Buffers",
  },
  ["e"] = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
  ["w"] = { "<cmd>w!<CR>", "Save File" },
  ["W"] = { "<cmd>wq<CR>", "Save File and Quit Window" },
  ["c"] = { "<cmd>q<CR>", "Quit Window" },
  ["C"] = { "<cmd>q!<CR>", "Quit Window Forced" },
  ["q"] = { "<cmd>Bdelete<CR>", "Close Buffer" },
  ["Q"] = { "<cmd>Bdelete!<CR>", "Close Buffer Forced" },
  ["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
  ["f"] = {
    "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
    "Find Files",
  },
  ["if"] = {
    "<cmd>lua require'telescope.builtin'.find_files({hidden=true, no_ignore=true, no_ignore_parent=true})<cr>",
    "Find Ignored Files",
  },
  ["r"] = {
    "<cmd>lua require'telescope.builtin'.live_grep(require('telescope.themes').get_dropdown())<cr>",
    "Find Text",
  },
  ["ir"] = {
    "<cmd>lua require'telescope.builtin'.live_grep({vimgrep_arguments = {'rg','--color=never', '--no-heading', '--with-filename','--line-number','--column','--smart-case','-u'}})<cr>",
    "Find Ignored Text",
  },
  ["P"] = { "<cmd>Telescope projects<cr>", "Projects" },
  ["N"] = { "<cmd>NoNeckPain<cr>", "Center window" },

  p = {
    name = "Packer",
    c = { "<cmd>PackerCompile<cr>", "Compile" },
    i = { "<cmd>PackerInstall<cr>", "Install" },
    s = { "<cmd>PackerSync<cr>", "Sync" },
    S = { "<cmd>PackerStatus<cr>", "Status" },
    u = { "<cmd>PackerUpdate<cr>", "Update" },
  },

  d = {
    name = "DAP",
    d = { ":lua require'dapui'.toggle()<CR>", "Toggle" },
    c = { ":lua require'dap'.continue()<CR>", "Continue" },
    t = { ":lua require'dap'.terminate()<CR>", "Terminate" },
    o = { ":lua require'dap'.step_over()<CR>", "Step Over" },
    i = { ":lua require'dap'.step_into()<CR>", "Step Into" },
    u = { ":lua require'dap'.step_out()<CR>", "Step Out" },
    b = { ":lua require'dap'.toggle_breakpoint()<CR>", "Toggle Breakpoint" },
    B = {
      ":lua require'dap'.toggle_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
      "Toggle Conditional Breakpoint",
    },
    p = {
      ":lua require'dap'.toggle_breakpoint(nil,nil,vim.fn.input('Log point message: '))<CR>",
      "Toggle Log? Breakpoint",
    },
    r = { ":lua require'dap'.repl.open()<CR>", "Open REPL" },
    v = { ":lua require'dapui'.eval()<CR>", "Eval" },
    P = {
      name = "Python debugging",
      t = { ":lua require('dap-python').test_method()<CR>", "Test method" },
    },
  },

  g = {
    name = "Git",
    g = { "<cmd>lua _LAZYGIT_TOGGLE()<CR>", "Lazygit" },
    j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
    k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
    l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
    L = { "<cmd>lua require 'gitsigns'.blame_line{full=true}<cr>", "Blame with changes" },
    p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
    r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
    R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
    s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
    S = { "<cmd>lua require 'gitsigns'.stage_buffer()<cr>", "Stage Buffer" },
    u = {
      "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
      "Undo Stage Hunk",
    },
    d = {
      "<cmd>lua require 'gitsigns'.diffthis()<cr>",
      "Diff with HEAD",
    },
    D = {
      "<cmd>lua require 'gitsigns'.toggle_deleted()<cr>",
      "Toggle Deleted",
    },
    o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
    b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
    m = { "<cmd>GitConflictListQf<cr>", "List merge conflicts" },
  },

  l = {
    name = "LSP",
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
    m = { "<cmd>CodeActionMenu<cr>", "Show Code Action Menu" },
    d = {
      "<cmd>Telescope diagnostics<cr>",
      "Document Diagnostics",
    },
    f = { "<cmd>lua vim.lsp.buf.format{async = true}<cr>", "Format" },
    i = { "<cmd>LspInfo<cr>", "Info" },
    I = { "<cmd>Mason<cr>", "Installer Info" },
    j = {
      "<cmd>lua vim.diagnostic.goto_next()<CR>",
      "Next Diagnostic",
    },
    k = {
      "<cmd>lua vim.diagnostic.goto_prev()<cr>",
      "Prev Diagnostic",
    },
    q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
    l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
    r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
    s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
    w = {
      "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
      "Workspace Symbols",
    },
    H = {
      name = "Haskell",
      s = { ":lua require'haskell-tools'.hoogle.hoogle_signature()<cr>", "Hoogle signatures" },
    },
    R = {
      name = "Rust",
      k = {
        ':lua require"rust-tools".hover_actions.hover_actions()<cr> :lua require"rust-tools".hover_actions.hover_actions()<cr>',
        "Hover actions",
      },
      a = { ':lua require"rust-tools".code_action_group.code_action_group()<cr>', "Code actions" },
    },
  },
  s = {
    name = "Search",
    b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
    h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
    M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
    R = { "<cmd>Telescope registers<cr>", "Registers" },
    k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
    C = { "<cmd>Telescope commands<cr>", "Commands" },
  },

  t = {
    name = "Terminal",
    n = { "<cmd>lua _NODE_TOGGLE()<cr>", "Node" },
    u = { "<cmd>lua _NCDU_TOGGLE()<cr>", "NCDU" },
    o = { "<cmd>lua _HTOP_TOGGLE()<cr>", "Htop" },
    p = { "<cmd>lua _PYTHON_TOGGLE()<cr>", "Python" },
    f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
    h = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", "Horizontal" },
    v = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", "Vertical" },
    t = { "<cmd>ToggleTerm direction=tab<cr>", "Tab" },
  },

  x = {
    name = "Trouble",
    x = { "<cmd>TroubleToggle<cr>", "Toggle" },
    w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics" },
    d = { "<cmd>TroubleToggle document_diagnostics<cr>", "Document Diagnostics" },
    l = { "<cmd>TroubleToggle loclist<cr>", "Location List" },
    q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix" },
    r = { "<cmd>TroubleToggle lsp_references<cr>", "Lsp References" },
    t = { "<cmd>TodoTrouble<cr>", "Todos" },
  },

  n = {
    name = "Neogen",
    f = { "<cmd>Neogen func<cr>", "Function Docstring" },
    c = { "<cmd>Neogen class<cr>", "Class Docstring" },
    t = { "<cmd>Neogen type<cr>", "Type Docstring" },
    F = { "<cmd>Neogen file<cr>", "File Docstring" },
  },

  m = {
    name = "Markdown",
    p = { [[<Plug>MarkdownPreviewToggle]], "preview markdown" },
  },

  R = {
    name = "Refactoring",
    b = { "<cmd>lua require('refactoring').refactor('Extract Block')<CR>", "Extract block" },
    bf = { "<cmd>lua require('refactoring').refactor('Extract Block To File')<CR>", "Extract block to file" },
    -- Inline variable can also pick up the identifier currently under the cursor without visual mode
    i = { "<cmd>lua require('refactoring').refactor('Inline Variable')<CR>", "Inline variable" },
    -- Debug operations:
    p = { "<cmd>lua require('refactoring').debug.printf({below = true})<CR>", "Printf to mark a function." },
    a = { "<cmd>lua require('refactoring').debug.print_var({ normal = { true }})<CR>", "Print variable" },
    c = { "<cmd>lua require('refactoring').debug.cleanup({})<CR>", "Cleanup print statements" },
  },
  v = {
    name = "VSCode Tasks",
    t = { "<cmd>lua require('telescope').extensions.vstask.tasks()<CR>", "Tasks" },
    i = { "<cmd>lua require('telescope').extensions.vstask.inputs()<CR>", "Inputs" },
    h = { "<cmd>lua require('telescope').extensions.vstask.history()<CR>", "History" },
    l = { "<cmd>lua require('telescope').extensions.vstask.launch()<cr>", "Launch" },
  },
}

local vopts = {
  mode = "v", -- VISUAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local vmappings = {
  ["/"] = { '<ESC><CMD>lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>', "Comment" },
  R = {
    name = "Refactoring",
    f = { "<Esc><cmd>lua require('refactoring').refactor('Extract Function')<cr>", "Extract function" },
    F = { "<Esc><cmd>lua require('refactoring').refactor('Extract Function To File')<cr>", "Extract function to file" },
    v = { "<Esc><cmd>lua require('refactoring').refactor('Extract Variable')<cr>", "Extract variable" },
    i = { "<Esc><cmd>lua require('refactoring').refactor('Inline Variable')<cr>", "Inline variable" },
    r = { "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>", "Telescoper refefactor " },
    -- Debug operations:
    a = { "<cmd>lua require('refactoring').debug.print_var({})<CR>", "Print selection" },
  },
}

which_key.setup(setup)
which_key.register(mappings, opts)
which_key.register(vmappings, vopts)
