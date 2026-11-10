#!/usr/bin/env bash
# How this port was carried from the upstream jar, and what was changed after.
# Run from the repository root; the jar is the player's own download.
#
#   MCW_JAR=.../mcw-fences-1.1.2-mc1.21.1neoforge.jar HORIZON=../../engine bash tools/carry.sh
#
# It rewrites content/assets and content/data, so the committed tree is this script
# plus the manifest, the creative tab and the properties table. Nothing is uploaded.
set -euo pipefail
cd "$(dirname "$0")/.."

JAR="${MCW_JAR:?set MCW_JAR to the upstream mcw-fences-1.1.2 jar}"
HORIZON="${HORIZON:-../../engine}"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# 1. The mechanical carry: assets/ and data/ upgraded from 1.21.1 to 26.3, the item
#    definitions 1.21.4 introduced, recipes and loot tables rewritten, and block
#    templates guessed from the jar's classes (all FenceBlock/FenceGateBlock).
cargo run -q --manifest-path "$HORIZON/Cargo.toml" -p horizon-port-pack -- \
    check "$JAR" "$work/carry"
rm -rf content/assets content/data
cp -r "$work/carry/carry/assets" content/assets
cp -r "$work/carry/carry/data" content/data

# 2. content/horizon-mod.toml is this port's own manifest, not the carry's stub.

# 3. The upstream creative tab is registered in Java (`TabInit`); as data it is
#    data/mcwfences/horizon/creative_tab/fences.json, generated from the block list.

# 4. Hardness, blast resistance, sounds, map colour and the tool rule, from the
#    mod's BlockInit, applied over the templates.
python3 tools/apply_properties.py

echo "carried; rebuild with: cd content && cargo horizon-mod build"
