# Claude handoff: current development checkpoint

## Start here

Updated 2026-10-26. Read [CLAUDE.md](../CLAUDE.md), [CONTRIBUTING.md](../CONTRIBUTING.md), [TESTING.md](TESTING.md) and [art terms](../resources/ART_LICENSE.md) before editing. This section is current; dated histories retain their original evidence scope.

- **Current main:** [live main](https://github.com/WaterLily5297/claude-chan-isaac/tree/main); B1 baseline `ef7d2dd` is owner-approved [PR #102](https://github.com/WaterLily5297/claude-chan-isaac/pull/102), including earlier O4 #101 and O5 #103. Later source adds art/interaction audits and a normal-Claude live-owner isolation correction, described below. PR #100 remains superseded and must not merge. Fetch main and inspect open PRs before editing.
- **Reviewed gameplay source:** installed `ef7d2dd` gameplay implements all 22 B1 conditions, O4 departure restoration and O5 pose packing. The later normal-Claude owner-isolation fix is source-only and not installed; it preserves same-entity form-return debt and Continue. Offline regressions do not establish native replacement/revival timing. Keep older engine evidence tied to its observed build.
- **Installed manual-test build:** gameplay checkpoint `ef7d2dded1f5d849c8a638a310074278a90e81c2`, installed on 2026-10-26. A fresh allowlisted backup preserved 443 old files and passed reread SHA-256 verification before replacement. All 451 installed tracked files matched canonical Git bytes. No paths were deleted. Documentation sync #104 then installed exact source `8fd6a8c8a543226f414a01c654ff1f85bde1214c`; all 451 tracked files were independently reverified. Preserve that installed version during source follow-ups.
- **Owner availability:** the owner approved merging #102 and downloading/installing it locally. Installation completed with the game closed; no game launch/input, settings changes or save access occurred. Agent-run engine testing still needs a fresh stated availability window. The owner replied "not tested yet" for installed `8fd6a8c` on 2026-10-26; no manual case is accepted. Keep the [14-item manual checklist](MANUAL_TEST_CHECKLIST.md) available without repeating the question this session.
- **Evidence:** #102 and merged main passed CI; the source gate passes 69 offline suites. The new installation has no gameplay observation. Historical f8b2b0b launched as Repentance+ v1.9.7.17.J460 but produced no gameplay keys, fresh starts or ancestry samples: [dated record](ENGINE_AUDIT_2026-10-26.md). Neither startup nor installation is engine acceptance.
- **Offline gate:** 69 Lua suites, 11 Python scanner cases, 13 Python item-art regression groups, 184 tracked Lua files, five XML files, deterministic assets and interaction-inventory freshness. CI runs the same gate. Passing stubs do not prove native callbacks, animation, controller input, real continuation or playability.
- **Current queue:** [CHARACTER_COMPLETION.md](CHARACTER_COMPLETION.md) maps all 22 open forms; [ITEM_COMPLETION.md](ITEM_COMPLETION.md) maps all 97 registered items and three unregistered systems. The [first ten designed icons](ITEM_ART_BATCH_01.md) have offline review; 82 placeholders remain in [ART_STATUS.md](ART_STATUS.md). **Next three units:** focused W3 compatibility regressions, W6 save/normalization or measured performance work, then the next icon batch. Interleave W2/W4 weapon/save/identity gaps, mechanical art and periodic hardening. O7/new synergies or additional persistence rules need explicit decisions. No further child-laser/Parent/derived-shot billing PR without native E2 evidence.
- **Desktop gate:** before each engine block, obtain a fresh owner confirmation of being away from the keyboard for a stated duration. On user-input, missing-monitor or obscured-window errors, stop immediately; do not retry or send keys. Close only the process launched for that block and restore settings. One attempt per go-ahead; the installed manual-test checkpoint must not be replaced again without owner authorization.

## W1.3 first designed icon batch (2026-10-26; offline art)

[Batch 01](ITEM_ART_BATCH_01.md) redraws ten existing collectibles with original object geometry/material ramps and supplies reproducible before-after sheets at 1x/4x on light/dark fields. The registry records ten designed and 82 placeholder icons.
Exactly ten existing PNGs change; 163 other PNGs are byte-identical and 25 animations retain canonical content. Two review sheets bring the art inventory to 200 files. Character identities, gameplay, registration and pools are unchanged.
The full gate, deterministic pixels and review-sheet freshness pass. Offline visual review covers silhouettes, lighting, colour separation and unintended text; native pedestal/EID presentation remains open.
Installed 8fd6a8c remains untouched and owner-untried. Next: focused W3 compatibility and W6 work, then more icon batches; no Workshop or automatic deployment.

## W1.2 item-art pipeline (2026-10-26; source tooling only)

[make_item_art.py](../tools/make_item_art.py) and the [manifest](item-art-manifest.json) explicitly distinguish placeholder/designed icons and enforce registration, provenance, palette/alpha, deterministic pixels and pools. All 92 shipped PNGs retain their old bytes and placeholder status.
Thirteen regression groups cover mixed status, malformed candidates, read-only/export behavior and legacy overwrite protection. An original test shape passes the new gate but fails the old equality gate; four isolated validation faults are rejected.
check_assets.py dispatches by status while preserving character/menu/pose checks. The old generator cannot overwrite registered designed icons in the canonical directory; temporary legacy exports remain available for review.
The full gate passes. Installed 8fd6a8c remains untested and untouched; the first real designed batch, native visuals and all broader acceptance work remain open.

## W3.1 all-item completion audit (2026-10-26; documentation only)

[ITEM_COMPLETION.md](ITEM_COMPLETION.md) maps 80 collectibles, 12 trinkets and five pills to XML/pools, source state, existing fixtures and remaining gaps; Agentic, Hydra and Relay Slime are separate. Every row remains open.
Fifteen follow-up findings distinguish source/text mismatches from unreproduced owner, charge, damage-order and Continue risks. No gameplay rule, schema or numeric value changes in this unit.
The audit corrects stale expansion rollout prose and reconciles 80 pool entries over 79 collectibles. The full offline gate and registration/link validation pass; neither proves native completion.
Installed 8fd6a8c remains untested and untouched. Next: designed-icon pipeline/batch, focused W3 regressions, then W6 save/performance work; preserve all engine and approval gates.

## Resource-text hardening (2026-10-26; source text only)

Normal Llama's dossier now distinguishes solo four blue flies from co-op two per ally; DeepSeek's EID says idle time does not refill pocket charge, without contradicting Thought charging.
T1/T2 in CHARACTER_COMPLETION.md are corrected in source. Gameplay, Birthright values, state and assets are unchanged; the full gate and regenerated interaction report pass.
Review of recent units retained #107's Continue/type-return controls, checked scanner limits and identified legacy Usage/Limited normalization and per-frame allocation as W6 follow-ups, not completed audits.
Installed `8fd6a8c` remains untouched and untested. Next: item completion inventory, designed-icon pipeline/batches, then focused save/performance work.

## W2.1 all-form completion audit (2026-10-26; documentation only)

[CHARACTER_COMPLETION.md](CHARACTER_COMPLETION.md) maps all 22 XML forms to source loops/B1, Birthright fixtures, actual save boundaries and concrete/common gaps. All 22 remain open; no native acceptance is added.
The audit records the Llama solo-four dossier omission, ambiguous DeepSeek idle pocket-charge wording and broad Continue targets versus transient source effects. Fix text separately; resolve rule changes before implementing them.
Obsolete initial-rollout and DeepSeek installed-version statements are corrected. The full offline gate and 22-row/link reconciliation validate this documentation unit, not engine behavior.
Installed `8fd6a8c` remains untested and untouched. Next: hardening/readability, W3.1 item audit, then icon pipeline/art batches.

## Normal Claude live-owner isolation (2026-10-26; offline fix, not installed)

A failing real-module probe showed a replacement entity in the same slot inheriting another Claude's age and debt. Transient pointer/InitSeed bindings now retire that account, clear aliases/volley guards and refresh affected caches; observed removed slots are pruned.
Continue resets only the transient bindings and retains saved accounts for recreated entities. The existing same-pointer/seed form-return debt rule is preserved; no state schema or B1 numerical rule changes.
Regressions cover distinct pointers, reused pointers/new seeds, same-frame shots, partners, aliases, retirement/Continue and slot reordering. One old Review assertion deliberately changes from inherited age 8 to fresh age 0; its eight-award cap control remains unchanged.
Installed `8fd6a8c` remains untested and untouched. Native co-op membership, revival and character-changing items remain acceptance work; resume the unfinished W2.1 all-form audit next.

## Static interaction inventory (2026-10-26; source tooling only)

The initial #106 [interaction inventory](INTERACTIONS.md) covered 110 production files, 397 callback registrations, 109 candidate field writes, cache references and Risk state roots; it regenerates as source changes. Overlapping writers are review candidates, not proven bugs.
The scanner never executes Lua and preserves manual review text. Eleven regression cases cover lexical exclusions, write classifications, multiple assignments, state roots and report freshness; check.sh enforces them.
Tungsten Cube's indirect speed assignment is already computed from current speed. Damage/colour/order and state candidates remain for focused combination/save tests; no gameplay or priority changes are bundled.
Installed `8fd6a8c` remains untested and untouched. W2/W3 completion audits and actual art production are next; engine/child-billing gates remain unchanged.

## Art inventory and production guide (2026-10-26; documentation only)

[ART_STATUS.md](ART_STATUS.md) reconciles all 198 bundled art paths, 92 registered icons, 22 forms and five native-presentation pills; it records outstanding side profiles, GLM fallen poses, nine tainted identities and Relay Slime art.
[ART_SPEC.md](ART_SPEC.md) replaces stale counts/templates with current contracts and a deterministic designed-icon pipeline specification. Validator migration and actual redraws remain pending.
The source gate covers 69 offline suites; no new rendering or engine evidence is claimed. The owner has not tested installed `8fd6a8c`, which remains unchanged.
The obsolete thumbnail-generator API is queued for a separate repair. No identity/balance decision, runtime deployment or Workshop publication is included.

## Long-term completion gates

| Area | Current evidence and remaining work |
|---|---|
| Art | Producer/validator and first ten designed icons with offline 1x/4x review are available; 82 placeholders remain. Further batches, profiles, distinct tainted previews, Relay Slime and native visuals remain open. |
| Characters | [W2 table](CHARACTER_COMPLETION.md) maps all 22 open forms and approved B1 conditions; text, weapon/save/identity gaps and real starts/combat floors remain open. |
| Items | [W3 table](ITEM_COMPLETION.md) covers all 97 registrations plus three systems; source discrepancies, designed icons and mechanism-by-mechanism native acceptance remain open. |
| Compatibility | W4 source interaction map and scanner exist; candidate semantics, combinations and broader native matrix remain open. |
| Optional synergies | Proposal/rule approval required before implementation; no implied approval from existing character rules. |
| Stability | W6 save/performance/integration hardening and representative full runs remain open; green CI is not playability acceptance. |

## B1 merge and installation (2026-10-26; native acceptance pending)

The owner approved merging #102 and installing locally; it merged at ef7d2dd after successful PR-head CI, and merged-main CI passed.
A fresh allowlisted backup preserved and reread-hash verified all 443 old files before replacement; all 451 new tracked files matched canonical Git bytes. No paths were deleted.
The game remained closed. No launch, input, settings change, save access or native observation occurred; preserve this checkpoint for manual testing.
O4, O5 and all 22 B1 conditions are installed. O6/O7 and E2-E5 remain; #100 is superseded. Exact private deployment/backup receipts stay local.

## B1 revision: added character tradeoffs (2026-10-26; implemented and approved)

The owner requested extra character features instead of reducing existing coefficients. Superseded draft #100 remains unmerged.
[DIFFICULTY_FEATURES.md](DIFFICULTY_FEATURES.md) records all 22 implemented challenges, exact trigger/counterplay, original baseline values, migrations and native limits.
The first eight conditions landed in draft #102 at 1422d81; the remaining fourteen add kill-order reviews, silence, Rice cancellation, reservation, target-choice penalties, angles, installation/build locks, stored direction, cones, speaker focus, task interruption and missed tickets. English HUD/dossiers/EID and current rules are synchronized; [TESTING.md](TESTING.md) records offline coverage and the native matrix.
The owner subsequently approved merge and installation, recorded above. Implementation itself was offline; O6/O7 and engine E2-E5 remain open.

## O5: all-form pose review and Death packing (2026-10-26; offline)

[POSE_REVIEW.md](POSE_REVIEW.md) lists all 22 forms, measured defects, deterministic preview commands and the shared-animation limits.
Three Death cells still used a 58px fit alongside the corrected Hit cell; they now use their measured native envelopes/anchors. Llama's Death-start source crop also retains the previously clipped body.
The new geometry check fails on all 66 old Death cells and passes after correction; only those three storage cells changed on each skin, with no redraw or native asset import.
B1 and current installation status are maintained in Start here; #100 is superseded. O6/O7 and engine acceptance remain open.

## O4: effect layers and native-form restoration (2026-10-26)

[Source audit and engine cases](TESTING.md#o4-effect-layers-and-departure-restoration-2026-10-26-source-and-stubs-only) distinguish cleared costumes from native mechanics/effect entities.
The departure helper now restores acquired native transformation costumes once; the new regression fails on aef6de9 and passes with the fix. Fixed mod looks stay unchanged.
Wings, state-driven shield cues, Mega Mush and remaining departure layers still need engine observation; an allowlist is an owner visual-policy choice.
No installation or engine session occurred during O4. Its later deployment is recorded above; B1 numerical draft #100 remains superseded.

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
The owner approved the exact rules; PR #95 merged at 178269b. The 68-suite gate and CI pass. It is included in the current installed build; engine acceptance is pending.

## O1: reserve multi-pocket DROP for native cycling (2026-10-26)

The owner kept short DROP and chose to disable abilities with multiple pocket items. All 22 forms share the new guard; native input and long holds remain untouched.
The prior source fails the new pocket regression; current tests cover all slots, inventory changes during gestures, rearming and Rice/co-op behavior. [Review and limits](DROP_POCKET_REVIEW.md).
PR #94 passed source/CI checks and is included in the current installed build. Physical keyboard/controller E4 and UI readability remain pending.

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

1. **O1: DROP tap and native pocket cycling.** The owner selected the multi-pocket restriction; implementation and regression are in PR #94 and [DROP_POCKET_REVIEW.md](DROP_POCKET_REVIEW.md). Merged at ef42b13 and included in the current installed build; source/CI verification is complete. Preserve native cycling and long-hold dropping. E4 must later test physical keyboard/controller input with a card and pocket active.
2. **O2: meme batch 2.** Let's Delve and Six Seven are merged in #95 under the owner-approved rules. See [the design and native limits](MEME_BATCH_2.md). Both extras are included in the current installed build; engine cases remain pending. Feel the AGI remains deferred.
3. **O3: vanilla compatibility audit.** Source audit complete: see the O3 table in TESTING.md. No gameplay change was justified. E4/E5 must observe the listed transformation, bag controls, reroll and shield cases before further fixes.
4. **New-item checklist.** Register module/constants/XML with ASCII pickup text; wire main in the right callback order; add EID, deterministic placeholder icon and pool entry; update `tests/eid_test.lua` counts, regenerate `docs/ITEMS.md`, update all three READMEs and relevant design records. Native systems first; new extras do not count again toward the completed fifty.
5. **Art and story.** Nine tainted sets currently derive deeper colors from normal art. Distinct hand-designed replacements and Chinese/Japanese story text remain owner decisions. Improve anatomy, side profiles and special poses from observed failures. Workshop is not authorized.

## Waiting for owner availability: engine acceptance

| Unit | Required observation | Status |
|---|---|---|
| E1 | Preserve the current installation; a later requested replacement needs a fresh allowlisted backup and reread-hash check. | Complete for gameplay checkpoint `ef7d2dd`, 451 files verified; preserve it. |
| E2 | One ancestry probe: Parent, SpawnerEntity and FrameCount at init/update for Tech X splits, Prism reflections, Trisagion and Brimstone/Tech combinations. | Observer installed; attempted session produced no samples. Await owner availability; prerequisite to more child-billing work. |
| E3 | Real menu fresh starts and first room for every normal/tainted form: stats, pockets, HUD, fixed look, dossier, story and errors. | Waiting for owner; type-change smoke does not satisfy this. |
| E4 | Physical keyboard/controller DROP taps and holds, card/pill plus pocket active, pause, disabled controls, room changes, death and reassignment. | Waiting for owner; O1 stubs cannot accept native input. |
| E5 | COSTUME-LOCK-01 and VANILLA-COMPAT-01, then the remaining animation, combat, weapons, saves, co-op, item and base-game matrix. | Waiting for owner. |

For an authorized run: follow the owner's E:/ba backup workflow before replacement; preserve other mods and saves; File 1's current run is disposable. Mute agent-run tests, close the game and restore settings afterward, recording only actions actually verified. Record exact game version, installed commit, case and evidence level. Repeat relevant cases in base Repentance and Repentance+ before claiming both supported. Never run historical `runtime_probe.lua` fixtures without reviewing their destructive/disposable-run assumptions.

## Known risks

- **Appearance:** Hit uses its 28x32 envelope; O5 additionally corrects three oversized Death cells using separate native measurements. [Pose review](POSE_REVIEW.md) covers all 22 forms offline, not visual acceptance. The nine newer side bodies still use narrowed fronts; GLM's fallen pose reads seated. Anatomy, motion, recovery, shared special poses, flight and revival remain to inspect with/without Reactions Port Pack.
- **Fixed look:** ClearCostumes may hide wings, Holy Mantle or other effect layers, or allow a one-frame pickup flash. O4 restores held collectibles and acquired native transformation costumes once after leaving a mod form; temporary/trinket/external layers and native reconstruction order remain open. Preserve size, flight, weapons and transformation mechanics.
- **Input:** PR #94 disables abilities when the observer sees multiple pocket items; native timing and inventory changes between samples remain E4 cases. Meal hooks block directional shooting, not every charged/programmatic/familiar attack.
- **Native attacks:** Incubus/Twisted Pair timing, melee hitbox lifetime, knife flight, Epic Fetus attribution, Ludovico steering, multi-shot allowance limits and Peak's 1.3x non-tear boost require engine cases. Modeled Parent ordering is not observed engine evidence.
- **Composition and saves:** CollisionDamage writer order with other mods, native save/exit order, exit during knife flight, Seahorse wisps, player-type changes and co-op reassignment remain open. Agentic's inventory/cache latch updates on the next player-effect callback; consequences require native observation.
- **New mechanics:** #102's migrations and conditional rewards pass supplied offline callbacks only. Legacy unowned meal timers are not cancelled as Rice; actual FireDelay and kill ordering remain unobserved. GPT attack history lasts for the current check, without a hard per-room cap. See DIFFICULTY_FEATURES.md and the B1 native matrix before claiming native acceptance.
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
