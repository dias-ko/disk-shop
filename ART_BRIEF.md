# Disk Shop production art

Direction approved 2026-10-01: loud underground record shop; cobalt, orange, violet, cyan and acid green; original thick-outline hip-hop cartoon character; chunky 3D props with vertex wobble; pixel/dither rendering; pure black outside rooms. Keep the existing camera. Baseball bat weapon. Album sleeves for purchases, graffiti/sticker accents for UI.

## Generation status

Built-in imagegen was attempted on 2026-10-01. It returned HTTP 429 `usage_limit_reached` with a roughly 24-hour reset window. No image output was produced or saved. User has no API key, so the API fallback is unavailable. The new illustrated character, album/poster artwork and illustrated ability assets remain pending. Existing `assets/boy.svg` remains the character until replacement art is available.

## Character sheet contract

Destination: `disk-shop/assets/character/boy_states.png`. Transparent PNG, four columns and two rows of equal cells. Frames: idle, idle bounce, walk left foot, walk right foot, windup, swing, pickup, victory. The player script recognizes this path and plays the appropriate frames. Check consistent scale, baseline, edges and alpha before integration. The character's 3D bat is hidden when an illustrated sheet with its own bat is loaded.

For the retry, request 2048 x 1024 so all eight cells are square. The unsuccessful original prompt below mixed square-cell wording with incompatible output aspect ratios; correct that constraint when retrying.

Exact attempted built-in prompt:

> Use case: illustration-story. Asset type: production game sprite sheet, transparent PNG. Create a single 4 columns by 2 rows regular sprite sheet (8 equally sized square cells) of the SAME original expressive teenage boy with medium brown skin, thick dark curly hair, oversized cobalt blue hoodie with orange lining, baggy dark shorts and chunky cream sneakers, carrying a sticker-covered wooden baseball bat. Bold black cartoon outlines, energetic underground hip-hop rhythm-game art, flat saturated colors, minimal highlights. Full body in each cell, identical scale, feet baseline at 88% of each cell, ample transparent margin, no overlap between cells. Row 1: idle bat on shoulder; idle crouched bounce; walking left foot forward; walking right foot forward. Row 2: bat windup; powerful sideways bat swing with orange swoosh; delighted cash pickup; triumphant bat raised victory. Three-quarter facing right in every cell. Actual transparent background, no labels, no text, no grid lines, no scenery. Maintain identical costume face and proportions. Output 1536x1024 or square with exact equal grid cells.

## Remaining illustration set

- Original fictional album sleeves and concert posters: square artwork using abstract speakers, vinyl, stylized sound bursts and graffiti; no copied logos, artists or existing covers.
- Ability illustrations: one distinct transparent symbol per ability, readable at 64 pixels, thick ink outline, consistent palette, record-label framing. Current UI uses original code-drawn record symbols.
- Title illustration: the same boy leaning on his bat beside a speaker stack, transparent backdrop, space for the native game title/buttons.

Generate each asset through the built-in tool after its limit resets. Save outputs into the project, inspect the alpha and small-size readability, and update `ASSET_SOURCES.md` with the actual output paths and prompts. No images have been claimed as generated in this pass.
