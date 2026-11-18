#!/usr/bin/env bash
# Shared paths and link manifest. Compatible with macOS /bin/bash 3.2.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
DOTFILES_TARGET_HOME="${DOTFILES_TARGET_HOME:-$HOME}"
DOTFILES_CONFIG_HOME="${DOTFILES_CONFIG_HOME:-${XDG_CONFIG_HOME:-$DOTFILES_TARGET_HOME/.config}}"

dotfiles_links() {
  local callback="$1"
  "$callback" "$REPO_ROOT/codex/dotfiles.config.toml" "$DOTFILES_TARGET_HOME/.codex/dotfiles.config.toml"
  "$callback" "$REPO_ROOT/.zprofile" "$DOTFILES_TARGET_HOME/.zprofile"
  "$callback" "$REPO_ROOT/.zshrc" "$DOTFILES_TARGET_HOME/.zshrc"
  "$callback" "$REPO_ROOT/.bash_profile" "$DOTFILES_TARGET_HOME/.bash_profile"
  "$callback" "$REPO_ROOT/.bashrc" "$DOTFILES_TARGET_HOME/.bashrc"
  "$callback" "$REPO_ROOT/.tmux.conf" "$DOTFILES_TARGET_HOME/.tmux.conf"
  "$callback" "$REPO_ROOT/.vim/.vimrc" "$DOTFILES_TARGET_HOME/.vimrc"
  "$callback" "$REPO_ROOT/nvim" "$DOTFILES_CONFIG_HOME/nvim"
  "$callback" "$REPO_ROOT/ghostty/config" "$DOTFILES_CONFIG_HOME/ghostty/config"
  "$callback" "$REPO_ROOT/ghostty/effects" "$DOTFILES_CONFIG_HOME/ghostty/effects"
  "$callback" "$REPO_ROOT/lgtm/config.toml" "$DOTFILES_CONFIG_HOME/lgtm/config.toml"
  "$callback" "$REPO_ROOT/lazygit/config.yml" "$DOTFILES_CONFIG_HOME/lazygit/config.yml"
  # Lazygit uses Application Support by default on macOS, even without XDG_CONFIG_HOME.
  if [[ "$(uname -s)" == Darwin ]]; then
    "$callback" "$REPO_ROOT/lazygit/config.yml" "$DOTFILES_TARGET_HOME/Library/Application Support/lazygit/config.yml"
    "$callback" "$REPO_ROOT/hammerspoon/init.lua" "$DOTFILES_TARGET_HOME/.hammerspoon/init.lua"
  fi
  "$callback" "$REPO_ROOT/bat/config" "$DOTFILES_CONFIG_HOME/bat/config"
  "$callback" "$REPO_ROOT/starship/starship.toml" "$DOTFILES_CONFIG_HOME/starship.toml"
  "$callback" "$REPO_ROOT/uv/uv.toml" "$DOTFILES_CONFIG_HOME/uv/uv.toml"
  "$callback" "$REPO_ROOT/uv/python-version" "$DOTFILES_CONFIG_HOME/uv/.python-version"
}

dotfiles_uv() {
  local candidate
  for candidate in /opt/homebrew/opt/uv/bin/uv /usr/local/opt/uv/bin/uv; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done
  command -v uv
}
