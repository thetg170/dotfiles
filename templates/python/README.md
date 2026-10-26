# Python project

Python 3.12, a project-local `.venv`, and dependencies locked by uv.

```sh
uv sync --locked
make run
make check
```

Add dependencies with `uv add PACKAGE` or `uv add --dev PACKAGE`. These update
`pyproject.toml` and `uv.lock`; commit both. Commit `.python-version` as well,
but never commit `.venv` or `.env` files.

Use `uv run --locked python script.py` to run scripts. No environment activation
is required. If a terminal session needs it: `source .venv/bin/activate`, then
`deactivate` when finished. Avoid installing packages into the system Python.

VS Code extension recommendations are included; select `.venv/bin/python` with
"Python: Select Interpreter" if an existing workspace remembers another Python.
Use basedpyright instead of Pylance for the same type checks as Neovim/CI.
The dotfiles Neovim config selects `.venv` and project-local language tools.

`make format` formats files; `make check` lints, checks types, tests, and verifies
formatting without modifying code. The included GitHub Actions workflow runs the
same commands against the committed lockfile.

Change `src/app` and the build/entry-point configuration when naming your package.
To target another Python version, update `.python-version`, `requires-python`,
Ruff's `target-version`, and basedpyright's `pythonVersion`, then run `uv lock`
and `uv sync --locked` and test against the deployment environment.

For notebooks, add `ipykernel` to this project's dev dependencies and select its
`.venv` kernel. Add JupyterLab only if you need the browser UI.
Keep Java/Spark environment settings and Docker Compose services project-specific.
