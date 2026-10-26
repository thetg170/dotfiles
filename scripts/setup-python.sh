#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

uv_bin="$(dotfiles_uv)" || {
  printf 'Install uv first: brew install uv\n' >&2
  exit 1
}

# No --upgrade or --force: keep installed runtimes and unrelated executables.
"$uv_bin" python install --default 3.12
python_bin="$("$uv_bin" python find --managed-python --system --offline 3.12)"
"$python_bin" --version
"$uv_bin" --version
printf 'Python ready. Open a new Zsh tab to use the updated PATH.\n'
