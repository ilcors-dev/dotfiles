#!/bin/bash

set -euo pipefail

usage() {
	cat <<'EOF'
Usage:
  ./setup-git-signing.sh <default-key-name> [override-key-name override-repo-path]

Examples:
  ./setup-git-signing.sh id_ed25519
  ./setup-git-signing.sh id_ed25519 jethr ~/src/jethr

This script:
  - installs gnupg and pinentry-mac with Homebrew
  - configures gpg-agent to use pinentry-mac
  - enables Git SSH commit signing globally
  - sets the default signing key from ~/.ssh/<default-key-name>.pub
  - optionally overrides the signing key for repos under override-repo-path
EOF
}

fail() {
	printf 'Error: %s\n' "$1" >&2
	exit 1
}

normalize_key_name() {
	local key_name="$1"
	printf '%s\n' "${key_name%.pub}"
}

expand_path() {
	case "$1" in
		~) printf '%s\n' "$HOME" ;;
		~/*) printf '%s/%s\n' "$HOME" "${1#~/}" ;;
		*) printf '%s\n' "$1" ;;
	esac
}

signer_line_from_pub() {
	local pub_path="$1"
	local algorithm key comment

	read -r algorithm key comment < "$pub_path"
	if [[ -z "${algorithm:-}" || -z "${key:-}" ]]; then
		fail "Could not parse SSH public key: $pub_path"
	fi

	if [[ -z "${comment:-}" ]]; then
		comment="$(basename "$pub_path" .pub)"
	fi

	printf '%s %s %s\n' "$comment" "$algorithm" "$key"
}

append_unique_line() {
	local file_path="$1"
	local line="$2"

	touch "$file_path"
	if ! grep -Fqx "$line" "$file_path"; then
		printf '%s\n' "$line" >> "$file_path"
	fi
}

if [[ $# -ne 1 && $# -ne 3 ]]; then
	usage
	exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
	fail "Homebrew is required. Install it first or run bootstrap.sh before this script."
fi

default_key_name="$(normalize_key_name "$1")"
default_pub="$HOME/.ssh/${default_key_name}.pub"

if [[ ! -f "$default_pub" ]]; then
	fail "Missing SSH public key: $default_pub"
fi

brew install gnupg pinentry-mac

pinentry_path="$(command -v pinentry-mac || true)"
if [[ -z "$pinentry_path" ]]; then
	fail "pinentry-mac was not found after installation"
fi

mkdir -p "$HOME/.gnupg" "$HOME/.config/git"
chmod 700 "$HOME/.gnupg"

printf 'pinentry-program %s\n' "$pinentry_path" > "$HOME/.gnupg/gpg-agent.conf"
chmod 600 "$HOME/.gnupg/gpg-agent.conf"
gpgconf --kill gpg-agent || true

allowed_signers="$HOME/.config/git/allowed_signers"
append_unique_line "$allowed_signers" "$(signer_line_from_pub "$default_pub")"
chmod 600 "$allowed_signers"

git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global user.signingkey "$default_pub"
git config --global gpg.ssh.allowedSignersFile "$allowed_signers"

if [[ $# -eq 3 ]]; then
	override_key_name="$(normalize_key_name "$2")"
	override_pub="$HOME/.ssh/${override_key_name}.pub"
	override_repo_path="$(expand_path "$3")"
	override_config="$HOME/.gitconfig-${override_key_name}"

	if [[ ! -f "$override_pub" ]]; then
		fail "Missing SSH public key: $override_pub"
	fi

	append_unique_line "$allowed_signers" "$(signer_line_from_pub "$override_pub")"
	git config --file "$override_config" user.signingkey "$override_pub"
	git config --global --replace-all "includeIf.gitdir:${override_repo_path%/}/.path" "$override_config"
fi

printf 'Configured Git SSH signing with default key %s\n' "$default_key_name"
if [[ $# -eq 3 ]]; then
	printf 'Configured override key %s for repos under %s\n' "$override_key_name" "$override_repo_path"
fi
