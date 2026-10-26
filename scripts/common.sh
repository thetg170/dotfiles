#!/usr/bin/env bash
# Shared paths and link manifest. Compatible with macOS /bin/bash 3.2.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
DOTFILES_TARGET_HOME="${DOTFILES_TARGET_HOME:-$HOME}"
DOTFILES_CONFIG_HOME="${DOTFILES_CONFIG_HOME:-${XDG_CONFIG_HOME:-$DOTFILES_TARGET_HOME/.config}}"

dotfiles_links() {
  local callback="$1"
  "$callback" "$REPO_ROOT/.zprofile" "$DOTFILES_TARGET_HOME/.zprofile"
  "$callback" "$REPO_ROOT/.zshrc" "$DOTFILES_TARGET_HOME/.zshrc"
  "$callback" "$REPO_ROOT/.bash_profile" "$DOTFILES_TARGET_HOME/.bash_profile"
  "$callback" "$REPO_ROOT/.bashrc" "$DOTFILES_TARGET_HOME/.bashrc"
  "$callback" "$REPO_ROOT/.tmux.conf" "$DOTFILES_TARGET_HOME/.tmux.conf"
  "$callback" "$REPO_ROOT/.vim/.vimrc" "$DOTFILES_TARGET_HOME/.vimrc"
  "$callback" "$REPO_ROOT/nvim" "$DOTFILES_CONFIG_HOME/nvim"
  "$callback" "$REPO_ROOT/ghostty/config" "$DOTFILES_CONFIG_HOME/ghostty/config"
  "$callback" "$REPO_ROOT/ghostty/effects" "$DOTFILES_CONFIG_HOME/ghostty/effects"
}
