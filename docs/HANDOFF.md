# Claude handoff: current development checkpoint

## Start here

Updated 2026-10-27. Read [CLAUDE.md](../CLAUDE.md), [CONTRIBUTING.md](../CONTRIBUTING.md), [TESTING.md](TESTING.md) and [art terms](../resources/ART_LICENSE.md) before editing. This file is the current summary. Dated entries for #104-#130 are preserved verbatim in [HANDOFF_HISTORY_2026-10-27.md](HANDOFF_HISTORY_2026-10-27.md); older evidence is in the [2026-10-25](HANDOFF_HISTORY_2026-10-25.md) and [2026-10-24](HANDOFF_HISTORY_2026-10-24.md) histories. Histories keep their original evidence scope and are not current acceptance.

- **Current main:** [live main](https://github.com/WaterLily5297/claude-chan-isaac/tree/main). Fetch it and inspect open PRs before editing. Draft PR #100 is a superseded numerical difficulty proposal and must never merge.
- **Installed manual-test build:** exact source `8fd6a8c8a543226f414a01c654ff1f85bde1214c` (gameplay checkpoint `ef7d2dd`, PR #102 plus O4/O5), installed 2026-10-26 after a fresh allowlisted backup of 443 files passed reread SHA-256 verification; all 451 tracked files were reverified. Source is now more than 25 PRs ahead of it. Preserve this installation during source follow-ups; replacing it needs separate owner authorization.
- **Owner testing:** the owner replied "not tested yet" on 2026-10-26. No manual case is accepted. Keep the [14-item manual checklist](MANUAL_TEST_CHECKLIST.md) available without repeating the question in the same session.
- **Evidence level:** the offline gate passes (73 Lua suites, 11 interaction-scanner cases, 13 item-art groups, six thumbnail groups, five XML files, deterministic assets, generated-reference and inventory freshness). CI runs the same `bash tools/check.sh`. Stubs do not prove native callbacks, animation, input, real Continue or playability. The only engine evidence is historical (PR #49 console smoke, one startup on f8b2b0b with no gameplay): [ENGINE_AUDIT_2026-10-26.md](ENGINE_AUDIT_2026-10-26.md).
- **Desktop gate:** before each engine block, obtain a fresh owner confirmation of being away from the keyboard for a stated duration. On user-input, missing-monitor or obscured-window errors, stop immediately; do not retry or send keys. Close only the process launched for that block and restore settings. One attempt per go-ahead.
- **Owner long-term plan (2026-10-27):** phases 0-5 (stabilize and test, playable alpha, character art, completion and compatibility, approved new content, publishing prep) with pending owner decisions. The plan lives in the project's shared files, not in this repository; the queue below follows it.

## Current queue

Pick the top unit that is not gated. A bug the owner reports beats everything.

1. **Owner-visible correctness first.** Remaining [ITEM_COMPLETION.md](ITEM_COMPLETION.md) findings F1, F6, F7, F10, F14, F15 and Disgrace Loop; F12 waits for native completion/removal evidence. Same Model Badge re-entry (F5 remainder) and F3 target gaps are rule decisions.
2. **Art.** 32 placeholder icons remain ([ART_STATUS.md](ART_STATUS.md)). Character work: proper side profiles for the nine newer families, GLM's fallen pose, special poses, Relay Slime and `thumb.png`. Distinct designs for the nine derived tainted families need an owner preview first.
3. **Characters.** [CHARACTER_COMPLETION.md](CHARACTER_COMPLETION.md) keeps all 22 rows open on shared gaps G1-G7 and special cases S1-S4; refusal-cue readability (W2.4) is still unaudited.
4. **Compatibility and stability.** Interaction candidates in [INTERACTIONS.md](INTERACTIONS.md), the wider vanilla matrix (special characters, Greed, challenges), seeded mod-item combination invariants, O6 save/continue audit and a whole-mod performance budget ([PERFORMANCE.md](PERFORMANCE.md)).
5. **Gated content.** Meme batch 3 (O7), character synergies (W5), Chinese/Japanese roster story text and Workshop all need explicit owner decisions.

No further child-laser/Parent/derived-shot billing PR without native E2 evidence. Repeat a scheduled hardening review after three to five substantive units or a concrete failure.

## Recent units (#104-#130)

All are offline source/tooling/documentation work; none is installed or engine-accepted. Full entries: [history](HANDOFF_HISTORY_2026-10-27.md).

| Area | PRs | Result |
|---|---|---|
| Audits | #105, #106, #108, #110 | [ART_STATUS.md](ART_STATUS.md), [INTERACTIONS.md](INTERACTIONS.md) scanner, [CHARACTER_COMPLETION.md](CHARACTER_COMPLETION.md) (22 forms, G1-G7/S1-S4), [ITEM_COMPLETION.md](ITEM_COMPLETION.md) (97 registrations, F1-F15). |
| Item art | #111, #112, #115, #118, #122, #126, #129 | Designed-icon pipeline and validator ([make_item_art.py](../tools/make_item_art.py)); 60 of 92 icons designed with 1x/4x light/dark review sheets ([batches 01-06](ITEM_ART_BATCH_01.md)). |
| Item fixes | #113, #116, #121, #124, #128, #130 | F8 Thinking Cleared refresh, F13 Cache Cartridge expiry, F11 I Panicked pickup protection, F2 Ignore Instructions distinct repeat target, F9 [charm after shields](CHARM_DAMAGE_ORDER.md), F4/F5 Subagent Swarm and Sanity Test text, F15 Rice Cooker reward saved across Continue (#132). |
| Characters | #107, #109, #123 | Normal Claude live-owner isolation (preserves same-entity form-return debt), T1/T2 text corrections, [pending Birthright timing](BIRTHRIGHT_TIMING.md) for four tainted forms. |
| Evidence only | #119, #127 | F12 [charged-use replacement](CHARGED_USE_AUDIT.md) reproduced, not fixed; [primary-tear composition](PRIMARY_TEAR_COMPOSITION.md) matrix, no defect found. |
| Stability | #114, #117, #120, #125 | Usage/Limited load validation, GPT/Grok binding allocation ([PERFORMANCE.md](PERFORMANCE.md)), thumbnail exporter repair, scheduled [hardening](HARDENING_2026-10-27.md). |
| Install record | #104 | Documentation sync installed as `8fd6a8c`. |
| Documentation | #131, #133 | Handoff compacted (D2 in TESTING.md); [PUBLISHING.md](PUBLISHING.md) refreshed with current counts, an owner go-ahead item and an explicit "not authorized yet" note. |

## Long-term completion gates

| Area | Current evidence and remaining work |
|---|---|
| Art | 60 designed and 32 placeholder icons. Side profiles, GLM fallen pose, nine distinct tainted identities, Relay Slime, thumbnail and native visuals remain open. |
| Characters | All 22 forms have a loop, B1 tradeoff and Birthright in source; every completion row is open pending G1-G7/S1-S4 and real fresh starts/combat floors. |
| Items | 80 collectibles, 12 trinkets and five pills registered. Five findings fixed in source; the rest and mechanism-by-mechanism native acceptance remain open. |
| Compatibility | Source scanner and focused fixtures exist; candidate semantics, combinations and the native matrix remain open. |
| Optional synergies | Proposal and rule approval required before implementation. |
| Stability | Save/performance/integration hardening and one full run to Mom per family group remain open; green CI is not playability acceptance. |

## Implemented source

| Area | Current implementation | Reference |
|---|---|---|
| Characters | 11 families, 22 normal/tainted forms: Claude, DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi and GLM. Each has its own meme loop, one owner-approved B1 tradeoff, Birthright behavior, starting-pickup contract, EID and dossier. | [Actual behavior](MODEL_ROSTER.md), [design targets](CHARACTER_GAMEPLAY.md), [B1 tradeoffs](DIFFICULTY_FEATURES.md) |
| Items | 80 collectibles (25 originals, meme batches 1-2 and all 50 requested backlog rows), 12 trinkets, five pills, meme extras and the Relay Slime enemy. | [Generated reference](ITEMS.md), [backlog](EXPANSION_DESIGN.md), [batch 2](MEME_BATCH_2.md) |
| Shared mechanics | Native-weapon resource observers, DeepSeek Thought adapters, DROP tap recognition (disabled with multiple pocket items), meal countdown, scoped helper shots, tear tint, feedback and co-op HUD bands. | [Native Thought](NATIVE_THOUGHT.md), [DROP review](DROP_POCKET_REVIEW.md), `scripts/characters/` |
| Risk and saves | Risk covers Claude forms only; DeepSeek has no proxy/IP/risk mechanics. Versioned per-player state and floor checkpoints. | `scripts/risk.lua`, [save cases](TESTING.md) |
| Appearance | All 22 skins, menus, stage portraits and MAP dossiers are wired. The fixed-look service clears item costume layers on mod forms while keeping item mechanics; O4 restores native transformation costumes after leaving a mod form. O5 corrected Death cell packing. | [Costume contract](COSTUME_COMPATIBILITY.md), [pose review](POSE_REVIEW.md) |
| Story | Appeal Queue (en/zh/ja) plus three-chapter English arcs for the other ten families. | [Story](STORY.md), `scripts/story_roster.lua` |

Compatibility fixes through #91 (fire-rate scaling, ghost guards, safe doors, co-op HUD, floor saves, Claude-only Risk, battery charge, familiar attribution, per-player Constitution, helper billing, Ludovico exemption) are merged in source. Use the individual cases in TESTING.md rather than treating this list as native acceptance.

## Decided rules and open owner decisions

Already decided; do not reopen: tainted DeepSeek non-tear weapons pay Compute for the 1.3x off-peak boost; normal GLM's forced Book of Secrets stays removed; fixed mod looks (costumes cleared, effects kept); short DROP stays and abilities are disabled with multiple pocket items; the #102 tradeoffs; Let's Delve and Six Seven rules.

Still the owner's call: distinct tainted designs (preview first), meme batch 3 and synergy rules, the broad Continue target versus explicit transient attempts ([CHARACTER_COMPLETION.md](CHARACTER_COMPLETION.md) follow-up 2), F3 target gaps, an effect-layer allowlist for the fixed look, difficulty feel after play, Chinese/Japanese roster story text, replacing the installed build, and Workshop publication (not authorized).

## Waiting for owner availability: engine acceptance

| Unit | Required observation | Status |
|---|---|---|
| E1 | Preserve the current installation; a later requested replacement needs a fresh allowlisted backup and reread-hash check. | Complete for `8fd6a8c`; preserve it. |
| E2 | One ancestry probe: Parent, SpawnerEntity and FrameCount at init/update for Tech X splits, Prism reflections, Trisagion and Brimstone/Tech combinations. | [Observer](ENGINE_ANCESTRY_PROBE.md) ready; attempted session produced no samples. Prerequisite to more child-billing work. |
| E3 | Real menu fresh starts and first room for every normal/tainted form: stats, pockets, HUD, fixed look, dossier, story and errors. | Waiting; type-change smoke does not satisfy this. |
| E4 | Physical keyboard/controller DROP taps and holds, card/pill plus pocket active, pause, disabled controls, room changes, death and reassignment. | Waiting; stubs cannot accept native input. |
| E5 | COSTUME-LOCK-01 and VANILLA-COMPAT-01, O3/O4 cases, MEME-BATCH-02, the B1 native matrix, then the remaining animation, combat, weapon, save, co-op and item matrix. | Waiting. |
| E6 | One full run to Mom per family group without mod errors ([GOALS.md](GOALS.md) first-playable milestone). | Not started. |

For an authorized run: follow the owner's E:/ba backup workflow before replacement; preserve other mods and saves; File 1's current run is disposable. Mute agent-run tests, close the game and restore settings afterward, recording only actions actually verified. Record exact game version, installed commit, case and evidence level. Repeat relevant cases in base Repentance and Repentance+ before claiming both supported. Never run historical `runtime_probe.lua` fixtures without reviewing their destructive/disposable-run assumptions.

## Known risks

- **Appearance:** Hit uses its 28x32 envelope and O5 corrected three oversized Death cells; this is offline geometry, not visual acceptance. The nine newer side bodies are narrowed fronts; GLM's fallen pose reads seated. Anatomy, motion, special poses, flight and revival remain to inspect with/without Reactions Port Pack.
- **Fixed look:** ClearCostumes may hide wings, Holy Mantle or other effect layers, or allow a one-frame pickup flash. Temporary/trinket/external layers and native reconstruction order remain open. Preserve size, flight, weapons and transformation mechanics.
- **Input:** abilities are disabled when the observer sees multiple pocket items; native timing and inventory changes between samples remain E4 cases. Meal hooks block directional shooting, not every charged/programmatic/familiar attack.
- **Native attacks:** Incubus/Twisted Pair timing, melee hitbox lifetime, knife flight, Epic Fetus attribution, Ludovico steering, multi-shot allowance limits and Peak's 1.3x non-tear boost require engine cases. Modeled Parent ordering is not observed engine evidence.
- **Composition and saves:** CollisionDamage writer order with other mods, native save/exit order, exit during knife flight, Seahorse wisps, player-type changes and co-op reassignment remain open. F12 can falsely observe a refused charged use after inventory replacement.
- **New mechanics:** #102 migrations and conditional rewards pass supplied offline callbacks only; actual FireDelay and kill ordering remain unobserved. See DIFFICULTY_FEATURES.md and the B1 native matrix.
- **Environment:** historical Stackable Items v2 load errors belong to that mod and must not be claimed fixed here.

## Direction and contributor workflow

Build recognizable community-meme choices: Claude bans/appeals, DeepSeek rice and Peak/Valley, GPT downgrade/Tibo resets. [Meme research](COMMUNITY_MEME_RESEARCH.md) distinguishes viewed sources, indexed titles, secondary claims and blocked pages. Fictional mechanisms are parody, not factual accusations. No real-person/nationality enemies, Grok July 2025 offensive references or official logos.

Use native systems and preserve their effects. Never restore DeepSeek proxy/IP/risk. Keep new code, comments, Markdown and UI English. Character design/art is not MIT: preserve ZipZipPipe and DeepSeek credits and the applicable non-commercial/share-alike terms; no extracted vanilla or unlicensed mod assets.

Fetch main, preserve all drafts and use one focused main-based branch/PR without stacks or history rewrites. Run `bash tools/check.sh`, update this handoff and the matching evidence, verify remote equality and CI. Own compatible fixes may merge after checks with no blocking bug or open design/balance decision. Preserve the installed manual-test build; no Workshop release or private data upload. Keep private paths, backups, saves, logs and source reference collections outside public commits.

New-item checklist: register module/constants/XML with ASCII pickup text; wire main in the right callback order; add EID, icon and pool entry; update `tests/eid_test.lua` counts; regenerate `docs/ITEMS.md` (`lua5.4 tools/item_reference.lua .`) and the interaction inventory (`python3 tools/audit_interactions.py --write`); update all three READMEs and the relevant design records.

**Keeping this file short:** stay under about 15 KB. Add each unit as one row in "Recent units" (or one line in an existing row) and put detailed evidence in TESTING.md or a dated audit. When the table outgrows about 30 PRs, move it verbatim to a new dated history file and start a fresh table.

Core files: `main.lua`, `scripts/constants.lua`, `content/*.xml`, `scripts/risk.lua`, `scripts/characters/`, `scripts/items/backlog/`. Tests are offline stubs; generated assets and item references are checked by `tools/check.sh`.
