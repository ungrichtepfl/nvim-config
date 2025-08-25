return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP: Start/Continue Debugging" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP: Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP: Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP: Step Out" },
    },
    config = function()
      -- NOTE: Checkout https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
      -- on how to setup different adapters

      -- Support JSON 5:
      require("dap.ext.vscode").json_decode = require("json5").parse
      -- Repl autocompletion:
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "dap-repl" },
        callback = function(_) require("dap.ext.autocompl").attach() end,
      })

      -- Signs:
      vim.fn.sign_define("DapBreakpoint", {
        text = "●",
        texthl = "DiagnosticError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointCondition", {
        text = "◆",
        texthl = "DiagnosticWarn",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "",
        texthl = "DiagnosticHint",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapLogPoint", {
        text = "▶",
        texthl = "DiagnosticInfo",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapStopped", {
        text = "➜", -- or  or ▶
        texthl = "DiagnosticOk",
        linehl = "Visual",
        numhl = "",
      })

      -- Configurations
      local adapters = { "python", { "codelldb", { "c", "rust", "cpp" } }, "haskell" }
      local dap = require "dap"
      for _, item in ipairs(adapters) do
        local adapter = item
        if type(item) == "table" then adapter = item[1] end

        local setting = require("plugins.dap.settings." .. adapter)
        if setting.adapter then dap.adapters[adapter] = setting.adapter end
        if setting.configurations then
          local fts = { adapter }
          if type(item) == "table" then fts = item[2] end
          for _, ft in ipairs(fts) do
            dap.configurations[ft] = dap.configurations[ft] or {}
            for _, config in ipairs(setting.configurations) do
              table.insert(dap.configurations[ft], config)
            end
          end
        end
      end
    end,
    dependencies = {
      { "Joakker/lua-json5", build = "./install.sh" },
      {
        "theHamsta/nvim-dap-virtual-text", -- Only load when dap is loaded
        opts = {},
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    enabled = false, -- NOTE: Used debugmaster, enable here and disable below
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").open()
          require("dap").continue()
        end,
        desc = "Open dap-ui and start debugging",
      },
      {
        "<leader>dd",
        function() require("dapui").toggle() end,
        desc = "Toggle dap-ui",
      },
    },
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.33 },
            { id = "breakpoints", size = 0.17 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 0.33,
          position = "right",
        },
        {
          elements = {
            { id = "repl", size = 0.45 },
            { id = "console", size = 0.55 },
          },
          size = 0.27,
          position = "bottom",
        },
      },
      floating = {
        max_height = 0.9,
        max_width = 0.5, -- Floats will be treated as percentage of your screen.
        border = vim.g.border_chars, -- Border style. Can be 'single', 'double' or 'rounded'
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
    },
    config = function(_, opts)
      local dap, dapui = require "dap", require "dapui"
      dapui.setup(opts)
      -- NOTE: Uncomment to automcatically open:
      -- dap.listeners.before.attach.dapui_config = function() dapui.open() end
      -- dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end,
  },
  {
    "miroshQa/debugmaster.nvim",
    dependencies = { "mfussenegger/nvim-dap" },
    enabled = true,
    keys = {
      {
        "<leader>d",
        function() require("debugmaster").mode.toggle() end,
        mode = { "n", "v" },
        desc = "Start debug mode",
        nowait = true,
      },
    },
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    keys = {
      {
        "<leader>dPm",
        function() require("dap-python").test_method() end,
        ft = "python",
        desc = "Run python test method",
      },
      {
        "<leader>dPc",
        function() require("dap-python").test_class() end,
        ft = "python",
        desc = "Run python test class",
      },
      {
        "<leader>dPs",
        function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
          require("dap-python").debug_selection()
        end,
        mode = "v",
        ft = "python",
        desc = "Debug python selection",
      },
    },
    config = function(_, _) -- Does not work with opts as it does not accept a table
      require("dap-python").setup "~/.virtualenvs/debugpy/bin/python"
      -- Additional settings:
    end,
  },
}
