# Workflow: lgtm + agent + Neovim

Mục tiêu: dùng AI để triển khai nhanh, đồng thời tự đọc hiểu code, kiểm chứng hành
vi và review diff trước khi commit. Tra lệnh/phím ở [COMMANDS.md](COMMANDS.md).

Một nguyên tắc cho cả workflow: mọi tham chiếu gửi cho agent có cùng dạng
`path:dòng` hoặc `path:dòng-dòng`, được gõ vào ô nhập của agent và **không bao giờ
tự Enter**. Bạn luôn là người đọc lại và bấm gửi.

## 1. Mở workspace

```sh
dev ~/Developer/Personal/my-pipeline
# Hoặc nếu zoxide đã nhớ project:
dev my-pipeline
```

Project phải tồn tại; chưa có thì tạo bằng `pynew`. Mỗi đường dẫn project có một
session riêng `dev-<tên>-<hash>`. Session dùng container có hậu tố `-dc`;
session local cũ vẫn được giữ. Gọi lại chỉ quay về session đang có.

| Window | Nội dung | Mục đích |
|---|---|---|
| 1 `review` | lgtm bên trái, shell cho agent bên phải | Đọc diff trực tiếp, hỏi agent |
| 2 `edit` | Neovim local hoặc trong dev container | Đọc sâu: `gd`, tìm kiếm, sửa tay |
| 3 `shell` | Shell trong thư mục project | Test, `lg`, log, Docker |

`dev` không tự mở agent. Ở pane bên phải, chạy agent bạn muốn: `codex`,
`codex resume`, `claude` hoặc `claude --continue`. lgtm đã được trỏ sẵn vào pane
này nên phím `Enter` trong lgtm gõ thẳng vào ô nhập của agent.

Session tạo trước khi đổi bố cục vẫn mở được nhưng `dev` sẽ nhắc: chạy
`tmux kill-session -t <tên>` rồi `dev` lại để có bố cục mới. Nếu lỡ thoát lgtm
(`:q`), pane còn lại một shell: chạy `lgtm` và chọn pane agent bằng `Space t` nếu
nó hỏi.

Prefix rồi `1/2/3` chuyển window, `h/l` chuyển pane, `z` phóng to một pane.

### Project có dev container

`dev` tự nhận `.devcontainer/devcontainer.json` hoặc `.devcontainer.json`.
Trên máy mới, chạy `make setup-devcontainer` một lần và mở Docker/OrbStack.
Lần đầu `dev <project>` build/start container, cài Neovim, Node, Basedpyright,
Ruff và công cụ build parser; cần mạng và có thể mất vài phút. Các lần sau dùng
lại container và volume plugin/cache riêng cho project.

Chỉ window `edit` chạy trong container. lgtm, agent và window `shell` vẫn ở Mac.
Config Neovim dùng chung từ dotfiles; plugin, parser, Mason và lockfile Linux
được lưu riêng, không dùng binary hoặc `.venv` macOS. LSP dùng Python và thư viện
của container. `Space a` và clipboard `+` đi qua cầu nối file về Mac; tham chiếu
vẫn chỉ được gõ vào pane agent, không tự Enter.

Project mới có thể bắt đầu với:

```sh
mkdir -p .devcontainer
cp ~/Developer/dotfiles/templates/devcontainer/devcontainer.json .devcontainer/
```

Đổi `image` hoặc `build` theo runtime của project, rồi thêm bước cài dependency
trong Dockerfile hoặc `postCreateCommand`. Mẫu Python không tự suy luận dependency.
Cài editor tự động hiện hỗ trợ container Debian/Ubuntu, CPU ARM64 hoặc x86_64;
user trong container cần cho phép root cài công cụ qua Docker exec.

```sh
dev <project>             # Tự chọn container nếu có config
dev --local <project>     # Mở editor trên Mac
dev --rebuild <project>   # Build lại container sau khi đổi Dockerfile/dependency
```

Trước `--rebuild`, thoát Neovim để window `edit` đóng; script từ chối rebuild
khi window này vẫn mở. Sau khi rebuild, nó tạo lại window `edit`, giữ agent và
shell đang chạy. Nếu chỉ thoát Neovim, gọi lại `dev` cũng mở lại window bị thiếu.
Detach/thoát tmux không tự xóa container hoặc volume. Runtime/test của project
vẫn chạy bằng các lệnh Docker/Compose riêng của project.

## 2. Đọc một đoạn rồi hỏi

**Từ lgtm** (cách chính, khi đang đọc diff):

