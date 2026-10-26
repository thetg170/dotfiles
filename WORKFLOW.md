# Workflow: Neovim + tmux + AI

Mục tiêu: dùng AI để triển khai nhanh, đồng thời tự đọc hiểu code, kiểm chứng hành
vi và review diff trước khi commit. Tra lệnh/phím ở [COMMANDS.md](COMMANDS.md).

## 1. Mở workspace

Mở tab Zsh mới để nạp các function và mapping mới, sau đó:

```sh
dev ~/Developer/Personal/my-pipeline
# Hoặc nếu zoxide đã nhớ project:
dev my-pipeline
```

Project phải tồn tại. Nếu chưa có, tạo bằng `pynew` trước. `dev` có thể chạy từ
ngoài hoặc trong tmux; mỗi đường dẫn project dùng một session riêng. Gọi lại chỉ
quay về session đang có, không reset bố cục hay mở thêm tiến trình.

| Window | Nội dung | Mục đích |
|---|---|---|
| `dev` | Neovim bên trái, Codex bên phải | Đọc, hỏi, sửa code |
| `check` | Shell trong thư mục project | Test, review, lazygit |
| `logs` | Shell trong thư mục project | Log ứng dụng/container khi cần |

Session có tên `dev-<tên-project>-<hash-đường-dẫn>` để tránh đụng tên project.
Editor và AI cùng thấy thư mục project. Chưa có tích hợp tự gửi selection vào
AI; chỉ clipboard được dùng. Hai window shell không tự chạy test hay service.

Các số window theo cấu hình hiện tại bắt đầu từ 1. Prefix rồi `n/p` hoặc `w`
nếu session cũ có thứ tự khác. Prefix rồi `z` để đọc một pane ở toàn window.

## 2. Đọc một đoạn rồi hỏi

Trong Neovim:

1. `Space ff` tìm file, `gd` theo định nghĩa, `Ctrl+o` quay lại.
2. Đọc hàm và tự dự đoán input/output, side effect, lỗi có thể xảy ra.
3. `V` rồi `j/k` chọn các dòng; bấm `Space ae`.
4. Prefix rồi `l` sang pane AI bên phải; `Cmd+v` để paste.
5. Đọc prompt, thêm câu hỏi cụ thể rồi mới gửi.
6. Prefix rồi `h` về Neovim, đối chiếu câu trả lời với code/test thực tế.

`Space ae` copy cả code, đường dẫn, khoảng dòng và prompt giải thích chỉ đọc.
Chọn kiểu ký tự/cột vẫn copy toàn bộ các dòng được chạm tới để giữ context.
Normal mode lấy dòng hiện tại; muốn cả hàm thì chọn các dòng của hàm trước.

Các lựa chọn khác:

- `Space ay`: copy context thuần, bạn tự viết câu hỏi.
- `Space ap`: copy file/range, không copy code; dùng khi file đã lưu và AI đọc được repo.
- `Space ar`: copy code kèm yêu cầu review chỉ đọc.
- `"+y`: chỉ copy selection thuần, không thêm prompt hoặc đường dẫn.

Snippet phản ánh buffer đang nhìn, có ghi rõ nếu chưa lưu. `Space ap` không gửi
buffer; chạy `:w` trước khi nhờ AI đọc file trên đĩa. Mapping không tự sửa hoặc
lưu file, không chuyển pane, không tự gửi Enter.

Ví dụ câu hỏi bổ sung:

```text
Tôi nghĩ batch này sẽ retry từ checkpoint cuối cùng. Hãy kiểm tra suy luận đó
bằng call sites và test. Nếu sink ghi xong nhưng commit checkpoint lỗi thì sao?
Chỉ đọc, chưa sửa code. Chỉ rõ phần chưa đủ bằng chứng.
```

Prompt chỉ đọc là hướng dẫn cho agent. Nếu muốn hạn chế quyền ghi bằng sandbox,
mở `airead` ở một shell riêng, ví dụ window `check`; tests có thể cần quyền ghi
cache nên chạy test ở shell thông thường của bạn.

## 3. Giao một thay đổi có thể đọc hết diff

Trước mỗi task, chạy `git status` để biết baseline và các thay đổi đang có. Dùng
branch/checkpoint phù hợp với project, giữ các thay đổi khác ngoài phạm vi task.

Trong Codex, dùng `/plan` khi thay đổi nhiều bước hoặc chưa rõ thiết kế. Khi đã
chốt hướng, giao một phần nhỏ với hành vi kiểm chứng được:

