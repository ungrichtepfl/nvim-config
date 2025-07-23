return {
  {
    "mg979/vim-visual-multi",
    init = function()
      vim.g.VM_mouse_mappings = 1
      vim.cmd [[
        let g:VM_maps = {}
        let g:VM_maps['Find Under']         = '<C-m>'  " replace C-n
        let g:VM_maps['Find Subword Under'] = '<C-m>'  " replace visual C-n
      ]]
    end,
  },
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    enabled = false, -- FIXME: There is a problem with blink.pairs
    opts = {},
    config = function(_, opts)
      local mc = require "multicursor-nvim"
      mc.setup(opts)

      local set = vim.keymap.set

      -- Add or skip cursor above/below the main cursor.
      set({ "n", "x" }, "<up>", function() mc.lineAddCursor(-1) end, { desc = "Set a new cursor" })
      set({ "n", "x" }, "<down>", function() mc.lineAddCursor(1) end, { desc = "Set a new cursor" })
      set({ "n", "x" }, "<C-up>", function() mc.lineSkipCursor(-1) end, { desc = "Skip a new cursor" })
      set({ "n", "x" }, "<C-down>", function() mc.lineSkipCursor(1) end, { desc = "Skip a new cursor" })

      -- Add and remove cursors with control + left click.
      set("n", "<c-leftmouse>", mc.handleMouse, { desc = "Set a new cursor" })
      set("n", "<c-leftdrag>", mc.handleMouseDrag, { desc = "Set a new cursor" })
      set("n", "<c-leftrelease>", mc.handleMouseRelease, { desc = "Set a new cursor" })

      -- Add or skip adding a new cursor by matching word/selection
      set({ "n", "x" }, "<c-n>", function() mc.matchAddCursor(1) end, { desc = "Set a new cursor on match" })
      set({ "n", "x" }, "<a-n>", function() mc.matchSkipCursor(1) end, { desc = "Skip a new cursor on match" })
      set({ "n", "x" }, "<c-p>", function() mc.matchAddCursor(-1) end, { desc = "Set a new cursor on match" })
      set({ "n", "x" }, "<a-p>", function() mc.matchSkipCursor(-1) end, { desc = "Skip a new cursor on match" })

      -- Disable and enable cursors (mc.enableCursors to enable all cursors again)
      set(
        { "n", "x" },
        "<c-q>",
        mc.toggleCursor,
        { desc = "Disable and enable cursors (hit ESC to enable all cursors again)" }
      )

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<left>", mc.prevCursor, { desc = "Select previous cursor as main one" })
        layerSet({ "n", "x" }, "<right>", mc.nextCursor, { desc = "Select next cursor as main one" })

        -- Delete the main cursor.
        layerSet({ "n", "x" }, "<c-x>", mc.deleteCursor, { desc = "Delete main cursor" })

        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end, { desc = "Enable or disable multi cursors" })
      end)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
  },
}
