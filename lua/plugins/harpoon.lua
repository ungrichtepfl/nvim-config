return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {},
    enabled = true, -- Enable if you uncommented config.harpoon
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>a", function() require("harpoon"):list():add() end, desc = "Add buffer to harpoon list" },
      {
        "<C-e>",
        function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end,
        desc = "Show harpoon list",
      },

      { "<A-h>", function() require("harpoon"):list():select(1) end, desc = "Select first harpoon buffer" },
      { "<A-j>", function() require("harpoon"):list():select(2) end, desc = "Select second harpoon buffer" },
      { "<A-k>", function() require("harpoon"):list():select(3) end, desc = "Select third harpoon buffer" },
      { "<A-l>", function() require("harpoon"):list():select(4) end, desc = "Select forth harpoon buffer" },

      { "<A-p>", function() require("harpoon"):list():prev() end, desc = "Next buffer in harpoon list" },
      { "<A-n>", function() require("harpoon"):list():next() end, desc = "Previous buffer in harpoon list" },
    },
  },
}
