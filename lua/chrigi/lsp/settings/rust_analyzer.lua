return {
  settings = {
    ["rust-analyzer"] = {
      completion = {
        -- addCallArgumentSnippets = false,
        addCallParenthesis = false,
      },
      checkOnSave = {
        allFeatures = true,
        overrideCommand = {
          "cargo",
          "clippy",
          "--workspace",
          "--message-format=json",
          "--all-targets",
          "--all-features",
        },
      },
    },
  },
}
