#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

if [[ $# != 1 || -z "$1" ]]; then
  printf 'Usage: %s <new-project-directory>\n' "$0" >&2
  exit 2
fi

destination="$1"
if [[ -e "$destination" || -L "$destination" ]]; then
  printf 'Refusing to overwrite an existing path: %s\n' "$destination" >&2
  exit 1
fi
project_name="$(basename "$destination" | tr '[:upper:]' '[:lower:]' | LC_ALL=C sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
if [[ -z "$project_name" ]]; then
  printf 'Use a project directory name containing letters or numbers.\n' >&2
  exit 2
fi
uv_bin="$(dotfiles_uv)" || { printf 'Install uv first: brew install uv\n' >&2; exit 1; }

mkdir -p "$(dirname "$destination")"
mkdir "$destination"
destination="$(cd "$destination" && pwd -P)"
# Copy hidden editor/CI files, but never carry a template's local environment.
tar -C "$REPO_ROOT/templates/python" \
  --exclude=.venv --exclude=__pycache__ --exclude=.pytest_cache \
  --exclude=.ruff_cache --exclude=.git --exclude=dist --exclude=build -cf - . |
  tar -C "$destination" -xf -
sed "s/^name = \"python-starter\"$/name = \"$project_name\"/" \
  "$destination/pyproject.toml" > "$destination/pyproject.toml.tmp"
mv "$destination/pyproject.toml.tmp" "$destination/pyproject.toml"

git -C "$destination" init -q
"$uv_bin" sync --project "$destination"
printf '\nCreated %s\nNext: cd "%s" && make check\n' "$project_name" "$destination"
