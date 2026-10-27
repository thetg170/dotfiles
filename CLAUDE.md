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
| `ghostty/effects/` | `~/.config/ghostty/effects` |
| `lgtm/config.toml` | `~/.config/lgtm/config.toml` |
| `lazygit/config.yml` | `~/.config/lazygit/config.yml` and the macOS Application Support config |
| `bat/config`, `starship/starship.toml` | `~/.config/bat/config`, `~/.config/starship.toml` |
| `uv/uv.toml` | `~/.config/uv/uv.toml` |
| `uv/python-version` | `~/.config/uv/.python-version` |

Karabiner does **not** support symlinks; its JSON files must be copied manually (see `karabiner/install.txt`).

## Neovim architecture

Built on [LazyVim](https://www.lazyvim.org) + [lazy.nvim](https://github.com/folke/lazy.nvim).

- `nvim/init.lua` — entry point, loads `config.lazy`
- `nvim/lua/config/lazy.lua` — lazy.nvim bootstrap + plugin spec (imports `lazyvim.plugins` and local `plugins/`)
- `nvim/lua/config/options.lua` — vim options (tabs=4, relativenumber, clipboard=unnamedplus)
- `nvim/lua/config/keymaps.lua` — custom keymaps (`<leader>` = Space)
- `nvim/lua/plugins/` — local plugin overrides; each file returns a lazy.nvim spec table
  - `colorscheme.lua` — Gruvbox dark soft with an explicit background and italics disabled
  - `training.lua` — `precognition.nvim` hints; `hardtime.nvim` is disabled
  - `indent.lua` — disables snacks.nvim indent guides
  - `markdown.lua` — tunes the `lang.markdown` extra for reading: render-markdown on, markdownlint off (wrap/no-spell/no-autoformat live in `autocmds.lua`)

## tmux

Prefix: `Ctrl+Space`. Copy mode uses Emacs keys. Reload config: `<prefix> r`.

## Review workspace

`scripts/dev.sh` (the `dev` command) builds one tmux session per project: window
`review` runs `lgtm --pane <agent pane>` beside a plain shell for the agent, `edit`
runs Neovim, `shell` is a plain shell. The agent pane id is stored in the session
option `@dotfiles_agent_pane`; `nvim/lua/agent.lua` (`<leader>a`) reads it to type
`path:line` references into that pane without pressing Enter. Shared review
presets live in `lgtm/config.toml`. `make check-workflow` tests both without
touching real tmux sessions.

Projects with `.devcontainer/devcontainer.json` or `.devcontainer.json` run the
`edit` window through `scripts/devcontainer.sh`; `--local` forces host Neovim.
Container sessions use a `-dc` suffix. Share the Neovim config, but keep Linux
plugins/parsers/lockfiles in their own Docker volume and never select the host
`.venv` inside a container. `host_bridge.lua` and `devcontainer/bridge.mjs` carry
clipboard operations and `Space a` references to the host without submitting.
`dev --rebuild` refuses to replace a container while its edit window is open.
New-project starter: `templates/devcontainer/devcontainer.json`. Editor tooling
supports Debian/Ubuntu containers; `make setup-devcontainer` installs the host CLI.

## Python

Homebrew owns the preferred uv executable; uv owns development Python versions.
The global default is Python 3.12; each project's `.python-version` takes priority.
`make setup-python` links the uv config and installs the default runtime without
upgrading existing Python installations. Do not remove other runtimes automatically.

`pynew <new-directory>` runs `scripts/new-python.sh`, copies `templates/python`,
creates a local Git repository, resolves `uv.lock`, and installs a project `.venv`.
It refuses existing paths. See `Python.md` for usage and migration guidance.
Neovim uses project-local Python, basedpyright, and Ruff when available, with
editor-installed language tools as a fallback. Keep dependencies project-specific.

## Dependencies

Install Command Line Tools and Homebrew first, then run `make setup`.
The bootstrap script installs Brewfile packages, Oh My Zsh, zsh-autosuggestions,
and fast-syntax-highlighting; links dotfiles; sets up Python; and runs checks.
`make setup-de` installs the optional app/DE profile. No cleanup or autoremove.
