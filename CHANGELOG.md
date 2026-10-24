# Changelog

## Unreleased normal Claude timer guards (2026-10-24)

- Advance normal Claude's Limited countdown and idle usage drain once per player/gameplay frame; freeze paused/dead updates and clear transient guards on start/exit. Balance values and save format are unchanged.
- Extend the real-module usage/save regression with duplicate wrappers, co-op isolation, pause/death, exact expiry, revival and lifecycle resets. Correct the old countdown fixture to advance actual frame values. Offline verified; engine timing and animation/costume acceptance remain pending.

## Unreleased handoff audit (2026-10-24)

- Normal and tainted Claude now bill usage/Quota for laser starts and Dr. Fetus bombs, sharing the frame's payment with tears; familiars, placed bombs and knives stay free.
- HANDOFF.md gains a "Status at a glance" section (done, needs the game, needs an owner decision) and drops stale lines found in a line-by-line audit against main.

## Unreleased roster story arcs (2026-10-24)

- Add three short story captions for each of DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi and GLM (normal or tainted), on run start, stage 3 and stage 5. Seven seconds, non-blocking, once per run, co-op queued in player order, saved in `Risk.state.rosterStory` (version 1).
- New offline suite `tests/story_roster_test.lua` (24 in total). English only; not tested in game.
## Unreleased roster stack landing (2026-10-24)

