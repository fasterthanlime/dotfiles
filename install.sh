#!/bin/bash

if [[ -d ~/powerlevel10k ]]; then
	echo "powerlevel10k is already installed"
else
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
fi

mkdir -p ~/.local/bin

# if [[ -f ~/.local/bin/starship ]]; then
# 	echo "starship is already installed"
# else
# 	curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir ~/.local/bin
# fi

if [[ -d ~/.tmux/plugins/tpm ]]; then
	echo "tpm is already installed"
else
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Creating symlinks..."
basedir=$PWD

mkdir -p ~/.config/

for i in .p10k.zsh .zshrc .zshrc.d .tmux.conf .config/starship.toml; do
	ln -f -s $PWD/$i ~/$(dirname $i)
done
echo "Creating symlinks... done!"

