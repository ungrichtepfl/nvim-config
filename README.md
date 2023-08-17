# Personal Neovim Config

## Installation

You need `fd-find`, `ripgrep` and `xclip`/`xsel` (X11) or `wl-clipboard` (wayland).

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
mkdir $HOME/.virtualenvs
cd $HOME/.virtualenvs
python3 -m venv debugpy
debugpy/bin/python -m pip install debugpy
```

## Get Healthy

In `nvim` use:

```nvim
:checkhealth
```
