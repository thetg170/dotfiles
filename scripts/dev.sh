#!/usr/bin/env bash
set -euo pipefail

no_attach=0
local_editor=0
rebuild=0
while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --no-attach) no_attach=1 ;;
    --local) local_editor=1 ;;
    --rebuild) rebuild=1 ;;
    --help)
      printf 'Usage: %s [--no-attach] [--local|--rebuild] [project-directory-or-zoxide-name]\n' "$0"
      exit 0 ;;
    --) shift; break ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done
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
for tool in tmux lgtm; do
  command -v "$tool" >/dev/null 2>&1 || { printf 'Missing command: %s\n' "$tool" >&2; exit 1; }
done
container_editor=0
if [[ "$local_editor" == 0 && ( -f "$project_dir/.devcontainer/devcontainer.json" || -f "$project_dir/.devcontainer.json" ) ]]; then
  container_editor=1
elif ! command -v nvim >/dev/null 2>&1; then
  printf 'Missing command: nvim\n' >&2
  exit 1
fi
script_dir="$(cd "$(dirname "$0")" && pwd -P)"
if [[ "$rebuild" == 1 && "$container_editor" == 0 ]]; then
  printf -- '--rebuild requires a dev container project (without --local).\n' >&2
  exit 2
fi
prepare=up
[[ "$rebuild" == 0 ]] || prepare=rebuild

slug="$(basename "$project_dir" | LC_ALL=C tr -cs '[:alnum:]_-' '-' | cut -c 1-32 | sed 's/-*$//')"
slug="${slug:-project}"
path_id="$(printf '%s' "$project_dir" | shasum | cut -c 1-10)"
session="dev-${slug}-${path_id}"
[[ "$container_editor" == 0 ]] || session+="-dc"
printf -v editor_command '%q ' "$script_dir/devcontainer.sh" edit "$project_dir" "$session"
tmux_cmd=(tmux)
# An optional socket lets tests create workspaces without touching active sessions.
[[ -z "${DOTFILES_TMUX_SOCKET:-}" ]] || tmux_cmd+=(-S "$DOTFILES_TMUX_SOCKET")

if "${tmux_cmd[@]}" has-session -t "$session" 2>/dev/null; then
  saved_dir="$("${tmux_cmd[@]}" show-options -v -t "$session" @dotfiles_project)"
  if [[ "$saved_dir" != "$project_dir" ]]; then
    printf 'Session name collision: %s\n' "$session" >&2
    exit 1
  fi
  if [[ -z "$("${tmux_cmd[@]}" show-options -qv -t "$session" @dotfiles_agent_pane)" ]]; then
    printf 'Session %s uses the old layout. Run: tmux kill-session -t %s, then dev again.\n' \
      "$session" "$session" >&2
  fi
  if [[ "$container_editor" == 1 ]]; then
    if "${tmux_cmd[@]}" list-windows -t "$session" -F '#{window_name}' | /usr/bin/grep -qx edit; then
      if [[ "$rebuild" == 1 ]]; then
        printf 'Close Neovim in the edit window first, then run dev --rebuild again.\n' >&2
        exit 1
      fi
    else
      "$script_dir/devcontainer.sh" "$prepare" "$project_dir"
      "${tmux_cmd[@]}" new-window -d -a -t "$session:review" -n edit -c "$project_dir" "$editor_command"
    fi
  fi
else
  if [[ "$container_editor" == 1 ]]; then
    "$script_dir/devcontainer.sh" "$prepare" "$project_dir"
  fi
  # Agent pane first: lgtm starts already pointed at it, so Enter never asks.
  agent_pane="$("${tmux_cmd[@]}" new-session -d -P -F '#{pane_id}' \
    -s "$session" -n review -c "$project_dir" -x 160 -y 45)"
  "${tmux_cmd[@]}" set-option -t "$session" @dotfiles_project "$project_dir"
  "${tmux_cmd[@]}" set-option -t "$session" @dotfiles_agent_pane "$agent_pane"
  "${tmux_cmd[@]}" set-option -t "$session" @dotfiles_editor "$([[ "$container_editor" == 1 ]] && printf devcontainer || printf local)"
  "${tmux_cmd[@]}" set-option -t "$session" renumber-windows on
  # lgtm on the left. If it quits, a shell keeps the pane and the layout.
  "${tmux_cmd[@]}" split-window -h -b -l 60% -t "$agent_pane" -c "$project_dir" \
    "lgtm --pane $agent_pane; exec \"\${SHELL:-/bin/zsh}\" -l"
  if [[ "$container_editor" == 1 ]]; then
    "${tmux_cmd[@]}" new-window -d -t "$session:" -n edit -c "$project_dir" "$editor_command"
  else
    "${tmux_cmd[@]}" new-window -d -t "$session:" -n edit -c "$project_dir" nvim .
  fi
  "${tmux_cmd[@]}" new-window -d -t "$session:" -n shell -c "$project_dir"
  "${tmux_cmd[@]}" select-window -t "$session:review"
  "${tmux_cmd[@]}" select-pane -t "$agent_pane"
fi

if [[ "$no_attach" == 1 ]]; then
  printf '%s\n' "$session"
elif [[ -n "${TMUX:-}" ]]; then
  "${tmux_cmd[@]}" switch-client -t "$session"
else
  "${tmux_cmd[@]}" attach-session -t "$session"
fi
