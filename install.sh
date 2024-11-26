#!/usr/bin/env zsh

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

git config --global core.excludesFile '~/.gitignore'

for i in .gitignore .zshenv .zshrc .zshrc.d .wezterm.lua .config/starship.toml .config/zed .config/tmux/tmux.conf; do
	ln -f -s $PWD/$i ~/$(dirname $i)
done
echo "Creating symlinks... done!"

# Set Git settings
git config --global push.autoSetupRemote true
git config --global init.defaultBranch main
git config --global receive.denyCurrentBranch updateInstead

brew install git-delta

git config --global core.pager 'delta'
git config --global interactive.diffFilter 'delta'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3

# get the path of the current script
script_dir="$(cd "$(dirname "${(%):-%N}")"; pwd -P)"
delta_themes_path="$script_dir/delta-themes.gitconfig"

echo "\033[1;34m📁 Current script directory:\033[0m $script_dir"
echo "\033[1;34m📄 Delta themes config path:\033[0m $delta_themes_path"

if [ -f "$delta_themes_path" ]; then
  echo "\033[1;32m✅ Found delta-themes.gitconfig, configuring git...\033[0m"
  # Check if the include path is already configured
  if ! git config --global --get-all include.path | grep -q "$delta_themes_path"; then
    git config --global include.path "$delta_themes_path"
    echo "\033[1;32m✨ Git configuration updated successfully!\033[0m"
  else
    echo "\033[1;33m⚠️ Delta themes config already included in git config\033[0m"
  fi
else
  echo "\033[1;31m❌ Could not find delta-themes.gitconfig at:\033[0m $delta_themes_path"
fi
