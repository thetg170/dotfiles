#!/bin/sh
set -eu
export PATH="/opt/dotfiles/editor/bin:$PATH"
export XDG_CONFIG_HOME=/opt/dotfiles/config
export XDG_DATA_HOME=/opt/dotfiles/state/data
export XDG_STATE_HOME=/opt/dotfiles/state/state
export XDG_CACHE_HOME=/opt/dotfiles/state/cache
mkdir -p "$XDG_STATE_HOME/nvim"
if [ ! -f "$XDG_STATE_HOME/nvim/lazy-lock.json" ]; then
  cp "$XDG_CONFIG_HOME/nvim/lazy-lock.json" "$XDG_STATE_HOME/nvim/lazy-lock.json"
fi
# Never use the macOS .venv exposed by the workspace bind mount.
unset VIRTUAL_ENV
if [ "${1:-}" = --command ]; then
  shift
  exec "$@"
fi
exec nvim .
