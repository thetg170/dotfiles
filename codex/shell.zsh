# Only interactive entry points get the shared keyboard profile. Administrative
# commands such as `codex features` reject --profile in Codex 0.166.
codex() {
  local argument
  case "${1:-}" in
    ''|resume|fork) ;;
    *) command codex "$@"; return ;;
  esac
  for argument in "$@"; do
    case "$argument" in
      -p|--profile|--profile=*|-p?*) command codex "$@"; return ;;
    esac
  done
  command codex --profile dotfiles "$@"
}
