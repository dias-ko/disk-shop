# Disk Shop asset sources

- `disk-shop/assets/boy.svg`: original code-authored pixel-style placeholder sprite created for this project by the coding assistant. No external reference image.
- `disk-shop/assets/audio/*.wav`: original procedural synthesis from `disk-shop/tools/generate_starter_assets.py`; no sampled recordings. Beat: 88 BPM synthesized hip-hop placeholder. Host: synthesized vocal-like blip, not a human voice recording.
- Runtime prop meshes and grain pattern: original procedural geometry and shader in this project. No external textures.
- UI fonts are bundled under `disk-shop/assets/fonts/`; see the typography entry below.
- Existing `icon.svg` is the starter project's Godot icon; replace it with a game-specific icon for final submission.

The SVG, audio, and meshes are implementation placeholders, not final art production. The generator overwrites the initial map as well as audio; do not run it over a hand-edited layout without preserving that layout.

## Presentation overhaul — 2026-10-01

Typography added 2026-10-01:

- `disk-shop/assets/fonts/Bungee-Regular.ttf`: unmodified Bungee from the [Google Fonts repository](https://github.com/google/fonts/tree/main/ofl/bungee), copyright The Bungee Project Authors. SIL Open Font License 1.1 bundled as `Bungee-OFL.txt`. Used for major headings, run timer and start button.
- `disk-shop/assets/fonts/SpaceGrotesk.ttf`: unmodified variable Space Grotesk from the [Google Fonts repository](https://github.com/google/fonts/tree/main/ofl/spacegrotesk), copyright The Space Grotesk Project Authors. SIL Open Font License 1.1 bundled as `SpaceGrotesk-OFL.txt`. FontVariation resources select Medium (500) and Semibold (600) for UI text, buttons and readable signage.
- `disk-shop/assets/fonts/PermanentMarker-Regular.ttf`: unmodified Permanent Marker from the [Google Fonts repository](https://github.com/google/fonts/tree/main/apache/permanentmarker). Apache License 2.0 bundled as `PermanentMarker-LICENSE.txt`; original copyright metadata remains in the font. Used for decorative slogans and graffiti/poster lettering.
- Downloaded from `raw.githubusercontent.com/google/fonts/main/` on 2026-10-01. Fonts are packaged locally, with no runtime font-service connection.

- `disk-shop/scripts/visual_props.gd`: original procedural record racks, sleeve bins, paper/cup/record litter, cartons, broken speakers, CRT/electronics piles, wall signs, elevator, vending machine and baseball-bat geometry. No imported model assets.
- `disk-shop/scripts/record_icon.gd` and `disk-shop/assets/ui/disk_logo.svg`: original code-authored record symbols and game icon. No external artwork or font dependency. The original Godot icon is no longer the application icon.
- `disk-shop/scripts/sound.gd`: original deterministic PCM synthesis for four material impacts, destruction, UI, elevator doors and differentiated abilities. No recordings or samples; existing original music and pickup sounds retained.
- `disk-shop/scripts/impact_fx.gd`, `shaders/prop_wobble.gdshader`, `shaders/print_finish.gdshader`: original bounded debris, mesh vertex movement and screen-space pixel/dither rendering.
- AI raster generation: attempted using the built-in imagegen tool, blocked by its usage limit; **no generated images were delivered**. See `ART_BRIEF.md` for the exact attempted prompt and outstanding deliverables. The player currently animates the existing placeholder sprite and a new modeled bat.

- Onboarding/shop revision (2026-10-01): colored vinyl grooves, category/tier palettes and return fade are original procedural UI drawing; no additional external assets.

## Uploaded soundtrack — 2026-10-01

- `disk-shop/assets/music/Crate Smash Sprint.mp3`, `Crate Smash Sprint (1).mp3`, `Crate Smash Sprint (2).mp3`, `Crate Smash Sprint (3).mp3`: user-uploaded run music.
- `disk-shop/assets/music/Elevator Jazz.mp3`, `Elevator Motif.mp3`: user-uploaded elevator music.
- Used at the user's explicit request. Creation method, author and license details were not supplied; no external download or modification was performed. These replace the procedural `beat.wav` in active playback. Existing synthesized sound effects remain.

## Depth and prop variation — 2026-10-01

- Orange brick/mortar pattern and disk halo are original procedural shaders (brick_wall.gdshader, disk_halo.gdshader); no external textures.
- Additional cans, paper stacks, cassettes, cartons, storage tubs, wooden crates, amplifiers, receivers, road cases, metal drums, towers, racks, printers and reel decks are original code-authored meshes. Bat overlay shader is original. No imported art or model assets.


- Player-centered darkness (2026-10-01): original screen-space shader math in print_finish.gdshader, with no external fog textures or assets. HUD panels use existing original procedural styles.

