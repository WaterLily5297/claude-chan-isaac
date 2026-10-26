# Claude handoff: current development checkpoint

## Start here

Updated 2026-10-26. Read [CLAUDE.md](../CLAUDE.md), [CONTRIBUTING.md](../CONTRIBUTING.md), [TESTING.md](TESTING.md) and [art terms](../resources/ART_LICENSE.md) before editing. This section is current; dated histories retain their original evidence scope.

- **Current main:** [live main](https://github.com/WaterLily5297/claude-chan-isaac/tree/main); O4 baseline `aef6de9` (PR #99 merged; main CI passed). PR #100 is a draft rejected numerical approach, not approved for merge. Verify live main and PRs before another branch.
- **Reviewed gameplay source:** `f8b2b0b` includes PRs #93-#97. It differs from the fetched main only in Markdown. Keep gameplay evidence tied to that installed commit, not the later documentation commits.
- **Installed manual-test build:** `f8b2b0bbd1267a37c2c299dd1c54c4ca9a739f79`, installed on 2026-10-26. A fresh allowlisted backup preserved 433 old files and passed reread SHA-256 verification before replacement. All 443 installed tracked files matched canonical Git bytes before launch and after shutdown. No files were removed. Historical source hashes below are audit baselines, not current installation claims.
- **Owner availability:** the owner authorized installation/testing, then said the desktop was unavailable and requested keeping the installed version. Preserve f8b2b0b; continue offline. The game is closed, audio restored to the fresh session snapshot, and all options key/value pairs match that snapshot. The checklist reply supplied no usable manual gameplay result; no item was accepted. Use the [14-item manual checklist](MANUAL_TEST_CHECKLIST.md); unencountered cases may be reported as not tried.
- **Evidence:** the installed version launched as Repentance+ v1.9.7.17.J460, but window recovery failed and captures were obscured by other apps. No gameplay keys, menu fresh start or ancestry probe ran. [Dated deployment/startup record](ENGINE_AUDIT_2026-10-26.md). Startup is not engine or visual acceptance.
- **Offline gate:** 69 suites, 182 tracked Lua files, five XML files and deterministic assets. CI runs the same gate. Passing stubs do not prove native callbacks, animation, controller input, real continuation or playability.
- **Current queue:** the 2026-10-26 prompt supersedes the old queue. M1/D2 provide the manual checklist and consistent records; The owner redirected B1 to new character-specific tradeoffs instead of blanket benefit reductions; draft #100 must not merge. Prepare a revised mechanic proposal with current base values preserved. Then O4 effect-layer audit, O5 pose preview, O6 save audit/regressions and O7 a two-item proposal (implement only after approval). E2-E5 wait for owner availability. No further child-laser/Parent/derived-shot billing PR without native E2 evidence.
- **Desktop gate:** before each engine block, obtain a fresh owner confirmation of being away from the keyboard for a stated duration. On user-input, missing-monitor or obscured-window errors, stop immediately; do not retry or send keys. Close only the process launched for that block and restore settings. One attempt per go-ahead; installed f8b2b0b must not be replaced without separate permission.

## O4: effect layers and native-form restoration (2026-10-26)

[Source audit and engine cases](TESTING.md#o4-effect-layers-and-departure-restoration-2026-10-26-source-and-stubs-only) distinguish cleared costumes from native mechanics/effect entities.
The departure helper now restores acquired native transformation costumes once; the new regression fails on aef6de9 and passes with the fix. Fixed mod looks stay unchanged.
Wings, state-driven shield cues, Mega Mush and remaining departure layers still need engine observation; an allowlist is an owner visual-policy choice.
No installation or engine session. Preserve f8b2b0b; B1 numerical draft #100 is held after the owner requested added gameplay tradeoffs.

## Manual checklist and current records (2026-10-26)

[Manual checklist](MANUAL_TEST_CHECKLIST.md): 14 ordinary-run checks, clear OK criteria and a short response template; difficulty feedback distinguishes the current build from a future approved pass.
Current main, reviewed gameplay source and installed build are separate; obsolete installation claims were removed from current records without rewriting history files.
Documentation only; no new native evidence, balance changes or deployment. The next gameplay unit is B1, with all 22 proposed rows requiring approval before merge.


## Installation and deferred engine session (2026-10-26)

Installed f8b2b0b after the verified backup; all 443 files were rechecked after shutdown. No gameplay code changed in this record.
Repentance+ v1.9.7.17.J460 started muted, but window/input conflicts prevented gameplay observation; E2-E5 remain pending.
The owner requested keeping this installation. Game closed and settings restored; [evidence and limits](ENGINE_AUDIT_2026-10-26.md).

## E2 preparation: bounded native observer (2026-10-26)

[Observer procedure](ENGINE_ANCESTRY_PROBE.md) and an explicitly loaded module are ready for a future authorized session; main.lua never loads it.
Offline checks cover snapshots, bounds and callback cleanup only. No native observations or billing changes were made.
E2 remains waiting for owner availability and authorization; no installation was performed during that audit. Full gate: 69 offline suites, engine acceptance pending.

## O3: native transformation and Tainted-item audit (2026-10-26)

The [TESTING.md audit table](TESTING.md#o3-native-transformations-and-tainted-mechanics-2026-10-26-source-audit-only) maps transformations, Agentic/rerolls, crafting, Tainted Eden and Holy Card risks to concrete engine cases.
No clear source bug was established in the inspected paths; no gameplay code changed. Native trait, item ownership and cosmetic layers are separate test cases.
The audit passed the 67-suite base gate; integration with merged O2 passes 68 suites. This provides no engine acceptance. E4/E5 wait for the owner and no installation was performed during that audit.

## O2: two native meme extras (2026-10-26)

Let's Delve delegates to the native shovel; Six Seven grants a seeded six or seven blue flies. [Approved rules and remaining tests](MEME_BATCH_2.md).
Registration, English EID/README text, original placeholder icon and offline callback coverage are included; no custom enemy or boss.
The owner approved the exact rules; PR #95 merged at 178269b. The 68-suite gate and CI pass. It is included in installed f8b2b0b; engine acceptance is pending.

## O1: reserve multi-pocket DROP for native cycling (2026-10-26)

The owner kept short DROP and chose to disable abilities with multiple pocket items. All 22 forms share the new guard; native input and long holds remain untouched.
The prior source fails the new pocket regression; current tests cover all slots, inventory changes during gestures, rearming and Rice/co-op behavior. [Review and limits](DROP_POCKET_REVIEW.md).
PR #94 passed source/CI checks and is included in installed f8b2b0b. Physical keyboard/controller E4 and UI readability remain pending.

## D1: compact current guidance (2026-10-26)

Current versions, owner availability and next actions are now at the top so the next contributor can find them quickly.
The complete prior handoff is preserved byte-for-byte in [the 2026-10-25 history](HANDOFF_HISTORY_2026-10-25.md); older [2026-10-24 history](HANDOFF_HISTORY_2026-10-24.md) is unchanged.
Verification is recorded under D1 in [TESTING.md](TESTING.md); this docs-only change supplies no new engine or visual evidence and does not alter the installed build.

## Recent source changes (2026-10-25)

PR #92 restored Start here and recorded the next-session priorities; README-VOICE-02 simplified all three introductions.
PRs #88-#91 retain child-laser identity and share the parent's existing attack/Compute decisions across modeled callbacks; #91 also observes backlog children at initialization.
Full evidence remains in [TESTING.md](TESTING.md) and [the verbatim history](HANDOFF_HISTORY_2026-10-25.md). Native ancestry and damage behavior remain unverified; E2 is required before further fixes on this line.

## Implemented source

| Area | Current implementation | Reference |
|---|---|---|
| Characters | 11 families, 22 normal/tainted forms: Claude, DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi and GLM. Each has its own meme loop, Birthright behavior, starting-pickup contract and EID information. | [Actual behavior](MODEL_ROSTER.md), [design targets](CHARACTER_GAMEPLAY.md) |
| Items | 80 collectibles: 25 originals, four meme batch 1 items, one batch 2 item and all 50 requested backlog rows. Also 12 trinkets, five pills, meme extras and Relay Slime. | [Generated item reference](ITEMS.md), [backlog](EXPANSION_DESIGN.md) |
| Shared mechanics | Native-weapon resource observers, DeepSeek Thought adapters, DROP tap recognition, meal countdown, scoped helper shots, tear tint, feedback and co-op HUD bands. | [Native Thought](NATIVE_THOUGHT.md), `scripts/characters/` |
| Risk and saves | Risk covers Claude forms only; DeepSeek has no proxy/IP/risk mechanics. Versioned per-player state and floor checkpoints are implemented. | `scripts/risk.lua`, [save cases](TESTING.md) |
| Appearance | All 22 skins, menus, stage portraits and MAP dossiers are wired. Fixed-look service clears item costume layers on mod forms while retaining item mechanics; vanilla forms remain native. | [Costume contract](COSTUME_COMPATIBILITY.md) |
| Story | Appeal Queue plus three-chapter English arcs for the other ten families. | [Story](STORY.md), `scripts/story_roster.lua` |

Compatibility fixes through #91 are merged in source, including fire-rate scaling, ghost guards, safe door handling, co-op HUD spacing, floor saves, Claude-only Risk, battery charge accounting, familiar attribution, per-player Constitution, helper billing and the Ludovico exemption. Use the individual cases in TESTING.md instead of treating this list as native acceptance.

## Unfinished tasks

1. **O1: DROP tap and native pocket cycling.** The owner selected the multi-pocket restriction; implementation and regression are in PR #94 and [DROP_POCKET_REVIEW.md](DROP_POCKET_REVIEW.md). Merged at ef42b13 and included in installed f8b2b0b; source/CI verification is complete. Preserve native cycling and long-hold dropping. E4 must later test physical keyboard/controller input with a card and pocket active.
2. **O2: meme batch 2.** Let's Delve and Six Seven are merged in #95 under the owner-approved rules. See [the design and native limits](MEME_BATCH_2.md). Both extras are included in installed f8b2b0b; engine cases remain pending. Feel the AGI remains deferred.
3. **O3: vanilla compatibility audit.** Source audit complete: see the O3 table in TESTING.md. No gameplay change was justified. E4/E5 must observe the listed transformation, bag controls, reroll and shield cases before further fixes.
4. **New-item checklist.** Register module/constants/XML with ASCII pickup text; wire main in the right callback order; add EID, deterministic placeholder icon and pool entry; update `tests/eid_test.lua` counts, regenerate `docs/ITEMS.md`, update all three READMEs and relevant design records. Native systems first; new extras do not count again toward the completed fifty.
5. **Art and story.** Nine tainted sets currently derive deeper colors from normal art. Distinct hand-designed replacements and Chinese/Japanese story text remain owner decisions. Improve anatomy, side profiles and special poses from observed failures. Workshop is not authorized.

## Waiting for owner availability: engine acceptance

| Unit | Required observation | Status |
|---|---|---|
| E1 | Preserve the current installation; a later requested replacement needs a fresh allowlisted backup and reread-hash check. | Complete for `f8b2b0b`, 443 files verified; preserve it. |
| E2 | One ancestry probe: Parent, SpawnerEntity and FrameCount at init/update for Tech X splits, Prism reflections, Trisagion and Brimstone/Tech combinations. | Observer installed; attempted session produced no samples. Await owner availability; prerequisite to more child-billing work. |
| E3 | Real menu fresh starts and first room for every normal/tainted form: stats, pockets, HUD, fixed look, dossier, story and errors. | Waiting for owner; type-change smoke does not satisfy this. |
| E4 | Physical keyboard/controller DROP taps and holds, card/pill plus pocket active, pause, disabled controls, room changes, death and reassignment. | Waiting for owner; O1 stubs cannot accept native input. |
| E5 | COSTUME-LOCK-01 and VANILLA-COMPAT-01, then the remaining animation, combat, weapons, saves, co-op, item and base-game matrix. | Waiting for owner. |

For an authorized run: follow the owner's E:/ba backup workflow before replacement; preserve other mods and saves; File 1's current run is disposable. Mute agent-run tests, close the game and restore settings afterward, recording only actions actually verified. Record exact game version, installed commit, case and evidence level. Repeat relevant cases in base Repentance and Repentance+ before claiming both supported. Never run historical `runtime_probe.lua` fixtures without reviewing their destructive/disposable-run assumptions.

## Known risks

- **Appearance:** the oversized hurt head has a source packing correction (28x32 envelope), not full visual acceptance. Side bodies use narrowed fronts; anatomy, symmetry, hurt recovery, death, carrying, flight, revival and transition poses remain to inspect, with and without Reactions Port Pack.
- **Fixed look:** ClearCostumes may hide wings, Holy Mantle or other effect layers, or allow a one-frame pickup flash. O4 restores held collectibles and acquired native transformation costumes once after leaving a mod form; temporary/trinket/external layers and native reconstruction order remain open. Preserve size, flight, weapons and transformation mechanics.
- **Input:** PR #94 disables abilities when the observer sees multiple pocket items; native timing and inventory changes between samples remain E4 cases. Meal hooks block directional shooting, not every charged/programmatic/familiar attack.
- **Native attacks:** Incubus/Twisted Pair timing, melee hitbox lifetime, knife flight, Epic Fetus attribution, Ludovico steering, multi-shot allowance limits and Peak's 1.3x non-tear boost require engine cases. Modeled Parent ordering is not observed engine evidence.
- **Composition and saves:** CollisionDamage writer order with other mods, native save/exit order, exit during knife flight, Seahorse wisps, player-type changes and co-op reassignment remain open. Agentic's inventory/cache latch updates on the next player-effect callback; consequences require native observation.
- **Environment:** historical Stackable Items v2 load errors belong to that mod and must not be silently claimed fixed here.

## Evidence boundaries and history

Historical PR #49 evidence includes a 22-form console/type-change smoke run, nine tear-color checks and one tainted DeepSeek Continue. PR #50 adds bounded GPT credit attribution cases; PR #51 records selected Hit frames. These do not establish 22 fresh menu starts, physical DROP input, current gameplay, full animations, native saves or ordinary-run balance.

- [TESTING.md](TESTING.md): current offline cases and pending engine criteria.
- [ENGINE_AUDIT_2026-10-24.md](ENGINE_AUDIT_2026-10-24.md): bounded historical engine evidence and original limitations.
- [HANDOFF_HISTORY_2026-10-25.md](HANDOFF_HISTORY_2026-10-25.md): the entire pre-compaction handoff at `a1d4d7a`, including all dated logs older than 2026-10-25, recent full notes and obsolete summaries, unchanged.
- [HANDOFF_HISTORY_2026-10-24.md](HANDOFF_HISTORY_2026-10-24.md): earlier preserved evidence, unchanged.

## Direction and contributor workflow

Build recognizable community-meme choices: Claude bans/appeals, DeepSeek rice and Peak/Valley, GPT downgrade/Tibo resets. [Meme research](COMMUNITY_MEME_RESEARCH.md) distinguishes viewed sources, indexed titles, secondary claims and blocked pages; a few posts do not establish majority opinion. Fictional mechanisms are parody, not factual accusations. No real-person/nationality enemies, Grok July 2025 offensive references or official logos.

Use native systems and preserve their effects. Normal GLM's forced Book of Secrets stays removed; tainted DeepSeek's non-tear 1.3x off-peak boost and fixed mod looks are already owner-decided. Never restore DeepSeek proxy/IP/risk. Keep new code, comments, Markdown and UI English. Character design/art is not MIT: preserve ZipZipPipe and DeepSeek credits and the applicable non-commercial/share-alike terms; no extracted vanilla or unlicensed mod assets.

Fetch main, preserve all drafts and use one focused main-based branch/PR without stacks or history rewrites. Run `bash tools/check.sh`, update this handoff and the matching evidence, verify remote equality and CI. Own compatible fixes may merge after checks with no blocking bug or open design/balance decision. Preserve the installed manual-test build; no Workshop release or private data upload. Keep the local ledger current and retain private paths, backups, saves, logs and source reference collections outside public commits.

Core files: `main.lua`, `scripts/constants.lua`, `content/*.xml`, `scripts/risk.lua`, `scripts/characters/`, `scripts/items/backlog/`. Tests are offline stubs; generated assets and item references are checked by `tools/check.sh`. Keep Start here first; each new dated entry below it has at most five lines, with detailed evidence in TESTING.md or a dated audit.
