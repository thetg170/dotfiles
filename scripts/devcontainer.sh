#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"

action="${1:-}"
rebuild=0
if [[ "$action" == rebuild ]]; then action=up; rebuild=1; fi
project="${2:-}"
[[ -d "$project" ]] || { printf 'Project directory required.\n' >&2; exit 2; }
project="$(cd "$project" && pwd -P)"
key="$(printf '%s' "$project" | shasum | cut -c 1-10)"
state="${DOTFILES_DEVCONTAINER_STATE_HOME:-$HOME/.cache/dotfiles/devcontainers}/$key"
config="$project/.devcontainer/devcontainer.json"
[[ -f "$config" ]] || config="$project/.devcontainer.json"
[[ -f "$config" ]] || { printf 'No devcontainer.json in %s\n' "$project" >&2; exit 1; }
for tool in docker devcontainer node; do
  command -v "$tool" >/dev/null || { printf 'Missing %s. Install Docker and run make setup-devcontainer.\n' "$tool" >&2; exit 1; }
done
# Match the terminal that is actually displaying the editor. In particular,
# screen-256color's legacy standout/italic capabilities differ from xterm's.
terminal="${TERM:-xterm-256color}"
if [[ -n "${TMUX:-}${DOTFILES_TMUX_SOCKET:-}" ]]; then
  terminal=tmux-256color
elif [[ "$terminal" == dumb || "$terminal" == screen* ]]; then
  terminal=xterm-256color
fi

case "$action" in
  up)
    docker info >/dev/null 2>&1 || { printf 'Start Docker/OrbStack first.\n' >&2; exit 1; }
    mkdir -p "$state/bridge"
    chmod 700 "$state"
    # The private parent protects this directory on the host; containers may use
    # a different UID and must be able to exchange clipboard/reference messages.
    chmod 777 "$state/bridge"
    result="$(mktemp "$state/up.XXXXXX")"
    trap 'rm -f "$result"' EXIT
    printf 'Preparing dev container for %s…\n' "$project" >&2
    up_cmd=(devcontainer up)
    [[ "$rebuild" == 0 ]] || up_cmd+=(--remove-existing-container)
    if ! "${up_cmd[@]}" --workspace-folder "$project" --config "$config" \
      --id-label "dotfiles.devcontainer=$key" \
      --mount "type=bind,source=$REPO_ROOT/nvim,target=/opt/dotfiles/config/nvim" \
      --mount "type=bind,source=$REPO_ROOT/devcontainer,target=/opt/dotfiles/tools" \
      --mount "type=bind,source=$state/bridge,target=/opt/dotfiles/bridge" \
      --mount "type=volume,source=dotfiles-nvim-$key,target=/opt/dotfiles/state" \
      > "$result"; then
      cat "$result" >&2
      exit 1
    fi
    node "$REPO_ROOT/devcontainer/result.mjs" "$result" "$state/container.json"
    container="$(node -p 'JSON.parse(require("fs").readFileSync(process.argv[1])).containerId' "$state/container.json")"
    remote_user="$(node -p 'JSON.parse(require("fs").readFileSync(process.argv[1])).remoteUser || "root"' "$state/container.json")"
    docker exec -u 0 "$container" sh /opt/dotfiles/tools/install-editor.sh "$remote_user" >&2
    ;;
  edit)
    [[ -f "$state/container.json" ]] || { printf 'Run dev for this project first.\n' >&2; exit 1; }
    session="${3:?tmux session required}"
    bridge="$state/bridge/editor-$$"
    mkdir -m 777 "$bridge"
    node "$REPO_ROOT/devcontainer/bridge.mjs" "$bridge" "$session" &
    bridge_pid=$!
    cleanup() {
      kill "$bridge_pid" 2>/dev/null || true
      wait "$bridge_pid" 2>/dev/null || true
      rm -rf "$bridge"
    }
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'exit 129' HUP
    devcontainer exec --workspace-folder "$project" --config "$config" \
      --id-label "dotfiles.devcontainer=$key" \
      --remote-env DOTFILES_DEVCONTAINER=1 \
      --remote-env "TERM=$terminal" \
      --remote-env COLORTERM=truecolor \
      --remote-env "DOTFILES_HOST_BRIDGE=/opt/dotfiles/bridge/editor-$$" \
      sh /opt/dotfiles/tools/editor.sh
    ;;
  exec)
    shift 2
    devcontainer exec --workspace-folder "$project" --config "$config" \
      --id-label "dotfiles.devcontainer=$key" \
      --remote-env DOTFILES_DEVCONTAINER=1 \
      --remote-env "TERM=$terminal" \
      --remote-env COLORTERM=truecolor \
      sh /opt/dotfiles/tools/editor.sh --command "$@"
    ;;
  *) printf 'Usage: %s {up|rebuild|edit|exec} project-directory [tmux-session|command…]\n' "$0" >&2; exit 2 ;;
esac
