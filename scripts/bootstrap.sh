#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

if [[ "$(uname -s)" != Darwin ]]; then
  printf 'This setup targets macOS.\n' >&2
  exit 1
fi
if ! xcode-select -p >/dev/null 2>&1; then
  printf 'Install Command Line Tools first: xcode-select --install\n' >&2
  exit 1
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
if ! command -v brew >/dev/null 2>&1; then
  printf 'Install Homebrew from https://brew.sh then run this script again.\n' >&2
  exit 1
fi

HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_AUTOREMOVE=1 \
  brew bundle install --file="$REPO_ROOT/Brewfile" --no-upgrade

clone_if_missing() {
  local url="$1" destination="$2"
  if [[ -e "$destination" || -L "$destination" ]]; then
    printf 'KEEP    %s\n' "$destination"
    return
  fi
  mkdir -p "$(dirname "$destination")"
  git clone --depth=1 "$url" "$destination"
}

omz_dir="${ZSH:-$HOME/.oh-my-zsh}"
omz_custom_dir="${ZSH_CUSTOM:-$omz_dir/custom}"
clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$omz_dir"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions.git "$omz_custom_dir/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$omz_custom_dir/plugins/fast-syntax-highlighting"

"$REPO_ROOT/scripts/link.sh"
"$REPO_ROOT/scripts/check.sh"
printf '\nSetup complete. Open a new Ghostty tab, then run:\n  %s/scripts/check.sh\n' "$REPO_ROOT"
