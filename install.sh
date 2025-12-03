#!/usr/bin/env zsh
set -x

mkdir -p ~/.local/bin

if [[ -d ~/.tmux/plugins/tpm ]]; then
	echo "tpm is already installed"
else
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Creating symlinks..."

# get the path of the current script
script_dir="$(cd "$(dirname "${(%):-%N}")"; pwd -P)"

mkdir -p ~/.config/
mkdir -p ~/.config/tmux
mkdir -p ~/.config/fish
mkdir -p ~/.config/wezterm/colors

git config --global core.excludesFile '~/.gitignore'

for i in .gitignore .zshenv .zshrc .zshrc.d .wezterm.lua .config/starship.toml .config/zed .config/tmux/tmux.conf .config/fish/config.fish .config/fish/git-alias.fish .config/grit.conf .config/wezterm/colors/melange_dark.toml .config/wezterm/colors/melange_light.toml; do
	ln -f -s $script_dir/$i ~/$(dirname $i)
done
echo "Creating symlinks... done!"

# Set Git settings
git config --global push.autoSetupRemote true
git config --global init.defaultBranch main
git config --global receive.denyCurrentBranch updateInstead

if command -v difft &>/dev/null; then
    echo "difftastic is already installed"
else
    brew install difftastic
fi

git config --global diff.external 'difft --color=always --syntax-highlight=on --display=inline --width=80'
git config --global core.pager 'less -R'
git config --global merge.conflictStyle zdiff3

git config --global diff.tool difftastic
git config --global difftool.difftastic.cmd 'difft --color=always --display=inline --syntax-highlight=on --width=80 "$LOCAL" "$REMOTE"'
git config --global difftool.prompt false
git config --global alias.dft difftool

git config --global alias.tagpush '!f() { git tag "$1" && git push origin "$1"; }; f'

# For everything inside `~/dotfiles/bin`, create a symlink in `~/.local/bin`
for file in ~/dotfiles/bin/*; do
    if [[ -f "$file" ]]; then
        ln -sf "$file" ~/.local/bin/
    fi
done

echo "Setup completed successfully!"