1. `j/k`, `]h` sang hunk kế, `]f` sang file kế, `/` tìm, `*` tìm từ dưới con trỏ.
2. Tự dự đoán input/output, side effect, lỗi có thể xảy ra trước khi hỏi.
3. `Enter` trên dòng (hoặc `V` chọn nhiều dòng rồi `Enter`). Compose box mở với
   tham chiếu như `#3 src/pipeline.py:47`.
4. Gõ câu hỏi, hoặc `Ctrl-i` chèn một preset (`explain`, `review`,
   `checkpoint`...). `Enter` để gõ vào ô nhập agent.
5. Prefix rồi `l` sang agent, đọc lại rồi tự bấm Enter.

**Từ Neovim** (khi đang đọc code ngoài diff): `Space a` gửi `path:dòng` của dòng
hiện tại, hoặc `path:dòng-dòng` của vùng chọn ở Visual mode, vào ô nhập agent rồi
chuyển sang pane đó để bạn gõ câu hỏi. Buffer chưa lưu thì mapping từ chối, vì
agent đọc file trên đĩa. Không tìm thấy pane agent (ngoài tmux, session cũ, pane
đã đóng) thì tham chiếu được copy vào clipboard.

Ví dụ câu hỏi bổ sung:

```text
src/pipeline.py:40-72 Tôi nghĩ batch này retry từ checkpoint cuối. Kiểm tra bằng
call sites và test. Nếu sink ghi xong nhưng commit checkpoint lỗi thì sao? Chỉ
đọc, chưa sửa code. Chỉ rõ phần chưa đủ bằng chứng.
```

Preset `explain`/`review` chỉ là lời dặn. Muốn chặn quyền ghi thật, mở thêm một
agent ở window `shell`: `codex --sandbox read-only` hoặc
`claude --permission-mode plan`.

## 3. Giao một thay đổi có thể đọc hết diff

Trước mỗi task, nhìn lgtm (hoặc `lgtm status`) để biết baseline. Dùng `/plan` khi
thay đổi nhiều bước hoặc chưa rõ thiết kế. Khi đã chốt hướng, giao một phần nhỏ
với hành vi kiểm chứng được:

```text
Thêm xử lý record thiếu device_id vào pipeline này.

Record thiếu device_id phải vào luồng reject. Các record hợp lệ vẫn được xử lý.
Thêm test batch trộn hai loại record và test retry. Giữ phạm vi thay đổi tập trung.
Khi xong, nêu file đã đổi, lệnh kiểm tra đã chạy và phần chưa kiểm chứng.
Chưa commit hoặc push; tôi sẽ review diff trước.
```

Mỗi lúc chỉ để một agent sửa cùng working tree. Trong lúc agent viết, lgtm vẽ lại
diff mỗi 500 ms và tự chụp snapshot sau mỗi lượt agent dừng ghi, kể cả trạng thái
trước khi agent bắt đầu. Tránh sửa cùng file trong Neovim lúc agent đang ghi; sau
đó `:checktime` để nạp thay đổi trên đĩa.

## 4. Review trong lgtm

lgtm hiển thị staged, unstaged và cả file untracked so với `HEAD`, nên không cần
nhớ rằng `git diff` bỏ sót file mới.

1. **Gom nhận xét**: `Space c` ghi chú trên dòng (kể cả dòng bị xoá), `Space gc`
   đề xuất sửa trực tiếp. Không gửi từng câu cho agent.
2. **Gửi một lần**: `Ctrl-s` ghi `.lgtm/review-N.md`, báo agent đọc file đó và đặt
   *mark* "đã đọc tới đây".
3. **Quay lại phần mới**: khi agent sửa xong, dòng mới có vạch ở gutter; `]m` đi
   qua chúng. Nhận xét tự bám theo code khi agent viết lại; nhận xét không đặt
   lại được thì hiện *stale*, không bị mất.
4. **Test bị làm yếu**: status line báo test bị xoá, `skip` mới, assertion giảm.
   `]w` nhảy tới đó. Đây là cách rẻ nhất để biến build đỏ thành xanh, đừng bỏ qua.
5. **Theo lượt**: `Space lt` liệt kê các lượt của agent. `↺ 4` nghĩa là agent vừa
   tự hoàn tác về lượt 4 (dấu hiệu đang loay hoay), `↩` là lượt chạm vào file bạn
   đã nhận xét. `R` khôi phục một file từ lượt đang xem, `u` hoàn tác lần đó.

