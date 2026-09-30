# Disk Shop — implementation instructions

## Source of truth

Read `GDD.md` before implementing gameplay. It records agreed mechanics, a proposed 12-ability roster, and explicitly provisional tuning. Preserve agreed mechanics; exercise judgment on provisional numbers and report material design changes. This is a solo two-day AI-assisted jam: prefer a small complete game over infrastructure.

The Godot project is in `disk-shop/`; this document and `GDD.md` live in its parent workspace. Requested engine: Godot 4.7.2. Check the installed editor and matching export templates before building; do not silently substitute a different version. Current project settings declare 4.7 and GL Compatibility. Do not claim browser support or successful export without running checks.

## Required game behavior

- Desktop web/itch.io only; keyboard and mouse. No mobile or controller scope.
- Fixed grid, cardinal WASD tile movement, held movement repeats.
- Click adjacent junk for one basic hit; hold for repeated hits. Enforce the same attack interval for both. Out-of-range clicks do nothing; no click-to-move.
- Directional abilities use last WASD facing. Area abilities center on the player. Active slots use 1/2/3/4; automatic abilities use cooldowns and valid targets.
- 60-second runs, up to 30-second elevator shops, manual shop skip, no automatic skip and no pause. First diamond camera reveal excludes run time.
- Reset junk and uncollected cash per run; preserve collected cash, upgrades, and disk unlocks for the session. Refill charges and clear transient effects.
- Cash spawns on the broken junk tile and requires collection. Tougher junk pays more. No health or enemies.
- Root-like branching map broadens downward, with unbreakable walls and disk stands. Silver/gold/platinum unlock in any order; collected disk locations yield cash in later runs.
- Random shop, free refresh each run, paid rerolls, displayed normalized tier odds. All purchases persist. No guaranteed fallback offer or hidden pity rule.
- Two initial ability slots; third and fourth purchasable. Replacement refunds 50% of acquisition price. Type-specific upgrades persist when an ability is replaced; duplicates upgrade rather than fill another slot.
- Cancel unresolved purchases without charging at shop timeout. Wallet/purchase/refund updates must be atomic.
- Implement 12 abilities; use the GDD roster as the initial design. Prevent recursive echoes and duplicate destruction rewards.
- Immediate diamond victory, fresh restart, no persistent save requirement.

## Technical approach

Use GDScript, Compatibility rendering, simple grid data, and small scenes/components. Establish a runnable web export early, then keep it working. Avoid physics-driven cash or movement, heavyweight addons, backend services, and speculative abstractions.

Separate immutable map/ability/offer definitions from session progression and per-run state. Centralize deadlines and state transitions. Logical tiles govern movement, range, targeting, and drops; visual interpolation and shader wobble must not change gameplay.

Keep prices, durability, tier weights, upgrade caps, and ability parameters in editable data. Make randomness reproducible for debugging when practical. Guard gameplay input by state and ignore UI-consumed mouse events. Handle browser focus return without granting extra timer time or running unattended attempt loops.

Use the existing project rather than generating a second Godot project. Do not edit generated `.godot/` files or commit exported build artifacts unless requested. Keep new project assets under clear folders such as `scenes/`, `scripts/`, `data/`, `assets/`, and `shaders/` inside the project. Add structure only as needed.

## Presentation

2D boy sprite, angled top-down 3D shop, low-resolution textures, dusty 2000s mall/old-PlayStation feel. Non-wall 3D props wobble subtly through a shared visual shader; walls do not. Prioritize clear tiles, clicking, character visibility, and readable cooldowns.

UI is animated and playful with concise labels, icons, and one-sentence descriptions. Host is unseen: exaggerated announcer captions and short vocal sounds. Use original hip-hop music and original art; fictional album-name references are allowed, copied covers/logos/lyrics/recordings are not part of the design. Track asset provenance in `ASSET_SOURCES.md` when assets are added.

## Delivery order and validation

Build the browser-compatible graybox loop first: movement → smashing → cash → timed reset → upgrade shop → diamond victory. Next add map branches, tiers, slot management, and all 12 abilities. Then balance and polish. Reduce cosmetic scope before agreed gameplay; raise unresolved scope conflicts explicitly.

Run relevant parser/editor checks and focused gameplay checks after meaningful changes. Verify state resets, out-of-order unlocks, weighted odds, replacement refunds, persistent ability levels, and echo guards. Use lightweight automated tests for calculations/state when useful; avoid tests that merely mirror implementation.

Before delivery, run the actual web export in a browser and complete a full session. Follow the GDD acceptance checklist, including timing, input/UI isolation, focus behavior, mass destruction, and restart. Record what was tested and what remains unverified. A desktop editor playthrough alone is not web validation.

Update the GDD when implemented rules change. Keep progress reports concise: outcome, meaningful checks, unresolved risks. Do not publish/upload externally unless authorized by the user.
