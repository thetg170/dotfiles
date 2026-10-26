.PHONY: setup setup-de setup-python link dry-run check check-workflow

setup:
	./scripts/bootstrap.sh

setup-de:
	HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_AUTOREMOVE=1 brew bundle install --file=./Brewfile.de --no-upgrade
	./scripts/check.sh

setup-python:
	./scripts/link.sh
	./scripts/setup-python.sh

link:
	./scripts/link.sh

dry-run:
	./scripts/link.sh --dry-run

check:
	./scripts/check.sh

check-workflow:
	nvim --headless -u NONE -l tests/ai_context.lua
	/bin/bash tests/workspace.sh
