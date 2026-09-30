# Smash the Record — jam game design

## Status and scope

Working design for a solo, two-day AI-assisted game jam with no theme. Target: browser play on itch.io, Godot 4.7.2 as requested. The existing project is `disk-shop/project.godot`. Engine patch version and export tooling must be checked before implementation; the project currently declares the 4.7 feature family.

Explicitly agreed mechanics below are requirements. Numbers, ability details, layouts, and implementation choices labeled **initial tuning** or **proposal** are starting points, not playtested facts. Do not silently replace agreed mechanics to simplify development.

## Experience

A boy who wants to become a singer enters an abandoned, dusty 2000s mall record shop to recover a diamond disk. An unseen, exaggerated fighting-show-style announcer introduces each attempt, cheers milestones, and delivers occasional short jokes. The tone is chaotic arcade comedy, with an original hip-hop soundtrack.

The player has 60 seconds per attempt. WASD movement follows a grid; mouse clicks smash adjacent junk. A fixed rectangular shop contains connected aisles and brick wall dividers. Branches offer cash and permanent disk unlocks at the cost of time. After timeout, the boy returns to an elevator, the shop resets, and a randomized upgrade shop appears for up to 30 seconds. Cash, purchased upgrades, and disk unlocks persist for this session. Obtaining the diamond ends the game immediately.

Target complete playtime: approximately 10–15 minutes. The original aspiration was 10–15 failed runs; shopping adds to this duration. **Initial tuning:** aim for a first win in roughly 8–10 attempts, then measure total session length and adjust. This is a pacing recommendation, not a change to the 60/30-second timers.

## Design pillars

- Know the route: a fixed map rewards learning shortcuts, cash pockets, and disk positions.
- Commit or detour: time spent earning or unlocking tools competes with immediate progress.
- Spend charges deliberately: an early clear may sacrifice a later bottleneck solution.
- Combine tools: line attacks, area damage, setup effects, mobility, and collection create distinct builds.
- Read at a glance: short labels, strong icons, visible hit feedback, and animated UI convey state.

Durability is the primary obstacle. No enemies, health, combat damage to the player, or mandatory hazard system.

## Controls and spatial rules

| Input | Behavior |
| --- | --- |
| WASD | Move one cardinal grid tile at a time; holding repeats movement. |
| Left click | Request one basic hit on the clicked adjacent junk tile. |
| Hold left mouse | Repeat basic hits at the current attack interval. |
| 1 / 2 / 3 / 4 | Activate the ability in that numbered slot, if it is an active ability. |
| Mouse in elevator | Buy, reroll, replace, or leave early. |

Only the four orthogonally adjacent tiles are in basic attack range. Clicking out of range does nothing and never causes pathfinding. Empty tiles, walls, and stands cannot be smashed. Mouse targeting and WASD facing are separate: directional abilities use the last WASD direction; area abilities center on the player. Initial facing is into the shop.

**Initial implementation rule:** clicks and holds share the attack cooldown so rapid clicking cannot bypass attack-speed upgrades. Each legal click requests one hit; no queued delayed hits. Holding re-evaluates the tile under the cursor each attack interval. Release stops attacking. Suppress gameplay clicks over UI and outside the run state.

Movement uses a logical grid with short visual interpolation. No diagonal movement. Collision and range use logical tiles, not rendered sprite bounds. A turn can change facing even when the destination is blocked. Ability resolution uses the current committed tile.

## Session flow

1. Title/start interaction enables browser audio and begins a fresh session.
2. The first start departs directly from the elevator without showing or rolling shop offers. Give free Bass Drop. Persistent first-run prompts explain WASD, clicking/holding adjacent trash to swing the bat, walking over cash, and the diamond/ability goal.
3. On the first exit only, reveal the diamond with a camera move and return to the player. Run time is not consumed during this sequence.
4. Start the 60-second run once control is available. Later attempts start when the elevator exit transition completes.
5. Breaking junk places cash on the same tile. Walking onto that tile collects it. Tougher junk gives more money.
6. Collect silver, gold, or platinum disks in any order. Unlock their shop tier immediately; continue the run. Unlocks persist even if the run times out.
7. At timeout, disable gameplay and play a one-second fade to an elevator arrival with closing doors before opening shopping. Restore all junk, discard uncollected cash, refill active charges, reset temporary effects and automatic cooldowns, and keep progression.
8. After the return transition, give one free shop refresh and start 30 seconds of shopping. The first shop prompts the player to buy upgrades; a successful purchase clears that introduction. The player may press a clearly visible skip/leave button at any time. Never automatically skip because of low cash.
9. At shop timeout, cancel any uncommitted replacement without charging money and begin the next attempt. Timer does not pause for descriptions or replacement choices.
10. Collect the diamond for immediate victory. Stop timers, inputs, and damage effects. Show a short payoff, attempt count, elapsed session time, and a fresh-session button.

