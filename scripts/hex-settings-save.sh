#!/usr/bin/env bash
# Snapshot the running Hex's settings into hex/settings.json.
# Read-only keys, keys for other OSes, and secrets are skipped.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$repo/hex/settings.json"
raw="$out.raw"
tmp="$out.tmp"

command -v hex >/dev/null || { echo "hex is not installed" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }

mkdir -p "$(dirname "$out")"

if ! hex settings list --json >"$raw" 2>/dev/null; then
    rm -f "$raw"
    echo "could not read Hex settings (is Hex running? try: hex start)" >&2
    exit 1
fi

python3 - "$raw" >"$tmp" <<'PY'
import json, sys

with open(sys.argv[1]) as f:
    doc = json.load(f)

settings = {
    entry["key"]: entry["value"]
    for entry in doc["settings"]
    if entry.get("writable") and entry.get("available")
}

# Machine-local routing; can hold an API key (jevApiKey), so never commit it.
settings.pop("capture.routing", None)

json.dump(settings, sys.stdout, indent=2, sort_keys=True)
sys.stdout.write("\n")
PY

rm -f "$raw"
mv "$tmp" "$out"
echo "saved $(python3 -c 'import json,sys; print(len(json.load(open(sys.argv[1]))))' "$out") settings to ${out#"$repo"/}"
