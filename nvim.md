# Neovim Keymaps (LazyVim)

**Leader = `Space`**

## AI context

| Key (Normal hoặc Visual) | Action |
|---|---|
| `<leader>ay` | Copy path + line range + code |
| `<leader>ap` | Copy reference, không kèm code |
| `<leader>ae` | Copy context + prompt giải thích chỉ đọc |
| `<leader>ar` | Copy context + prompt review chỉ đọc |

Normal dùng dòng hiện tại; Visual dùng các dòng đang chọn. Copy vào clipboard
macOS, không gửi AI hoặc đổi pane. Chuyển bằng tmux prefix rồi `l`, paste `Cmd+v`,
xem lại và gửi. [Workflow đầy đủ](WORKFLOW.md).

---

## File

| Key | Action |
|---|---|
| `<leader>w` | Save file |
| `<leader>q` | Quit window |
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>e` | File explorer |
| `<Esc>` | Clear search highlight |

---

## Buffers

| Key | Action |
|---|---|
| `Shift+L` | Next buffer |
| `Shift+H` | Previous buffer |
| `<leader>,` | Pick buffer from list |
| `<leader>bd` | Delete buffer |

---

## Windows / Splits

| Key | Action |
|---|---|
| `<leader>-` | Split horizontal |
| `<leader>\|` | Split vertical |
| `Ctrl+h/j/k/l` | Move between windows |
| `<leader>wd` | Close window |

---

## Search

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search text in files) |
| `<leader>fb` | Find open buffers |
| `<leader>sg` | Search grep |
| `<leader>sw` | Search word under cursor |

---

## LSP / Code

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | References |
| `gI` | Go to implementation |
| `K` | Hover docs |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format file |
| `[d` / `]d` | Prev / next diagnostic |
| `<leader>cd` | Show diagnostic |

Python projects use `basedpyright` for type analysis and `ruff` for linting. In a kata
buffer, completion starts disabled; `<leader>kc` enables it temporarily while
`mini.pairs` remains active.

---

## Git

| Key | Action |
|---|---|
| `<leader>gg` | Open lazygit |
| `<leader>gb` | Git blame line |
| `<leader>gd` | Git diff |
| `]h` / `[h` | Next / prev hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |

---

## Tabs

| Key | Action |
|---|---|
| `<leader><tab>l` | Last tab |
| `<leader><tab>f` | First tab |
| `<leader><tab>n` | New tab |
| `<leader><tab>d` | Close tab |

---

## Motion (enforced by hardtime.nvim)

| Key | Action |
|---|---|
| `w` / `b` / `e` | Word forward / back / end |
| `f{c}` / `t{c}` | Jump to / before char on line |
| `F{c}` / `T{c}` | Jump to / before char (backwards) |
| `;` / `,` | Repeat f/t forward / backward |
| `{` / `}` | Jump paragraph |
| `gg` / `G` | Top / bottom of file |
| `Ctrl+d` / `Ctrl+u` | Half-page down / up (cursor centered) |
| `%` | Jump to matching bracket |
| `*` / `#` | Search word under cursor forward / back |

---

## Editing

| Key | Action |
|---|---|
| `gcc` | Toggle comment line |
| `gc` (visual) | Toggle comment selection |
| `gsa{motion}{c}` | Add surrounding (e.g. `gsaiw"`) |
| `gsd{c}` | Delete surrounding |
| `gsr{old}{new}` | Replace surrounding |
| `gsf{c}` / `gsF{c}` | Find surrounding right / left |
| `gsh{c}` | Highlight surrounding |
| `u` / `Ctrl+r` | Undo / redo |
| `>` / `<` (visual) | Indent / dedent |

The `gs` prefix is LazyVim's `mini.surround` convention and avoids taking `s` away
from Flash. Use surround from the first kata: wrap arguments or conditions, then
practice `gsr` and `gsd` while refactoring.

---

## LeetCode Kata

Open Neovim anywhere inside the LeetCode repository. Scratch files (`kata.py` and
`buggy.py`) are ignored by Git; the accepted solution remains the reference.
The statement opens as a clean, read-only Markdown buffer generated from LeetHub's
HTML; the original `README.md` is never modified.
When a scratch already exists, choose `Resume existing` to continue its session or
`Restart from blank` to overwrite it with a fresh stub. `Cancel` changes nothing.

| Key | Action |
|---|---|
| `<leader>kn` | Start the next due core kata |
| `<leader>kp` | Pick any Python problem for recall |
| `<leader>kb` | Pick a repair kata with one planted comparison bug |
| `<leader>kr` | Run the current problem tests in a bottom terminal |
| `<leader>kf` | Grade and finish the session |
| `<leader>kd` | Open the due/streak/time dashboard |
| `<leader>kc` | Toggle completion for the current buffer |
| `<leader>kh` | Toggle Precognition motion hints |
| `<leader>km` | Open the Hardtime motion report |

A 30-minute session: 2 minutes choose a due problem and a motion focus; 20 minutes
solve with completion off; 5 minutes test and refactor using surround/text objects;
3 minutes grade, record the motions used, and commit only durable improvements.

---

## Terminal

| Key | Action |
|---|---|
| `Ctrl+/` | Toggle floating terminal |
| `<leader>ft` | Open floating terminal |
| `<leader>fT` | Open full terminal |
| `Ctrl+\ Ctrl+n` | Exit terminal mode to normal mode |
