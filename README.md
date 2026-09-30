# Smash the Record

Open `disk-shop/project.godot` in **Godot 4.7.2**, then press F6 on `scenes/main.tscn` or F5 to play. The project uses Compatibility rendering and GDScript. No external addons are required.

## Controls

The presentation now uses a black void, colorful record racks and varied smashable junk, an animated bat, material-specific impact sounds, a compact record-icon HUD and an isolated elevator with a Track-O-Matic vending machine. Hover records for descriptions; click **OPEN DOORS** to leave the shop early. The main menu includes **HOW TO PLAY** and sound controls.

Generated character/illustration assets are still pending the image service's usage-limit reset. See `ART_BRIEF.md` for the character-sheet contract and outstanding artwork, and `IMPLEMENTATION_STATUS.md` for validation results.

DROP IN starts your first run directly, with prompts for swinging the bat and collecting cash. When 60 seconds end, a fade and elevator door closure precede the upgrade shop. The store now has a rectangular footprint with connected aisles. Shop disks use green for stats, cyan for upgrades and pink for new abilities; card backgrounds show their tier.

WASD moves tile by tile. Click adjacent junk for a hit or hold to repeat. Active abilities use 1–4 and face the last WASD direction. Automatic abilities trigger on cooldown. Walk over green cash. Approach a disk stand from the tile immediately above it. Shop purchases last for the current session; browser reload starts fresh.

## Edit the map

1. Open `disk-shop/scenes/shop_map.tscn` and select the `ShopMap` root.
2. In the **Disk Map** dock, enable tile painting and pick a tile type.
3. Left-click tiles in the 3D editor viewport. Ctrl+Z/Ctrl+Shift+Z undo/redo. Turn painting off to use normal selection.
4. Click **Save layout resource**. This saves `data/shop_layout.tres`; runtime resets read this resource.

Alternatively select the Layout resource in the Inspector and edit its multiline **Tiles** text. Each character is one tile: space = void, `.` = floor, `#` = wall, `1`–`4` = junk durability tiers, `E` = spawn, `$` = cash, `S/G/P/D` = disk stands. Rows are Z and columns are X. Add rows/columns in the text to resize. Painter coordinates cover existing row lengths, including void cells.

Keep exactly one E and D and one of each tier disk. Disk stands are impassable; keep the tile above each stand walkable or breakable and connected to the map. The first reveal automatically finds the diamond. The map node should retain its default origin/scale for runtime grid coordinates.

## Music

The uploaded tracks in `disk-shop/assets/music/` are now the soundtrack. Runs shuffle the four Crate Smash Sprint variations; the elevator alternates Elevator Jazz and Elevator Motif. Each pool plays every variation before reuse, avoids consecutive repeats across reshuffles, and advances when a track ends. Music begins after DROP IN and follows the sound mute control.

## Tune the game

- `data/balance.json`: run/shop timing, player base stats, junk HP/rewards/colors, tier weights/prices, slots, rerolls.
- `data/abilities.json`: the 12 ability definitions, charges, cooldowns, damage/ranges and short descriptions.
- `scripts/progression.gd`: stat scaling, pricing, offer generation, and permanent session state.
- `scripts/abilities.gd`: effect behavior and upgrade scaling.
- `GDD.md` in the parent workspace: full design and provisional balance rules.

## Web export

Install matching Godot 4.7.2 export templates using the editor, create `disk-shop/build/web/`, then export the **Web** preset. Threads are disabled for simpler itch.io embedding. Zip the contents of the export folder with `index.html` at the archive root, upload as an HTML game, and use a 1280×720 embed with fullscreen available. Serve the output over HTTP locally; opening the HTML via `file://` is not a valid browser test.

Do not commit `.godot/`, generated exports, or engine binaries. See `IMPLEMENTATION_STATUS.md` for verified checks and limitations.
