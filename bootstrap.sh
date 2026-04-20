#!/bin/bash

BREW_PACKAGES=(
	stow
	starship
	zsh-autosuggestions
	neovim
	fd
	tree-sitter-cli
	uv
	opencode
	lazygit
	prettierd
	eslint_d
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

echo "Installing uv-managed Python 3.13..."
"$(brew --prefix)/bin/uv" python install 3.13 --default

if [ -x "$HOME/.local/bin/ty" ]; then
	echo "Upgrading ty..."
	"$(brew --prefix)/bin/uv" tool upgrade ty
else
	echo "Installing ty..."
	"$(brew --prefix)/bin/uv" tool install ty@latest
fi

defaults write com.apple.screencapture location /tmp
killall SystemUIServer
