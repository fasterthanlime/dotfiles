#!/bin/bash

if [[ -d ~/powerlevel10k ]]; then
	echo "powerlevel10k is already installed"
else
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
fi

echo "Creating symlinks..."
shopt -s dotglob
ln --verbose --force --symbolic ~/ftl/dotfiles/[.]* ~/
echo "Creating symlinks... done!"
