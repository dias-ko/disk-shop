# Presentation overhaul — 2026-10-01

## Implemented

- Pure black world background; saturated record-shop palette; world-only pixel/dither finish; shared vertex wobble on props and stable walls.
- Record shelving, sleeve bins, fictional typographic wall posters, graffiti marks, litter/cups/vinyl, cartons, broken speakers and CRT/electronic scrap. Existing logical map, durability and rewards preserved. Breakable geometry is combined into single draws and cached; static boxes use chunked MultiMeshes.
- Separate elevator room, rails, signage, sliding doors and Track-O-Matic vending machine. OPEN DOORS starts a 0.65-second departure presentation; the run timer starts afterward. First diamond reveal remains outside run time.
- Compact record-icon HUD, charge pips, automatic cooldown rings, hover descriptions, normalized tier odds, reacting buttons, fading announcer captions, main menu, controls page, themed victory screen and original application icon.
- Modeled baseball bat, animated idle/walk/swing/pickup reactions, visible swing arc, bounded debris/impact rings and short camera kicks. Player remains visible in front of props. Victory clears active impact effects and freezes player animation.
- Four material impact sounds, destruction, door/UI sounds and differentiated abilities, synthesized from original PCM without samples. Eight voices, short retrigger guards and bounded mixing levels. Existing original beat retained.
- Focus loss suppresses inputs and unattended phase cycling while preserving elapsed deadlines; focus return resolves the expired current phase once.

## Outstanding artwork

The imagegen service returned HTTP 429 `usage_limit_reached`. The user has no API key for the fallback. No AI raster image was generated. The requested new illustrated boy and animation frames, illustrated ability art, album/poster textures and title illustration remain incomplete. The existing boy sprite is still in use with new motion and a modeled bat. `ART_BRIEF.md` contains the exact attempted prompt and the supported sprite-sheet layout; `ASSET_SOURCES.md` records asset provenance.

## Validation

- Installed editor and cached templates verified as **4.7.2.stable**, Compatibility renderer. Debug and release Web exports succeeded.
- **43 regression checks passed**: weighted odds, out-of-order unlocks, persistent progression, collection/drop/reset rules, replacement/refund transactions, cancellation, abilities, elevator transition timing, hidden-tab phase handling, diamond victory, and restart through the real UI signal.
- Rendered native screenshots inspected for menu, elevator, run, dense aisles and a four-slot replacement selection. Parser/runtime checks found no GDScript or shader errors in the final native capture.
- Actual WebGL export served over localhost and exercised in headless Chrome using mouse/keyboard events. Two full debug-export sessions reached the diamond in three and two attempts respectively; restart returned to the title with wallet/attempts reset. A temporary **read-only** observer supplied state and screen coordinates to the driver. The driver did not modify gameplay state, timers, wallet, damage, map or RNG. The observer hook is absent from the final source and release export.
- Browser playtesting caught a restart sound callback after scene removal; it was fixed by ordering feedback before the action and guarding detached audio. The 43-check regression includes the restart button path.
- Dense-aisle performance improved after mesh consolidation. Instrumented headless Chrome sampled roughly 29–39 FPS in dense areas; these are debugging measurements, not a hardware-independent performance guarantee. Geometry caching further reduces rebuild cost.
- Local editor/export checks print a Windows root-certificate-store warning in this environment. It did not prevent rendering, regression tests or export.

## Limits

Final illustrated assets and subjective listening review remain outstanding. Firefox, Safari, actual itch.io embedding and human playtest balance have not been verified. No external upload was performed. Automated pathfinding wins faster than the provisional 8–10-attempt target; balance was deliberately left unchanged for this presentation task.

Generated exports are under ignored `disk-shop/build/web/`. Local screenshots and automation traces are under ignored `.checks/`; they are not source assets.


## Gameplay/onboarding revision — 2026-10-01

- Fresh start departs directly without opening or rolling a zero-cash shop. Free Bass Drop and the diamond reveal remain; run time begins after departure/reveal.
- Persistent first-run instructions explain WASD, clicking/holding adjacent trash to swing the bat, collecting cash, and using Bass Drop. First shop introduces purchasing; a completed purchase clears that introduction.
- Run timeout blocks gameplay immediately, freezes the player, invalidates delayed ability effects, fades into the elevator and closes its doors. Shopping starts after the one-second return presentation, with the full 30-second deadline.
- Green stat records, cyan ability-upgrade records and pink new-ability records, with a legend. Card backgrounds/borders use distinct Common/Silver/Gold/Platinum colors. Equipped abilities use pink records consistently. Replacement selection fits the 720p layout.
- Rectangular 31 × 39 store replaces the cone, retaining spawn/stand locations and the middle route while extending side aisles. Full-width shelf dividers offer three gates. Extra junk/cash changes available detour rewards; base durability, prices and reward values remain unchanged.

