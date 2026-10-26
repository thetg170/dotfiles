#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd -P)"
scratch="$(mktemp -d /tmp/dotfiles-dev.XXXXXX)"
socket="$scratch/socket"
mkdir -p "$scratch/bin" "$scratch/a/My Project" "$scratch/b/My Project"

# Stub both interactive apps: tests never start an AI session or edit user files.
for app in nvim codex; do
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
[[ "$(tmux -S "$socket" list-windows -t "$first" -F '#{window_name}')" == $'dev\ncheck\nlogs' ]]
[[ "$(tmux -S "$socket" list-panes -t "$first:dev" -F '#{pane_id}' | wc -l | tr -d ' ')" == 2 ]]
expected="$(cd "$scratch/a/My Project" && pwd -P)"
while IFS= read -r pane_path; do
  [[ "$pane_path" == "$expected" ]]
done < <(tmux -S "$socket" list-panes -s -t "$first" -F '#{pane_current_path}')
if "$repo/scripts/dev.sh" --no-attach "$scratch/missing" >/dev/null 2>&1; then
  printf 'Missing project was incorrectly accepted\n' >&2
  exit 1
fi
printf 'Workspace tests passed: layout, project cwd, reuse, same-name projects, missing-path rejection\n'