```text
Thêm xử lý record thiếu device_id vào pipeline này.

Record thiếu device_id phải vào luồng reject. Các record hợp lệ vẫn được xử lý.
Thêm test batch trộn hai loại record và test retry. Giữ phạm vi thay đổi tập trung.
Khi xong, nêu file đã đổi, lệnh kiểm tra đã chạy và phần chưa kiểm chứng.
Chưa commit hoặc push; tôi sẽ review diff trước.
```

Mỗi lúc chỉ để một AI sửa cùng working tree. Bạn có thể đọc code trong lúc AI
làm việc; tránh sửa đồng thời cùng file hoặc ghi buffer cũ đè lên thay đổi mới.
Sau khi agent hoàn tất, dùng `:checktime` để nạp thay đổi trên đĩa nếu buffer sạch.
Nếu cả buffer và file trên đĩa cùng đổi, xem diff và giải quyết trước khi ghi.

## 4. Tự kiểm chứng

Chờ writer dừng rồi chuyển sang window `check`:

```sh
git status
lg
make check
```

`make check` áp dụng cho Python template mới. Với project khác, dùng đúng test,
lint, typecheck và integration checks của project. Đọc cả file mới, test mới và
lockfile thay đổi; `git diff` đơn thuần không hiển thị file untracked.

Trước khi đọc giải thích của AI, thử trả lời: code thay hành vi gì, trường hợp lỗi
nào còn thiếu, và test mới có bắt được lỗi cũ không? Dùng fixture/dữ liệu mẫu phù
hợp để đối chiếu kết quả, không chỉ nhìn trạng thái test pass.

## 5. Review riêng

Khi diff đã ổn định, ở shell window `check`:

```sh
aireview                 # Staged + unstaged + untracked
# Hoặc để review nhánh:
aireview main
```

Chọn phạm vi phù hợp. Review so với `origin/main` chỉ dùng trạng thái ref đã fetch.
Đây là lượt review riêng với lượt viết; vẫn cần bạn xác minh findings bằng code
hoặc test. Một lượt AI không phát hiện lỗi không chứng minh code đúng.

Để trao đổi review theo hàm, chọn code trong Neovim rồi `Space ar`, hoặc mở
`airead` và yêu cầu kiểm tra cụ thể. Lệnh shell không gõ vào ô chat Codex.

| Với pipeline DE, kiểm tra | Tình huống cần nghĩ đến |
|---|---|
| Idempotency | Chạy lại batch có tạo dữ liệu trùng không? |
| Checkpoint/transaction | Sink thành công nhưng checkpoint thất bại thì sao? |
| Data contract | Null, thiếu field, schema mới, timezone, decimal |
| SQL/transform | Join nhân bản record, filter làm mất dữ liệu |
| Tài nguyên | Dataset lớn, collect/toPandas, toàn bộ file bị tải vào RAM |
| Quan sát | Đối chiếu số record đọc/ghi/reject, lỗi bị nuốt |

Ghi các invariant thực sự của project và lệnh test vào `AGENTS.md` của project.
Không cần tạo một bộ tài liệu kế hoạch lớn cho mọi task.

## 6. Sửa findings rồi commit

Yêu cầu writer sửa lỗi đã xác nhận, thêm regression test khi phù hợp. Chạy lại
kiểm tra và đọc diff mới. Trong `lg`, stage đúng phần bạn muốn giữ, rồi commit.
`git diff --cached` cho thấy nội dung chuẩn bị commit. Push khi đã sẵn sàng.

Khi cần nhiều AI triển khai song song, dùng Git worktree riêng cho từng writer.
Reviewer cần đọc các thay đổi chưa commit thì dùng cùng working tree sau khi
writer dừng; worktree mới không tự chứa các thay đổi chưa commit đó.

## Kết thúc và quay lại

Prefix rồi `d` detach. Các tiến trình có thể tiếp tục khi máy vẫn chạy; tmux không
tự khôi phục session sau reboot. Lần sau dùng `dev <project>` để attach lại.
`dev` không tự resume cuộc hội thoại Codex nếu tiến trình đã thoát; chạy
`codex resume` trong pane AI để tiếp tục phiên đã lưu.

## Nguồn và phạm vi

- [OpenAI CLI commands](https://learn.chatgpt.com/docs/developer-commands?surface=cli): review và read-only sandbox.
- [Codex CLI](https://learn.chatgpt.com/docs/codex/cli): workflow và review.
- [AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md): hướng dẫn theo repo.

Workflow này dùng tool đã có: Ghostty, tmux, Neovim, Codex, lazygit và uv.
Không thêm plugin AI cho Neovim và không tự gửi code hoặc gọi model khi copy.
