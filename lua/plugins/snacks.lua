return {
  "folke/snacks.nvim",
  opts = {
    input = {}, -- Nicer input
    bigfile = {}, -- Do not launch lsp and treesitter on bigfiles
    quickfile = {}, -- Load file as quickly as possible
    dashboard = {
      preset = {
        keys = {
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        {
          section = "recent_files",
          cwd = true,
          align = "center",
        },
        {
          section = "keys",
          align = "center",
          padding = 3,
        },
        { section = "startup" },
      },
    },
  },
  init = function()
    -- Quickfix never reuses the dashboard window (buftype=nofile) and splits instead,
    -- so close the dashboard once a file got opened from quickfix
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = vim.api.nvim_create_augroup("_snacks_dashboard_qf", { clear = true }),
      callback = function()
        if vim.bo.buftype ~= "" or vim.fn.getwinvar(vim.fn.winnr "#", "&buftype") ~= "quickfix" then return end
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "snacks_dashboard" then
            vim.api.nvim_win_close(win, true)
          end
        end
      end,
    })
  end,
}
