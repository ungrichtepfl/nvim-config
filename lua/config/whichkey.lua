local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  vim.notify "'which-key' plugin not found."
  return
end

local mappings = {
  { "<leader><leader>C", "<cmd>q!<CR>", desc = "Quit Window Forced", nowait = true, remap = false },
  { "<leader>N", "<cmd>NoNeckPain<cr>", desc = "Center window", nowait = true, remap = false },
  { "<leader>P", "<cmd>Telescope projects<cr>", desc = "Projects", nowait = true, remap = false },
  { "<leader>Q", "<cmd>Bdelete!<CR>", desc = "Close Buffer Forced", nowait = true, remap = false },
  { "<leader>R", group = "Refactoring", nowait = true, remap = false },
  {
    "<leader>Ra",
    "<cmd>lua require('refactoring').debug.print_var({ normal = { true }})<CR>",
    desc = "Print variable",
    nowait = true,
    remap = false,
  },
  {
    "<leader>Rb",
    "<cmd>lua require('refactoring').refactor('Extract Block')<CR>",
    desc = "Extract block",
    nowait = true,
    remap = false,
  },
  {
    "<leader>Rbf",
    "<cmd>lua require('refactoring').refactor('Extract Block To File')<CR>",
    desc = "Extract block to file",
    nowait = true,
    remap = false,
  },
  {
    "<leader>Rc",
    "<cmd>lua require('refactoring').debug.cleanup({})<CR>",
    desc = "Cleanup print statements",
    nowait = true,
    remap = false,
  },
  {
    "<leader>Ri",
    "<cmd>lua require('refactoring').refactor('Inline Variable')<CR>",
    desc = "Inline variable",
    nowait = true,
    remap = false,
  },
  {
    "<leader>Rp",
    "<cmd>lua require('refactoring').debug.printf({below = true})<CR>",
    desc = "Printf to mark a function.",
    nowait = true,
    remap = false,
  },
  { "<leader>W", "<cmd>wq<CR>", desc = "Save File and Quit Window", nowait = true, remap = false },
  {
    "<leader>b",
    "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>",
    desc = "Buffers",
    nowait = true,
    remap = false,
  },
  { "<leader><leader>", "<cmd>q<CR>", desc = "Quit Window", nowait = true, remap = false },
  { "<leader>d", group = "DAP", nowait = true, remap = false },
  {
    "<leader>dB",
    ":lua require'dap'.toggle_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
    desc = "Toggle Conditional Breakpoint",
    nowait = true,
    remap = false,
  },
  { "<leader>dP", group = "Python debugging", nowait = true, remap = false },
  { "<leader>dPt", ":lua require('dap-python').test_method()<CR>", desc = "Test method", nowait = true, remap = false },
  {
    "<leader>db",
    ":lua require'dap'.toggle_breakpoint()<CR>",
    desc = "Toggle Breakpoint",
    nowait = true,
    remap = false,
  },
  { "<leader>dc", ":lua require'dap'.continue()<CR>", desc = "Continue", nowait = true, remap = false },
  { "<leader>dd", ":lua require'dapui'.toggle()<CR>", desc = "Toggle", nowait = true, remap = false },
  { "<leader>di", ":lua require'dap'.step_into()<CR>", desc = "Step Into", nowait = true, remap = false },
  { "<leader>do", ":lua require'dap'.step_over()<CR>", desc = "Step Over", nowait = true, remap = false },
  {
    "<leader>dp",
    ":lua require'dap'.toggle_breakpoint(nil,nil,vim.fn.input('Log point message: '))<CR>",
    desc = "Toggle Log? Breakpoint",
    nowait = true,
    remap = false,
  },
  { "<leader>dr", ":lua require'dap'.repl.open()<CR>", desc = "Open REPL", nowait = true, remap = false },
  { "<leader>dt", ":lua require'dap'.terminate()<CR>", desc = "Terminate", nowait = true, remap = false },
  { "<leader>du", ":lua require'dap'.step_out()<CR>", desc = "Step Out", nowait = true, remap = false },
  { "<leader>dv", ":lua require'dapui'.eval()<CR>", desc = "Eval", nowait = true, remap = false },
  { "<leader>e", "<cmd>Oil<cr>", desc = "Explorer", nowait = true, remap = false },
  {
    "<leader>f",
    "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<cr>",
    desc = "Find Files",
    nowait = true,
    remap = false,
  },
  { "<leader>g", group = "Git", nowait = true, remap = false },
  {
    "<leader>gD",
    "<cmd>lua require 'gitsigns'.toggle_deleted()<cr>",
    desc = "Toggle Deleted",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gL",
    "<cmd>lua require 'gitsigns'.blame_line{full=true}<cr>",
    desc = "Blame with changes",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gR",
    "<cmd>lua require 'gitsigns'.reset_buffer()<cr>",
    desc = "Reset Buffer",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gS",
    "<cmd>lua require 'gitsigns'.stage_buffer()<cr>",
    desc = "Stage Buffer",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gb",
    "<cmd>Telescope git_branches<cr>",
    desc = "Checkout branch",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gc",
    "<cmd>Telescope git_commits<cr>",
    desc = "Checkout commit",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gd",
    "<cmd>DiffviewOpen<cr>",
    desc = "Diff with HEAD",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gdd",
    "<cmd>DiffviewClose<cr>",
    desc = "Close diff with HEAD",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gg",
    "<cmd>lua _LAZYGIT_TOGGLE()<CR>",
    desc = "Lazygit",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gj",
    "<cmd>lua require 'gitsigns'.next_hunk()<cr>",
    desc = "Next Hunk",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gk",
    "<cmd>lua require 'gitsigns'.prev_hunk()<cr>",
    desc = "Prev Hunk",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gl",
    "<cmd>lua require 'gitsigns'.blame_line()<cr>",
    desc = "Blame",
    nowait = true,
    remap = false,
  },
  {
    "<leader>go",
    "<cmd>Telescope git_status<cr>",
    desc = "Open changed file",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gp",
    "<cmd>lua require 'gitsigns'.preview_hunk()<cr>",
    desc = "Preview Hunk",
    nowait = true,
    remap = false,
  },
  { "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = "Reset Hunk", nowait = true, remap = false },
  { "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = "Stage Hunk", nowait = true, remap = false },
  {
    "<leader>gu",
    "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
    desc = "Undo Stage Hunk",
    nowait = true,
    remap = false,
  },
  { "<leader>h", "<cmd>nohlsearch<CR>", desc = "No Highlight", nowait = true, remap = false },
  {
    "<leader>if",
    "<cmd>lua require'telescope.builtin'.find_files({hidden=true, no_ignore=true, no_ignore_parent=true})<cr>",
    desc = "Find Ignored Files",
    nowait = true,
    remap = false,
  },
  {
    "<leader>ir",
    "<cmd>lua require'telescope.builtin'.live_grep({vimgrep_arguments = {'rg','--color=never', '--no-heading', '--with-filename','--line-number','--column','--smart-case','-u'}})<cr>",
    desc = "Find Ignored Text",
    nowait = true,
    remap = false,
  },
  { "<leader>l", group = "LSP", nowait = true, remap = false },
  { "<leader>lH", group = "Haskell", nowait = true, remap = false },
  {
    "<leader>lHs",
    ":lua require'haskell-tools'.hoogle.hoogle_signature()<cr>",
    desc = "Hoogle signatures",
    nowait = true,
    remap = false,
  },
  {
    "<leader>lI",
    "<cmd>Mason<cr>",
    desc = "Installer Info",
    nowait = true,
    remap = false,
  },
  {
    "<leader>la",
    "<cmd>lua require('actions-preview').code_actions()<cr>",
    desc = "Code Action",
    nowait = true,
    remap = false,
  },
  {
    "<leader>ld",
    "<cmd>Telescope diagnostics<cr>",
    desc = "Project Diagnostics",
    nowait = true,
    remap = false,
  },
  {
    "<leader>lf",
    "<cmd>lua vim.lsp.buf.format{async = true}<cr> <bar> <cmd>Format<cr>",
    desc = "Format",
    nowait = true,
    remap = false,
  },
  {
    "<leader>li",
    "<cmd>LspInfo<cr>",
    desc = "Info",
    nowait = true,
    remap = false,
  },
  {
    "<leader>lj",
    "<cmd>lua vim.diagnostic.goto_next()<CR>",
    desc = "Next Diagnostic",
    nowait = true,
    remap = false,
  },
  {
    "<leader>lk",
    "<cmd>lua vim.diagnostic.goto_prev()<cr>",
    desc = "Prev Diagnostic",
    nowait = true,
    remap = false,
  },
  {
    "<leader>ll",
    "<cmd>lua vim.lsp.codelens.run()<cr>",
    desc = "CodeLens Action",
    nowait = true,
    remap = false,
  },
  {
    "<leader>lq",
    "<cmd>lua vim.diagnostic.setqflist()<cr>",
    desc = "Diagnostic Quickfix",
    nowait = true,
    remap = false,
  },
  {
    "<leader>lr",
    "<cmd>lua vim.lsp.buf.rename()<cr>",
    desc = "Rename",
    nowait = true,
    remap = false,
  },
  {
    "<leader>ls",
    "<cmd>Telescope lsp_document_symbols<cr>",
    desc = "Document Symbols",
    nowait = true,
    remap = false,
  },
  {
    "<leader>lw",
    "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
    desc = "Workspace Symbols",
    nowait = true,
    remap = false,
  },
  { "<leader>m", group = "Markdown", nowait = true, remap = false },
  { "<leader>mp", "<Plug>MarkdownPreviewToggle", desc = "preview markdown", nowait = true, remap = false },
  { "<leader>n", group = "Neogen", nowait = true, remap = false },
  { "<leader>nF", "<cmd>Neogen file<cr>", desc = "File Docstring", nowait = true, remap = false },
  { "<leader>nc", "<cmd>Neogen class<cr>", desc = "Class Docstring", nowait = true, remap = false },
  { "<leader>nf", "<cmd>Neogen func<cr>", desc = "Function Docstring", nowait = true, remap = false },
  { "<leader>nt", "<cmd>Neogen type<cr>", desc = "Type Docstring", nowait = true, remap = false },
  { "<leader>p", "<cmd>Copilot enable<cr>", desc = "Copilot enable", nowait = true, remap = false },
  { "<leader>pp", "<cmd>Copilot disable<cr>", desc = "Copilot disable", nowait = true, remap = false },
  { "<leader>pr", "<cmd>Copilot restart<cr>", desc = "Copilot restart", nowait = true, remap = false },
  { "<leader>ps", "<cmd>Copilot status<cr>", desc = "Copilot status", nowait = true, remap = false },
  { "<leader>q", "<cmd>Bdelete<CR>", desc = "Close Buffer", nowait = true, remap = false },
  {
    "<leader>r",
    "<cmd>lua require'telescope.builtin'.live_grep(require('telescope.themes').get_dropdown())<cr>",
    desc = "Find Text",
    nowait = true,
    remap = false,
  },
  { "<leader>s", group = "Search", nowait = true, remap = false },
  { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands", nowait = true, remap = false },
  { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages", nowait = true, remap = false },
  { "<leader>sR", "<cmd>Telescope registers<cr>", desc = "Registers", nowait = true, remap = false },
  { "<leader>sb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch", nowait = true, remap = false },
  { "<leader>sc", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme", nowait = true, remap = false },
  { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Find Help", nowait = true, remap = false },
  { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps", nowait = true, remap = false },
  { "<leader>sr", "<cmd>Telescope oldfiles<cr>", desc = "Open Recent File", nowait = true, remap = false },
  { "<leader>t", group = "Terminal", nowait = true, remap = false },
  { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float", nowait = true, remap = false },
  {
    "<leader>th",
    "<cmd>ToggleTerm size=10 direction=horizontal<cr>",
    desc = "Horizontal",
    nowait = true,
    remap = false,
  },
  { "<leader>tn", "<cmd>lua _NODE_TOGGLE()<cr>", desc = "Node", nowait = true, remap = false },
  { "<leader>to", "<cmd>lua _HTOP_TOGGLE()<cr>", desc = "Htop", nowait = true, remap = false },
  { "<leader>tp", "<cmd>lua _PYTHON_TOGGLE()<cr>", desc = "Python", nowait = true, remap = false },
  { "<leader>tt", "<cmd>ToggleTerm direction=tab<cr>", desc = "Tab", nowait = true, remap = false },
  { "<leader>tu", "<cmd>lua _NCDU_TOGGLE()<cr>", desc = "NCDU", nowait = true, remap = false },
  { "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "Vertical", nowait = true, remap = false },
  { "<leader>v", group = "VSCode Tasks", nowait = true, remap = false },
  {
    "<leader>vh",
    "<cmd>lua require('telescope').extensions.vstask.history()<CR>",
    desc = "History",
    nowait = true,
    remap = false,
  },
  {
    "<leader>vi",
    "<cmd>lua require('telescope').extensions.vstask.inputs()<CR>",
    desc = "Inputs",
    nowait = true,
    remap = false,
  },
  {
    "<leader>vl",
    "<cmd>lua require('telescope').extensions.vstask.launch()<cr>",
    desc = "Launch",
    nowait = true,
    remap = false,
  },
  {
    "<leader>vt",
    "<cmd>lua require('telescope').extensions.vstask.tasks()<CR>",
    desc = "Tasks",
    nowait = true,
    remap = false,
  },
  { "<leader>w", "<cmd>w!<CR>", desc = "Save File", nowait = true, remap = false },
  { "<leader>x", group = "Trouble", nowait = true, remap = false },
  { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List", nowait = true, remap = false },
  { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix", nowait = true, remap = false },
  {
    "<leader>xr",
    "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
    desc = "Lsp References",
    nowait = true,
    remap = false,
  },
  { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todos", nowait = true, remap = false },
  { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle", nowait = true, remap = false },
  {
    "<leader>xX",
    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    desc = "Buffer Diagnostics (Trouble)",
    nowait = true,
    remap = false,
  },
}

local vmappings = {
  {
    mode = { "v" },
    { "<leader>R", group = "Refactoring", nowait = true, remap = false },
    {
      "<leader>RF",
      "<Esc><cmd>lua require('refactoring').refactor('Extract Function To File')<cr>",
      desc = "Extract function to file",
      nowait = true,
      remap = false,
    },
    {
      "<leader>Ra",
      "<cmd>lua require('refactoring').debug.print_var({})<CR>",
      desc = "Print selection",
      nowait = true,
      remap = false,
    },
    {
      "<leader>Rf",
      "<Esc><cmd>lua require('refactoring').refactor('Extract Function')<cr>",
      desc = "Extract function",
      nowait = true,
      remap = false,
    },
    {
      "<leader>Ri",
      "<Esc><cmd>lua require('refactoring').refactor('Inline Variable')<cr>",
      desc = "Inline variable",
      nowait = true,
      remap = false,
    },
    {
      "<leader>Rr",
      "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
      desc = "Telescoper refactor",
      nowait = true,
      remap = false,
    },
    {
      "<leader>Rv",
      "<Esc><cmd>lua require('refactoring').refactor('Extract Variable')<cr>",
      desc = "Extract variable",
      nowait = true,
      remap = false,
    },
  },
}

which_key.add(mappings)
which_key.add(vmappings)
