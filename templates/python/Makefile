UV ?= uv

.PHONY: sync run lint format typecheck test check

sync:
	$(UV) sync --locked

run:
	$(UV) run --locked app

lint:
	$(UV) run --locked ruff check .

format:
	$(UV) run --locked ruff format .

typecheck:
	$(UV) run --locked basedpyright

test:
	$(UV) run --locked pytest

check: lint typecheck test
	$(UV) run --locked ruff format --check .
