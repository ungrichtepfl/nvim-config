return {
  "nvim-neotest/neotest",
  cmd = "Neotest",
  keys = {
    {
      "<leader>tt",
      function() require("neotest").run.run() end,
      desc = "Run nearest test.",
    },
    {
      "<leader>td",
      function() require("neotest").run.run { strategy = "dap" } end,
      desc = "Debug nearest test.",
    },
    {
      "<leader>tf",
      function() require("neotest").run.run(vim.fn.expand "%") end,
      desc = "Test file",
    },
    {
      "<leader>tw",
      function() require("neotest").watch.toggle(vim.fn.expand "%") end,
      desc = "Toggle watching file (reruns tests when file changed)",
    },
    {
      "<leader>ts",
      function() require("neotest").summary.toggle() end,
      desc = "Toggle test summary",
    },
    {
      "<leader>tp",
      function() require("neotest").output_panel.toggle() end,
      desc = "Toggle test ouput panel",
    },
    {
      "<leader>to",
      function() require("neotest").output.open { enter = true } end,
      desc = "Toggle test ouput",
    },
  },
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Adapters
    "mrcjkb/rustaceanvim",
    "nvim-neotest/neotest-python",
    {
      "fredrikaverpil/neotest-golang",
      version = "*",
    },
    "mrcjkb/neotest-haskell",
    "lawrence-laz/neotest-zig",
    "nsidorenco/neotest-vstest", -- dotnet
    "orjangj/neotest-ctest",
    "alfaix/neotest-gtest",
  },
  opts = function()
    return {
      adapters = {
        require "rustaceanvim.neotest",
        require "neotest-python",
        require "neotest-golang",
        require "neotest-haskell",
        require "neotest-zig" {
          dap = { adapter = "codelldb" },
        },
        require "neotest-vstest",
        require("neotest-ctest").setup {},
        require("neotest-gtest").setup {},
      },
    }
  end,
  init = function()
    local neotest_ns = vim.api.nvim_create_namespace "neotest"
    vim.diagnostic.config({
      virtual_text = {
        format = function(diagnostic)
          -- Convert newlines, tabs and whitespaces into a single whitespace
          -- for improved virtual text readability
          local message = diagnostic.message:gsub("[\r\n\t%s]+", " ")
          return message
        end,
      },
    }, neotest_ns)
  end,
}
