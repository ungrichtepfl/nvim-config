local vault_path = vim.fn.expand "~" .. "/Notes"
local KEYMAP_PREFIX = "<leader>z"

---Keymaps that only make sense inside a note, under <localleader>
local function set_note_keymaps(buf)
  local function map(lhs, cmd, desc)
    vim.keymap.set("n", "<localleader>" .. lhs, "<cmd>" .. cmd .. "<cr>", { buffer = buf, desc = desc })
  end
  map("b", "Obsidian backlinks", "Backlinks to this note")
  map("l", "Obsidian links", "Links in this note")
  map("o", "Obsidian toc", "Outline of this note")
  map("v", "Obsidian follow_link vsplit", "Follow link in vertical split")
  map("y", "Obsidian yesterday", "Yesterday's daily note")
  map("t", "Obsidian tomorrow", "Tomorrow's daily note")
  map("r", "Obsidian rename", "Rename note and update links")
  map("p", "Obsidian paste_img", "Paste image from clipboard")
  map("T", "Obsidian template", "Insert template")
  map("m", "RenderMarkdown buf_toggle", "Toggle markdown rendering")
end

---Presentation decks for presenterm, which need their own front matter and stay unrendered
local function is_in_slides_folder(path) return ("/" .. path):find("/Slides/", 1, true) ~= nil end

---Pick a presenterm comment command (<!-- pause -->, ...) and insert it at the cursor
local function insert_presenterm_command()
  if vim.fn.executable "presenterm" == 0 then
    vim.notify("presenterm is not installed", vim.log.levels.ERROR)
    return
  end
  require("fzf-lua").fzf_exec("presenterm --list-comment-commands", { prompt = "presenterm> ", complete = true })
end

local function set_deck_keymaps(buf)
  vim.keymap.set(
    "n",
    "<localleader>c",
    insert_presenterm_command,
    { buffer = buf, desc = "Insert presenterm comment command" }
  )
end

---obsidian.nvim skips its own UI when render-markdown is installed, so render notes with that instead.
---Scheduled because render-markdown attaches to the buffer in its own FileType autocmd.
local function enable_note_rendering(buf)
  if not require("lazy.core.config").plugins["render-markdown.nvim"] then return end
  if is_in_slides_folder(vim.api.nvim_buf_get_name(buf)) then return end
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_call(buf, function() require("render-markdown").buf_enable() end)
    end
  end)
end

local function is_in_vault(path) return vim.startswith(path, vault_path .. "/") end

---Obsidian writes image links relative to the vault root or as the bare file name (![[x.png]])
local function resolve_vault_image_path(document_path, image_path, fallback)
  if is_in_vault(document_path) then
    for _, candidate in ipairs { vault_path .. "/" .. image_path, vault_path .. "/images/" .. image_path } do
      if vim.uv.fs_stat(candidate) then return candidate end
    end
  end
  return fallback(document_path, image_path)
end

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  cmd = { "Obsidian" },
  specs = {
    { "folke/which-key.nvim", opts = { spec = { { KEYMAP_PREFIX, group = "notes" } } } },
    {
      "3rd/image.nvim",
      optional = true,
      opts = { integrations = { markdown = { resolve_image_path = resolve_vault_image_path } } },
    },
    {
      "saghen/blink.cmp",
      optional = true,
      opts = {
        sources = {
          default = { "presenterm" },
          providers = {
            presenterm = {
              name = "presenterm",
              module = "blink-cmp-presenterm",
              enabled = function() return is_in_slides_folder(vim.api.nvim_buf_get_name(0)) end,
            },
          },
        },
      },
    },
  },
  keys = {
    { KEYMAP_PREFIX .. "z", "<cmd>Obsidian quick_switch<cr>", desc = "Find note by name or alias" },
    { KEYMAP_PREFIX .. "s", "<cmd>Obsidian search<cr>", desc = "Search text in notes" },
    { KEYMAP_PREFIX .. "d", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
    { KEYMAP_PREFIX .. "D", "<cmd>Obsidian dailies<cr>", desc = "List daily notes" },
    { KEYMAP_PREFIX .. "n", "<cmd>Obsidian new<cr>", desc = "New note" },
    { KEYMAP_PREFIX .. "t", "<cmd>Obsidian tags<cr>", desc = "Find notes by tag" },
  },
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    -- refer to `:h file-pattern` for more examples
    "BufReadPre "
      .. vault_path
      .. "/*.md",
    "BufNewFile " .. vault_path .. "/*.md",
  },
  dependencies = {
    -- Optional
    "ibhagwan/fzf-lua",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "personal",
        path = vault_path,
      },
    },
    -- Same file names as the existing notes, readable in the Obsidian phone app ("My Note" -> "My-Note.md")
    note_id_func = function(title)
      if title == nil or vim.trim(title) == "" then return require("obsidian.builtin").zettel_id() end
      return (vim.trim(title):gsub("%s+", "-"))
    end,
    -- presenterm rejects unknown front matter keys, so do not add id/aliases/tags to decks
    frontmatter = {
      enabled = function(vault_relative_path)
        return vault_relative_path == nil or not is_in_slides_folder(vault_relative_path)
      end,
    },
    -- Must match the attachment and daily-note settings of the Obsidian app
    attachments = { folder = "images" },
    daily_notes = { folder = "Daily", workdays_only = false },
  },
  init = function()
    vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
      pattern = vault_path .. "/*.md",
      callback = function() vim.wo[0][0].conceallevel = 2 end,
      desc = "Set conceallevel=2 for markdown in vault",
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "ObsidianNoteEnter",
      callback = function(args)
        set_note_keymaps(args.buf)
        if is_in_slides_folder(vim.api.nvim_buf_get_name(args.buf)) then set_deck_keymaps(args.buf) end
        enable_note_rendering(args.buf)
      end,
      desc = "Set note keymaps and render the note",
    })
  end,
}
