-- vim.cmd "colorscheme default"

-- local colorscheme = "darcula-solid"
-- local colorscheme = "tokyonight"
-- local colorscheme = "darcula"
-- local colorscheme = "nightfox"
-- local colorscheme = "moonfly"
-- local colorscheme = "terafox"
-- local colorscheme = "rosebones"
-- local colorscheme = "kanagawa"
local colorscheme = "kanso"

local status_ok_color_plug, color_plug = pcall(require, colorscheme)
if status_ok_color_plug then
  if colorscheme == "tokyonight" then
    color_plug.setup {
      style = "night",
    }

  elseif colorscheme == "kanso" then
    color_plug.setup{
      compile = true
    }
    colorscheme = colorscheme .. "-zen"
    -- colorscheme = colorscheme .. "-ink"
  elseif colorscheme == "kanagawa" then
    color_plug.setup {
      compile = true,
      theme = "dragon",
      background = "",
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },

          -- Save an hlgroup with dark background and dimmed foreground
          -- so that you can use it where your still want darker windows.
          -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
          NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

          -- Popular plugins that open floats will link to NormalFloat by default;
          -- set their background accordingly if you wish to keep them dark and borderless
          LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

          Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
          PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
        }
      end,
    }
  end
end

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)

if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found")
  return
end
