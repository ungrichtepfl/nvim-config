return {
  configurations = {
    {
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
    },
    {
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
    },

    {
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
    },
  },
}
