#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/common.sh"
failed=0
tmux_check_dir=''

ok() { printf 'OK      %s\n' "$*"; }
fail() { printf 'FAIL    %s\n' "$*"; failed=1; }

for tool in brew git gh zsh nvim tmux starship uv rg zoxide fzf lazygit bat eza; do
  if command -v "$tool" >/dev/null 2>&1; then ok "$tool"; else fail "Missing command: $tool"; fi
done

# A command can exist on PATH while dyld cannot load its shared libraries.
for tool in node npm; do
  if command -v "$tool" >/dev/null 2>&1 && "$tool" --version >/dev/null; then
    ok "$tool runtime"
  else
    fail "$tool runtime (run $tool --version to inspect the error)"
  fi
done
uv_bin="$(dotfiles_uv)" || uv_bin=''
if [[ -n "$uv_bin" ]] && "$uv_bin" --version; then
  python_bin="$("$uv_bin" python find --managed-python --system --offline 3.12)" || python_bin=''
  if [[ -n "$python_bin" ]] && "$python_bin" -c 'import sys; assert sys.version_info[:2] == (3, 12)'; then
    ok "uv-managed Python 3.12 ($python_bin)"
  else
    fail 'uv-managed Python 3.12 (run make setup-python)'
  fi
else
  fail 'uv runtime'
fi
if command -v codex >/dev/null 2>&1; then
  if codex --version >/dev/null; then ok 'codex runtime'; else fail 'codex runtime'; fi
fi

check_link() {
  if [[ -L "$2" && -e "$2" && "$(readlink "$2")" == "$1" ]]; then
    ok "$2"
  else
    fail "Wrong or missing symlink: $2 (expected $1)"
  fi
}
dotfiles_links check_link

for file in .zprofile .zshrc; do
  if /bin/zsh -n "$REPO_ROOT/$file"; then ok "$file syntax"; else fail "$file syntax"; fi
done
for file in .bash_profile .bashrc scripts/*.sh; do
  if /bin/bash -n "$REPO_ROOT/$file"; then ok "$file syntax"; else fail "$file syntax"; fi
done

omz_dir="${ZSH:-$HOME/.oh-my-zsh}"
if [[ -r "$omz_dir/oh-my-zsh.sh" ]]; then ok 'Oh My Zsh'; else fail 'Oh My Zsh missing'; fi
for plugin in zsh-autosuggestions fast-syntax-highlighting; do
  if [[ -d "${ZSH_CUSTOM:-$omz_dir/custom}/plugins/$plugin" ]]; then ok "$plugin"; else fail "$plugin missing"; fi
done
if [[ -s "$REPO_ROOT/ghostty/effects/cursor_warp.glsl" ]]; then ok 'Cursor shader'; else fail 'Cursor shader missing'; fi

ghostty_bin="$(command -v ghostty || true)"
if [[ -z "$ghostty_bin" && -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]]; then
  ghostty_bin=/Applications/Ghostty.app/Contents/MacOS/ghostty
fi
if [[ -n "$ghostty_bin" ]]; then
  if "$ghostty_bin" +validate-config --config-file="$REPO_ROOT/ghostty/config"; then
    ok 'Ghostty config'
  else
    fail 'Ghostty config'
  fi
else
  fail 'Ghostty missing'
fi

# Source the config in an isolated server, never in the user's active sessions.
cleanup() {
  if [[ -n "$tmux_check_dir" ]]; then
    tmux -S "$tmux_check_dir/socket" kill-server >/dev/null 2>&1 || true
    rmdir "$tmux_check_dir" 2>/dev/null || true
  fi
}
trap cleanup EXIT
if command -v tmux >/dev/null 2>&1; then
  tmux_check_dir="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-tmux.XXXXXX")" || exit 1
  if tmux -S "$tmux_check_dir/socket" -f /dev/null new-session -d -s check '/bin/sleep 30' &&
    tmux -S "$tmux_check_dir/socket" source-file "$REPO_ROOT/.tmux.conf"; then
    ok 'tmux config (isolated server)'
  else
    fail 'tmux config'
  fi
fi

if [[ "$failed" == 0 ]]; then printf '\nAll checks passed.\n'; else printf '\nFix FAIL entries and rerun scripts/check.sh.\n'; fi
exit "$failed"