- Bring the full roster stack to main in one PR: nine normal loops (GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi, GLM), nine tainted forms and the tainted roster art. The stacked PRs #24, #27 and #29-#45 had been merged into each other's branches instead of main.
- Regenerate the nine tainted gameplay sheets from the walk-cycle sheets (#25), which the original derivation predated. Portraits and dossiers are unchanged. 42 offline suites pass; no engine validation.

## Unreleased tainted Claude Appeal Pending (2026-10-24)

- Tainted Claude becomes Appeal Pending: 220 Quota and two Appeal Pages per floor; each paid tear volley costs 1 Quota (2 with Subagent Swarm) at 1.25x damage; at zero she is Suspended at 0.5x. A DROP tap while Suspended spends a Page on a six-second active-combat review that restores 60 Quota (Birthright 90); leaving the room cancels it. Three unique combat clears earn a Page.
- Banked Reset refills Quota and cancels a pending review without returning its Page. Per-player saved state replaces the shared weekly counter; tear color is tinted. English HUD, dossier and EID text. Offline only.

## Unreleased Claude Appeals (2026-10-24)

- Normal Claude becomes One More Day: usage is billed once per same-frame tear volley (Subagent Swarm doubles it inside Claude's billing) and drains 10 per second only while not firing. Appeals start at 1, cap 2, and are earned every two unique combat clears; a DROP tap spends one to remove 40 usage, never during Limited.
- Birthright keeps account age through the first suspension on each floor; a saved latch stops continue from re-judging it. English HUD, dossier, EID and caption `Another love letter.`
- Seventeen offline suites pass, including the new Appeals suite. Account age is still shared; tainted Appeal Pending and non-tear billing remain pending. No runtime or Workshop changes.
## Unreleased native Thought adapters (2026-10-24)

- Normal DeepSeek Thought: delayed bursts share the paid volley until the native firing cycle could repeat (floor of MaxFireDelay, cap 15 updates); Incubus and Twisted Pair tears copy a paid volley without paying; each melee swing hitbox pays once; Epic Fetus rockets pay once and their explosions are re-dealt at that factor.
- New offline suite `tests/thought_adapters_test.lua` (23 in total). Source only; engine attribution for hitboxes, rockets and familiars is unverified.

## Unreleased tainted GLM Please Retry (2026-10-24)

- Register Tainted GLM-chan with the deeper-colour art. Please Retry: damage 0.9x; a DROP tap queues a two-second request on the nearest enemy within 200 units (three-second cooldown); a surviving target takes 2x plus 1x per Retry, consuming them, and an early death adds one Retry (cap 3); Birthright failures also remove one nearby enemy bullet. Offline only.

## Unreleased tainted Kimi You Are the Manager (2026-10-24)

- Register Tainted Kimi-chan with the deeper-colour art. You Are the Manager: damage 0.85x; a DROP tap assigns a task to the nearest unassigned enemy within 220 units, dealing three 0.6x pulses (Birthright 0.7x) two seconds apart; three tasks at once and nine pulses per room; exit cancels tasks without refunding the budget. Offline only.

## Unreleased tainted Doubao I'll Do It Again (2026-10-24)

- Register Tainted Doubao-chan with the deeper-colour art. I'll Do It Again: a DROP tap starts six seconds of Confident (1.35x damage), then four seconds of Apology (0.85x, Birthright three), then ready; timers run only in combat, and an enemy hit during Confident starts the Apology early. Offline only.

## Unreleased tainted Mistral Le Gros Chaton (2026-10-24)

- Register Tainted Mistral-chan with the deeper-colour art. Le Gros Chaton: speed -0.1, damage 0.9x; standing without firing for two seconds bakes a Baguette (cap 2, Birthright 1.5 seconds); a DROP tap sends a slow 120-unit shockwave dealing 2.5x once per enemy, stopped by walls, with a two-second cooldown. Offline only.

## Unreleased tainted Llama Still Waiting (2026-10-24)

- Register Tainted Llama-chan with the deeper-colour art. Still Waiting: damage 0.9x; unique combat clears add Hype (cap 3); a DROP tap spends all of it on a stationary helper that fires one 0.5x native tear per second at the nearest enemy for four seconds per Hype (Birthright five), removed on room exit. Offline only.

## Unreleased tainted Qwen Final Final Fine-Tune (2026-10-24)

- Register Tainted Qwen-chan with the deeper-colour art. Final Final Fine-Tune: in cleared rooms a DROP tap cycles Heavy (1.3x damage, 1.2x interval), Tiny (0.85x, 0.8x) and Balanced, locked in combat; unique clears with all three builds award +0.2 damage for the floor (Birthright +0.3), up to three. Offline only.

## Unreleased tainted Grok Quote Without Reading (2026-10-24)

- Register Tainted Grok-chan with the deeper-colour art. Quote Without Reading: base damage 0.9x; a DROP tap quotes the nearest enemy within 220 units for six seconds (ten-second cooldown); paid hits on other enemies build Ratio (cap three), which lands on the quote as 1x damage pulses at expiry. Birthright moves half the Ratio once if the quote dies. Offline only.

## Unreleased tainted Gemini One More Edit (2026-10-24)

- Register Tainted Gemini-chan with the deeper-colour art. One More Edit: base damage 0.9x; a DROP tap starts a six-second (Birthright ten) chain on the nearest enemy within 180 units; three distinct paid hits go Crop, Recolor, Export and add one 2x damage pulse, once per room. Saved per player. Offline only.

## Unreleased normal GLM Number in Queue (2026-10-24)

- Normal GLM replaces active-item tool links and the forced pocket Book of Secrets. Each unique combat clear advances the Queue (max three); at three, a DROP tap redeems an Access Pass giving +20% damage in each of the next two new hostile rooms (Birthright three). The Queue pauses while the pass is active; revisits never spend or stack it. Saved per player in `Risk.state.glmQueue`.
- The roster module now keeps only identities, dossier lines and the tear tint.
- 26 offline suites pass, including the new GLM Queue suite. No runtime or Workshop changes; engine validation pending.

## Unreleased normal Kimi Another Slide Deck (2026-10-24)

- Normal Kimi replaces flawless-clear pages. Each unique combat clear earns a Slide (cap six); a DROP tap spends three (Birthright two) to present to the three nearest enemies within 220 units, slowing them for four seconds and adding +15% to the owner's damage against them. No audience, no spend. Saved per player in `Risk.state.kimiSlides`.
- 25 offline suites pass, including the new Kimi Slides suite. No runtime or Workshop changes; engine validation pending.

## Unreleased normal Doubao Sorry, You're Right (2026-10-24)

- Normal Doubao replaces the every-third-clear meal. The first enemy-caused hit in each hostile room grants a six-second Apology token (Birthright: until room exit); a DROP tap slows enemies within 100 units for two seconds and removes the four nearest enemy bullets. No health refund. Saved per player in `Risk.state.doubaoApology`.
- 24 offline suites pass, including the new Doubao Apology suite. No runtime or Workshop changes; engine validation pending.

## Unreleased tainted GPT Reset Watcher (2026-10-24)

- Register Tainted GPT-chan with the deeper-colour tainted art. Reset Watcher: 80 Credits per run (Birthright 100); DROP toggles Standard and Full Send (1.5x, one Credit per same-frame paid attack); three unique combat clears bank one Tibo reset that the next tap claims to refill Credits. Saved per player across floors and continue. Kept out of the proxy account. English HUD, dossier and EID. Offline only.

## Unreleased tainted roster art (2026-10-24)

- Add deeper-colour tainted gameplay sheets, stage portraits, dossiers and menu cells for the nine newer families, derived deterministically from the normal art (including the new walk cycle) by `tools/make_roster_tainted_art.py`. Hashes are checked by the asset gate. The forms are not registered yet; each tainted mechanic PR registers its own.
## Unreleased fifty-row backlog, rows 02-50 (2026-10-24)

- Add the 49 remaining collectibles of the fifty-row backlog (EXPANSION_DESIGN.md): four per family for Claude, DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi and GLM, plus six shared items. 22 actives and 27 passives, all with original 32x32 icons, pool entries and English EID.
- One shared service (`scripts/items/backlog/common.lua`) handles attacks across tears, lasers, knives and Fetus bombs, ordinary-bullet guards, unique clears, timers and versioned per-player saved state.
- Fix Stuck in Mt. Moon to identify rooms by `GetCurrentRoomDesc().SafeGridIndex`.
- Two new offline suites (22 in total). No engine validation, runtime or Workshop changes.

## Unreleased meme extras, batches 4-5 (2026-10-24)

- Add Seahorse Emoji (A3: one room-scoped native wisp of a random vanilla active), Temperature Dial (A2: saved toggle between x1.1 damage and one random native tear flag per tear), Deep Research (A12: native map, compass and secret-room reveal), trinkets As an AI Language Model (removes one non-Labyrinth curse per floor), System Prompt Leak (compass effect per floor) and Disgrace Loop (first real hit in a room freezes enemies 1.5 s), and the Rolled Back pill (all stats up for one room).
- Original icons, English EID and a new offline suite; twenty suites pass. No engine validation.

## Unreleased meme extras, batch 3 (2026-10-24)

- Add Strawberry (every third tear per player is a red 2x "R" tear; tears only) and Golden Gate Claude (native spectral tears, +1.5 range, golden tint, occasional seeded caption). Completes the nine-item meme-extras proposal. Nineteen suites pass; no engine validation.

## Unreleased meme extras, batch 2 (2026-10-24)

- Add three trinkets and one pill outside the fifty-row backlog: Claudius's Discount (refund 1 coin on confirmed purchases of 2+ coins; lose 1 coin per new floor), One Small Rock a Day (once per floor, breaking a rock heals half a red heart; kept while at full health), Stuck in Mt. Moon (six backtracks into cleared rooms reveal the floor map, once per floor) and 9.11 > 9.9 (permanent +0.11 damage, horse pill +0.9).
- Shared versioned per-player state in `Risk.state.memeExtras` (floor-scoped flags, saved pill bonus). Native prices are never rewritten. Original icons, English EID and a new offline suite; nineteen suites pass. No engine validation.

## Unreleased meme extras, batch 1 (2026-10-24)

- Add three collectibles outside the fifty-row backlog: Ignore All Previous Instructions (A4: charm the nearest non-boss within 200 units for 8 s, confuse a boss for 2 s, empty use keeps charge, Car Battery picks a second target), Tungsten Cube (+0.8 damage, -0.15 speed per copy, native knockback tears) and Pizza Glue (25% slowing tears, luck 10-50%, -0.1 shot speed; tears only).
- Original generated icons, pool entries, English EID and a new offline suite. Eighteen offline suites pass. No engine validation, runtime or Workshop changes.

## Unreleased roster walk cycles (2026-10-24)

- GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi and GLM walk with visible legs: a ten-frame stride, alternating front steps, swinging side legs and a one-pixel bob. Each direction uses one stable body, removing the old frame-to-frame jitter. Carry cells get the same legs.
- Deterministic `tools/animate_roster_walk.py`, wired into the hurt-pose rebuild verifier; the asset gate now checks all thirteen atlases against the art manifest. Offline preview: `tools/preview_original_movement.py --walk-roster`. No engine validation yet.

## Unreleased roster review fixes (2026-10-24)

- The nine model roster families leave the proxy IP / risk account. A roster-only or DeepSeek-and-roster run has no IP or risk. In co-op with Claude or a vanilla character, only those covered players raise risk when hit, spoil a clean room or take the suspension damage penalty; DeepSeek no longer takes that penalty in co-op either.
- Qwen chains and Kimi pages ignore deliberate self-damage flagged `DAMAGE_NO_PENALTIES` (Blood Donation, IV Bag, sacrifice rooms), and a hit from a player outside the player list no longer errors.
- Roster tear colors tint the existing color instead of replacing it, so item colors and offsets survive.
- Seventeen offline suites pass, including the new risk coverage suite. No runtime or Workshop changes; engine validation pending.

## Unreleased tainted DeepSeek Peak / Valley (2026-10-24)

- Tainted DeepSeek becomes Wenfeng / Wengu: twelve combat seconds of Valley alternate with twelve of Peak, frozen in cleared rooms and on pause; every floor starts in Valley. Compute starts at 12 (cap 24, Birthright 32) and carries across floors. Paid tear volleys fork into two native half-damage tears for 2 (Valley) or 4 (Peak); Valley recovers 3 per second in combat while not firing. DROP tap toggles Forks On / Saving.
- Remove legacy random Server Busy shot deletion and free unconditional forks. Saved per-player Compute, phase, timer and mode; identity, character change and corrupt data reset safely. English HUD, dossier and EID text.
- Sixteen offline suites pass, including the new Peak / Valley lifecycle suite. Non-tear weapons get no forks yet; engine validation pending. No runtime or Workshop changes.

## Unreleased native Thought adapters (2026-10-24)

- Apply normal DeepSeek Thought to native lasers, flying knives and Dr. Fetus bombs, preserving original weapons and visual/effect fields. Repeated-hit beams and controlled tears use saved six-update windows; single-hit beams and released rings snapshot one attack.
- Stop persistent attacks from regenerating their own Thought. Raw continuous forks inherit the parent factor without paying again, and cleanup removes transient factors before exit. 1M Context snapshots the unboosted continuous baseline, preventing permanent compounded bonuses.
- Fifteen offline suites pass, including a regression that fails against the earlier tear-only Rice module. Epic Fetus, melee, delayed bursts, familiars, conflicting damage writers and engine validation remain pending. No runtime or Workshop changes.

## Unreleased Rice First source candidate (2026-10-24)

- Normal DeepSeek earns rice from unique combat clears and spends a bowl on a short DROP release. A two-second meal grants full Thought and six seconds of +0.15 speed; Birthright halves meal duration. The intrinsic meal never heals. Personal counters, remaining bonuses and pending meals survive continue.
- Remove normal random shot deletion and idle pocket charging. Same-frame tear pellets share one Thought payment, with resolved damage inherited by Swarm and native tear fields unchanged. English HUD, dossier and EID descriptions reflect the actual candidate.
- Fourteen offline suites pass, including meal/save/room/co-op and callback-order regressions. Non-tear and persistent-attack accounting, tainted Peak / Valley, current-engine validation and costume acceptance remain pending. Owner currently requests source/offline work only.

## Unreleased meal lifecycle correction (2026-10-24)

- Lunch Break and Brb, Getting Food share a per-player saved three-second countdown. Suppress directional shooting queries during the meal, preserve movement and other controls, and restore the remaining countdown on continue without changing character types or costumes.
- Lunch Break preserves charge during an existing meal and ignores Car Battery repeats. Offline regressions reproduce the old repeated heal and cover input isolation, pause, continue, duplicate updates, expiry and co-op identity. Charged weapons, persistent attacks and other input mods still require engine acceptance.

## Unreleased DROP tap/hold correction (2026-10-24)

- GPT/Gemini switch mode on a short DROP release rather than immediately on press. Long holds do not switch, and native input remains available for dropping and pocket cycling.
- Cancel pending gestures across pause, transitions, lost control, death, continue and observed identity/controller changes. Preserve saved mode and existing balance. Offline input regressions pass; keyboard/controller and native-drop engine acceptance remain pending.

## Unreleased hurt-pose correction

- Fit all thirteen registered skins' shared hurt-pose cell to the measured vanilla envelope and ground anchor instead of filling a 64px storage cell. Correct Llama's truncated source crop without redrawing its art.
- Source hashes and surrounding atlas pixels are unchanged. The offline regression fails on the previous thirteen skins and passes exact rebuilt corrections. Hit and the four other transitions sharing this cell still need engine acceptance; no runtime installation or Workshop publication.

## Community-meme design and character reference review

- Replace the capability-based character draft with twenty-two meme-led proposals. Source strength and blocked-video limits are explicit; none of these replacement loops is implemented yet.
- Pin three public character/template repositories and inspect vanilla hurt-frame geometry. The oversized hurt-pose bug is still open; no third-party artwork was imported.

## Unreleased Summary Stapler candidate

- First of fifty additional collectibles: Summary Stapler, a four-charge treasure active. Absorbs at most twelve nearby ordinary hostile bullets and emits one native tear with a bounded multiplier. Preserves native tear effects and this mod's limits/forks; no weapon or costume replacement, empty-use charge loss, quota reset or Car Battery repeat.
- Original geometric stapler/paper icon using the existing item-icon generator; English description. Theme: summary-based compaction from [Claude context documentation](https://platform.claude.com/docs/en/build-with-claude/context-editing). Bilibili swarm leads and access limits, 22-form loops, nine darker tainted directions and all fifty item designs are recorded in `docs/EXPANSION_DESIGN.md`.
- Source implementation and offline tests only. No installation, engine acceptance or Workshop publication.

## Unreleased model roster candidate (2026-10-23)

- Owner-requested portrait overhaul: thirteen full illustrations for eleven normal families and both existing tainted characters, imported into menus, transitions and clear-room MAP dossiers.
- Nine new normal characters: GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi, and GLM. Each has a distinct bounded gameplay loop; see `docs/MODEL_ROSTER.md` for exact values and source boundaries.
- Per-player saved progress, duplicate-room reward protection, current-run transient meters and extended Reactions Port Pack fallback support. Existing DeepSeek direct-connection behavior is preserved.
- Normal portraits adapted from credited ZipZipPipe illustrations; approved tainted designs subtly darkened. All thirteen gameplay sheets now match the selected portrait hair, costume and accessories. Separate art credits, source hashes and edit prompts are recorded. No video frames or official avatars are included. Animation polish and engine acceptance remain pending; no Workshop publication.

## v0.5-dev

Characters (owner request: normal + tainted for both; DeepSeek-chan is unrelated to IPs):

- **DeepSeek-chan redesigned.** She connects directly, so a DeepSeek-only run has no IP, no risk and no risk-based difficulty (`Risk:IsActive`). New gimmicks from her own memes: **Deep Think** (深度思考, "已深度思考（用时N秒）"), **Server busy** (服务器繁忙，请稍后再试), and the pocket active **Lunch Break** (飯食ってくる / 去吃饭了), recharged by **slacking off** (摸鱼: 5 s standing still in a cleared room; from the viral Bilibili video 《大肥鱼成精了！在摸鱼！》). The Server busy mechanic also matches DeepSeek's 2026-10-15 global outage. The Support Ticket stays a shop item.
- **Tainted Claude-chan** (周限额): per-floor tear quota instead of the usage meter; pocket Banked Reset refills it. From the weekly-limit posts on X.
- **Tainted DeepSeek-chan** (开源): every tear is forked into two weaker copies; busier servers.
- **Claude-chan: Account age** (账号满月): +0.2 damage per floor without suspension; reset on suspension ("Banned again" / 《又封了》). From the "喜报：Claude满月啦" posts and the Bilibili song 《又封了》.
- Tainted sprites, portraits and menu portraits are recolours of the normal art (`tools/make_tainted_art.py`); `content/gfx/characterportraitsalt.anm2` added.

Sprites:

- Fixed heads spilling over their 32px cells (clipped in game, leaking into neighbouring frames), Claude-chan's cut-off side-shooting head, and DeepSeek-chan's walking bodies (front-facing, arms-raised copies, so she slid sideways). `tools/fix_character_cells.py`.

Items (memes on X):

- **529 Overloaded:** you're left "coding manually" during an outage: you can shoot, at 50% damage (was: no shooting).
- **Vibe Coding:** "Make no mistakes": no hit on a floor waives the next API bill.

Bug fixes:

- Ban Hammer bans no longer let a Relay Slime split. Thinking Cleared only drains on a room's first visit. The Constitution no longer refuses self-inflicted damage (IV Bag, Razor Blade, blood donation).
- The runtime probe now runs on a Claude-chan run (DeepSeek-chan no longer carries the Support Ticket).

## v0.4-dev (2026-10-23)

- Queue simultaneous story captions and save unseen pending chapters, preventing room/floor callbacks from silently dropping dialogue. Add collision/continue regressions and an explicit manual engine probe. Positive-risk insufficient funds, Car Battery and queued-story JSON round-trip passed in Repentance+.

- Reviewed and merged PR #1 (collaboration checks) and PR #2 (RORICO444's 21 item/trinket icons).
- Added Support Ticket: six charges, three coins for risk -20, with failed-use and Car Battery guards.
- Added playable DeepSeek-chan with blue tears, a firing-interval/damage tradeoff, pocket Support Ticket and team-wide no-hit risk recovery.
- Added The Appeal Queue: four original saved captions in en/zh/ja. Early approvals preserve later chapters with approved-route dialogue.
- Added generated Claude/DeepSeek character atlases, portraits, names and menu assets. Runtime fixes preserve faces with Reactions Port Pack, map DeepSeek clothing correctly and fit repaired Claude rear-head/body cutouts into engine cells.
- Moved story captions above the Loadout prompt and away from the upper EID text.
- Seed Silent Update before each floor roll, including pre-start NEW_LEVEL; continue preserves its stored multiplier.
- Fixed Windows Python detection and UTF-8 handling. Checks cover deterministic sprites, character assets, animation bounds, pools and gameplay boundaries.

Validation: required offline checks and initial Repentance+ 1.9.7.17 runtime checks passed, including both custom skins, corrected Claude rear hair, actual ticket use/refusal, an approved-route chapter, subtitle placement and continued runs. Tests were muted and the game was closed normally. Full animation/costume coverage, ordinary Repentance, co-op and a full run remain open; see HANDOFF.md. Character-art permissions and Workshop publication remain separate release requirements.

## v0.3-dev (unreleased, not yet tested in game)

New items, each based on a Claude / AI meme:

- **Compact** (active): the "compacting ate my 5-hour limit" complaints.
- **You're Absolutely Right!** (passive, angel): sycophancy.
- **9.9 Yuan Relay** (passive, devil): cheap relays secretly swapping the model (掺水).
- **Ultrathink** (active, timed): think / megathink / ultrathink and the 31,999-token budget.
- **1M Context** (passive): context rot.
- **Silent Update** (passive): 降智, behaviour changes missing from the changelog.
- **--dangerously-skip-permissions** (passive, devil): no prompts, occasional `rm -rf`.
- **All Tests Passing** (active): reward hacking by deleting assertions.
- **Vibe Coding** (passive): "Claude Code is vibe-coded" and the $1,986 vibe-coding bill video.
- **Banked Reset** (active): Anthropic's save-it-for-later rate-limit reset.
- **Subagent Swarm** (passive, devil): the sessions that spawned excessive parallel subagents.
- **Cat-girl Mode** / **Brb, Getting Food** (pills): DeepSeek-chan memes.
- **Welcome Notice** (trinket): fan lore where DeepSeek-chan swaps Claude-chan's ban card; Ban Hammer recruits instead of bans.
- **Status Page** (trinket): the status page that said everything was fine during outages.
- **The Constitution** (passive, angel): the priority order in Claude's 2026-01-21 constitution.
- **Opus Mode** (passive, shop): "more expensive than gold"; damage for coins.
- **529 Overloaded** (trinket): the July–August 2026 outages.
- **Hardcoded Output** (trinket): special-casing the expected output.
- **Thinking Cleared** (trinket): the cache bug that wiped thinking every turn.

New enemy: **Relay Slime** (placeholder on vanilla Clotty): splits twice on death, appears from risk 30.

EID: descriptions for the pills and for Claude-chan herself (en / zh / ja); language codes checked against EID's source.

New: **Suspended** state at risk 90+ (damage ×0.75), and the **Appeal Form** trinket that resets risk to 50 instead.

New: **Agentic** transformation (any 3 of the 6 Claude Code items): flight, tears up, +0.5 damage.

HUD: risk, IP and usage text now follow the game language (English / 简体中文 / 日本語), falling back to English if no CJK font loads.

Changed: **Ban Hammer** now misbans: 20% of bans hit innocent developers, +3 risk each.

Also: in-game test checklist (`docs/TESTING.md`), goals (`docs/GOALS.md`).

## v0.2

- Playable **Claude-chan** (design by ZipZipPipe): Range +1.5, Shot Speed +0.2, Speed −0.1, pocket Ban Hammer, usage limit mechanic. Placeholder art.
- Art license split from code license; art spec for the pixel artist.

## v0.1

- Risk score and random proxy IP per floor, enemy HP scaling, hydra respawns.
- **Ban Hammer** (active) and **Residential IP** (passive).
- EID descriptions in English, Chinese and Japanese.
