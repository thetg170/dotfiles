# Tmux Keymaps

**Prefix = `Ctrl+Space`**

---

## Session

| Key | Action |
|---|---|
| `prefix $` | Rename session |
| `prefix d` | Detach (session stays alive) |
| `prefix )` | Next session |
| `prefix (` | Previous session |
| `tmux attach -t main` | Reattach to session |

---

## Windows

| Key | Action |
|---|---|
| `prefix c` | New window |
| `prefix n` | Next window |
| `prefix p` | Previous window |
| `prefix &` | Kill window (confirm) |
| `prefix ,` | Rename window |
| `prefix .` | Move window to new index |
| `prefix '` | Go to window by name |
| `prefix f` | Find window |
| `prefix w` | List all windows |

---

## Panes

| Key | Action |
|---|---|
| `prefix -` | Split horizontal |
| `prefix \` | Split vertical |
| `prefix h/j/k/l` | Move between panes |
| `prefix o` | Cycle to next pane |
| `prefix ;` | Last pane |
| `prefix x` | Kill pane (confirm) |
| `prefix !` | Break pane into new window |
| `prefix H/J/K/L` | Resize pane (repeatable) |

---

## Copy Mode (Emacs keys)

| Key | Action |
|---|---|
| `prefix [` | Enter copy mode |
| `prefix ]` | Paste buffer |
| `Ctrl+Space` | Begin selection |
| `Ctrl+w` | Copy selection to clipboard |
| `Ctrl+g` | Clear selection |
| `M-<` / `M->` | Jump to top / bottom |
| `Ctrl+s` | Search forward |
| `n` | Next search match |
| `q` | Exit copy mode |
| `PageUp` / `PageDown` | Scroll up / down |

---

## Misc

| Key | Action |
|---|---|
| `prefix r` | Reload tmux config |