Review cả nhánh: `lgtm diff main` (vẫn live, gồm cả phần chưa commit). Review pull
request: `lgtm --pr 123` (cần `gh` đã đăng nhập).

Lượt review thứ hai bởi AI, khi diff đã ổn định: `/review` trong Codex hoặc
`/code-review` trong Claude Code. Tốt nhất mở agent đó ở window `shell`, tách khỏi
agent đã viết code. Một lượt AI không phát hiện lỗi không chứng minh code đúng.

Với pipeline DE, các câu hỏi dưới đây có sẵn thành preset trong lgtm (`Ctrl-i`):

| Kiểm tra | Preset | Tình huống cần nghĩ đến |
|---|---|---|
| Idempotency | `idempotent` | Chạy lại batch có tạo dữ liệu trùng không? |
| Checkpoint/transaction | `checkpoint` | Sink thành công nhưng checkpoint thất bại thì sao? |
| Data contract | `contract` | Null, thiếu field, schema mới, timezone, decimal |
| SQL/transform | `join` | Join nhân bản record, filter làm mất dữ liệu |
| Tài nguyên | `memory` | Dataset lớn, collect/toPandas, tải toàn bộ file vào RAM |
| Quan sát | `counts` | Đối chiếu số record đọc/ghi/reject, lỗi bị nuốt |

Ghi các invariant thực sự của project và lệnh test vào `AGENTS.md` (Codex) hoặc
`CLAUDE.md` (Claude Code) của project. Preset dùng chung đặt trong
`lgtm/config.toml` của dotfiles; preset riêng một project đặt trong
`.lgtm/config.toml` của project đó.

## 5. Tự kiểm chứng

Ở window `shell`:

```sh
make check      # Python template: lint, typecheck, test, lgtm risk
lgtm risk       # Project khác: chỉ kiểm tra test bị làm yếu, exit 1 nếu có
```

Với project khác, dùng đúng test, lint, typecheck và integration checks của
project. Trước khi đọc giải thích của AI, thử trả lời: code thay hành vi gì, trường
hợp lỗi nào còn thiếu, và test mới có bắt được lỗi cũ không? Dùng fixture/dữ liệu
mẫu để đối chiếu kết quả, không chỉ nhìn trạng thái test pass.

## 6. Sửa findings rồi commit

Yêu cầu agent sửa lỗi đã xác nhận, thêm regression test khi phù hợp (preset
`test`). Chạy lại kiểm tra, dùng `]m` đọc phần mới. Trong `lg`, stage đúng phần bạn
muốn giữ rồi commit; `git diff --cached` cho thấy nội dung sắp commit.

Khi cần nhiều agent song song, dùng Git worktree riêng cho từng agent và
`dev <đường-dẫn-worktree>`: mỗi worktree có session, lgtm và nhận xét riêng.

## Dữ liệu lgtm để lại

- `.lgtm/` trong project: nhận xét theo branch, các `review-N.md`, trạng thái mark.
  lgtm tự thêm `.gitignore` nên không lọt vào commit.
- Snapshot nằm trong git dưới `refs/lgtm/**`, không hiện ở `git branch` hay
  `git status`. Xoá hết khi không cần:
  `git for-each-ref --format='%(refname)' refs/lgtm | xargs -n1 git update-ref -d`.

lgtm đang ở giai đoạn pre-alpha: nếu một phím hay hành vi khác tài liệu, `?` trong
lgtm hiện bảng phím thực tế của bản đang cài.

## Kết thúc và quay lại

Prefix rồi `d` detach. Tiến trình tiếp tục khi máy vẫn chạy; tmux không tự khôi
phục session sau reboot. Lần sau `dev <project>` để attach lại. Agent đã thoát thì
mở lại ở pane phải, hoặc `codex resume` / `claude --continue`. Mark và nhận xét của
lgtm vẫn còn sau khi thoát.

## Nguồn và phạm vi

- [lgtm](https://noah-code.com/docs/lgtm): phím, cấu hình, snapshot, `lgtm risk`.
- [Codex CLI](https://learn.chatgpt.com/docs/codex/cli): workflow, `/review`, sandbox.
- [Claude Code Code Review](https://code.claude.com/docs/en/code-review): `/code-review`.
- [AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md): hướng dẫn theo repo.

Workflow dùng Ghostty, tmux, Neovim, lgtm, Codex hoặc Claude Code, lazygit và uv.
Neovim không có plugin AI: `Space a` chỉ gõ tham chiếu vào pane agent, không gọi
model và không tự gửi.
