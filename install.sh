#!/usr/bin/env zsh

if [[ -d $ZSH/custom/themes/powerlevel10k ]]; then
  	echo "powerlevel10k is already installed"
else
		mkdir -p $ZSH/custom/themes
		git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
fi

mkdir -p ~/.local/bin

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

