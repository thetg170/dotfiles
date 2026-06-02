# dotfiles

Personal config for macOS. Repo lives at `~/work/dotfiles`.

## What's inside

| Path in repo | Symlinked to |
|---|---|
| `.bash_profile` | `~/.bash_profile` |
| `.bashrc` | `~/.bashrc` |
| `.zshrc` | `~/.zshrc` |
| `.tmux.conf` | `~/.tmux.conf` |
| `.vim/.vimrc` | `~/.vimrc` |
| `nvim/` | `~/.config/nvim` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `ghostty/shaders/` | `~/.config/ghostty/shaders` |
| `karabiner/` | manual — see below |

## Setup on a new machine

```sh
git clone https://github.com/<you>/dotfiles ~/work/dotfiles
cd ~/work/dotfiles

# Shell
ln -sf ~/work/dotfiles/.zshrc ~/.zshrc
ln -sf ~/work/dotfiles/.bash_profile ~/.bash_profile
ln -sf ~/work/dotfiles/.bashrc ~/.bashrc

# tmux
ln -sf ~/work/dotfiles/.tmux.conf ~/.tmux.conf

# vim
ln -sf ~/work/dotfiles/.vim/.vimrc ~/.vimrc

# Neovim
mkdir -p ~/.config
ln -sf ~/work/dotfiles/nvim ~/.config/nvim

# Ghostty
mkdir -p ~/.config/ghostty
ln -sf ~/work/dotfiles/ghostty/config ~/.config/ghostty/config
ln -sf ~/work/dotfiles/ghostty/shaders ~/.config/ghostty/shaders
```

## Karabiner

Karabiner stores its live config at `~/.config/karabiner/karabiner.json` and does
not support symlinks well. Instead, use the install script:

```sh
cat karabiner/install.txt
```

## Dependencies

- [Oh My Zsh](https://ohmyz.sh)
- zsh plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fast-syntax-highlighting`, `zsh-autocomplete`
- [tmux](https://github.com/tmux/tmux)
- [Neovim](https://neovim.io) + [lazy.nvim](https://github.com/folke/lazy.nvim) (auto-installed on first launch)
- [uv](https://docs.astral.sh/uv) (Python toolchain, installed to `~/.local/bin`)
- [Ghostty](https://ghostty.org)
