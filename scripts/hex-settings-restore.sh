#!/usr/bin/env bash
# Apply hex/settings.json to the installed Hex. Safe to re-run; keys this OS
# or Hex version does not accept are skipped (and listed).
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
file="$repo/hex/settings.json"

command -v hex >/dev/null || { echo "hex is not installed; install it first, then rerun this script" >&2; exit 1; }
[ -s "$file" ] || { echo "missing $file; create it with scripts/hex-settings-save.sh" >&2; exit 1; }

data="${XDG_DATA_HOME:-$HOME/.local/share}/hex"
if [ -f "$data/settings.json" ]; then
    bak="$data/settings.json.bak-$(date +%Y%m%d-%H%M%S)"
    cp -a "$data/settings.json" "$bak"
    echo "backed up current settings to $bak"
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# /home/yoda is the machine that wrote the snapshot; repoint it to this $HOME
# so folder settings still make sense on a different user or machine.
sed "s#/home/yoda#${HOME}#g" "$file" >"$tmp"

skipped=()
apply() { hex settings apply "$tmp" 2>&1; }

while ! out=$(apply); do
    key=$(printf '%s\n' "$out" | sed -n 's/.*`\([^`]*\)`.*/\1/p' | head -n1)
    if [ -z "$key" ]; then
        printf '%s\n' "$out" >&2
        exit 1
    fi
    python3 - "$tmp" "$key" <<'PY'
import json, sys

path, key = sys.argv[1], sys.argv[2]
with open(path) as f:
    settings = json.load(f)
settings.pop(key, None)
with open(path, "w") as f:
    json.dump(settings, f, indent=2, sort_keys=True)
    f.write("\n")
PY
    skipped+=("$key")
done

[ -n "$out" ] && printf '%s\n' "$out"
[ ${#skipped[@]} -gt 0 ] && echo "skipped ${#skipped[@]} keys this machine does not support: ${skipped[*]}"
echo "applied ${file#"$repo"/}"
