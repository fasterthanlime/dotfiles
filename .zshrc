
## Git editor
export EDITOR=vim
## But keep emacs keymap
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

if [[ -f ~/.cargo/env ]]; then
	source ~/.cargo/env
fi

## Paths I often jump to
export CDPATH=.:~/work:~/bearcove:~/bearcove/lith:~/bearcove/lith/mods:~/bearcove/lith/common:~

## This apparently makes tab-complete with CDPATH work
fpath=(~/.zshrc.d/completions $fpath)

if type brew &>/dev/null
then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

autoload -Uz compinit && compinit

# PATH additions
export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.ghcup/bin:$PATH:$HOME/go/bin:$HOME/.local/bin

####################################################
## Aliases
####################################################

alias nt="cargo nextest"
alias k="kubectl"
alias fact="act --rm -W .forgejo/workflows -P docker=node:16-bullseye"
alias tf="tofu"

## Colorful ls
alias ls="eza --color=always"
alias l="eza --color=always -lhA"
alias ll="eza --color=always -lh"

## I don't like AT&T syntax
alias objdump="objdump -Mintel"

## zprezto-like git aliases
source $HOME/.zshrc.d/git-alias.zsh

eval "$(direnv hook zsh)"

## starship prompt
eval "$(starship init zsh)"

## mise
eval "$(mise activate zsh)"

eval "$(atuin init zsh --disable-up-arrow)"

alias da="/opt/homebrew/bin/direnv allow"

alias t="terminus"

export PROVIDER=ollama

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

function seecert () {
  nslookup $1
  (openssl s_client -showcerts -servername $1 -connect $1:443 <<< "Q" | openssl x509 -text | grep -iA2 "Validity")
}

alias mosh="mosh --server=/opt/homebrew/bin/mosh-server"


alias earthly="earthly -i"
alias e="earthly"
alias eb="earthly build"
alias vim="nvim"

export SOPRINTLN=1
