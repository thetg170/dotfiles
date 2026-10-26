#!/usr/bin/env bash
set -euo pipefail

no_attach=0
if [[ "${1:-}" == --no-attach ]]; then
  no_attach=1
  shift
fi
if [[ "${1:-}" == --help ]]; then
  printf 'Usage: %s [--no-attach] [project-directory-or-zoxide-name]\n' "$0"
  exit 0
fi
if [[ $# -gt 1 ]]; then
  printf 'Expected one project directory or zoxide name.\n' >&2
  exit 2
fi
project_dir="${1:-$PWD}"
if [[ ! -d "$project_dir" ]] && command -v zoxide >/dev/null 2>&1; then
  project_dir="$(zoxide query -- "$project_dir")" || exit 1
fi
if [[ ! -d "$project_dir" ]]; then
  printf 'Project directory not found: %s\n' "$project_dir" >&2
  exit 1
fi
project_dir="$(cd "$project_dir" && pwd -P)"
for tool in tmux nvim codex; do
  command -v "$tool" >/dev/null 2>&1 || { printf 'Missing command: %s\n' "$tool" >&2; exit 1; }
done

slug="$(basename "$project_dir" | LC_ALL=C tr -cs '[:alnum:]_-' '-' | cut -c 1-32 | sed 's/-*$//')"
slug="${slug:-project}"
path_id="$(printf '%s' "$project_dir" | shasum | cut -c 1-10)"
session="dev-${slug}-${path_id}"
tmux_cmd=(tmux)
# An optional socket lets tests create workspaces without touching active sessions.
[[ -z "${DOTFILES_TMUX_SOCKET:-}" ]] || tmux_cmd+=(-S "$DOTFILES_TMUX_SOCKET")

if "${tmux_cmd[@]}" has-session -t "$session" 2>/dev/null; then
  saved_dir="$("${tmux_cmd[@]}" show-options -v -t "$session" @dotfiles_project)"
  if [[ "$saved_dir" != "$project_dir" ]]; then
    printf 'Session name collision: %s\n' "$session" >&2
    exit 1
  fi
else
  editor_pane="$("${tmux_cmd[@]}" new-session -d -P -F '#{pane_id}' \
    -s "$session" -n dev -c "$project_dir" -x 160 -y 45 nvim .)"
  "${tmux_cmd[@]}" set-option -t "$session" @dotfiles_project "$project_dir"
  "${tmux_cmd[@]}" set-option -t "$session" renumber-windows on
  "${tmux_cmd[@]}" split-window -h -l 40% -t "$editor_pane" -c "$project_dir" codex
  "${tmux_cmd[@]}" new-window -d -t "$session:" -n check -c "$project_dir"
  "${tmux_cmd[@]}" new-window -d -t "$session:" -n logs -c "$project_dir"
  "${tmux_cmd[@]}" select-window -t "$session:dev"
  "${tmux_cmd[@]}" select-pane -t "$editor_pane"
fi

if [[ "$no_attach" == 1 ]]; then
  printf '%s\n' "$session"
elif [[ -n "${TMUX:-}" ]]; then
  "${tmux_cmd[@]}" switch-client -t "$session"
else
  "${tmux_cmd[@]}" attach-session -t "$session"
fi
