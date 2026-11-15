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

### Spell checking in other languages

Neovim ships only the English dictionary. For another language, convert the
hunspell dictionary of your distribution (package names like `hunspell-de`)
with `:mkspell`. The files are usually in `/usr/share/hunspell/`. Example for
Swiss German (`de_CH`, use `de_DE` or `de_AT` for the other spellings):

```shell
mkdir -p ~/.local/share/nvim/site/spell
nvim --headless -c "mkspell! $HOME/.local/share/nvim/site/spell/de /usr/share/hunspell/de_CH" -c 'qa!'
```

This creates `de.utf-8.spl` for `spelllang=de`. Without a hunspell package, the
ready-made Vim spell files can be downloaded instead:
`https://ftp.nluug.nl/pub/vim/runtime/spell/de.utf-8.spl` (and `.sug` for
suggestions) into the same folder.

To use the language in one file only, end it with a modeline, e.g. in markdown:

```markdown
<!-- vim: set spelllang=de: -->
```

### Debuggers

#### Python

```shell
mkdir ~/.virtualenvs
cd ~/.virtualenvs
python -m venv debugpy
debugpy/bin/python -m pip install debugpy
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
