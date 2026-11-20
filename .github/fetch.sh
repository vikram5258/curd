#!/bin/bash
# Fetches the source this build was asked for into ./source, and sets
# TAG for the steps after it. The source is private: nothing about it is
# printed here.
set -eu
sha=$(sed -n 's/^sha=\([0-9a-f]\{40\}\)$/\1/p' build/request)
tag=$(sed -n 's/^tag=\(v[0-9][0-9.]*\)$/\1/p' build/request)
if [ -z "$sha" ] || [ -z "$tag" ]; then
    echo "build/request does not name a commit and a version"
    exit 1
fi
echo "TAG=$tag" >> "$GITHUB_ENV"
if [ "${1:-}" = "--tag-only" ]; then
    exit 0
fi
mkdir -p "$HOME/.ssh"
printf '%s\n' "$KEY" > "$HOME/.ssh/source_key"
chmod 600 "$HOME/.ssh/source_key"
export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/source_key -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"
if ! git clone --quiet "git@github.com:$SOURCE.git" source >/dev/null 2>&1; then
    rm -f "$HOME/.ssh/source_key"
    echo "Could not fetch the source"
    exit 1
fi
rm -f "$HOME/.ssh/source_key"
git -C source checkout --quiet "$sha" >/dev/null 2>&1
echo "Fetched the source for $tag"
