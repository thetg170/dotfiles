UV ?= uv

.PHONY: sync run lint format typecheck test risk check

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

# Fails when the change deletes a test or adds a skip. Skipped where lgtm is not
# installed (CI) or before the first commit, when there is no HEAD to compare.
risk:
	@if ! command -v lgtm >/dev/null 2>&1; then echo "lgtm not installed; skipping test-weakening check"; \
	elif ! git rev-parse --verify -q HEAD >/dev/null; then echo "no commit yet; skipping lgtm risk"; \
	else lgtm risk; fi

check: lint typecheck test risk
	$(UV) run --locked ruff format --check .
