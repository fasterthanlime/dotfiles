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
    ~/work
    ~/sdr-pod
    ~/bearcove
    ~/bearcove/lith
    ~/bearcove/lith/mods
    ~/bearcove/lith/common
    ~/bearcove/loona/crates
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
    cargo fmt || true
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

alias k="kubectl"
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
alias npm="echo no"

# source <(jj util completion zsh)

. "$HOME/.cargo/env"

# pnpm
export PNPM_HOME="/Users/amos/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/amos/.lmstudio/bin"
alias claude="/Users/amos/.claude/local/claude"
