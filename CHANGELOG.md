# Changelog

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
