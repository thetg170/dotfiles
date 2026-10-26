# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal macOS dotfiles repo living at `~/Developer/dotfiles`. All configs are **symlinked** into their expected locations — edits here take effect immediately (no deploy step needed).

## Symlink map

| Repo path | Live location |
|---|---|
| `.zshrc`, `.bash_profile`, `.bashrc` | `~/.*` |
| `.tmux.conf` | `~/.tmux.conf` |
| `.vim/.vimrc` | `~/.vimrc` |
| `nvim/` | `~/.config/nvim` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `ghostty/shaders/` | `~/.config/ghostty/shaders` |

Karabiner does **not** support symlinks; its JSON files must be copied manually (see `karabiner/install.txt`).

## Neovim architecture

Built on [LazyVim](https://www.lazyvim.org) + [lazy.nvim](https://github.com/folke/lazy.nvim).

- `nvim/init.lua` — entry point, loads `config.lazy`
- `nvim/lua/config/lazy.lua` — lazy.nvim bootstrap + plugin spec (imports `lazyvim.plugins` and local `plugins/`)
- `nvim/lua/config/options.lua` — vim options (tabs=4, relativenumber, clipboard=unnamedplus)
- `nvim/lua/config/keymaps.lua` — custom keymaps (`<leader>` = Space)
- `nvim/lua/plugins/` — local plugin overrides; each file returns a lazy.nvim spec table
  - `colorscheme.lua` — Gruvbox soft/transparent (tokyo-night and catppuccin disabled)
  - `training.lua` — `precognition.nvim` + `hardtime.nvim` to enforce vim motion habits
  - `indent.lua` — disables snacks.nvim indent guides

## tmux

Prefix: `Ctrl+Space`. Copy mode uses Emacs keys. Reload config: `<prefix> r`.

## Dependencies (must be pre-installed)

- Oh My Zsh + plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fast-syntax-highlighting`, `zsh-autocomplete`
- `tmux`, `neovim`, `ghostty`
- `uv` (Python toolchain at `~/.local/bin`)
- `brew install --cask karabiner-elements` for keyboard remapping
