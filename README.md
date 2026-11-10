# mcwfences (Horizon port)

A Horizon port of Macaw's Fences and Walls — MIT.

**Status:** data-tier carry. The blocks, states, drops, recipes, tags and creative tab work on
a dedicated server and on the client; the three behaviour gaps below are what a native mod
would add.

## Implemented so far

- Content API 0.2 gives a block a vanilla template's class, states and shapes, plus
  `hardness`, `explosion_resistance`, `light`, `requires_tool`, `friction`, `map_color`,
  `sounds` and `random_ticks`. That carries the **look, light, hardness, states, drops,
  recipes, tags and tabs**.
- 150 blocks: 10 leaf hedges, 47 fences, 37 gates and 56 walls, in eleven woods and
  thirteen stone sets, declared on the vanilla fence and fence-gate templates.
- 192 recipes (150 crafting, 42 stonecutting), 150 loot tables, the mod's tags and five
  language files, carried from the upstream jar.
- Hardness, blast resistance, sounds and the pickaxe requirement are the upstream values,
  read from the mod's own `BlockInit` (`tools/properties.json`).
- Exercised on a dedicated server, Horizon Nightly 2026-11-07 with 26.3 resources: the mod
  loads with no warnings, adds 4,800 block states and 150 items, fences and walls connect,
  gates face, waterlogging works, the mineable tags apply and the hedge loot table drops its
  item. `tools/test-server.sh` repeats it.
- Exercised on the client, Nightly 2026-11-08 on an AMD RX 6700 (RADV, Vulkan): the resource
  bake logs no errors, a test-terrain world meshes 3,687 sections, the hedge, picket fences,
  gate and pillared wall draw correctly, and page 2 of the creative screen shows the
  **Macaw's Fences & Walls** tab with its items ([screenshot](screenshots/fences.png),
  [tab](screenshots/creative-tab.png)).

## Not yet ported

- **The 11 wired fences deal no damage.** Upstream `WiredFence.entityInside` hurts for 2.0;
  that is native-mod territory and is recorded as a gap.
- **The 79 wooden fence items do not burn in a furnace.** Upstream they are `FuelItemBlock`
  with a burn time.
- **One block's shape.** The block built on the mod's own `FenceHitbox` keeps the vanilla
  fence's outline and collision instead of its own.
- **Crafting** parsed without error on the server; no player joined to craft one.

## Install

Put `mcwfences.hmod` in the game folder's `horizon-mods` folder and enable it in
Options > Mods, or start the game with `--dev-mod mcwfences.hmod`. Build it with the
commands below, or add the file from the registry once it is listed.

## Build from source

```sh
cargo install --git https://github.com/horizon-rust/horizon cargo-horizon-mod
cd content && cargo horizon-mod build     # content/target/horizon-mod/mcwfences.hmod
python3 tools/verify.py                   # models, textures, items, names, tags
HORIZON_CLIENT=… HORIZON_RESOURCES=… bash tools/test-server.sh
```

## Credits and licence

Original mod: [Macaw's Fences and Walls](https://github.com/sketchmacaw/Fences) by Sketch
Macaw and Peachy Macaw. Port: PlexTDM. Licence: MIT — see [LICENSE](LICENSE); the original
notices are preserved in [LICENSE-NOTICE.md](LICENSE-NOTICE.md).
