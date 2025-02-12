set -gx PATH \
            $HOME/.cargo/bin \
            /opt/homebrew/bin \
            /opt/homebrew/sbin \
            /opt/homebrew/opt/curl/bin \
            $HOME/.local/bin \
            $HOME/go/bin \
            $PATH
set -gx EDITOR vim

# Key bindings
bind \e\[1\;5C forward-word
bind \e\[1\;5D backward-word
bind \e\[1\;3C forward-word
bind \e\[1\;3D backward-word
bind \e\[3~ delete-char
bind \e\[3\;3~ delete-word
bind \e\[H beginning-of-line
bind \e\[F end-of-line

set -gx WORDCHARS '*?_-.~=&;!#$%^(){}<>'

# Paths I often jump to
set -gx CDPATH . ~/work ~/sdr-pod ~/bearcove ~/bearcove/lith ~/bearcove/lith/mods ~/bearcove/lith/common ~/bearcove/loona/crates ~

# Extend function path with additional completions directory
set -gx fish_function_path ~/.zshrc.d/completions $fish_function_path

# Include Homebrew zsh site functions if available
if type -q brew
    set -gx fish_function_path (brew --prefix)/share/zsh/site-functions $fish_function_path
end

# Aliases
alias vim nvim
alias j just
alias nt "cargo nextest"
alias k kubectl
alias tf tofu
alias earthly "earthly -i"
alias e earthly
alias eb "earthly build"
alias ls "eza --color=always"
alias l "eza --color=always -lhA"
alias ll "eza --color=always -lh"
alias objdump "objdump -Mintel"

# Git aliases and functions
if test -f ~/.config/fish/git-alias.fish
    source ~/.config/fish/git-alias.fish
end

function git-skip
    echo $argv[1] >> .git/info/exclude
end

function git-unskip
    sed -i "/$argv[1]/d" .git/info/exclude
end

function git-ls-skipped
    cat .git/info/exclude
end

function seecert
    nslookup $argv[1]
    printf "Q" | openssl s_client -showcerts -servername $argv[1] -connect $argv[1]:443 | openssl x509 -text | grep -iA2 "Validity"
end

# Starship prompt initialization
starship init fish | source

# Atuín history and completions
atuin init fish --disable-up-arrow | source

alias t "lith term --"

alias carog cargo
alias carg cargo
alias cagro cargo
alias carho cargo
alias crago cargo
alias crd "cargo run"
alias crp "cargo run --release"

# Load additional completions from jj util
if type -q jj
    jj util completion fish | source
end
