# Neovim-Cheatsheet

## Find plugins

Check out this secion on the [Awesom-Neovim](https://github.com/rockerBOO/awesome-neovim#plugin) repo.

## Plugin installation path (Packer)

Plugin data can be found in `~/.local/share/nvim`, more specifically *Packer* installs the plugins to `~/.local/share/nvim/site/pack/packer/`.

## Plugin log file patch

Logs can be found in `~/.cache/nvim`


## Deep dive for plugins

- Go to the plugin repo and check the `doc` folder.
- Check help for different functions or plugins: `:h <plugin-name>`

## Run lua functions in vim command line

`:lua <lua-command>`


## Keybindings

### Default

- **Folding**: `zc` (close), `zM` (close all), `za` (open), `zR` (open all)
- **New Line Insert Mode**: `o`

### Plugins 

#### Telescope

- **Live Grep**: `<C-t`
- **Find file**: `<Leader>f`

#### Lsp

- **Go to Declaration**: `gD`
- **Go to Definition**: `gd`
- **Go to Implementation**: `gi`
- **Hover**: `K`
- **Function Signature**: `<C-k>`
- **Rename**: `<leader>rn`
- **Line Diagnostic**: `gl`
- **References**: `gr`

#### Comments

- **Comments Line**
  - **Normal**: `gcc`, `gcA` (end of line)
  - **Visual**: `gc`

#### Nvimtree

- **Open Tree**: `<leader>e`

#### Bufferline

- **Close buffer**: `<leader>q`

