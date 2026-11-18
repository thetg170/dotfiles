# ~/.bash_profile
# Load interactive Bash config.
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :
. "$HOME/.cargo/env"


# Added by Antigravity CLI installer
export PATH="/Users/tranthe/.local/bin:$PATH"
