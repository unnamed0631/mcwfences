#!/usr/bin/env python3
"""Apply tools/properties.json to the block declarations.

The carry gives every block the template's hardness, blast resistance and sounds.
The upstream mod sets its own in `BlockInit`: `strength(a, b)`, `sound(SoundType.X)`,
`requiresCorrectToolForDrops()`, and `ofFullCopy(Blocks.OAK_LEAVES)` for the hedges.
`tools/properties.json` is that table, read from
https://github.com/sketchmacaw/Fences/blob/main/1.20.4%20Forge/init/BlockInit.java
(the newest source upstream publishes; the 1.21.1 jar registers the same 150 names).
"""
import glob
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT = os.path.join(ROOT, "content")
DECLS = os.path.join(CONTENT, "data", "mcwfences", "horizon", "block")


def main():
    properties = json.load(open(os.path.join(ROOT, "tools", "properties.json"), encoding="utf-8"))
    applied = 0
    for path in sorted(glob.glob(os.path.join(DECLS, "*.json"))):
        name = os.path.basename(path)[:-5]
        declaration = json.load(open(path, encoding="utf-8"))
        if name in properties:
            declaration["properties"] = properties[name]
            applied += 1
        with open(path, "w", encoding="utf-8") as f:
            json.dump(declaration, f, indent=2)
            f.write("\n")
    print(f"applied upstream properties to {applied} block declarations")


if __name__ == "__main__":
    main()