No pause feature and no saved progression across browser reloads. **Proposal for browser focus:** use elapsed time rather than frame counts; a hidden tab may defer presentation, but returning after the deadline must not grant extra run or shop time. Resolve only the current phase on return rather than simulating unattended repeated attempts.

## Map and obstacles

Handcraft one fixed map. Elevator at the top center; interconnected aisles run down toward the diamond. The outer footprint is a 31 × 39 rectangle, with full-width brick wall dividers and three gates at each depth boundary. Unbreakable walls and disk stands separate paths and create readable intersections. A short route contains tough junk; longer branches contain weaker junk, cash opportunities, and disk stands. Cross-connections allow route changes during a run.

**Implemented layout revision, 2026-10-01:** 31 tiles wide by 39 tiles deep, with straight perimeter walls and rectangular playable footprint. New side aisles add junk/cash opportunities; original spawn, disk stands and central route remain. Use three rough depth bands rather than procedural generation. Put silver on an early side branch, gold midway across another branch, and platinum on a costly late detour. Make access independent: no tier keys or prerequisite disk gates. Place the diamond at the deep end. Tune distances after movement is playable.

Stand tiles remain unbreakable. **Proposal:** a disk is collected automatically from a marked walkable approach tile adjacent to its stand. After its first collection, that approach becomes a recurring cash pickup on subsequent attempts; no duplicate unlock or same-run bonus pickup. Use the same explicit interaction for the diamond. Do not require walking into an impassable stand.

| Junk | Initial HP | Initial cash |
| --- | ---: | ---: |
| Loose litter | 2 | 1 |
| Cardboard boxes | 6 | 3 |
| Packed crates | 16 | 8 |
| Heavy scrap | 36 | 18 |

Cash is not awarded directly on destruction, including ability destruction. Spawn it on the cleared tile. A drop under the player is collected immediately. Coalesce cash per tile to reduce visual clutter. No cash physics or scattering. Uncollected cash is lost at timeout; collected cash persists.

## Progression and elevator shop

All purchases persist for the session. Cash can be saved across attempts. Two ability slots begin available; slots three and four can be purchased. Automatic abilities also occupy a slot but have no key action; display their automatic/cooldown status instead of prompting a keypress.

Three random offers per refresh (**initial tuning**), with no guaranteed damage offer or pity rule. Free refresh after every run; paid rerolls during shopping. Display current tier odds next to the reroll control. Slot unlocks appear as dedicated purchase controls separate from the random offers (**proposal**).

Purchases include basic damage, attack speed, movement speed, new abilities, and ability-specific upgrades. Unlocking a disk makes that tier eligible and changes its roll weight. Ordinary upgrades remain available. Higher-tier upgrades should be strong without making mobility, collection, or combinations irrelevant.

**Initial odds algorithm:** weights Common 60, Silver 25, Gold 10, Platinum 5. Locked tiers have weight zero. Normalize only eligible tiers. Thus the starting shop is 100% Common, while collecting Gold first gives Common 85.7% / Gold 14.3%. Show the actual normalized percentages. All unlocked gives 60% / 25% / 10% / 5%. No sequential tier prerequisite.

Roll tier first, then a valid offer from that tier. Exclude capped or unusable upgrade offers. If a tier has no eligible offers, exclude it and renormalize the displayed odds. Avoid duplicate offers within one shop when possible. Unlocks affect the next generated offers; do not silently replace existing offers.

