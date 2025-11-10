return {
  "norcalli/nvim-colorizer.lua",
  event = "VeryLazy",

  -- needs config to work when no options are given
  config = function() require("colorizer").setup() end,
}
