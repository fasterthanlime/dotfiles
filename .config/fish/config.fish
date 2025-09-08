set -U fish_greeting

set -gx PATH \
            $HOME/.cargo/bin \
            /opt/homebrew/bin \
            /opt/homebrew/sbin \
            /opt/homebrew/opt/curl/bin \
            /usr/local/go/bin \
            $HOME/.local/bin \
            $HOME/go/bin \
            $PATH
set -gx EDITOR nvim

set -gx BEARDIST_CACHE_DIR /tmp/beardist-cache

if test (uname) = "Linux"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    set -gx PKG_CONFIG_PATH /home/linuxbrew/.linuxbrew/lib/pkgconfig
    set -gx LD_LIBRARY_PATH /home/linuxbrew/.linuxbrew/lib
end

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
set -gx CDPATH . ~/work ~/play ~/sdr-pod ~/sdr ~/bearcove ~/facet-rs/facet ~/facet-rs ~/bearcove/home ~/bearcove/home/crates ~/bearcove/home/binaries ~/bearcove/facet ~

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
alias nrc "cargo nextest run --no-capture"
alias nff "cargo nextest run --no-fail-fast"
alias nffa "cargo nextest run --no-fail-fast --all-features"
alias mff "cargo +nightly miri nextest run --no-fail-fast"
alias mffa "cargo +nightly miri nextest run --no-fail-fast --all-features"
alias nr "cargo nextest run"
alias k kubectl
alias tf tofu
alias earthly "earthly -i"
alias e earthly
alias eb "earthly build"
alias ls "eza --color=always"
alias l "eza --color=always -lhA"
alias ll "eza --color=always -lh"
alias objdump "objdump -Mintel"
alias rp "release-plz"

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
alias c cargo
alias crd "cargo run"
alias crp "cargo run --release"
alias lg "lazygit"
alias p "pnpm"
alias npm "echo use_pnpm"
alias ntr "cargo nextest run"
alias nt "cargo nextest"
# alias terraform "echo use_tofu"
# alias tf "echo use_tofu"
alias bd beardist
alias ci "cargo insta"
alias cir "cargo insta review"
alias claude "/Users/amos/.claude/local/claude"

alias gpnv "git push --no-verify"
alias gpfnv "git push --force-with-lease --no-verify"

# mnemonic: "git add commit push"
function acp
    git add .
    git commit -m "$argv"
    git push
end

# mnemonic: "cargo install dot"
function cid
    cargo install --path . --locked
end

function ipinfo
    curl -s "https://ipinfo.io/$argv[1]/json" | jq -C '.'
end

# Load additional completions from jj util
if type -q jj
    jj util completion fish | source
end

# pnpm
if test (uname) = "Darwin"
    set -gx PNPM_HOME "$HOME/Library/pnpm"
else
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
end
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/amos/.lmstudio/bin
alias claude="/Users/amos/.claude/local/claude"

set -gx CEF_PATH "$HOME/.local/share/cef"
set -gx DYLD_FALLBACK_LIBRARY_PATH $DYLD_FALLBACK_LIBRARY_PATH $CEF_PATH "$CEF_PATH/Chromium Embedded Framework.framework/Libraries"

