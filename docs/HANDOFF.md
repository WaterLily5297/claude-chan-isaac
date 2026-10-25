# Claude handoff: current development checkpoint

## Start here

Updated 2026-10-26. Read [CLAUDE.md](../CLAUDE.md), [CONTRIBUTING.md](../CONTRIBUTING.md), [TESTING.md](TESTING.md) and [art terms](../resources/ART_LICENSE.md) before editing. This section is current; dated histories retain their original evidence scope.

- **GitHub and local source:** main `2182cb1` at this review, including merged PR #93 (D1 compaction), #92 (Claude's next-session handoff) and #91; merge CI passed. O1 is the `codex/drop-pocket-audit` draft follow-up, with no production changes. Check the [live PR list](https://github.com/WaterLily5297/claude-chan-isaac/pulls) and main before continuing.
- **Installed manual-test build:** `e1ff4d1` including #91, installed on 2026-10-25 after a fresh allowlisted backup was reread and hash-verified. All 433 installed tracked files matched canonical Git bytes. The local deployment receipt supersedes the next-session prompt's older `220d542` statement. Preserve this installation during offline work.
- **Owner feedback:** asked about the installed build; owner replied "not tested yet" on 2026-10-25. No new engine or visual acceptance. No launch, input, process inspection, save access or runtime replacement in D1; current game state has not been inspected.
- **Offline baseline:** 67 suites, 177 tracked Lua files, five XML files and deterministic assets. CI runs the same gate. Passing stubs do not prove native callbacks, animation, controller input, real continuation or playability.
- **Current queue:** D1 complete; O1 source/API audit and offline overlap reproduction complete, gesture decision pending; O2 a small meme batch; O3 read-only transformation/Tainted-item audit. Engine units E2-E5 are **waiting for owner**. E1 installation is already complete. The owner's `gpt-next-session-2026-10-25.md` sets this order and supersedes the old engine-first queue.
- **Stop speculative billing work:** no further child-laser, Parent-ancestry or derived-shot billing PR until E2 provides a native observation. The exploratory Bethany charge audit is parked, with no source fix or engine claim.

## O1: DROP can also select a pocket item (2026-10-26)

The real Rice/Meal/DROP modules permit native input and spend a bowl after the same short gesture; the offline fixture supplies the pocket rotation and is not engine evidence.
[The review](DROP_POCKET_REVIEW.md) recommends MAP + short DROP with a scoped swap guard; keeping plain DROP only when no pocket can cycle is the alternative. Owner choice is required before changing controls.
Production code and installed `e1ff4d1` are unchanged. The draft adds characterization coverage; physical keyboard/controller E4 remains pending.

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
| Items | 79 collectibles: 25 originals, four meme batch 1 items and all 50 requested backlog rows. Also 12 trinkets, four pills, meme extras and Relay Slime. | [Generated item reference](ITEMS.md), [backlog](EXPANSION_DESIGN.md) |
| Shared mechanics | Native-weapon resource observers, DeepSeek Thought adapters, DROP tap recognition, meal countdown, scoped helper shots, tear tint, feedback and co-op HUD bands. | [Native Thought](NATIVE_THOUGHT.md), `scripts/characters/` |
| Risk and saves | Risk covers Claude forms only; DeepSeek has no proxy/IP/risk mechanics. Versioned per-player state and floor checkpoints are implemented. | `scripts/risk.lua`, [save cases](TESTING.md) |
| Appearance | All 22 skins, menus, stage portraits and MAP dossiers are wired. Fixed-look service clears item costume layers on mod forms while retaining item mechanics; vanilla forms remain native. | [Costume contract](COSTUME_COMPATIBILITY.md) |
| Story | Appeal Queue plus three-chapter English arcs for the other ten families. | [Story](STORY.md), `scripts/story_roster.lua` |

