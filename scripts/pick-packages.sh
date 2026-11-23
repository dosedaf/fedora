#!/usr/bin/env bash
# Pick packages interactively, save the selection. Does not install.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

kind="${1:-dnf}"
case "$kind" in
    dnf)     list=packages/dnf-userinstalled.txt; preview='dnf info {} 2>/dev/null | head -25' ;;
    flatpak) list=packages/flatpak.txt;           preview='flatpak info {} 2>/dev/null | head -25' ;;
    brew)    list=packages/brew-formulae.txt;     preview='brew info {} 2>/dev/null | head -20' ;;
    npm)     list=packages/npm.txt;               preview='npm view {} 2>/dev/null | head -20' ;;
    uv)      list=packages/uv.txt;                preview='echo {}' ;;
    *) echo "usage: $0 dnf|flatpak|brew|npm|uv" >&2; exit 1 ;;
esac

[ -s "$list" ] || { echo "nothing in $list" >&2; exit 1; }

out="packages/selected-$kind.txt"
fzf --multi --height 80% --reverse \
    --header "pick $kind packages - TAB select, ENTER save" \
    --preview "$preview" < "$list" > "$out" || true

echo "saved $(wc -l < "$out") -> $out"
