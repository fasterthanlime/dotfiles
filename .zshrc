if [[ "$IN_DEV_CONTAINER" = "1" ]]; then
	if [[ -n "$GITHUB_CODESPACE_TOKEN" ]]; then
		export REAL_HOME=$HOME
	else
		export REAL_HOME=/host/home/amos
	fi

        ## Things that don't belong in dotfiles
        if [[ -f "${REAL_HOME}/.secrets.zsh" ]]; then
                source ${REAL_HOME}/.secrets.zsh
        fi
else
	export REAL_HOME=$HOME
fi

if [[ "$IN_DEV_CONTAINER" != "1" ]]; then
	## Go binaries
	export PATH=$PATH:$HOME/go/bin
	
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
		source ~/.keychain/comet-sh
	fi

	## PATH additions
	export PATH=$PATH:~/bin

	## Use neovim by default
	alias vim="nvim"

	## Git editor
	export EDITOR=vim
	## But keep emacs keymap
	bindkey -e

	## asdf
	if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
		. $HOME/.asdf/asdf.sh
	fi

	## Paths I often jump to
	export CDPATH=.:~/work:~/bearcove:~/ftl:~

	## Things that don't belong in dotfiles
	source ~/.secrets.zsh
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## Prompt theme
# source $REAL_HOME/powerlevel10k/powerlevel10k.zsh-theme

## zprezto-like git aliases
source $REAL_HOME/.zshrc.d/git-alias.zsh

## Fix ctrl-left / ctrl-right
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

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
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(starship init zsh)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