Compatibility fixes through #91 are merged in source, including fire-rate scaling, ghost guards, safe door handling, co-op HUD spacing, floor saves, Claude-only Risk, battery charge accounting, familiar attribution, per-player Constitution, helper billing and the Ludovico exemption. Use the individual cases in TESTING.md instead of treating this list as native acceptance.

## Unfinished tasks

1. **O1: DROP tap and native pocket cycling.** Audit/reproduction are complete in [DROP_POCKET_REVIEW.md](DROP_POCKET_REVIEW.md); choose the ability gesture with the owner before implementing or merging a control change. Preserve native cycling and long-hold dropping. E4 must later test physical keyboard/controller input with a card and pocket active.
2. **O2: meme batch 2.** After D1/O1, select two or three of Let's Delve (native shovel active), Feel the AGI / AGI achieved internally, and Six Seven pill. Keep one small PR; no new enemies/bosses. Open balance or design decisions still need the owner.
3. **O3: vanilla compatibility audit.** Read-only first: transformations, Bag of Crafting, Tainted Eden rerolls and Tainted Lost Holy Cards on mod forms. Add a short table to TESTING.md with code path, expected risk and native case; fix only clear source bugs, one PR each.
4. **New-item checklist.** Register module/constants/XML with ASCII pickup text; wire main in the right callback order; add EID, deterministic placeholder icon and pool entry; update `tests/eid_test.lua` counts, regenerate `docs/ITEMS.md`, update all three READMEs and relevant design records. Native systems first; new extras do not count again toward the completed fifty.
5. **Art and story.** Nine tainted sets currently derive deeper colors from normal art. Distinct hand-designed replacements and Chinese/Japanese story text remain owner decisions. Improve anatomy, side profiles and special poses from observed failures. Workshop is not authorized.

## Waiting for owner: engine acceptance

| Unit | Required observation | Status |
|---|---|---|
| E1 | Install `e1ff4d1` or newer only when requested, after the allowlisted backup and reread-hash check. | Complete for `e1ff4d1`; preserve it. |
| E2 | One ancestry probe: Parent, SpawnerEntity and FrameCount at init/update for Tech X splits, Prism reflections, Trisagion and Brimstone/Tech combinations. | Waiting for owner; prerequisite to more child-billing work. |
| E3 | Real menu fresh starts and first room for every normal/tainted form: stats, pockets, HUD, fixed look, dossier, story and errors. | Waiting for owner; type-change smoke does not satisfy this. |
| E4 | Physical keyboard/controller DROP taps and holds, card/pill plus pocket active, pause, disabled controls, room changes, death and reassignment. | Waiting for owner; O1 stubs cannot accept native input. |
| E5 | COSTUME-LOCK-01 and VANILLA-COMPAT-01, then the remaining animation, combat, weapons, saves, co-op, item and base-game matrix. | Waiting for owner. |

For an authorized run: follow the owner's E:/ba backup workflow before replacement; preserve other mods and saves; File 1's current run is disposable. Mute agent-run tests, close the game and restore settings afterward, recording only actions actually verified. Record exact game version, installed commit, case and evidence level. Repeat relevant cases in base Repentance and Repentance+ before claiming both supported. Never run historical `runtime_probe.lua` fixtures without reviewing their destructive/disposable-run assumptions.

## Known risks

- **Appearance:** the oversized hurt head has a source packing correction (28x32 envelope), not full visual acceptance. Side bodies use narrowed fronts; anatomy, symmetry, hurt recovery, death, carrying, flight, revival and transition poses remain to inspect, with and without Reactions Port Pack.
- **Fixed look:** ClearCostumes may hide wings, Holy Mantle or other effect layers, or allow a one-frame pickup flash. Leaving a mod form restores held collectible costumes only; transformation layers are not rebuilt. Preserve size, flight, weapons and transformation mechanics.
- **Input:** DROP is observed rather than consumed, so one tap may both use an ability and cycle a pocket slot. Meal hooks block directional shooting, not every charged/programmatic/familiar attack.
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