Buying an ability fills a slot. When full, show a compact replacement choice. Charge and replace atomically only after confirmation. Refund 50% of the outgoing ability's original acquisition price, rounded down; a free starter refunds zero. Previously purchased upgrades are not refunded and remain attached to that ability type. Rebuying that ability restores its retained upgrade level. Duplicate offers for an equipped ability upgrade it instead of occupying another slot. Mark new abilities and upgrades distinctly.

**Initial economy:** reroll 5 cash; third slot 60; fourth slot 140; basic stat upgrade 10 × 1.5^purchases, rounded up; abilities Common 15 / Silver 35 / Gold 70 / Platinum 120; ability upgrades 60% of base ability price × 1.5^prior upgrades, rounded up. Replacement refunds may contribute to affordability only inside the atomic transaction. No negative cash or repeated refunds.

**Initial player stats:** damage 2; attack interval 0.30 seconds; movement step 0.18 seconds. Damage upgrade +1; attack interval ×0.90, floor 0.12; movement step ×0.92, floor 0.10. Ability levels 1–3. Prices, caps, and eligible pools must be data-driven.

## Twelve abilities

This is the proposed complete jam roster. Names, tier assignments, numbers, and exact upgrade effects are initial tuning. Active charges refill every run. Automatic abilities use cooldowns and fire only with a valid opportunity; they do not consume a cooldown on an invalid target. No active-charge refill pickups in the base scope.

| Ability | Tier | Mode | Initial effect | Upgrade direction |
| --- | --- | --- | --- | --- |
| Bass Drop | Common | Active, 3 charges | Deal 8 damage to junk within Manhattan distance 1. | Damage, then radius. |
| Piercing Note | Common | Active, 3 charges | Deal 10 damage along 4 tiles in the facing direction; passes through junk, stops at walls/stands. | Damage and length. |
| Double Time | Silver | Active, 2 charges | For 5 seconds, movement and basic attacks are 35% faster. | Duration and speed, respecting safety caps. |
| Feedback | Silver | Automatic, 6-second cooldown | Mark nearest junk within 2 tiles for 6 seconds; destroying it deals 8 damage to adjacent junk. | Explosion damage and mark duration. |
| Stage Dive | Silver | Active, 3 charges | Teleport exactly 3 tiles in the facing direction, instantly destroying destination junk regardless of HP; skip intermediate junk. Walls/stands anywhere along the three tiles cancel without spending a charge. Collect cash only at landing. | +1 charge per level (3/4/5); distance stays 3. |
| Cash Magnet | Common | Automatic, 5-second cooldown | Collect cash within Manhattan distance 2 along reachable cleared tiles. | Radius and cooldown. |
| Hi-Hat | Common | Automatic, 3-second cooldown | Deal 3 damage to an adjacent junk tile, preferring the facing tile. | Damage and cooldown. |
| Sample Loop | Gold | Automatic, 8-second cooldown | When ready, echo the next basic hit onto the same surviving target for its basic-hit damage. | Echo damage and cooldown. |
| Subwoofer | Gold | Automatic, 7-second cooldown | Deal 6 damage to all adjacent junk. | Damage and cooldown. |
| Remix | Gold | Active, 2 charges | Pull reachable cash within 3 tiles, then deal 12 damage to adjacent junk. | Collection radius and damage. |
| Platinum Rush | Platinum | Active, 2 charges | Dash up to 3 tiles, dealing 24 damage to encountered junk; advance through destroyed junk, stop at surviving junk or walls/stands. | Damage and distance. |
| Encore | Platinum | Automatic, 12-second cooldown | Echo the next damaging active ability at 50% damage after a brief delay, using its original origin/direction; no extra movement or cash effect. | Echo damage and cooldown. |

**Stage Dive revision, 2026-10-01 (user requested):** teleport and landing destruction replace the cleared-corridor dash. It preserves facing, stops current visual movement immediately and uses the normal destruction/drop/Feedback path once. Encore does not echo this instant-break teleport. Landing on a disk approach collects it immediately, including diamond victory. Intermediate junk and cash remain untouched unless a normal Feedback explosion reaches them. This materially strengthens route skipping; economy and the other abilities are unchanged.

