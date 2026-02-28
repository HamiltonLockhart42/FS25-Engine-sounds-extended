# FS25 More Motor Sounds

`FS25 More Motor Sounds` is a script mod for Farming Simulator 25 that adds an additional **shop configuration** to select alternative engine sound packs for compatible motorized vehicles.

## Core functions
- Adds a new shop config type: **More Motor Sounds**.
- Preserves the base game/mod vehicle sound as **Standard**.
- Adds curated alternative sound presets across 4/6/8-cylinder variants.
- Applies matching logic by vehicle category, brand, model-name keywords, and excludes.
- Saves your selected sound option in the savegame.
- Automatically hides blowoff-related options in multiplayer / dedicated server sessions.

## Included sound preset groups
- 1990, 4 cyl. turbo
- 2000, 4 cyl. turbo
- Fendt 380 GTA
- 1990, 6-cyl.
- 1990, 6-cyl. + turbo
- 1995, 6-cyl.
- 2000, 6-cyl.
- 2000, 6-cyl. + open pipe
- 2000, 6-cyl. + open pipe + blowoff (singleplayer only)
- 1990, 8-cyl. + turbo
- 90s IHC

## Dedicated server readiness
This package is structured to be dedicated-server friendly:
- `modDesc.xml` uses FS25 descriptor version (`93`).
- Blowoff options are filtered when multiplayer state is detected.
- All local sound XML `file="..."` references resolve to files in this package (non-`$data` paths).
- No merge-conflict markers or missing local asset references are present.

## Installation
1. Zip the mod so `modDesc.xml` is at the root of the ZIP.
2. Example filename: `FS25_MoreMotorSounds.zip`.
3. Copy ZIP to:
   - Windows: `Documents/My Games/FarmingSimulator2025/mods`
   - Linux dedicated server: `<server profile>/mods`
4. Enable the mod for your savegame/server.

## Notes
- This is an FS25 conversion of the uploaded FS22-style configurable engine sound setup.
- Some referenced sounds intentionally use FS base-game `$data/...` audio paths.
