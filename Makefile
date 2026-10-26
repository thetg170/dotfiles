.PHONY: setup setup-de link dry-run check

setup:
	./scripts/bootstrap.sh

setup-de:
	HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_AUTOREMOVE=1 brew bundle install --file=./Brewfile.de --no-upgrade
	./scripts/check.sh

link:
	./scripts/link.sh

dry-run:
	./scripts/link.sh --dry-run

check:
	./scripts/check.sh
