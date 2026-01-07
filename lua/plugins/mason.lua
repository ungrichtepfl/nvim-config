local mason_tools_to_install = {
  "checkmake",
  "markdownlint",
  "shellcheck",
  "markdownlint",
  "prettierd",
  "beautysh",
  "codelldb",
  "mypy"
}

return {
  "mason-org/mason.nvim",
  event = "VeryLazy",
  opts = {},
  config = function(_, opts)
    require("mason").setup(opts)

    local mason_registry = require "mason-registry"
    local function install_tool(tool)
      local p = mason_registry.get_package(tool)
      local is_globally_installed = vim.fn.executable(tool) == 1
      if not is_globally_installed and not p:is_installed() then p:install() end
    end

    mason_registry.refresh(function()
      for server, tool in pairs(require "config.lsp.servers") do
        if not tool then tool = server end
        install_tool(tool)
      end
      for _, tool in ipairs(mason_tools_to_install) do
        install_tool(tool)
      end
    end)
  end,
}
