zmodload zsh/zprof

## Git editor
export EDITOR=vim

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

# Load zsh completions
autoload -Uz compinit && compinit

####################################################
## Aliases
####################################################

alias vim="nvim"

alias nt="cargo nextest"

alias k="kubectl"
alias tf="tofu"

alias mosh="mosh --server=/opt/homebrew/bin/mosh-server"

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

zprof