Validation for this revision: installed editor and cached web templates verified as 4.7.2.stable; 50 regression checks passed, including first-start bypass, persistent onboarding, first purchase, rectangle/stand connectivity, return input isolation and full shop clock after arrival. Native screenshots inspected for run prompts, arrival, category/tier colors and replacement layout. Actual debug WebGL export in headless Chrome completed a three-attempt session using ordinary keyboard/mouse events: two natural timeouts, return transitions, purchases, diamond victory and fresh restart. Read-only observer used during browser tests is removed from the source and release export. Additional Chrome checks passed: distant/UI clicks do not damage junk; the tutorial fits 960 × 540; simulated browser blur lasting beyond the natural run deadline resolves exactly one return and opens a full-duration shop; the zero-cash shop stays open until its natural deadline and then starts attempt two. Final release export launched and started a run in Chrome with no browser exceptions/errors and no observer hook. A web-only missing legend glyph was removed after screenshot review. Native tools continue to print the known root-certificate-store warning; no parser/runtime/shader failures occurred. Firefox, Safari, actual itch.io embedding, listening review and human balance testing remain unverified. No upload or external publication performed.


## Uploaded music — 2026-10-01

- Replaced active procedural beat playback with all six user-uploaded MP3s from `assets/music/`. Four Crate Smash Sprint variations play during runs; Elevator Jazz and Elevator Motif play during elevator departure, return and shopping.
- Separate randomized shuffle bags exhaust each pool before reuse and prevent an immediate repeat across reshuffles. History survives phase changes for the session. Same-phase calls preserve the playing track; natural track completion advances the playlist. Music starts after player interaction and retains the existing mute control.
- Timeout immediately changes to elevator music, avoiding a brief additional sprint song during the return animation.
- Godot/editor and cached templates verified as 4.7.2.stable. **61 regression checks passed**, including multi-cycle no-repeat rotation, valid/non-looping MP3 imports, phase switching, completion advance and mute/restart behavior. Focused playback tests sought near the ends of actual MP3 streams and confirmed natural finished signals advance both pools; test teardown is clean.
- Actual debug WebGL export completed a two-attempt Chrome session through purchases, victory and restart using ordinary mouse/keyboard input. Logs confirmed different sprint variations between attempts, both elevator tracks playing, and music stopping on fresh restart. No browser exceptions/errors. Observer instrumentation was removed from source before the final release export.
- Final release Web export succeeded and launched/started a run in Chrome with no observer hook and no browser errors. Subjective listening/mix review, Firefox/Safari and itch.io embedding remain unverified. Asset provenance is recorded in `ASSET_SOURCES.md`.

## Typography — 2026-10-01

- Bundled Bungee for major headings, the run timer and DROP IN; Space Grotesk Medium/Semibold for UI and readable signage; Permanent Marker for short decorative slogans and poster/graffiti lettering. Title uses cream lettering, dark outline, orange shadow and a slight tilt.
- Font weights use the numeric OpenType wght tag so Godot selects the intended 500/600 weights. Original font files, upstream licenses and provenance are bundled; export explicitly includes the license text files.
- Godot 4.7.2 and cached 4.7.2 web templates verified. Final regression: 61 checks, zero failures. Native menu and replacement screenshots inspected; Chrome release title, run and natural timeout/shop inspected. After correcting the weight setting, final release export and Chrome title/run smoke check passed with zero browser errors. No new full winning session was run for this typography change. Firefox/Safari and itch.io remain unverified.
- Concurrent visual changes briefly produced incomplete-source parser errors during an intermediate capture/export; final regression/export and browser checks passed after those edits completed. Known Windows root-certificate warning remains.

## Depth, brick walls and junk variation — 2026-10-01

- Wall height increases from 0.8 to 1.8 tiles; bare orange brick/mortar shader replaces shelving, posters and graffiti attached to walls. Stable wall geometry and all logical wall cells remain unchanged.
- Lower ambient/key-light energy, muted prop colors and darker grain, enabled directional shadows, and a slightly oblique orthographic camera make top/side faces and floor shadows visible. Compatibility rendering retained.
- Six deterministic variants within each durability tier replace the regular repeating pattern; heavy bands include amplifiers, road cases, drums, towers, equipment racks, printers and reel decks. HP, cash, map symbols, routes, prices and progression are unchanged. Meshes remain cached/combined; non-wall props retain bounded vertex wobble.
- Collectible disks have emissive faces, colored local light and an additive pulsing halo supported in Compatibility. Dark center hubs keep the record silhouette readable. Raised visuals clear taller walls; collection approaches remain unchanged. Disk glow/light is removed with the collected disk.
- Bat uses a dedicated overlay material with depth testing disabled and higher render priority, drawing in front of the boy.

Validation: exact Godot editor and cached web templates verified as 4.7.2.stable. 61 regression checks passed. Native Compatibility captures inspected for aisles, walls, prop variation, disk glow, bat, menu and elevator; no parser/runtime/shader errors. Chrome WebGL debug export completed a three-attempt session using ordinary keyboard/mouse events: natural run timeouts, cash collection, shopping/upgrades, manual departures, diamond victory and fresh restart (wallet/attempts reset). No browser exceptions or console errors. Temporary read-only observer is removed from final source and excluded from release. Native tools emit the existing root-certificate-store warning. Full route testing used the final geometry/camera/shadows; subsequent disk-face brightness/hub refinement is cosmetic.

