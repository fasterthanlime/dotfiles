## Git editor
export EDITOR=nvim

####################################################
## History stuff
####################################################

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt INC_APPEND_HISTORY # append into history file
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS  ## Delete empty lines from history file
setopt HIST_NO_STORE  ## Do not add history and fc commands to the history

####################################################
## Key bindings
####################################################

bindkey -e

## Fix ctrl-left / ctrl-right
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

## Same alt-left / alt-right (WezTerm macOS)
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

## Apple Magic Keyboard on macOS: delete key
bindkey "^[[3~" delete-char
bindkey "^[[3;3~" delete-word

## ..home/end
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

export WORDCHARS='*?_-.~=&;!#$%^(){}<>'

## Paths I often jump to
cdpath=(
    .
    ~/bearcove
    ~/bearcove/cove
    ~/bearcove/cove/crates
    ~/facet-rs/facet
    ~/facet-rs
    ~
)

## This apparently makes tab-complete with CDPATH work
fpath=(~/.zshrc.d/completions $fpath)

# Include brew zsh site functions if they exist
if type brew &>/dev/null
then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

## Path setup
export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/curl/bin:/usr/local/go/bin:$HOME/.local/bin:$HOME/go/bin:$PATH"

## BeardDist cache dir
export BEARDIST_CACHE_DIR=/tmp/beardist-cache

## Linux-specific setup
if [[ $(uname) == "Linux" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    export PKG_CONFIG_PATH=/home/linuxbrew/.linuxbrew/lib/pkgconfig
    export LD_LIBRARY_PATH=/home/linuxbrew/.linuxbrew/lib
fi

## Git alias: Add commit push (acp)
function acp() {
    git add .
    git commit -m "$*"
    git push
}

# Load zsh completions
autoload -Uz compinit && compinit

####################################################
## Aliases
####################################################

alias vim="nvim"

alias j="just"
alias nt="cargo nextest"
alias nrc="cargo nextest run --no-capture"
alias nff="cargo nextest run --no-fail-fast"
alias nr="cargo nextest run"
alias dt="cargo test --doc --all-features"
alias cla="cargo clippy --all-targets --all-features"
alias claf="cargo clippy --all-targets --all-features --fix --allow-dirty"

alias kubectl="tsh kubectl"
alias k="tsh kubectl"
alias tf="tofu"

# alias mosh="mosh --server=/opt/homebrew/bin/mosh-server"

alias earthly="earthly -i"
alias e="earthly"
alias eb="earthly build"

## Colorful ls on all platforms
alias ls="eza --color=always"
alias l="eza --color=always -lhA"
alias ll="eza --color=always -lh"

## AT&T syntax makes me sad
alias objdump="objdump -Mintel"

## zprezto-like git aliases
source $HOME/.zshrc.d/git-alias.zsh
alias git-skip='f() { echo "$1" >> .git/info/exclude; }; f'
alias git-unskip='f() { sed -i "\|$1|d" .git/info/exclude; }; f'
alias git-ls-skipped='cat .git/info/exclude'

function seecert () {
  nslookup $1
  (openssl s_client -showcerts -servername $1 -connect $1:443 <<< "Q" | openssl x509 -text | grep -iA2 "Validity")
}

# Prompt — see https://starship.rs/
eval "$(starship init zsh)"

# History completion, search, etc. — see https://atuin.sh/
eval "$(atuin init zsh --disable-up-arrow)"

alias t="lith term --"

if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

alias carog="cargo"
alias carg="cargo"
alias cagro="cargo"
alias carho="cargo"
alias carho="cargo"
alias crago="cargo"
alias crd="cargo run" # cargo run "dev"
alias crp="cargo run --release" # cargo run "prod"
alias lg="lazygit"
alias p="pnpm"

# source <(jj util completion zsh)

. "$HOME/.cargo/env"

# pnpm
export PNPM_HOME="$HOME/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

eval "$(direnv hook zsh)"


# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/amos/.lmstudio/bin"

alias rp="release-plz"
alias claude="claude --allow-dangerously-skip-permissions"
alias clau="claude --model haiku --allow-dangerously-skip-permissions"
alias codex="codex --full-auto --search"

alias gid="git diff --staged"
alias gpnv="git push --no-verify"

# mocap likes its process
ulimit -n 4096

# Added by Helix CLI installer
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.amvm/bin:$PATH"

# iTerm2 integration
# source ~/.iterm2_shell_integration.zsh

# macOS clang suxx (no wasm32)
export PATH="$(brew --prefix llvm)/bin:$PATH"

# WezTerm shell integration - send OSC 7 with hostname + cwd
# Always emit for interactive shells - WezTerm needs this for cwd tracking
# (WEZTERM_PANE may not be set over SSH due to AcceptEnv restrictions)
__wezterm_osc7() {
    printf '\e]7;file://%s%s\e\\' "${HOST}" "${PWD}"
}

# Set terminal title to user@host:dir
__wezterm_title() {
    print -Pn '\e]0;%n@%m:%~\e\\'
}

# Hook into prompt
autoload -Uz add-zsh-hook
add-zsh-hook precmd __wezterm_osc7
add-zsh-hook precmd __wezterm_title

# Doesn't work anyway
export DISABLE_COST_WARNINGS=1

# Pipe to this to copy remotely
wezcopy() {
    local data b64
    data=$(cat)
    b64=$(printf '%s' "$data" | base64 | tr -d '\n')
    printf '\033]1337;SetUserVar=%s=%s\007' wez_copy "$b64"
}

# Use inside zed to counteract GIT_PAGER=""
interactive() {
    export GIT_PAGER="less -R"
}

# helper: ensure tag looks like vX.Y.Z (digits only)
is_semver_tag() {
local tag="$1"
# zsh pattern: v + digits + . + digits + . + digits
if [[ "$tag" == v[0-9]##.[0-9]##.[0-9]## ]]; then
    return 0
else
    echo "error: tag '$tag' must match vX.Y.Z (e.g. v1.2.3)" >&2
    return 1
fi
}

# push tag
ptag() {
local tag="$1"
if [[ -z "$tag" ]]; then
    echo "usage: ptag vX.Y.Z" >&2
    return 1
fi
is_semver_tag "$tag" || return 1
git tag -a "$tag" -m "$tag" && git push origin "$tag"
}

# replace tag
rtag() {
local tag="$1"
if [[ -z "$tag" ]]; then
    echo "usage: rtag vX.Y.Z" >&2
    return 1
fi
is_semver_tag "$tag" || return 1
git tag -d "$tag" && git push origin :"$tag" && ptag "$tag"
}

# list tags
ltag() {
git tag --sort=-v:refname
}


