# Macaw's Fences and Walls — for Horizon

A port of [Macaw's Fences and Walls](https://github.com/sketchmacaw/Fences) 1.1.2 by Sketch
Macaw and Peachy Macaw for [Horizon](https://github.com/horizon-rust/horizon), Minecraft: Java
Edition 26.3 rewritten in Rust.

**150 blocks**: 10 leaf hedges, 47 fences (picket, stockade, horse and wired, in eleven woods),
37 gates (highley, pyramid and railing), and 56 walls (modern, railing, pillared and
grass-topped) in eleven woods and thirteen stone sets. Every one has its own model, item
model, blockstate, name and loot table, and the mod's 192 recipes (150 crafting, 42
stonecutting), tags and five language files are carried.

Hardness, blast resistance, sounds, map colour and the pickaxe requirement are the upstream
values, read from the mod's own `BlockInit`; the shapes and behaviour come from the vanilla
fence and fence-gate templates, which the mod's blocks extend.

This is a **data-tier carry**: no native code, no hooks, no engine patch.

## What is not carried

These are the only differences from the upstream jar; each needs native code or a hook, so
they are left out rather than faked:

- **The wired fences (11 blocks) deal no damage.** Upstream, walking through one hurts for
  2.0 damage (`WiredFence.entityInside`). The blocks, models and recipes are here; only the
  damage is not.
- **The wooden fence items do not burn in a furnace.** Upstream, 79 of them are `FuelItemBlock`
  with a burn time.
- **One block's shape** — the one the mod gives its own `FenceHitbox` class — keeps the vanilla
  fence's outline and collision.

Nothing else is known to differ.

## Install

1. Take `mcwfences.hmod` from the [latest release](../../releases/latest).
2. Put it in the game folder's `horizon-mods` folder — the game folder is the one holding
   `options.txt`.
3. Mods are off by default: enable it in Options > Mods.

## Build

`content/` is the whole mod: `horizon-mod.toml`, `assets/` and `data/`.

```sh
cargo install --git https://github.com/horizon-rust/horizon cargo-horizon-mod
cd content && cargo horizon-mod build    # content/target/horizon-mod/mcwfences.hmod
python3 tools/verify.py                  # models, textures, items, names, tags resolve
cargo horizon-mod check target/horizon-mod/mcwfences.hmod   # the registry's checks
```

## Layout

| Path | What |
| --- | --- |
| `content/` | the mod: manifest, 150 block declarations, assets and data |
| `content/data/mcwfences/horizon/block/` | one declaration per block, on the vanilla fence or fence-gate template |
| `content/data/mcwfences/horizon/creative_tab/` | the mod's creative tab, as 26.3 data (upstream registers it in Java) |
| `tools/verify.py` | structural checks the registry's file check cannot see |
| `tools/properties.json` | the upstream hardness, blast resistance, sounds and tool rule per block |
| `tools/carry.sh` | how the jar was carried, and the patches applied after |
| `compatibility.json` | the Horizon revision this was built and checked on, and the upstream pins |

## Licence

MIT. The original's copyright and licence notices are kept in [LICENSE](LICENSE) and
[LICENSE-NOTICE.md](LICENSE-NOTICE.md) records where each was read from. This is an
unofficial port: Horizon is not affiliated with the original authors.
