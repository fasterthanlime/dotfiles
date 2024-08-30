#!/usr/bin/env zsh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

export ZSH="$HOME/.oh-my-zsh"

mkdir -p ~/.local/bin

if [[ -d ~/.tmux/plugins/tpm ]]; then
	echo "tpm is already installed"
else
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Creating symlinks..."
basedir=$PWD

mkdir -p ~/.config/
mkdir -p ~/.config/tmux

for i in .zshrc .zshrc.d .wezterm.lua .config/starship.toml .config/zed .config/tmux/tmux.conf; do
	ln -f -s $PWD/$i ~/$(dirname $i)
done
echo "Creating symlinks... done!"

