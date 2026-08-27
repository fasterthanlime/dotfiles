
if [[ -f ~/.cargo/env ]]; then
	source ~/.cargo/env
fi

# PATH additions
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.ghcup/bin:$PATH:$HOME/go/bin"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
. "$HOME/.cargo/env"

# zsh has a `log` builtin that shadows /usr/bin/log in NON-interactive shells
# (harness/agent shells source only .zshenv). Interactive rc chain already
# loses the builtin; this evens it out so `log show` works everywhere.
disable log 2>/dev/null