Resolve automatic targeting deterministically: distance, then facing preference, then a stable tile order. Feedback explosions cannot recursively duplicate the same destruction. Echoes cannot trigger themselves or one another. Encore applies only to damage, never consumes an extra active charge, and cannot repeat marks, buffs, or a dash movement. Timed boosts cannot exceed movement/attack safety limits.

Examples of useful builds: Feedback + Bass Drop for clustered junk; Piercing Note + Encore for dense corridors; Stage Dive + Cash Magnet for detour collection; Double Time + Sample Loop for focused breaking. Do not require a specific random build to win.

## Art, camera, UI, and audio

**Approved typography, 2026-10-01:** Bungee for major headings, the run timer and start button; Space Grotesk Medium/Semibold for readable UI and signage; Permanent Marker for short slogans and graffiti/poster accents. Bundle fonts and their licenses locally. Title lettering uses cream, dark outline and orange offset shadow; preserve sharp UI text and check wider display headings against menu bounds.

**Approved presentation revision, 2026-10-01:** dusty underground record store with taller bare orange brick walls, muted prop colors and directional shadows; pure black outside the environment. Keep the angled camera and 2D boy/3D world. The boy uses a baseball bat. Prefer icon-led record/sticker UI, short hover descriptions, animated button feedback and strong brief impacts. Use mesh vertex wobble, never texture-coordinate wobble. Pixel/dither finishing applies to the world, leaving UI text sharp.

The elevator is a separate 3D room with a Track-O-Matic upgrade vending machine, visible sliding doors and a short departure walk. OPEN DOORS is the manual skip. A 0.65-second departure presentation precedes every attempt; the first departure additionally reveals the diamond. The run clock starts after this presentation. Timeout plays a 0.4-second fade out, elevator arrival/door closure, 0.4-second fade in and 0.2-second settling before the full shop clock begins. The first start skips the shop, and first-run guidance persists beyond announcer captions. Purchase cancellation rules are unchanged.

Implemented props use six deterministic appearance variants per existing durability tier: varied loose litter, containers, packed/audio junk and heavy electronics. Bare stable brick walls are 1.8 tiles tall, replacing wall fixtures. An oblique orthographic camera, reduced ambient light and directional shadows emphasize volume. Collectible disks emit colored light and pulse with an additive halo; their visual height clears the walls. The bat draws in front of the boy. These are appearance changes, with unchanged HP and cash values. Procedural icons, prop meshes, bat motion, capped debris and original synthesized material/ability sounds are implemented. Final generated character frames and illustrated poster/ability/title art remain pending because the image service returned a usage-limit error. See `ART_BRIEF.md`.

2.5D top-down presentation: a 2D boy sprite in a 3D shop, an angled orthographic camera, low-resolution textures, and old PlayStation-inspired forms. Non-wall 3D props use subtle vertex wobble; walls stay stable. Wobble is visual only and never changes collision or targeting. Use a shared shader with bounded displacement. Keep the grid legible and the character visible behind foreground props.

During runs, a world-only soft darkness falloff follows the player, with a clear inner radius of 0.20 screen heights and an outer radius of 0.62; distant scenery retains at least 45% brightness. Disable it for the first reveal, elevator, title and victory so those presentations stay readable. UI remains unaffected. These parameters are editable shader uniforms, with no visibility or targeting restrictions.

Run HUD: dark bordered panels behind cash, the large timer and fading announcer captions; four compact ability positions, charge/cooldown indicators, and a subtle facing indicator. Show locked slots without lengthy text. Elevator: green stat disks, cyan ability-upgrade disks, and pink new-ability disks, with full card backgrounds and borders colored by Common/Silver/Gold/Platinum tier; a category legend; three animated offer cards, cash, tier odds, reroll cost, slot purchases, countdown, and skip button. Descriptions should fit one short sentence. Use brief bounce, flip, pulse, and hit animations; avoid camera shake that obscures clicking.

Host is never shown. Short captions plus brief original vocal sounds; no full voiceover requirement. Host lines must not block shopping or obscure the playfield. Introduce controls in small steps during the first visit and use milestone/event-driven banter, with repetition suppression.

