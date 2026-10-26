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

`dev` tạo window `dev` (Neovim + Codex), `check`, `logs`. Gọi lại sẽ dùng session
cũ, không mở thêm editor/AI. Cần có `tmux`, `nvim`, Codex đã cài và đăng nhập.

## File và tìm kiếm

| Lệnh/phím tại prompt Zsh | Công dụng |
|---|---|
| `ll` / `la` | Danh sách chi tiết / gồm file ẩn |
| `lt` | Cây thư mục sâu hai cấp |
| `bat file.py` | Đọc file có màu và số dòng; `q` thoát pager |
| `rg 'TODO'` | Tìm nội dung trong project |
| `rg --files -g '*.py'` | Liệt kê file Python, tôn trọng `.gitignore` |
| `Ctrl+r` | Tìm history, Enter chọn rồi kiểm tra command trước khi chạy |
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
| `Space ay` | Copy path + khoảng dòng + code cho AI |
| `Space ap` | Copy path + khoảng dòng, không kèm code |
| `Space ae` | Copy context kèm prompt giải thích, chỉ đọc |
| `Space ar` | Copy context kèm prompt review, chỉ đọc |
| `Space gg` | Mở lazygit theo cấu hình LazyVim |
| `:checktime` | Kiểm tra và nạp thay đổi trên đĩa nếu buffer không có thay đổi riêng |

Các mapping `Space a...` dùng được ở Normal và Visual mode. Normal lấy dòng hiện
tại; Visual lấy toàn bộ các dòng được selection chạm tới, kể cả chọn ngược hoặc
chọn dạng cột. Snippet lấy từ buffer, có ghi chú nếu chưa lưu. Mapping không gửi
AI, không đổi pane, không sửa/lưu file. Với `Space ap`, cần `:w` trước khi nhờ AI
đọc nội dung trên đĩa. Xem thêm [nvim.md](nvim.md).

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

Phím của Neovim và prefix tmux là hai lớp khác nhau: `Space ae` dùng trong
Neovim; `Ctrl+Space` rồi `l` dùng để chuyển pane. Xem thêm [tmux.md](tmux.md).

## AI và review

| Lệnh | Công dụng |
|---|---|
| `codex` | Mở phiên AI trong project hiện tại |
| `codex resume` | Chọn phiên cũ để tiếp tục |
| `airead` | Mở Codex với sandbox read-only để hỏi/đọc code |
| `aireview` | Review thay đổi chưa commit, gồm staged/unstaged/untracked |
| `aireview main` | Review nhánh so với `main` |
| `aireview origin/main` | Review so với ref remote đang có trên máy |

`aireview` và `airead` chạy trong shell, không gõ vào ô chat Codex. Trong chat có
thể dùng `/plan` để lên kế hoạch và `/review` để chọn chế độ review. Ref remote
không tự cập nhật: fetch khi bạn cần so với trạng thái mới nhất.

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
`p` pull, `?` xem phím theo panel, `q` thoát. Review file mới ở lazygit hoặc qua
`aireview`; đừng chỉ nhìn `git diff` rồi bỏ sót chúng.

## Python

| Lệnh | Công dụng |
|---|---|
| `pynew ~/Developer/Personal/my-pipeline` | Tạo project mới có uv, test, editor và CI |
| `uv sync --locked` | Dựng môi trường theo lockfile đã commit |
| `uv add pandas` | Thêm dependency runtime |
| `uv add --dev pytest-cov` | Thêm dev dependency |
| `uv run --locked python main.py` | Chạy script trong môi trường project |
| `make check` | Với template: lint, typecheck, test, kiểm tra format |
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

Chạy Compose tại project có cấu hình phù hợp. Window `logs` của workspace không
tự khởi động service; bạn chọn lệnh theo project. Không có alias tự xóa volume.

## Quản lý dotfiles

| Lệnh ở repo dotfiles | Công dụng |
|---|---|
| `make setup` | Cài dependency cơ bản, link config, setup Python và kiểm tra |
| `make setup-de` | Cài profile app/DE tùy chọn |
| `make setup-python` | Setup Python 3.12 và config uv |
| `make dry-run` | Xem link/backup dự kiến |
| `make link` | Tạo link, backup file cũ nếu cần |
| `make check` | Kiểm tra setup, runtime và cú pháp |
| `make check-workflow` | Thử mapping AI và workspace bằng clipboard/AI giả lập, server tmux riêng |
