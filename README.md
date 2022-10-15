# Personal Neovim Config

## Installation

You need `fd-find`, `ripgrep` and `xclip`/`xsel` (X11) or `wl-clipboard` (wayland).

Also for python support:
```
pip install pynvim
```

And for node support:
```
npm i -g neovim
```

### Debuggers

#### Python

```shell
mkdir .virtualenvs
cd .virtualenvs
python -m venv debugpy
debugpy/bin/python -m pip install debugpy
```
## Get Healthy

In `nvim` use:

```
:checkhealth
```
