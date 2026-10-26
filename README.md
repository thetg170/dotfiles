# dotfiles

Cấu hình macOS cho Ghostty + Zsh + tmux + Neovim. Sửa file trong repo là sửa
config đang dùng qua symlink. Repo có thể đặt ở bất kỳ thư mục nào.

## Cài trên máy mới

Cài Apple Command Line Tools (`xcode-select --install`) và [Homebrew](https://brew.sh), rồi chạy:

```sh
git clone https://github.com/thetg170/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
make setup
```

`make setup` cài package còn thiếu trong `Brewfile`, Oh My Zsh và đúng hai plugin
đang dùng: `zsh-autosuggestions`, `fast-syntax-highlighting`. Sau đó tạo symlink.
Setup dùng `--no-upgrade`, tắt cleanup/autoremove và không đổi login shell hệ thống.
Homebrew vẫn có thể cập nhật dependency cần thiết khi cài package mới.
Plugin đã tồn tại cũng được giữ nguyên. Neovim tự cài plugin ở lần mở đầu tiên.

Mở tab Ghostty mới để nạp môi trường login đầy đủ, rồi chạy `make check`.
Với terminal khác, dùng Zsh hoặc chọn `/bin/zsh` trong cấu hình terminal đó.

`Brewfile` chỉ quản lý bộ công cụ cho dotfiles và các cask Homebrew đã có trên máy:
Ghostty, Ubuntu Mono Nerd Font, Karabiner-Elements, Maccy, gcloud CLI. Các app cài
thủ công như OrbStack, VS Code, trình duyệt và ứng dụng công việc không bị thay đổi.
Các công cụ chuyên dự án như Java/Spark cũng không bị cài lại bởi setup này.

## Profile Data Engineering

`Brewfile.de` là profile tùy chọn, cài bằng `make setup-de`:

- Apps DE: OrbStack, VS Code, DBeaver Community, draw.io, Obsidian, Keka.
- Browser chính: Brave Browser. Google Chrome dùng riêng cho Claude và ChatGPT.
- Tiện ích/cá nhân: OpenKey, Caffeine, Macs Fan Control, Telegram, Zalo, Anki, IINA.
- CLI: Java 17, btop, tree, wget, tailspin, openfortivpn, pandoc, poppler.

App đã tồn tại trong `/Applications` hoặc `~/Applications` sẽ được giữ nguyên,
không chuyển sang Homebrew hoặc cài trùng. Trên máy mới, app còn thiếu sẽ được cài.
Profile này không tự chạy khi dùng `make setup` và không khởi động dịch vụ nền.
Script cài app nhưng không thay đổi browser mặc định, login item hoặc thiết lập
bộ gõ của macOS. Các tùy chọn này được giữ theo cài đặt hiện tại của bạn.

Theo lựa chọn hiện tại, không thêm Plotly Studio, Microsoft Excel, Amethyst,
abctl, Podman, tnftp, libomp hoặc graphviz. Không gỡ các mục đã cài trên máy.
Homebrew vẫn tự quản lý dependency cần cho các package được chọn.

Astro đang được giữ ngoài cài đặt tự động vì formula mặc định phụ thuộc Podman.
Nếu cần dựng Airflow trên máy mới với OrbStack, có thể dùng formula chính thức
`astronomer/tap/astro` với tùy chọn `--without-podman` theo
[hướng dẫn Astronomer](https://www.astronomer.io/astro/cli/install-cli).
Script không thay thế Astro hiện tại của bạn.

## Lệnh quản lý

| Lệnh tại thư mục repo | Công dụng |
|---|---|
| `make setup` | Cài dependency còn thiếu và tạo symlink |
| `make setup-de` | Cài profile DE tùy chọn, giữ nguyên app đã có |
| `make dry-run` | Xem các link/backup dự kiến, chưa sửa file |
| `make link` | Chỉ tạo symlink, không cài package |
| `make check` | Kiểm tra command, plugin, symlink, shader và cú pháp config |

Link đã đúng sẽ được bỏ qua. File, thư mục hoặc link cũ được chuyển thành
`<tên-file>.backup.<timestamp>-<pid>` ngay cạnh vị trí cũ trước khi tạo link mới.
Để khôi phục, bỏ riêng symlink mới rồi chuyển bản backup về tên cũ.
Không có script nào tự xóa backup.

`make check` kiểm tra tmux trong server riêng, không reload hay đóng session đang dùng.
Nó không đo hiệu năng GPU và không cài/nâng cấp plugin Neovim.
Ngoài kiểm tra command có tồn tại, script chạy thử Node, npm, Python 3.14 và Codex
(nếu đã cài) bằng `--version` để phát hiện lỗi thiếu thư viện động. `make setup`
và `make setup-de` cũng chạy kiểm tra sau khi hoàn tất cài đặt.

Nếu gặp `dyld: Library not loaded` khi chạy Node/npm/Codex sau khi Homebrew thay
đổi dependency, cài lại Node để liên kết với thư viện hiện tại rồi kiểm tra:

```sh
HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_AUTOREMOVE=1 brew reinstall --no-ask node
node --version
npm --version
codex --version
make check
```

Lệnh reinstall dùng phiên bản Node hiện tại của formula Homebrew, có thể khác
major version đã cài trước đó. Không tạo symlink giả giữa các bản dylib khác phiên
bản; xem [hướng dẫn Homebrew](https://docs.brew.sh/Common-Issues).

## Dùng các công cụ mới

### Nhảy thư mục: zoxide

Đi đến một thư mục bằng `cd` ít nhất một lần, để prompt hiện ra, sau đó zoxide sẽ nhớ nó:

```sh
cd ~/Developer/dotfiles
cd ~
z dotfiles          # Nhảy về thư mục dotfiles đã dùng
z work dot         # Tìm theo nhiều phần tên đường dẫn
zi                 # Chọn trong danh sách thư mục đã nhớ bằng fzf
zi dot             # Lọc danh sách trước khi chọn
z -                # Quay lại thư mục trước
```

`cd` vẫn giữ hành vi thông thường. Database zoxide là dữ liệu riêng trên từng máy,
không commit vào dotfiles. Không có kết quả? Đi đến thư mục bằng `cd` trước.

### Tìm history và file: fzf

Các phím này dùng trực tiếp tại dòng lệnh Zsh, **không cần tmux prefix**:

| Phím | Cách dùng |
|---|---|
| `Ctrl+r` | Gõ một phần command cũ, chọn bằng mũi tên rồi Enter |
| `Ctrl+t` | Chọn file và chèn đường dẫn vào dòng lệnh; Tab chọn nhiều file |
| `Alt+c` / `Option+c` trong Ghostty | Chọn thư mục con và chuyển đến đó |
| `Esc` hoặc `Ctrl+c` trong danh sách | Hủy tìm kiếm |

Ví dụ: gõ `nvim ` rồi nhấn `Ctrl+t`, tìm `.tmux.conf`, Enter để chèn đường dẫn,
nhấn Enter lần nữa để mở. `Ctrl+r` cũng chỉ đưa command lên dòng nhập để bạn kiểm
tra trước khi thực thi. `Ctrl+t` có preview bằng bat, tìm cả file ẩn nhưng tôn trọng
`.gitignore`; bỏ qua `.git`, `node_modules`, `.venv`, `__pycache__`.

Không dùng `Ctrl+t` trong phần soạn thảo Neovim để gọi fzf của shell; hãy chạy từ
prompt Zsh. Trong tmux cũng dùng trực tiếp các phím trên tại prompt trong pane.

### Git: lazygit

```sh
cd ~/Developer/dotfiles
lg                 # Viết tắt của lazygit
```

Trong lazygit: dùng mũi tên hoặc `h/j/k/l` để di chuyển, `Space` stage/unstage file,
`c` tạo commit ở panel Files, `P` push, `p` pull, `?` xem phím theo panel, `q` thoát.
Xem diff trước khi stage/commit; không có alias tự add + commit + push.

### Đọc file: bat

```sh
bat .zshrc
bat --line-range 1:80 .tmux.conf
bat --paging=never .gitignore
```

Bat hiển thị syntax highlight và số dòng; nếu vào pager thì dùng `q` để thoát.
`cat` vẫn là lệnh gốc.

### Xem thư mục: eza

```sh
ll                 # Danh sách chi tiết, thư mục trước, có icon
la                 # Như ll, thêm file ẩn
lt                 # Cây thư mục sâu 2 cấp
eza --tree --level=3 nvim
```

`ls` vẫn là lệnh gốc. `lg`, `ll`, `la`, `lt` chỉ được khai báo khi có tool tương ứng.

## Cấu hình riêng từng máy

Thêm override vào `~/.zshrc.local`; file này không được link hoặc commit:

```sh
export EDITOR=nvim
# Chỉ thêm biến môi trường/đường dẫn thực sự cần trên máy này.
[[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)
# export JAVA_HOME="..."
# export SPARK_HOME="..."
```

Nạp lại thay đổi shell bằng `exec zsh -l` hoặc mở tab mới (không chạy `exec` khi
đang có shell job cần giữ). History được chia sẻ giữa các tab/pane. Command bắt đầu
bằng một dấu cách không được lưu vào history. Không đặt secret vào file trong repo.

Zsh là shell chính của Ghostty và tmux. `.bashrc`/`.bash_profile` được giữ lại cho
Bash cũ; các tích hợp mới trong hướng dẫn này dành cho Zsh.

## Bản đồ symlink

| Trong repo | Vị trí sử dụng |
|---|---|
| `.zprofile`, `.zshrc` | `~/.zprofile`, `~/.zshrc` |
| `.bash_profile`, `.bashrc` | `~/.bash_profile`, `~/.bashrc` |
| `.tmux.conf` | `~/.tmux.conf` |
| `.vim/.vimrc` | `~/.vimrc` |
| `nvim/` | `~/.config/nvim` |
| `ghostty/config` | `~/.config/ghostty/config` |
| `ghostty/effects/` | `~/.config/ghostty/effects` |

Nếu đã đặt `XDG_CONFIG_HOME`, script dùng thư mục đó thay cho `~/.config`.
`DOTFILES_TARGET_HOME` và `DOTFILES_CONFIG_HOME` có thể trỏ tới thư mục tạm để
thử script tạo link mà không chạm config đang dùng.

## Ghostty, tmux và Karabiner

Ghostty giữ theme/font/titlebar hiện tại. Shader `ghostty/effects/cursor_warp.glsl` được lưu cùng
repo để không thiếu trên máy mới; chỉ animate cửa sổ đang focus để giảm render nền.
Xem [ghi chú shader](ghostty/README.md). Reload Ghostty bằng `Cmd+Shift+,`.

Tmux giữ prefix `Ctrl+Space`, keybind và status bar hiện tại. Xem [tmux.md](tmux.md).
Nếu có session đang chạy, reload bằng `tmux source-file ~/.tmux.conf` hoặc prefix + `r`.

Karabiner được cài qua Brewfile nhưng không ghi đè `karabiner.json` đang dùng.
Import rule bạn chọn trong `karabiner/` qua Karabiner-Elements. Rule Alt-navigation
hiện áp dụng toàn hệ thống khi bật, không tự nhận biết Insert Mode của Neovim.

### Đổi Caps Lock thành Control

Sau khi setup máy mới, đổi Caps Lock thành Control để bấm các shortcut terminal
và tmux thuận tay hơn. Dùng tùy chọn có sẵn của macOS:

1. Mở **System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys**.
2. Chọn bàn phím cần chỉnh nếu có nhiều bàn phím.
3. Đặt **Caps Lock Key → Control**, rồi nhấn **Done**.
4. Mở tmux, giữ **Caps Lock + Space**, thả ra rồi bấm `c` để thử tạo window mới.

Caps Lock lúc này hoạt động như Ctrl; phím Control cũ vẫn dùng bình thường.
Thiết lập này làm thủ công trên từng máy/bàn phím; `make setup` không tự đổi nó.
Xem [hướng dẫn của Apple](https://support.apple.com/en-asia/guide/mac-help/mchlp1011/mac).

Nếu muốn **giữ Caps Lock = Control, bấm nhanh = Escape** cho Neovim, dùng rule
`karabiner/capslock.json` có sẵn trong repo. Với cách này, giữ Caps Lock ở mặc định
trong Modifier Keys của macOS và chỉ dùng Karabiner để remap, tránh chồng hai cách.

## Nguồn tham khảo

- [MarkPhamm/mac_setup](https://github.com/MarkPhamm/mac_setup): ý tưởng Brewfile, backup/link và verify.
- [fzf shell integration](https://github.com/junegunn/fzf#setting-up-shell-integration)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
