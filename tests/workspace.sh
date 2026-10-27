#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd -P)"
scratch="$(mktemp -d /tmp/dotfiles-dev.XXXXXX)"
socket="$scratch/socket"
mkdir -p "$scratch/bin" "$scratch/a/My Project" "$scratch/b/My Project"

# Stub both interactive apps: tests never start an AI session or edit user files.
for app in nvim lgtm; do
  cat > "$scratch/bin/$app" <<'SH'
#!/bin/sh
exec /bin/sleep 60
SH
  chmod +x "$scratch/bin/$app"
done
export PATH="$scratch/bin:$PATH"
export DOTFILES_TMUX_SOCKET="$socket"
cat > "$scratch/tmux.conf" <<'CONF'
set -g default-shell /bin/sh
set -g base-index 1
set -g automatic-rename off
CONF
cleanup() { tmux -S "$socket" kill-server >/dev/null 2>&1 || true; }
trap cleanup EXIT
tmux -S "$socket" -f "$scratch/tmux.conf" new-session -d -s sentinel /bin/sleep 60

first="$("$repo/scripts/dev.sh" --no-attach "$scratch/a/My Project")"
again="$("$repo/scripts/dev.sh" --no-attach "$scratch/a/My Project")"
second="$("$repo/scripts/dev.sh" --no-attach "$scratch/b/My Project")"
[[ "$first" == "$again" ]]
[[ "$first" != "$second" ]]
[[ "$(tmux -S "$socket" list-windows -t "$first" -F '#{window_name}')" == $'review\nedit\nshell' ]]
[[ "$(tmux -S "$socket" list-panes -t "$first:review" -F '#{pane_id}' | wc -l | tr -d ' ')" == 2 ]]
agent_pane="$(tmux -S "$socket" show-options -qv -t "$first" @dotfiles_agent_pane)"
# lgtm on the left, the agent's plain shell on the right and focused.
[[ "$(tmux -S "$socket" list-panes -t "$first:review" -F '#{pane_id}' | tail -n 1)" == "$agent_pane" ]]
[[ -z "$(tmux -S "$socket" display-message -p -t "$agent_pane" '#{pane_start_command}')" ]]
lgtm_pane="$(tmux -S "$socket" list-panes -t "$first:review" -F '#{pane_id}' | head -n 1)"
[[ "$(tmux -S "$socket" display-message -p -t "$lgtm_pane" '#{pane_start_command}')" == *"lgtm --pane $agent_pane"* ]]
[[ "$(tmux -S "$socket" display-message -p -t "$first" '#{window_name} #{pane_id}')" == "review $agent_pane" ]]
[[ "$(tmux -S "$socket" display-message -p -t "$first:edit" '#{pane_start_command}')" == *nvim* ]]
expected="$(cd "$scratch/a/My Project" && pwd -P)"
while IFS= read -r pane_path; do
  [[ "$pane_path" == "$expected" ]]
done < <(tmux -S "$socket" list-panes -s -t "$first" -F '#{pane_current_path}')
if "$repo/scripts/dev.sh" --no-attach "$scratch/missing" >/dev/null 2>&1; then
  printf 'Missing project was incorrectly accepted\n' >&2
  exit 1
fi

# Exercise detection/reuse/failure with fake Docker; no containers are touched.
export DOTFILES_DEVCONTAINER_STATE_HOME="$scratch/state"
export DOTFILES_TEST_UP_LOG="$scratch/up.log"
tmux -S "$socket" set-environment -g DOTFILES_DEVCONTAINER_STATE_HOME "$DOTFILES_DEVCONTAINER_STATE_HOME"
tmux -S "$socket" set-environment -g DOTFILES_TEST_UP_LOG "$DOTFILES_TEST_UP_LOG"
cat > "$scratch/bin/docker" <<'SH'
#!/bin/sh
if [ "$1" = info ] && [ "${DOTFILES_TEST_DOCKER_DOWN:-0}" = 1 ]; then exit 1; fi
exit 0
SH
cat > "$scratch/bin/devcontainer" <<'SH'
#!/bin/sh
case "$1" in
  up)
    echo up >> "$DOTFILES_TEST_UP_LOG"
    echo '{"outcome":"success","containerId":"fixture","remoteUser":"root","remoteWorkspaceFolder":"/workspace"}'
    ;;
  exec) exec /bin/sleep 60 ;;
  *) exit 1 ;;
esac
SH
chmod +x "$scratch/bin/docker" "$scratch/bin/devcontainer"
mkdir -p "$scratch/Container Project/.devcontainer"
printf '{"image":"fixture"}\n' > "$scratch/Container Project/.devcontainer/devcontainer.json"
container="$("$repo/scripts/dev.sh" --no-attach "$scratch/Container Project")"
[[ "$container" == *-dc ]]
[[ "$(tmux -S "$socket" show-options -qv -t "$container" @dotfiles_editor)" == devcontainer ]]
[[ "$(tmux -S "$socket" display-message -p -t "$container:edit" '#{pane_start_command}')" == *devcontainer.sh* ]]
[[ "$("$repo/scripts/dev.sh" --no-attach "$scratch/Container Project")" == "$container" ]]
[[ "$(wc -l < "$DOTFILES_TEST_UP_LOG" | tr -d ' ')" == 1 ]]
if "$repo/scripts/dev.sh" --no-attach --rebuild "$scratch/Container Project" >/dev/null 2>&1; then
  printf 'Rebuild with an open editor was incorrectly accepted\n' >&2
  exit 1
fi
tmux -S "$socket" kill-window -t "$container:edit"
[[ "$("$repo/scripts/dev.sh" --no-attach --rebuild "$scratch/Container Project")" == "$container" ]]
[[ "$(wc -l < "$DOTFILES_TEST_UP_LOG" | tr -d ' ')" == 2 ]]
[[ "$(tmux -S "$socket" list-windows -t "$container" -F '#{window_name}')" == $'review\nedit\nshell' ]]
local_session="$("$repo/scripts/dev.sh" --no-attach --local "$scratch/Container Project")"
[[ "$local_session" != "$container" ]]
[[ "$(tmux -S "$socket" show-options -qv -t "$local_session" @dotfiles_editor)" == local ]]
mkdir -p "$scratch/Docker down"
printf '{"image":"fixture"}\n' > "$scratch/Docker down/.devcontainer.json"
before="$(tmux -S "$socket" list-sessions -F '#{session_name}')"
if DOTFILES_TEST_DOCKER_DOWN=1 "$repo/scripts/dev.sh" --no-attach "$scratch/Docker down" >/dev/null 2>&1; then
  printf 'Docker unavailable was incorrectly accepted\n' >&2
  exit 1
fi
[[ "$(tmux -S "$socket" list-sessions -F '#{session_name}')" == "$before" ]]
printf 'Workspace tests passed: layout, reuse, container detection, local override, safe rebuild/editor recovery, quoted paths, Docker failure without partial session\n'
