# Python development trên macOS

## Các thành phần

- Homebrew quản lý uv; PATH ưu tiên `/opt/homebrew/opt/uv/bin` (Intel: `/usr/local/opt/uv/bin`).
- uv quản lý Python dev. Mặc định là Python 3.12, project có thể pin phiên bản khác.
- Mỗi project có `.venv`, `pyproject.toml`, `uv.lock`, `.python-version` riêng.
- Ruff lint/format/imports, pytest test, basedpyright kiểm tra type.
- Không dùng `sudo pip`, không cài package của project vào Python hệ thống.

`make setup` đã bao gồm Python. Nếu chỉ cần cập nhật setup Python trên máy này:

```sh
cd ~/Developer/dotfiles
make setup-python
exec zsh -l
```

`exec` thay phiên shell hiện tại; mở tab mới nếu đang có shell job cần giữ.
Setup không tự nâng patch Python đã cài, không gỡ Python Homebrew hay uv cũ.
Config và global pin của uv được symlink qua `make link`, có backup nếu đã tồn tại.

Kiểm tra sau khi mở tab mới:

```sh
command -v uv
uv --version
python --version
uv python find --managed-python --system 3.12
```

Trên Apple Silicon, uv phải trỏ vào `/opt/homebrew/opt/uv/bin/uv` và Python mặc
định là 3.12. Project `.python-version` ưu tiên hơn global pin. Trong `.venv` đã
activate, `python` vẫn là interpreter của môi trường đó.

## Tạo project mới

```sh
pynew ~/Developer/Personal/my-pipeline
cd ~/Developer/Personal/my-pipeline
make run
make check
```

Hoặc dùng script trực tiếp nếu chưa nạp Zsh config:

```sh
~/Developer/dotfiles/scripts/new-python.sh ~/Developer/Personal/my-pipeline
```

Script chỉ nhận đường dẫn chưa tồn tại, tạo Git repository local, cài dev tools
vào `.venv` và sinh `uv.lock`. Không tự commit, tạo GitHub repo hay push.
Package mẫu là `src/app`; tên project lấy từ tên thư mục.
Nếu mạng/cài package gặp lỗi, thư mục đã tạo được giữ nguyên; vào đó chạy lại
`uv sync` sau khi xử lý lỗi, không cần chạy `pynew` lần nữa.

## Workflow hằng ngày

| Mục đích | Lệnh |
|---|---|
| Khôi phục môi trường từ Git | `uv sync --locked` |
| Thêm dependency runtime | `uv add pandas` |
| Thêm dependency dev | `uv add --dev pytest-cov` |
| Gỡ dependency | `uv remove pandas` |
| Chạy script | `uv run --locked python script.py` |
| Chạy ứng dụng mẫu | `make run` |
| Lint | `make lint` |
| Format file | `make format` |
| Kiểm tra type | `make typecheck` |
| Test | `make test` |
| Toàn bộ kiểm tra như CI | `make check` |

Sau `uv add`/`uv remove`, commit cả `pyproject.toml` và `uv.lock`.
Commit `.python-version`, không commit `.venv`, cache hoặc `.env` chứa secret.
`uv sync --locked` báo lỗi nếu metadata và lockfile lệch nhau; chỉ dùng `uv lock`
hoặc `uv sync` để thay lockfile khi bạn thực sự muốn cập nhật dependency.

Không bắt buộc activate môi trường. Nếu cần làm việc theo cách truyền thống:

```sh
source .venv/bin/activate
python -m app
deactivate
```

Alias `pip=pip3` đã bỏ. Dùng `uv add` cho uv project, `uv pip` khi cố ý thao tác
với một virtualenv truyền thống. Môi trường uv có thể không cài sẵn pip; đây là bình thường.

## Editor và CI

Neovim tự tìm `.venv/bin/python` theo root project cho basedpyright, ưu tiên
language server và Ruff trong `.venv`, fallback về executable của editor nếu thiếu.
Ruff formatter cũng ưu tiên `.venv/bin/ruff`. Nếu vừa tạo/thay môi trường khi
editor đang mở, restart LSP hoặc mở lại Neovim.

Template có `.vscode/settings.json` và extension recommendations cho Python,
basedpyright, Ruff. Cài các extension được đề xuất, disable Pylance cho workspace
để tránh hai language server Python cùng chạy. Nếu VS Code nhớ interpreter cũ,
chạy **Python: Select Interpreter** rồi chọn `.venv/bin/python`.

Template cũng có `.github/workflows/ci.yml`: Linux + Python theo `.python-version`,
uv cố định phiên bản, `uv sync --locked` và `make check`. Không tự cấu hình deploy.

## Chuyển project cũ

Không chạy `pynew` lên project đã có. Chọn từng project và kiểm tra Python trên
deployment, cấu hình hiện tại, dependency và cách build trước khi đổi.

- Đã dùng uv: kiểm tra `.python-version`, `uv.lock`, rồi `uv sync --locked`.
- Có `pyproject.toml` nhưng chưa dùng uv: xác định Python, dùng `uv python pin`
  cho phiên bản phù hợp, chạy `uv lock`, `uv sync`, rồi test đầy đủ.
- Chỉ có `requirements.txt`: có thể giữ workflow cũ bằng `uv venv --python 3.12`
  và `uv pip sync requirements.txt` cho tới khi sẵn sàng migrate.
- Với project chỉ hỗ trợ Python khác 3.12, pin phiên bản đúng; không ép theo global default.

Không đổi hàng loạt project công ty. Các project hiện tại chưa được migrate bởi setup này.

## Notebook và DE

Với notebook trong VS Code, thêm kernel vào đúng project:

```sh
uv add --dev ipykernel
```

Chọn kernel `.venv` trong notebook. Nếu cần giao diện browser độc lập:

```sh
uv add --dev jupyterlab
uv run --locked jupyter lab
```

PostgreSQL, Kafka, Redis, MinIO chạy qua Docker Compose/OrbStack theo project.
Java/Spark, `PYSPARK_PYTHON`, `SPARK_HOME` và cloud credential phải khớp runtime
deployment; không export chung cho mọi project từ `.zshrc`.
Nếu cần đọc biến môi trường cho script: `uv run --env-file .env python script.py`.

Với CLI độc lập, dùng `uvx TOOL` để chạy hoặc `uv tool install TOOL` để cài riêng.
Tool được project/CI sử dụng nên nằm trong dev dependencies và chạy qua `uv run`.

## Tham khảo

- [uv Python versions](https://docs.astral.sh/uv/concepts/python-versions/)
- [uv projects](https://docs.astral.sh/uv/guides/projects/)
- [uv tools](https://docs.astral.sh/uv/concepts/tools/)
- [uv GitHub Actions](https://docs.astral.sh/uv/guides/integration/github/)
