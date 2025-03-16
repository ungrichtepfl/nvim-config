return {
  settings = {
    ["rust-analyzer"] = {
      completion = {
        -- addCallArgumentSnippets = false,
        addCallParenthesis = false,
      },
      checkOnSave = {
        allFeatures = true,
        -- FIXME: Somehow this does not work?
        -- overrideCommand = {
        --   "cargo",
        --   "clippy",
        --   "--workspace",
        --   "--message-format=json",
        --   "--all-targets",
        --   "--all-features",
        --   "--",
        --   "-Dclippy::all",
        --   "-Dclippy::pedantic",
        -- },
      },
    },
  },
}
