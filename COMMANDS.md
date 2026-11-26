# Command và phím hữu ích

Tra nhanh khi làm việc. Quy trình đầy đủ nằm trong [WORKFLOW.md](WORKFLOW.md).
Mở tab Zsh mới sau khi đổi config, hoặc chạy `source ~/.zshrc`.

## Thư mục và workspace

| Lệnh | Công dụng |
|---|---|
| `dot` | Vào repo dotfiles, tự nhận vị trí repo |
| `pdev` | Vào `~/Developer/Personal` |
| `vntt` | Vào `~/Developer/Vntt` |
| `box` | Vào `~/Developer/Sandbox` |
| `z unitee` | Nhảy tới thư mục đã ghé có tên khớp |
| `zi` | Chọn thư mục đã nhớ bằng fzf |
| `dev` | Mở hoặc quay lại tmux workspace cho thư mục hiện tại |
| `dev ~/Developer/Personal/unitee` | Mở workspace theo đường dẫn |
| `dev unitee` | Tìm thư mục bằng zoxide rồi mở workspace |
| `dev --local <project>` | Mở Neovim trên Mac dù project có dev container |
| `dev --rebuild <project>` | Build lại dev container sau khi đã thoát Neovim |

`dev` tạo window `review` (lgtm + shell cho agent), `edit` (Neovim), `shell`. Gọi
lại sẽ dùng session cũ. Cần có `tmux`, `nvim` và `lgtm`. Ở pane bên phải của
`review`, tự chạy agent: `codex`, `codex resume`, `claude` hoặc `claude --continue`.

