return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {},
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = function()
      local harpoon = require "harpoon"
      return {
        { "<leader>a", function() harpoon:list():add() end, desc = "Add buffer to harpoon list" },
        { "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Show harpoon list" },

        { "<C-h>", function() harpoon:list():select(1) end, desc = "Select first harpoon buffer" },
        { "<C-j>", function() harpoon:list():select(2) end, desc = "Select second harpoon buffer" },
        { "<C-k>", function() harpoon:list():select(3) end, desc = "Select third harpoon buffer" },
        { "<C-l>", function() harpoon:list():select(4) end, desc = "Select forth harpoon buffer" },

        { "<C-S-P>", function() harpoon:list():prev() end, desc = "Next buffer in harpoon list" },
        { "<C-S-N>", function() harpoon:list():next() end, desc = "Previous buffer in harpoon list" },
      }
    end,
  },
}
