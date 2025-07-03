# Personal Neovim Config

## Installation

You need `fd-find`, `ripgrep` and `xclip`/`xsel` (X11) or `wl-clipboard`
(wayland) and `fzf`.

Also for python support:

```shell
pip install pynvim
```

And for node support:

```shell
npm i -g neovim
```

### Debuggers

#### Python

```shell
pipx install debugpy
```

## Get Healthy

In `nvim` use:

```nvim
:checkhealth
:checkhealth lsp
```

## Formatting

Use stylua for lua formatting:

```shell
cargo install stylua --features lua52
```

```shell
stylua .
```
