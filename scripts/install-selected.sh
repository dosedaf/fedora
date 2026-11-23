#!/usr/bin/env bash
# Install only the packages previously chosen with pick-packages.sh
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

run() {  # file installer...
    local file="$1"; shift
    [ -s "$file" ] || return 0
    echo "== $file ($(wc -l < "$file") packages)"
    xargs -r "$@" < "$file"
}

run packages/selected-dnf.txt     sudo dnf install -y
run packages/selected-flatpak.txt flatpak install -y flathub
run packages/selected-brew.txt    brew install
run packages/selected-npm.txt     npm install -g
run packages/selected-uv.txt      uv tool install

echo "done"
