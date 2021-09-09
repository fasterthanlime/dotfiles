#!/bin/bash

if [[ -d ~/powerlevel10k ]]; then
	echo "powerlevel10k is already installed"
else
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
fi

echo "Creating symlinks..."
basedir=$PWD
for i in .p10k.zsh .zshrc .zshrc.d; do
	ln --verbose --force --symbolic ./dotfiles/$i ~/
done
echo "Creating symlinks... done!"

if [[ -z "$CLOUDSMITH_API_KEY" ]]; then
	echo "CLOUDSMITH_API_KEY env var not set, not configuring git credential helper"
else
	echo "Setting up git credential helper"
	git config --global credential.helper store
	echo "https://fasterthanlime:${CLOUDSMITH_API_KEY}@dl.cloudsmith.io" >> ~/.git-credentials
fi
