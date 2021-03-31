#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")/.."

git fetch -q https://github.com/docker-library/docs.git master
numstat="$(git diff --numstat FETCH_HEAD...HEAD -- '*/README.md')"
if [ -n "$numstat" ]; then
	echo >&2 'Error: at least one repo README.md has changed'
	echo >&2 'These files are autogenerated, so it is unnecessary to modify them'
	echo >&2 'Please update content.md and docker-library-bot will take care of README.md'
	echo >&2 'See: https://github.com/docker-library/docs/#image-namereadmemd'
	echo >&2
	exit 1
fi