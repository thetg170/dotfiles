export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  fast-syntax-highlighting
)

export PATH="$HOME/.local/bin:$PATH"

source $ZSH/oh-my-zsh.sh


# Navigation
alias work="cd ~/work"
alias dot="cd ~/work/dotfiles"
alias vntt="cd ~/Developer/Vntt"
alias pdev="cd ~/Developer/Personal"
alias box="cd ~/Developer/Sandbox"

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
alias pip="pip3"

# uv completions
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"

# Starship prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"
