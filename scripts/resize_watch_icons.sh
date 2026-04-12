#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/scripts/watch-icon-source.png"
DEST="$ROOT/Sources/Watch/Assets.xcassets/AppIcon.appiconset"
[[ -f "$SRC" ]] || { echo "Missing $SRC — run generate_watch_icon.py first"; exit 1; }
for s in 48 55 58 87 80 88 92 100 102 108 172 196 216 234 258 1024; do
  sips -z "$s" "$s" "$SRC" --out "$DEST/${s}.png" >/dev/null
done
echo "Updated Watch AppIcon PNGs in $DEST"
