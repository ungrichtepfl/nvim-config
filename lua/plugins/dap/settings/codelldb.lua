return {
  adapter = {
    type = "executable",
    command = "codelldb", -- or if not in $PATH: "/absolute/path/to/codelldb"

    -- On windows you may have to uncomment this:
    -- detached = false,
  },
  configurations = {
    {
      name = "Launch file",
      type = "codelldb",
      request = "launch",
      program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  },
}
