#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

dry_run=0
case "${1:-}" in
  --dry-run) dry_run=1 ;;
  '') ;;
  *) printf 'Usage: %s [--dry-run]\n' "$0" >&2; exit 2 ;;
esac

backup_stamp="$(date +%Y%m%d-%H%M%S)-$$"

require_source() {
  [[ -e "$1" ]] || { printf 'Missing source: %s\n' "$1" >&2; return 1; }
}
dotfiles_links require_source

backup_and_link() {
  local source="$1" target="$2" backup
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    printf 'OK      %s\n' "$target"
    return
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    backup="${target}.backup.${backup_stamp}"
    printf 'BACKUP  %s -> %s\n' "$target" "$backup"
    if [[ "$dry_run" == 0 ]]; then
      [[ ! -e "$backup" && ! -L "$backup" ]]
      mv "$target" "$backup"
    fi
  fi
  printf 'LINK    %s -> %s\n' "$target" "$source"
  if [[ "$dry_run" == 0 ]]; then
    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
  fi
}
dotfiles_links backup_and_link
