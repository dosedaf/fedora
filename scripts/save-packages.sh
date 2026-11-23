#!/usr/bin/env bash
# Refresh package snapshots. Nothing is installed.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

dnf5 repoquery --userinstalled --queryformat '%{name}\n' 2>/dev/null | sort -u > packages/dnf-userinstalled.txt
flatpak list --app --columns=application 2>/dev/null | sort > packages/flatpak.txt
brew list --formula 2>/dev/null | sort > packages/brew-formulae.txt
brew bundle dump --file=packages/Brewfile --force 2>/dev/null || true
ls "$HOME/.npm-global/lib/node_modules" 2>/dev/null | grep -v '^npm$' | sort > packages/npm.txt || true
uv tool list 2>/dev/null | awk '/^[a-zA-Z0-9_-]+ v/{print $1}' | sort > packages/uv.txt || true

echo "snapshots updated"