Generated web exports remain ignored. No upload or publication. Firefox, Safari, itch.io embedding and human balance/listening review remain unverified.

Additional browser checks: distant/UI clicks preserve junk state; onboarding remains readable at 960 x 540; simulated blur past the 60-second deadline resolves one return and starts a full shop clock. Final release Web export succeeded.


The natural zero-cash shop deadline starts attempt two correctly. Final release launched and started a run in Chrome with no observer hook, browser exceptions or console errors; screenshot inspected. Release files are in ignored disk-shop/build/web/.


## Player darkness and HUD panels — 2026-10-01

- World-only screen shader adds a soft darkness falloff centered on the player's projected position. Inner radius stays fully lit; outer scenery retains at least 45% brightness. Resolution/aspect correction keeps the falloff round, and visual motion/camera movement update its center. Strength and radii are editable shader uniforms. It does not restrict logical targeting, drops, movement or disk collection.
- Effect applies only during runs, preserving title/elevator/diamond reveal/victory presentation. Sharp UI stays above the darkness pass.
- Dark bordered panels behind cash/LP count, timer and announcer captions. Caption panel fades with its text and hides when empty/faded. Panels consume mouse clicks so HUD clicks cannot smash underlying junk.
- Removed sound on/off button, its signal and scene callback. Audio still starts after the user starts a session. Removed the two obsolete mute-button regression assertions.

Validation so far: Godot editor and cached templates verified as 4.7.2.stable. 59 regression checks passed. Native Compatibility render inspected for darkness, walls, prop readability and HUD panels; no parser/runtime/shader errors. Debug and release Web exports succeeded. Chrome screenshots inspected, and actual clicks on all three new top HUD panels preserved junk state. Known root-certificate-store warning remains. Test observer removed from source and excluded from release. No upload/publication.

Chrome WebGL playthrough completed a two-attempt session through a natural run timeout, elevator shopping/upgrades, manual departure, diamond victory and fresh restart (wallet and attempts reset), using ordinary mouse/keyboard input. All three top HUD panels isolate clicks. No browser exceptions or console errors in the full-session trace.


Final release launched and started a run in Chrome with no read-only observer hook, browser exceptions or console errors. HUD/darkness screenshots inspected at 1280 x 720 and 960 x 540. Firefox, Safari and itch.io embedding remain unverified.


## Stage Dive teleport and itch.io package — 2026-10-01

Stage Dive now teleports exactly three cardinal tiles, using last WASD facing. It skips intermediate junk, instantly breaks landing junk of any durability through the normal drop/Feedback path, and collects landing cash. Intermediate cash remains. A wall/stand anywhere on the route, an invalid boundary, or no charges cancels without consuming a charge. Upgrades add one charge per level (3/4/5), keeping distance fixed. Encore does not echo the instant-break teleport. Landing on a disk approach collects it immediately; diamond victory stops remaining ability presentation. Platinum Rush retains its existing dash behavior. GDD and in-game Stage Dive description updated.

Godot editor/templates verified as 4.7.2.stable. 59 regressions passed plus 23 focused Stage Dive checks, also passed in Chrome WebGL: direction, skipped junk/cash, heavy/empty landing, single payout/charge, stopped interpolation, collision/bounds, upgrades/refill, Feedback, echo exclusion, invalid-state input and immediate diamond victory. Temporary web fixture and observer hooks removed; final release excludes tests. Existing native certificate-store warning remains.

Release archive: disk-shop/build/disk-shop-web.zip, 17,391,732 bytes, nine runtime files with index.html at the ZIP root. Integrity/CRC, required files and HTML pack-size metadata verified. Thread support disabled; no SharedArrayBuffer isolation is required. No external upload or publishing performed. Actual itch.io hosting, Firefox and Safari remain unverified.

Latest debug WebGL build completed a two-attempt Chrome session through natural timeout, upgrade purchases, manual shop departure, diamond victory and fresh restart using ordinary keyboard/mouse input. No browser exceptions or console errors. Dedicated Stage Dive browser checks ran against a controlled test fixture, separate from this normal playthrough.


The exact release ZIP was extracted and served at a nested URL inside a 960 x 540 iframe. Chrome loaded its title and started a run; screenshot inspected; no test observer, browser exceptions or console errors. This is a local iframe check, not an actual itch.io upload/embed validation.


## Title rename and rebuilt web package — 2026-10-01

- Application/browser title is now Smash the Record. Menu uses two-line SMASH THE / RECORD lettering at 54 px so the longer title fits the existing panel. Documentation headings updated; project directory and internal identifiers retained.
- Godot editor and web templates verified as 4.7.2.stable. Release export succeeded. New upload archive: disk-shop/build/smash-the-record-web.zip (17,392,005 bytes); nine runtime files and index.html at root, CRC/file metadata checked.
- Exact ZIP extracted and launched in Chrome inside a 960 x 540 local iframe. Browser document title verified as Smash the Record; menu screenshot inspected for title/button fit; DROP IN begins the elevator departure and first reveal. No observer hook, browser exceptions or console errors. Actual itch.io hosting remains unverified; no upload/publication performed. Gameplay is unchanged from the preceding validated build.