User-supplied soundtrack: four Crate Smash Sprint MP3 variations for runs, and Elevator Jazz/Elevator Motif for the elevator. Each context uses a randomized shuffle bag, playing all variations before reuse and preventing a repeat across bag boundaries. Switch on run start/return to the elevator; repeated same-phase calls keep the current song. Finished tracks advance to the next variation. Start only after user interaction. Keep clear smash, pickup, ability, warning, and shop sounds. No sound toggle is shown in the HUD. Start audio after user interaction. Keep sound layers limited and avoid clipping during mass destruction.

Album references use fictional wordplay and original artwork, for example “Abbey Load,” “Nevermind the Boxes,” and “The Dark Side of the Mall.” Do not copy album covers, logos, recordings, lyrics, or artist likenesses. Renaming is not treated as a legal guarantee. Maintain an asset/source ledger, including AI generation and license information where applicable.

## Implementation structure

Use GDScript and the Compatibility renderer. Keep browser export requirements central; verify a minimal actual web export early before choosing dependencies. The existing starter declares Jolt; grid gameplay should not depend on rigid-body simulation or a particular physics backend.

Suggested responsibilities:
- Session controller: state transitions, authoritative deadlines, first reveal, victory.
- Grid/map: immutable handcrafted layout plus per-run junk/cash state.
- Player: tile movement, facing, click/hold requests, and interpolation.
- Ability runner: effects, cooldowns, charges, targeting, and event recursion guards.
- Progression/shop: wallet, unlocks, slots, upgrades, weighted offers, atomic purchases.
- Presentation: camera, sprites, prop wobble, UI, host, and audio.

Use Resources or similarly simple data definitions for junk, offers, and abilities. Avoid a general-purpose framework. Reset from a clean map definition, not reverse mutations. Use simple picking against the ground grid or stable tile colliders. Timers and cash have one authoritative owner each.

## Two-day build order

1. Early day one: confirm editor/export version, export a minimal browser build, then implement grid movement and adjacent click/hold breaking.
2. Day one: implement cash, timeout/reset, elevator purchases, permanent session upgrades, and a diamond victory in a graybox map. Export and play a full loop.
3. Late day one: add branches, three tier disks, random offers/odds, slots/replacement, and representative active/automatic abilities.
4. Day two: complete all 12 data-driven abilities and their upgrade paths; balance routes, economy, and first-win duration.
5. Day two finish: replace placeholders, add wobble, host, audio, animated UI, and first reveal. Test exported browser build and package for itch.io.

If time runs short, cut visual variants, lengthy dialogue, complex transitions, and optional results flourishes first. The agreed 12 abilities remain a requirement; report a scope conflict rather than quietly reducing the roster. Reserve time for export and a complete playthrough.

## Acceptance and playtest checklist

- Export launches in desktop browsers with readable UI and user-initiated audio; verify the actual itch.io embed when upload is authorized.
- WASD repeats by tiles, cannot cross walls, and changes facing predictably. Adjacent clicking gives one hit; holding repeats; distant clicking does nothing.
- All 12 abilities function; 1–4 match slot positions; automatic slots have cooldown feedback. Dash collision and echo recursion are bounded.
- Sixty seconds ends a run; 30 seconds ends shopping; skip works at any cash amount. First start skips shopping. First reveal and elevator return/departure consume no run/shop time.
- Junk respawns, uncollected cash disappears, charges refill, temporary effects clear, and collected cash/upgrades/unlocks remain.
- Disk tiers unlock out of order. Previously collected disks become cash opportunities on later runs. Displayed shop odds match eligible roll weights.
- Replacement/refund is atomic; canceled or expired replacement costs nothing. Retained ability upgrades survive replacement/rebuying. No duplicate slots for one ability.
- Diamond wins once, freezes gameplay, and restart clears all session progress. Reload has no progression persistence.
- Playtest several shop seeds: at least two routes/builds should be viable, and saving a charge or taking a detour should visibly change an attempt's outcome.
- Record attempts, total time, cash collected, purchases, and winning build during tuning. Check that basic clicking remains useful without becoming the only effective strategy.
- Verify heavy clears, narrow embed sizes, browser focus changes, UI click isolation, and audio playback. Report tested browsers and any unverified platform behavior.
