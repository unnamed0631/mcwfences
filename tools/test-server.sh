#!/usr/bin/env bash
# Run the port on a real Horizon dedicated server and assert that its blocks,
# states, tags and loot table work. Needs a Horizon build:
#
#   HORIZON_CLIENT=~/.local/share/horizon-launcher/versions/<v>/horizon-client \
#   HORIZON_RESOURCES=<a horizon-prepare output, e.g. .local/horizon-client/26.3> \
#   bash tools/test-server.sh
#
# It builds the .hmod if content/target/horizon-mod/mcwfences.hmod is missing.
# Exit status 0 means every assertion passed; the server's log is kept on failure.
set -euo pipefail
cd "$(dirname "$0")/.."
PORT="${PORT:-25571}"

: "${HORIZON_CLIENT:?set HORIZON_CLIENT to horizon-client}"
: "${HORIZON_RESOURCES:?set HORIZON_RESOURCES to a prepared resources folder}"

hmod="content/target/horizon-mod/mcwfences.hmod"
if [ ! -f "$hmod" ]; then
    (cd content && cargo horizon-mod build)
fi

dir="$(mktemp -d)"
mkdir -p "$dir/horizon-mods"
cp "$hmod" "$dir/horizon-mods/"
printf 'eula=true\n' > "$dir/eula.txt"
printf 'mod.mcwfences:true\n' > "$dir/horizon-mods.txt"
mkfifo "$dir/console"

cleanup() {
    if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
        printf 'stop\n' >&3 2>/dev/null || true
        exec 3>&- 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    fi
    rm -rf "$dir"
}
trap cleanup EXIT

# The server reads console commands from the FIFO, so the commands can be sent
# once it says it is up.
( cd "$dir" && exec "$HORIZON_CLIENT" --resources "$HORIZON_RESOURCES" --dedicated --nogui \
    --port "$PORT" --world testworld < "$dir/console" > "$dir/out" 2>&1 ) &
pid=$!
exec 3>"$dir/console"

for _ in $(seq 1 90); do
    grep -q "Done (" "$dir/out" 2>/dev/null && break
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "server exited before it was up:" >&2
        tail -40 "$dir/out" >&2
        exit 1
    fi
    sleep 1
done
grep -q "Done (" "$dir/out" || { echo "server did not come up" >&2; tail -40 "$dir/out" >&2; exit 1; }

grep -q "content from 1 mod(s)" "$dir/out" || {
    echo "the mod was not loaded (check horizon-mods.txt)" >&2
    tail -40 "$dir/out" >&2
    exit 1
}

cat >&3 <<'EOF'
forceload add 0 0
setblock 2 100 2 mcwfences:oak_picket_fence
setblock 3 100 2 mcwfences:oak_picket_fence
setblock 2 100 6 mcwfences:stone_pillar_wall
setblock 3 100 6 minecraft:stone
setblock 2 100 10 mcwfences:acacia_highley_gate
execute if block 2 100 2 mcwfences:oak_picket_fence[east=true] run say ASSERT_FENCE_CONNECTS
execute unless block 2 100 2 mcwfences:oak_picket_fence[north=true] run say ASSERT_FENCE_NORTH_OFF
execute if block 2 100 2 mcwfences:oak_picket_fence[waterlogged=false] run say ASSERT_NOT_WATERLOGGED
execute if block 2 100 2 #minecraft:fences run say ASSERT_IN_FENCES
execute if block 2 100 6 mcwfences:stone_pillar_wall[east=true] run say ASSERT_WALL_CONNECTS
execute if block 2 100 6 #minecraft:mineable/pickaxe run say ASSERT_IN_PICKAXE
execute if block 2 100 10 mcwfences:acacia_highley_gate[facing=north] run say ASSERT_GATE_FACING
loot spawn 2 101 2 loot mcwfences:blocks/oak_hedge
data get entity @e[type=item,limit=1]
EOF
sleep 8

failed=0
for marker in ASSERT_FENCE_CONNECTS ASSERT_FENCE_NORTH_OFF ASSERT_NOT_WATERLOGGED \
              ASSERT_IN_FENCES ASSERT_WALL_CONNECTS ASSERT_IN_PICKAXE ASSERT_GATE_FACING; do
    if grep -q "$marker" "$dir/out"; then
        echo "ok: $marker"
    else
        echo "FAIL: $marker" >&2
        failed=1
    fi
done
if grep -q 'id: "mcwfences:oak_hedge"' "$dir/out"; then
    echo "ok: loot table drops mcwfences:oak_hedge"
else
    echo "FAIL: the loot table did not drop mcwfences:oak_hedge" >&2
    failed=1
fi
if grep -qiE "warn|error|refus|invalid|unknown" "$dir/out"; then
    echo "note: the server logged warnings:" >&2
    grep -iE "warn|error|refus|invalid|unknown" "$dir/out" >&2 || true
fi

if [ "$failed" -ne 0 ]; then
    echo "--- server log ---" >&2
    tail -60 "$dir/out" >&2
    exit 1
fi
echo "all server assertions passed"
