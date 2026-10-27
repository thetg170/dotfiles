#!/bin/sh
set -eu
editor=/opt/dotfiles/editor
version=4
remote_user="${1:-root}"
if [ ! -f "$editor/.installed-$version" ]; then
  command -v apt-get >/dev/null || {
    echo 'Automatic editor tooling currently supports Debian/Ubuntu dev containers.' >&2
    exit 1
  }
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y --no-install-recommends ca-certificates curl git build-essential pkg-config libclang-dev unzip xz-utils ripgrep fd-find python3-venv ncurses-term ncurses-bin
  # tmux-256color must describe real italics, not screen's legacy standout mode.
  infocmp -1 tmux-256color | grep -q 'sitm='
  mkdir -p "$editor/bin"
  case "$(uname -m)" in
    aarch64|arm64) nvim_arch=arm64; node_arch=arm64; nvim_sha=8f1f64a0bdb97247034038c3823c6cbad5bdf9ecd5751b85494b71c3ee04c815 ;;
    x86_64|amd64) nvim_arch=x86_64; node_arch=x64; nvim_sha=474430d53e6264f6d6dd18db42d6dc9df3a1b56ca9e88a325bbf860e1a811d87 ;;
    *) echo 'Unsupported CPU architecture.' >&2; exit 1 ;;
  esac
  scratch="$(mktemp -d)"
  trap 'rm -rf "$scratch"' EXIT
  curl -fL --retry 3 "https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-linux-$nvim_arch.tar.gz" -o "$scratch/nvim.tar.gz"
  printf '%s  %s\n' "$nvim_sha" "$scratch/nvim.tar.gz" | sha256sum -c -
  tar -xzf "$scratch/nvim.tar.gz" -C "$editor"
  ln -sf "$editor/nvim-linux-$nvim_arch/bin/nvim" "$editor/bin/nvim"
  node_name="node-v24.19.0-linux-$node_arch.tar.xz"
  curl -fL --retry 3 "https://nodejs.org/dist/v24.19.0/$node_name" -o "$scratch/$node_name"
  curl -fL --retry 3 https://nodejs.org/dist/v24.19.0/SHASUMS256.txt -o "$scratch/SHASUMS256.txt"
  (cd "$scratch" && grep " $node_name\$" SHASUMS256.txt | sha256sum -c -)
  tar -xJf "$scratch/$node_name" -C "$editor"
  for program in node npm npx; do
    ln -sf "$editor/node-v24.19.0-linux-$node_arch/bin/$program" "$editor/bin/$program"
  done
  export PATH="$editor/bin:$PATH"
  npm install --prefix "$editor" basedpyright@1.40.2
  ln -sf "$editor/node_modules/.bin/basedpyright-langserver" "$editor/bin/basedpyright-langserver"
  ln -sf "$editor/node_modules/.bin/basedpyright" "$editor/bin/basedpyright"
  # Build against this container's libc. Upstream ARM64 binaries currently need
  # glibc 2.39, while common Python/Spark images still use Debian 12/Ubuntu 22.
  if ! "$editor/bin/tree-sitter" --version >/dev/null 2>&1; then
    export CARGO_HOME="$editor/build-cargo" RUSTUP_HOME="$editor/build-rustup"
    export CARGO_TARGET_DIR="$editor/build-tree-sitter"
    curl -fsSL --retry 3 https://sh.rustup.rs -o "$scratch/rustup.sh"
    sh "$scratch/rustup.sh" -y --profile minimal --default-toolchain 1.91.1 --no-modify-path
    PATH="$CARGO_HOME/bin:$PATH" cargo install --git https://github.com/tree-sitter/tree-sitter \
      --rev 87165ab22a770bdb147f35f20c130cfab06dc768 --locked --root "$editor/tree-sitter" tree-sitter-cli
    ln -sf "$editor/tree-sitter/bin/tree-sitter" "$editor/bin/tree-sitter"
    rm -rf "$CARGO_HOME" "$RUSTUP_HOME" "$CARGO_TARGET_DIR"
  fi
  # Ruff's Linux executable is independent of the project's Python interpreter.
  if ! command -v ruff >/dev/null; then
    python3 -m venv "$editor/ruff"
    "$editor/ruff/bin/pip" install ruff==0.16.9
    ln -sf "$editor/ruff/bin/ruff" "$editor/bin/ruff"
  fi
  ln -sf /usr/bin/fdfind "$editor/bin/fd"
  touch "$editor/.installed-$version"
fi
mkdir -p /opt/dotfiles/state/data /opt/dotfiles/state/state /opt/dotfiles/state/cache
chown "$remote_user" /opt/dotfiles/state /opt/dotfiles/state/data /opt/dotfiles/state/state /opt/dotfiles/state/cache
