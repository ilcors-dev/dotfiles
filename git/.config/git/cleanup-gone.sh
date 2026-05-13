#!/bin/sh

mode=${1:---preview}

case "$mode" in
	--preview|preview)
		delete=0
		;;
	--delete|delete)
		delete=1
		;;
	*)
		printf 'usage: %s [--preview|--delete]\n' "$0" >&2
		exit 2
		;;
esac

git fetch --prune || exit $?

current_branch=$(git branch --show-current)
branches=$(
	git branch --format='%(if:equals=[gone])%(upstream:track)%(then)%(refname:short)%(end)' --omit-empty |
		grep -Fxv "$current_branch" |
		grep -Ev '^(main|master|develop|dev|production|staging[0-9]*)$' || true
)

if [ -z "$branches" ]; then
	exit 0
fi

if [ "$delete" -eq 0 ]; then
	printf '%s\n' "$branches"
	exit 0
fi

git branch -d $branches
