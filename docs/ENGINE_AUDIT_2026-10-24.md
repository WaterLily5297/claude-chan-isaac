# Engine compatibility audit: 2026-10-24

## COMPOSE-01: pending PR source integration experiment

Offline-only experiment on an isolated export of main `2ec15efe8cf2ebf40192618fabc73225630aac09`. No Git ref, PR merge state or installed file changed. Inputs were applied in order #50, #51, #52, #53, #54 using three-way file composition against that shared base:

| PR | Examined head | Scope |
|---|---|---|
| #50 | `8d5ac3628c59dacc210a16469deeb360ec5f6653` | Familiar attribution and controlled GPT evidence |
| #51 | `c3a3efe395b4a3c3a8512e677c24637869071cd1` | Bounded hurt-frame evidence only |
| #52 | `42dc481c23410e291c08dc922cd9435f7919bc8c` | Claude frame/pause/death timer guards |
| #53 | `3f2e38213f09cb74a1dbb2a5ced5f949f0c3f6fb` | Item-helper resource billing |
| #54 | `382570d665a35bfb8a714c2a2485786b253a8bae` | Vibe damage eligibility |

All source/test edits applied without conflict. The combined tree passed 48 stub suites, 146 Lua files, five XML files and deterministic asset checks; unlike the development checkout's syntax traversal, these 146 Lua files contain no private probes. The Claude timer and helper changes coexist in both the implementation and its tests. The reporting-only follow-up on #54 does not alter these tested source files.

Markdown overlaps occurred in CHANGELOG.md, HANDOFF.md, TESTING.md and this audit. For that experiment, conflicted documents stayed at the last clean version; conflict outputs were reviewed separately. Therefore the result proves source/test composition, not a complete merged document tree. Preserve attribution's two bounded engine cases, ANIM-01's sixteen clean mod-form Hit6 observations and six pending cases, all three source-only fixes, and their engine retest checklists. Do not resolve by keeping just one side. Consolidate authorization statements under the latest offline-only instruction, and retain per-checkpoint counts rather than presenting 48 suites as main's current count.

No candidate was deployed, no game was launched, and no new engine acceptance occurred. Each PR still needs its own owner merge approval. Other application orders and any later source edits require fresh verification; the runtime remains main `2ec15ef`.

## VIBE-01 offline follow-up

The owner remains unavailable for game control and requests offline work. Installed runtime stays main `2ec15ef`; the game remains closed. There is no new engine observation.

Source reproduction: Vibe Coding records fake/no-penalty hits as mistakes, and its default-priority observer runs before the backlog's subsequently registered hit blockers. In the real-module fixture this incorrectly charges 10 of 40 coins on the next floor despite Sold Out or Red Stamp cancelling the hit. Filtering the two flags and moving the observer to late priority corrects those cases. Ordinary damage, co-op ownership, floor reset, late item acquisition and exit remain covered; the bill amount and saved format are unchanged. Old main and separate removals of the flag filter and late priority fail the regression. Full offline gate: 46 suites, five XML files and deterministic asset checks, with 144 tracked Lua files.

This candidate is directly based on main, independently of PRs #50-53. Engine callback order, actual health/coin observations, third-party later blockers and save/continue remain pending in TESTING.md. Earlier historical smoke and hurt-frame observations are not evidence for this change.

## Scope and versions

The owner resumed synchronization, local deployment and muted engine testing, then explicitly confirmed that local fixes may be tested before uploading to GitHub. Workshop publication remains unauthorized. New code, documentation and UI text remain English.

Claude's work was already merged through PR #48: main `3983c592c65b9c56e3acb330615ad9df30588c9a`. No open PR remained at the start of this audit. The clean working checkout was fast-forwarded from `b9a7871`; its previous commit was retained on an archive branch, and the separate `215df90` checkout and its two uncommitted drafts were untouched.

The actual existing mod folder was `claude-chan-isaac`, not the older `claude-chan-isaac-main` path. Its 206 tracked application files were copied to a fresh allowlisted backup under the owner's designated backup root and hash-verified before deployment. All 389 integration-base files were then verified byte-for-byte against Git blobs. No duplicate mod folder was created. No private saves, credentials, unrelated mods or backup contents are published here.

Game: **Repentance+ v1.9.7.17**, existing local mod environment, File 1 explicitly authorized as disposable. Music and SFX were temporarily set to zero. This was not a clean single-mod environment: EID, ReactionAPI/Reactions Port Pack, Loadout, character-menu and other installed mods remained present.

## Observed integration-base results