Có `.devcontainer/devcontainer.json` hoặc `.devcontainer.json` thì window `edit`
chạy trong container, dùng config Neovim chung và plugin/cache Linux riêng.
Cần Docker/OrbStack và `make setup-devcontainer` một lần. `Space a` và clipboard
vẫn hoạt động qua host bridge. Xem [workflow container](WORKFLOW.md#project-có-dev-container).

## File và tìm kiếm

| Lệnh/phím tại prompt Zsh | Công dụng |
|---|---|
| `ll` / `la` | Danh sách chi tiết / gồm file ẩn |
| `lt` | Cây thư mục sâu hai cấp |
| `bat file.py` | Đọc file có màu và số dòng; `q` thoát pager |
| `rg 'TODO'` | Tìm nội dung trong project |
| `rg --files -g '*.py'` | Liệt kê file Python, tôn trọng `.gitignore` |
| `Ctrl+r` | Tìm history, Enter chọn rồi kiểm tra command trước khi chạy |
| `Ctrl+y` | Nhận toàn bộ gợi ý lệnh |
| `Ctrl+e` | Ẩn gợi ý lệnh |
| `Ctrl+t` | Chọn file, chèn đường dẫn vào dòng nhập |
| `Option+c` | Chọn thư mục con để chuyển đến trong Ghostty |
| `du -sh .` | Dung lượng thư mục hiện tại |
| `df -h` | Dung lượng ổ đĩa |

## Neovim

Leader là `Space`. Các phím dưới dùng trong Normal mode nếu không ghi khác.

| Phím/lệnh | Công dụng |
|---|---|
| `Space ff` | Tìm file |
| `Space sg` | Tìm nội dung trong project |
| `gd` | Tới định nghĩa khi LSP hỗ trợ |
| `K` | Xem thông tin symbol từ LSP |
| `Ctrl+o` | Quay lại vị trí trước sau khi jump |
| `Space w` / `:w` | Lưu file |
| `V`, rồi `j/k` | Chọn các dòng code |
| `vip` | Chọn đoạn văn/code phân cách bởi dòng trống; không đảm bảo là cả hàm |
| `"+y` trong Visual mode | Copy code thuần vào clipboard macOS |
| `Space a` | Gửi `path:dòng` (Visual: `path:dòng-dòng`) vào ô nhập agent, chuyển sang pane đó |
| `Space um` | Markdown: bật/tắt bản render trong buffer |
| `Space cp` | Markdown: preview trong trình duyệt |
| `Space gg` | Mở lazygit theo cấu hình LazyVim |
| `:checktime` | Kiểm tra và nạp thay đổi trên đĩa nếu buffer không có thay đổi riêng |

`Space a` không bấm Enter, không sửa hay lưu file. Buffer chưa lưu thì từ chối
(`:w` trước), vì agent đọc file trên đĩa. Ngoài workspace `dev` thì tham chiếu
được copy vào clipboard. Xem thêm [nvim.md](nvim.md).

## tmux

Prefix là `Ctrl+Space`: nhấn rồi thả, sau đó bấm phím tiếp theo.

| Phím/lệnh | Công dụng |
|---|---|
| Prefix rồi `h/j/k/l` | Chuyển pane trái/xuống/lên/phải |
| Prefix rồi `z` | Zoom hoặc thu nhỏ pane hiện tại |
| Prefix rồi `H/J/K/L` | Resize pane, mỗi lần 5 ô |
| Prefix rồi `\` / `-` | Chia trái-phải / trên-dưới |
| Prefix rồi `c` | Tạo window |
| Prefix rồi `1/2/3` | Chuyển window theo số |
| Prefix rồi `n/p` | Window kế/trước |
| Prefix rồi `w` | Liệt kê window |
| Prefix rồi `d` | Detach, giữ session chạy |
| `tmux ls` | Xem session |
| `dev <project>` | Quay lại workspace project bằng đường dẫn hoặc tên zoxide |
| Prefix rồi `r` | Reload tmux config |

Phím của Neovim, lgtm và prefix tmux là ba lớp khác nhau: `Space a` dùng trong
Neovim; `Ctrl+Space` rồi `l` dùng để chuyển pane. Xem thêm [tmux.md](tmux.md).

## lgtm (window `review`)

Bảng đầy đủ: bấm `?` trong lgtm, hoặc [tài liệu lgtm](https://noah-code.com/docs/lgtm).

| Phím/lệnh | Công dụng |
|---|---|
| `j/k`, `]h` `[h`, `]f` `[f` | Di chuyển, hunk kế/trước, file kế/trước |
| `/`, `*` | Tìm trong toàn bộ review, tìm từ dưới con trỏ |
| `Enter` / `V` rồi `Enter` | Compose câu hỏi kèm `path:dòng`, gõ vào ô nhập agent (không Enter) |
| `Ctrl-i` trong compose | Chèn preset: `explain`, `review`, `checkpoint`, `contract`... |
| `Space c` / `Space gc` | Ghi nhận xét / đề xuất sửa trên dòng |
| `Space lc` | Danh sách nhận xét |
| `Ctrl-s` | Ghi `.lgtm/review-N.md`, báo agent, đặt mark |
| `]m` `[m` | Dòng mới xuất hiện từ sau mark |
| `]w` `[w` | Test bị xoá, `skip` mới, assertion giảm |
| `Space lt`, `]t` `[t` | Các lượt agent đã ghi; `R` khôi phục file từ lượt đó, `u` hoàn tác |
| `Space f` / `Space F` | File đã đổi / mọi file trong project |
| `Space e` | Mở dòng hiện tại trong Neovim (`$EDITOR`) |
| `Space t` | Chọn pane nhận tham chiếu |
| `-`, `zw`, `Tab` | Side-by-side ↔ một cột, wrap, ẩn khung |
| `:config edit`, `:q` | Sửa config (nạp lại ngay), thoát |

| Lệnh shell | Công dụng |
|---|---|
| `lgtm` | Review working tree so với `HEAD`, gồm file untracked |
| `lgtm diff main` | Review cả nhánh, gồm phần chưa commit |
| `lgtm --pr 123` | Review pull request (cần `gh`) |
| `lgtm status` | Bảng file đã đổi, +/−, thời gian ghi |
| `lgtm risk` | Kiểm tra test bị làm yếu, exit 1 nếu có |

Review lần hai bằng AI: `/review` trong Codex, `/code-review` trong Claude Code.
Agent chỉ đọc: `codex --sandbox read-only` hoặc `claude --permission-mode plan`.

## Git

| Lệnh | Công dụng |
|---|---|
| `gst` | `git status` |
| `glg` | Lịch sử dạng graph |
| `lg` | Mở lazygit để đọc diff, stage và commit |
| `git diff` | Xem thay đổi tracked chưa stage; không gồm file mới untracked |
| `git diff --cached` | Xem đúng nội dung đã stage chuẩn bị commit |
| `git diff --check` | Kiểm tra lỗi whitespace trong diff tracked |

Trong lazygit: `Space` stage/unstage file, `c` commit trong panel Files, `P` push,
`p` pull, `?` xem phím theo panel, `q` thoát. `git diff` bỏ sót file untracked;
lgtm và `lgtm status` thì không.

## Python

| Lệnh | Công dụng |
|---|---|
| `pynew ~/Developer/Personal/my-pipeline` | Tạo project mới có uv, test, editor và CI |
| `uv sync --locked` | Dựng môi trường theo lockfile đã commit |
| `uv add pandas` | Thêm dependency runtime |
| `uv add --dev pytest-cov` | Thêm dev dependency |
| `uv run --locked python main.py` | Chạy script trong môi trường project |
| `make check` | Với template: lint, typecheck, test, format, `lgtm risk` |
| `make format` | Với template: format code |
| `uv tool list` | Xem CLI cài riêng qua uv |

`pynew` chỉ nhận đường dẫn chưa tồn tại; `pynew .` bị từ chối. `make check` ở
dotfiles kiểm tra môi trường máy, còn ở project là target do project định nghĩa.
Hướng dẫn chi tiết ở [Python.md](Python.md).

## Container và debug

```sh
docker compose up -d
docker compose ps
docker compose logs -f --tail 100
docker compose logs -f --tail 100 SERVICE
docker stats
btop
lsof -nP -iTCP:8080 -sTCP:LISTEN
```

Chạy Compose tại project có cấu hình phù hợp. Window `shell` của workspace không
tự khởi động service; bạn chọn lệnh theo project. Không có alias tự xóa volume.

## Quản lý dotfiles

| Lệnh ở repo dotfiles | Công dụng |
|---|---|
| `make setup` | Cài dependency cơ bản, link config, setup Python và kiểm tra |
| `make setup-de` | Cài profile app/DE tùy chọn |
| `make setup-python` | Setup Python 3.12 và config uv |
| `make setup-devcontainer` | Cài Dev Containers CLI cho chế độ editor trong Docker |
| `make dry-run` | Xem link/backup dự kiến |
| `make link` | Tạo link, backup file cũ nếu cần |
| `make check` | Kiểm tra setup, runtime và cú pháp |
| `make check-workflow` | Thử `Space a` với tmux giả lập và bố cục `dev` trên server tmux riêng |
