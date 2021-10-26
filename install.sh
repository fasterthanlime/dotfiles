#!/bin/bash

# if [[ -d ~/powerlevel10k ]]; then
# 	echo "powerlevel10k is already installed"
# else
# 	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
# fi

curl -fsSL https://starship.rs/install.sh | bash -s -- --yes

if [[ -d ~/.tmux/plugins/tpm ]]; then
	echo "tpm is already installed"
else
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Creating symlinks..."
basedir=$PWD
for i in .p10k.zsh .zshrc .zshrc.d .tmux.conf; do
	if [[ -d ~/dotfiles ]]; then
		# probably on my computer
		ln --verbose --force --symbolic ./dotfiles/$i ~/
	else
		# probably on GitHub Codespaces, which clones it elsewhere
		# then turns links into actual files for some reason
		ln --verbose --force --symbolic $PWD/$i ~/
	fi
done
echo "Creating symlinks... done!"

if [[ -z "$CLOUDSMITH_API_KEY" ]]; then
	echo "CLOUDSMITH_API_KEY env var not set, not configuring git credential helper"
else
	echo "Setting up git credential helper"
	git config --global credential.helper store
	echo "https://fasterthanlime:${CLOUDSMITH_API_KEY}@dl.cloudsmith.io" >> ~/.git-credentials
fi
