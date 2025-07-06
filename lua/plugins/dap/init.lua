return {
  {
    "mfussenegger/nvim-dap",
    init = function()
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

      -- Keymappins:
      vim.keymap.set("n", "<F5>", function() require("dap").continue() end, { desc = "DAP: Start/Continue Debugging" })

      vim.keymap.set("n", "<F10>", function() require("dap").step_over() end, { desc = "DAP: Step Over" })
      vim.keymap.set("n", "<F11>", function() require("dap").step_into() end, { desc = "DAP: Step Into" })
      vim.keymap.set("n", "<F12>", function() require("dap").step_out() end, { desc = "DAP: Step Out" })

      vim.keymap.set(
        "n",
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        { desc = "DAP: Toggle Breakpoint" }
      )
      vim.keymap.set(
        "n",
        "<leader>dB",
        function() require("dap").set_breakpoint() end,
        { desc = "DAP: Set Breakpoint (with condition)" }
      )

      vim.keymap.set(
        "n",
        "<leader>lp",
        function() require("dap").set_breakpoint(nil, nil, vim.fn.input "Log point message: ") end,
        { desc = "DAP: Set Log Point" }
      )

      vim.keymap.set("n", "<leader>dr", function() require("dap").repl.open() end, { desc = "DAP: Open REPL" })
      vim.keymap.set(
        "n",
        "<leader>dl",
        function() require("dap").run_last() end,
        { desc = "DAP: Run Last Debug Session" }
      )

      vim.keymap.set(
        { "n", "v" },
        "<leader>dh",
        function() require("dap.ui.widgets").hover() end,
        { desc = "DAP: Hover (variable value)" }
      )
      vim.keymap.set(
        { "n", "v" },
        "<leader>dp",
        function() require("dap.ui.widgets").preview() end,
        { desc = "DAP: Preview Expression" }
      )

      vim.keymap.set("n", "<leader>df", function()
        local widgets = require "dap.ui.widgets"
        widgets.centered_float(widgets.frames)
      end, { desc = "DAP: Show Call Stack" })

      vim.keymap.set("n", "<leader>ds", function()
        local widgets = require "dap.ui.widgets"
        widgets.centered_float(widgets.scopes)
      end, { desc = "DAP: Show Scopes (Variables)" })
    end,
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "Joakker/lua-json5", build = "./install.sh" },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
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
    init = function()
      local dap, dapui = require "dap", require "dapui"
      -- NOTE: Uncomment to automcatically open:
      -- dap.listeners.before.attach.dapui_config = function() dapui.open() end
      -- dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {},
    dependencies = { "mfussenegger/nvim-dap" },
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function(_, _) -- Does not work with opts as it does not accept a table
      require("dap-python").setup "~/.virtualenvs/debugpy/bin/python"

      -- Keymappings:
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
          vim.keymap.set(
            "n",
            "<leader>dPm",
            ":lua require('dap-python').test_method()<CR>",
            { desc = "Run python test method" }
          )

          vim.keymap.set(
            "n",
            "<leader>dPc",
            ":lua require('dap-python').test_class()<CR>",
            { desc = "Run python test class" }
          )

          vim.keymap.set(
            "v",
            "<leader>dPs",
            "<ESC>:lua require('dap-python').debug_selection()<CR>",
            { desc = "Debug python selection" }
          )
        end,
      })

      -- Additional settings:
      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        module = "flask",
        name = "Flask Dir",
        args = {
          --[[ "--debug", ]]
          "run",
          "--no-debugger",
          "--host",
          "0.0.0.0",
        },
        env = {
          --[[ FLASK_DEBUG=0, ]]
          FLASK_APP = function() return vim.fn.input("Local flask folder > ", vim.fn.getcwd(), "file") end,
          --[[ FLASK_ENV = "development" ]]
        },
        jinja = true,
        justMyCode = false,
      })

      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "launch",
        module = "flask",
        name = "Flask app.py in current directory",
        args = {
          --[[ "--debug", ]]
          "run",
          "--no-debugger",
          "--host",
          "0.0.0.0",
        },
        env = {
          --[[ FLASK_DEBUG=0, ]]
          FLASK_APP = "app.py",
          --[[ FLASK_ENV = "development" ]]
        },
        jinja = true,
        justMyCode = false,
      })

      table.insert(require("dap").configurations.python, {
        type = "python",
        request = "attach localhost port 5678",
        connect = {
          port = 5678,
          host = "127.0.0.1",
        },
        mode = "remote",
        name = "Container Attach Debug",
        cwd = vim.fn.getcwd(),
        pathMappings = {
          {
            localRoot = function()
              return vim.fn.input("Local code folder > ", vim.fn.getcwd(), "file")
              --"/home/alpha2phi/workspace/alpha2phi/python-apps/ml-yolo/backend", -- Local folder the code lives
            end,
            remoteRoot = function()
              return vim.fn.input("Container code folder > ", "/", "file")
              -- "/fastapi", -- Wherever your Python code lives in the container.
            end,
          },
        },
      })
    end,
  },
}
