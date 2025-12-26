#!/bin/bash

BREW_PACKAGES=(
	stow
	starship
	zsh-autosuggestions
	neovim
)

set -e

echo "Installing base packages.."

if ! command -v brew &> /dev/null; then
	echo "Homebrew not found. Installing..."
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	if [[ -f /opt/homebrew/bin/brew ]]; then
  	eval "$(/opt/homebrew/bin/brew shellenv)"
	elif [[ -f /usr/local/bin/brew ]]; then
		eval "$(/usr/local/bin/brew shellenv)"
	fi
else
    echo "Homebrew is already installed."
fi

echo "Installing packages: ${BREW_PACKAGES[*]}..."
brew install "${BREW_PACKAGES[@]}"
