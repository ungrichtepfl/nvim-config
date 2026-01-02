return {
  -- Show RGB and hex colors
  "norcalli/nvim-colorizer.lua",
  event = "VeryLazy",

  -- NOTE: Does not work with empty opts dict so config is used:
  config = function() require("colorizer").setup() end,
}
