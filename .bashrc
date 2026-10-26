# ~/.bashrc
# macOS-friendly default Bash config (interactive shells)
# If your login shell does not load this file automatically, add this line to ~/.bash_profile:
#   [ -f ~/.bashrc ] && . ~/.bashrc

# Stop here for non-interactive shells.
case "$-" in
  *i*) ;;
  *) return ;;
esac

# ---- History ----
HISTSIZE=5000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
shopt -s histappend cmdhist checkwinsize

# Keep history in sync across terminal tabs.
if [[ -n "${PROMPT_COMMAND:-}" ]]; then
  PROMPT_COMMAND="${PROMPT_COMMAND}; history -a; history -n"
else
  PROMPT_COMMAND="history -a; history -n"
fi

# ---- PATH helpers ----
path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

for dir in \
  "$HOME/bin" \
  "$HOME/.local/bin" \
  "/opt/homebrew/bin" \
  "/opt/homebrew/sbin" \
  "/usr/local/bin" \
  "/usr/local/sbin"
do
  [[ -d "$dir" ]] && path_prepend "$dir"
done
export PATH

# ---- Defaults ----
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export LANG="${LANG:-en_US.UTF-8}"

# ---- Prompt ----
if [[ "$TERM" != "dumb" ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\W\[\e[0m\]\$ '
else
  PS1='\u@\h:\W\$ '
fi

# ---- Aliases ----
if ls -G . >/dev/null 2>&1; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

eval "$(starship init bash)"

# ---- Bash auto-completion ----
# Homebrew bash-completion needs non-POSIX mode.
if shopt -oq posix; then
  set +o posix 2>/dev/null
fi

# Bash 3.2 does not provide mapfile/readarray; provide a minimal fallback
# used by some completion scripts (e.g. ghostty).
if ! type mapfile >/dev/null 2>&1; then
  mapfile() {
    local target="MAPFILE"
    local line
    local -a lines=()

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -t)
          shift
          ;;
        *)
          target="$1"
          shift
          break
          ;;
      esac
    done

    while IFS= read -r line; do
      lines+=("$line")
    done

    # read -r already strips trailing newlines; -t is accepted for compatibility.
    eval "$target=(\"\${lines[@]}\")"
  }
fi

shopt -s progcomp
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"
complete -cf sudo

for completion_file in \
  "/opt/homebrew/etc/profile.d/bash_completion.sh" \
  "/usr/local/etc/profile.d/bash_completion.sh" \
  "/etc/bash_completion"
do
  if [[ -r "$completion_file" ]]; then
    . "$completion_file"
    break
  fi
done

# ---- Local overrides ----
[[ -f "$HOME/.bashrc.local" ]] && . "$HOME/.bashrc.local"

export BASH_SILENCE_DEPRECATION_WARNING=1
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"
export PYSPARK_PYTHON=python3
export SPARK_HOME=/opt/spark/spark-3.5.2-bin-hadoop3
export PATH="$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH"
. "$HOME/.cargo/env"
