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

if [[ -z "$CLOUDSMITH_API_KEY" ]]; then
	echo "CLOUDSMITH_API_KEY env var not set, not configuring git credential helper"
else
	echo "Setting up git credential helper"
	git config --global credential.helper store
	echo "https://fasterthanlime:${CLOUDSMITH_API_KEY}@dl.cloudsmith.io" >> ~/.git-credentials
fi