- All 22 names resolved to distinct valid normal/tainted IDs in the engine. The pairs were Claude 41/43, DeepSeek 42/44, then GPT through GLM 45/46 through 61/62. IDs are observations of this installation, not constants to hardcode.
- A fresh normal Gemini run reached the starting room. The normal selection menu, Gemini story caption, character HUD and EID display rendered.
- A temporary console-only callback exercised all 22 forms for 180 updates each. It changed the player type, added The Sad Onion, Transcendence and Magic Mushroom at update 30, submitted one damage event at 70, removed those items at 110, and logged completion at 179. All 22 completion markers appeared. No new Lua error from this mod appeared during that sequence.
- These are runtime smoke results, not 22 fresh-start tests, combat acceptance or visual approval. Damage callbacks can run without proving every hurt frame is correctly drawn. The sequence does not verify pocket-item initialization, unlocks, menu switching, enemy attribution, native attack damage, co-op or every persisted mechanic.
- Stackable Items v2 reported `resources/scripts/main.lua:154: table index is nil` while its own main file loaded. This pre-existing third-party load error appeared before our probes in both launches. Some other installed mods also reported XML version or shutdown animation-cache warnings. They were left unchanged; this environment cannot establish compatibility with a successfully initialized Stackable Items v2.

## Confirmed defect and fix

Normal Claude and both DeepSeek forms replaced the engine's tear color with a fixed identity color. In the integration-base engine test, Ipecac's native RGB `(0.500, 0.900, 0.400)` became the fixed Claude `(1.000, 0.550, 0.250)`, normal DeepSeek `(0.350, 0.650, 1.000)` or tainted DeepSeek `(0.450, 1.000, 0.950)` instead of composing with the item.

The fix adds `scripts/characters/tear_tint.lua` and composes the RGB/alpha multiplier with the existing color while preserving additive offsets. Normal Claude's Limited tear tint uses the same helper. It does not replace costumes, change tear flags or scale, modify damage accounting, or restore any DeepSeek risk mechanic. The mod description now describes the current family roster rather than implying every character uses proxy risk.

The exact gameplay candidate tested was local commit `2d546b37e536908c167fdf4ed454d8ece2e64e02`, containing the six code/test/metadata files. A second verified backup preserved the 389-file base before the 391-file candidate was installed. Later documentation-only commits and GitHub upload commits may have different hashes; final source/runtime equality is recorded externally.

After restarting the process, File 1 Continue successfully restored the disposable tainted DeepSeek run and its Compute HUD. This is one continue smoke case, not a complete state-persistence matrix.

The same Ipecac probe now produced:

| Form | RGB after composition |
|---|---|
| Vanilla Isaac control | 0.500, 0.900, 0.400 |
| Normal Claude | 0.500, 0.495, 0.100 |
| Normal DeepSeek | 0.175, 0.585, 0.400 |
| Tainted DeepSeek | 0.225, 0.900, 0.380 |

A further engine assertion compared each of those three mod forms with vanilla Isaac for **Ipecac, Spoon Bender and Number One**: all nine combinations passed the expected RGB multiplication and unchanged alpha/additive-offset checks. Each item was removed before testing the next. This validates the engine color cache for those cases, not every weapon renderer or every third-party color writer.

The offline gate passed **143 Lua files, five XML files, deterministic assets and 45 stub suites**. `native_tear_color_test.lua` covers composition, opacity, nonzero additive offsets, cache reset after item removal and unrelated players. Swarm's regression uses real-shaped color stubs and confirms children inherit the resolved parent color. These offline assertions are separate from the nine engine cases.

A temporary synthetic Gemini Hit-frame preview was attempted, but an overlapping pickup animation prevented a clear hurt-pose observation. It supplies **no visual acceptance**. All temporary probe callbacks existed only in the running process and were discarded on shutdown; none is automatically enabled in the shipped mod.

## Next compatibility work

1. Complete the full hurt/death/fall/revival animation and costume matrix for every form. Retain the standard base-animation geometry; inspect native costume priorities before splitting baked hair/clothing into layers. The oversized-head report is not closed by this audit.
2. Test native weapon damage against actual enemies, especially callback order and other damage writers. Normal Claude's Limited penalty still weakens tears only; knives/Epic Fetus billing and continuous-beam billing remain incomplete. Tainted DeepSeek's Compute/forks remain tear-only. Do not label these gaps fixed by the color change.
3. Test normal DeepSeek's Thought adapters with beams, rings, Ludovico, knives, Dr./Epic Fetus, melee, delayed bursts, Incubus/Twisted Pair, Swarm and 1M Context; check real damage, charge cancellation and save/continue.
4. Exercise all 22 fresh starts and their pocket items, both selection menus, DROP actions in real combat, room transitions, co-op isolation and process-restart saves. Test the 75 collectibles, 12 trinkets and four pills in focused interaction groups rather than inferring coverage from registration.
5. Reproduce third-party errors separately before changing integration behavior. Do not silently disable unrelated installed mods or publish local logs containing private data.

Continue with small fixes and regression tests before more expansion. Preserve the English-only and non-commercial art requirements, update this handoff with exact evidence, back up before runtime replacement, keep the game muted during tests and close it afterward. No Workshop release.
