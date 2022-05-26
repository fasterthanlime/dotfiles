

## Go binaries
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

## Local binaries
export PATH=$PATH:$HOME/.local/bin

## fly.io
export FLYCTL_INSTALL="/home/amos/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

## Runtime toolkit
export PATH=$PATH:$HOME/work/runtime-toolkit

## SSH key manager
which keychain &> /dev/null
if [[ $? == 0 ]]; then
	keychain -q ~/.ssh/id_ed25519
	source ~/.keychain/*-sh
fi

## PATH additions
export PATH=$PATH:~/bin

## Use neovim by default
alias vim="nvim"

## Git editor
export EDITOR=vim
## But keep emacs keymap
bindkey -e

## Paths I often jump to
export CDPATH=.:~/work:~/bearcove:~/ftl:~

## Don't make me add 'root@' to every command
export TELEPORT_LOGIN=root

## Prompt theme
source $HOME/powerlevel10k/powerlevel10k.zsh-theme

## zprezto-like git aliases
source $HOME/.zshrc.d/git-alias.zsh

## Fix ctrl-left / ctrl-right
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

## Fix home/end/delete (GNOME Terminal, outside tmux)
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char

## Fix home/end (GNOME Terminal, within tmux, with TERM=screen-256color)
bindkey  "^[[1~"   beginning-of-line
bindkey  "^[[4~"   end-of-line

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

## Colorful ls
alias ls="ls --color=always"
alias l="ls --color=always -lhA"
alias ll="ls --color=always -lh"

alias objdump="objdump -Mintel"

if [[ -f ~/.cargo/env ]]; then
        source ~/.cargo/env
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# This apparently makes tab-complete with CDPATH work
autoload -Uz compinit && compinit

# eval "$(starship init zsh)"
# eval "$(zoxide init zsh)"

# Grrr
unset AWS_REGION
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

export PATH="$WASMTIME_HOME/bin:$PATH"

export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

source /etc/zsh_command_not_found

fpath+=~/.zshrc.d/completions
compinit

