# Keep user tools first and avoid PATH growth when reloading the config.
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/bin" $path)
if [[ -x /opt/homebrew/bin/brew ]]; then
  path=("$HOME/.local/bin" /opt/homebrew/bin /opt/homebrew/sbin $path)
elif [[ -x /usr/local/bin/brew ]]; then
  path=("$HOME/.local/bin" /usr/local/bin /usr/local/sbin $path)
fi
# Prefer the Homebrew-managed uv/uvx without changing Python's PATH priority.
for uv_bin_dir in /opt/homebrew/opt/uv/bin /usr/local/opt/uv/bin; do
  if [[ -x "$uv_bin_dir/uv" ]]; then
    path=("$uv_bin_dir" $path)
    break
  fi
done
unset uv_bin_dir
export PATH

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

ZSH_THEME=""

plugins=(git)
for plugin in zsh-autosuggestions fast-syntax-highlighting; do
  [[ -d "${ZSH_CUSTOM:-$ZSH/custom}/plugins/$plugin" ]] && plugins+=("$plugin")
done
unset plugin
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Shared history for terminal tabs and tmux panes. Leading spaces skip saving.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

if (( $+commands[nvim] )); then
  export EDITOR="${EDITOR:-nvim}"
else
  export EDITOR="${EDITOR:-vim}"
fi
export VISUAL="${VISUAL:-$EDITOR}"
export PAGER="${PAGER:-less}"
export BAT_THEME=gruvbox-dark
bindkey -e

# Match Neovim completion: Ctrl+y accepts, Ctrl+e dismisses suggestions.
if (( ${+widgets[autosuggest-accept]} && ${+widgets[autosuggest-clear]} )); then
  bindkey '^Y' autosuggest-accept
  bindkey '^E' autosuggest-clear
fi

# Navigation
typeset -g DOTFILES_DIR="${${(%):-%x}:A:h}"
alias work="cd ~/work"
alias dot='cd -- "$DOTFILES_DIR"'
alias vntt="cd ~/Developer/Vntt"
alias pdev="cd ~/Developer/Personal"
alias box="cd ~/Developer/Sandbox"
dev() {
  "$DOTFILES_DIR/scripts/dev.sh" "$@"
}
source "$DOTFILES_DIR/codex/shell.zsh"

# Git
alias gst="git status"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gcm="git commit -m"
alias gps="git push"
alias gpl="git pull"
alias glg="git log --oneline --graph --decorate"

# Python
alias py="python3"
unalias pip 2>/dev/null
pynew() {
  "$DOTFILES_DIR/scripts/new-python.sh" "$@"
}

expy() (
  if [[ $# != 1 || ! "$1" =~ '^[a-z0-9]+(-[a-z0-9]+)*$' ]]; then
    print -u2 'Usage: expy <exercise-slug>'
    return 2
  fi
  local workspace exercise solution
  workspace=$(exercism workspace) || return
  exercise="$workspace/python/$1"
  if [[ ! -f "$exercise/.exercism/config.json" ]]; then
    exercism download --track=python --exercise="$1" || return
  fi
  cd -- "$exercise" || return
  solution=$(python3 -c 'import json; print(json.load(open(".exercism/config.json"))["files"]["solution"][0])') || return
  exec nvim -- "$solution"
)

# Keep the original ls/cat commands; use these when extra detail helps.
if (( $+commands[eza] )); then
  alias ll='eza -l --group-directories-first --icons=auto'
  alias la='eza -la --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
fi
(( $+commands[lazygit] )) && alias lg='lazygit'

# Ctrl+r: history; Ctrl+t: insert file paths; Alt+c: choose a directory.
if (( $+commands[fzf] )); then
  export FZF_DEFAULT_OPTS='--height=45% --layout=reverse --border --info=inline --color=dark,bg:#282828,bg+:#32302f,fg:#ebdbb2,fg+:#ebdbb2,hl:#b8bb26,hl+:#fabd2f,prompt:#83a598,pointer:#fe8019,marker:#b8bb26,spinner:#d3869b,header:#83a598,border:#504945,info:#928374,preview-bg:#282828,preview-fg:#ebdbb2'
  if (( $+commands[rg] )); then
    export FZF_CTRL_T_COMMAND='rg --files --hidden -g "!.git" -g "!node_modules" -g "!.venv" -g "!__pycache__"'
    export FZF_DEFAULT_COMMAND="$FZF_CTRL_T_COMMAND"
  fi
  if (( $+commands[bat] )); then
    export FZF_CTRL_T_OPTS='--preview "bat --theme=gruvbox-dark --color=always --style=numbers --line-range=:200 -- {}"'
  fi
  source <(fzf --zsh)
fi

# z/zi learn visited directories; cd retains its normal behavior.
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# uv completions
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"

# Starship prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"

# Machine-specific paths, environment and overrides stay outside the repo.
if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi


# Added by Antigravity CLI installer
export PATH="/Users/tranthe/.local/bin:$PATH"
