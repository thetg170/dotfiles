# Neovim Keymaps (LazyVim)

**Leader = `Space`**

## Agent

| Key | Action |
|---|---|
| `<leader>a` | Gửi `path:dòng` (Visual: `path:dòng-dòng`) vào ô nhập agent và chuyển sang pane đó |

Không bấm Enter, không sửa hay lưu file. Buffer chưa lưu thì từ chối (`:w`
trước). Ngoài workspace `dev` thì copy tham chiếu vào clipboard. Câu hỏi soạn sẵn
(explain, review, checklist DE) nằm ở preset của lgtm. [Workflow đầy đủ](WORKFLOW.md).

---

## Markdown

Extra `lang.markdown` của LazyVim, chỉnh trong `plugins/markdown.lua` và
`config/autocmds.lua`. Mở file `.md` là thấy bản đã render ngay trong buffer:
heading, bảng, code block, checklist, link. Dòng có con trỏ hiện Markdown gốc để sửa
cho chính xác.

| Key | Action |
|---|---|
| `<leader>um` | Bật/tắt render (xem Markdown gốc) |
| `<leader>cp` | Preview trong trình duyệt, cuộn theo con trỏ |
| `<leader>ss` | Nhảy tới heading (symbol từ marksman) |
| `gd` trên link `[..](file.md#heading)` | Mở file/heading được link tới |

Với Markdown: tự xuống dòng theo từ, tắt spellcheck tiếng Anh, không format khi lưu
và không lint. Cần format thì `<leader>cf`.

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

## Motion (Hardtime enforcement disabled by default)

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
