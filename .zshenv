
if [[ -f ~/.cargo/env ]]; then
	source ~/.cargo/env
fi

# PATH additions
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.ghcup/bin:$PATH:$HOME/go/bin"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
