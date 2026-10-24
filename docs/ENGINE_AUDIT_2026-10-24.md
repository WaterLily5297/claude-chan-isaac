# Engine compatibility audit: 2026-10-24

## RISK-01: proxy-account damage eligibility (offline only)

Source review after main `d91eee7` found Risk still recorded fake/no-penalty damage and ran before backlog shields. The regression loads real Risk, Constitution and all backlog modules in main order. Main raises risk from 50 to 51 for a fake event and for a Sold Out bullet that is later cancelled; a separate case also exposes damage bookkeeping after exit. The candidate ignores those events, preserves a clean-room reduction from 50 to 49, and retains ordinary damage at +1, the existing shared-account semantics, and DeepSeek/roster exclusions. Start/continue clears the transient room latch; nothing is added to saved data.

The full gate passes 49 suites, 147 tracked Lua files, five XML files and asset checks. Four isolated guard-removal mutants fail their intended behavioral assertions. The [damage callback documentation](https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html#mc_entity_take_dmg) describes a pre-damage observer and dispatch stopping at any non-nil result; the [damage flags](https://wofsauge.github.io/IsaacDocs/rep/enums/DamageFlag.html) define fake/no-penalty events. The fixture models these documented rules, not actual health loss or arbitrary third-party ordering.

No engine session, deployment, new art or balance change occurred. Installed source remains `2ec15ef`. Native shield dispatch, suspension threshold, co-op, later-priority cancellation and save/continue are still pending. The transient hit latch remains unsaved; this fix does not close mid-room persistence. This focused candidate requires its own merge approval; PR #50-54 approval is not reused.

## Current source integration

Source integration checkpoint (2026-10-24): this tree combines PRs #50-54 under the owner's explicit merge instruction. The latest owner constraint remains offline-only. Installed game files remain at main `2ec15ef`; no combined engine acceptance or Workshop release is claimed. Earlier candidate, approval and deployment statements below are historical checkpoint records.

COMPOSE-01 below remains the earlier isolated 48-suite experiment. Its unresolved-document statements describe that experiment; the authorized integration now reconciles all four documents. Final source checks must be tied to the actual integration commit. No new engine evidence was produced during merging.

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

## DERIVED-01 offline follow-up

The owner requested offline work while unavailable for game control. No game launch, runtime replacement or new engine acceptance occurred in this unit. The installed runtime remains main `2ec15ef`.

The real backlog/character integration fixture reproduces unintended resource consumption from item helper tears: normal Claude usage +4, tainted Claude Quota -1, normal DeepSeek full Thought consumed, tainted DeepSeek Compute -2. The helper marker was missing during synchronous FireTear callback dispatch. Marking before the character callbacks and exempting normal Claude from new billing corrects the source regression. Existing Limited damage reduction remains active. Following ordinary shots, both item schedules and resource isolation across four player slots are checked offline. Two older Claude fixtures now provide the native GetData method.

Focused game acceptance remains pending, including callback ordering with other mods, native damage, Swarm, Context and save/continue. This does not resolve the hurt-head report, fresh-menu coverage or the remaining weapon/costume matrix. See TESTING.md for reproducible steps.

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

### TIMER-01: normal Claude callback-clock hardening (offline only)

Source review of main `2ec15ef` found that normal Claude's `MC_POST_PEFFECT_UPDATE` advanced the Limited countdown and idle usage drain on every callback invocation, without per-frame, pause or death guards. A new regression invoking the real module twice through wrappers for the same player/frame failed because both invocations decremented the timer. The previous save test had used 149 invocations at one frame value to simulate 149 updates; it now advances the frame between updates. This establishes a source-level callback contract failure, not a reproduced ordinary-game timing defect.

The candidate keeps a transient pointer/seed/frame record for each player, ignores repeated updates at that frame, freezes paused/dead updates and forgets interrupted DROP gestures. Start/exit clears the record; observed type changes clear that player's guard. No entity references are serialized, no save schema changes, and all balance constants and existing slot-keyed usage ownership remain unchanged. This does not resolve the broader co-op slot-reassignment/account-age design risks.

The real-module regression covers exact Limited expiry, drain, separate players, wrappers, pause/death, revival and fresh/continued lifecycle resets. Removing each of four protections (frame, pause, death, lifecycle reset) independently fails a targeted assertion. Full-game timing, save serialization and physical controls remain unaccepted. Runtime installation remains main until a verified backup and focused engine retest of the candidate can be completed.

ANIM-02 attempted a fresh muted main launch for the six remaining clean Hit-frame observations, but repeated focus/input interruptions limited it to the title screen. No run or new visual case was accepted. The game was closed and music/SFX restored from that block's fresh snapshot. PR #51 contains the preceding bounded visual evidence; PR #50 remains the separate familiar-attribution candidate. These branches target main independently, with no merge authorization implied by CI.

### ANIM-01: actual damage, bounded Hit-frame observation

Tested main `2ec15efe8cf2ebf40192618fabc73225630aac09` on Repentance+ v1.9.7.17. A fresh allowlisted backup was verified before restoring main; all 392 installed tracked files matched its Git blobs. PR #50's familiar-attribution candidate was not installed for this unrelated sweep. EID, Reactions Port Pack and the existing other mods remained enabled. File 1 was disposable; music and SFX were muted, then restored from this block's fresh snapshot after closing the game.

A temporary, explicitly entered console fixture changed the existing player's type, added survival hearts and applied one real `TakeDamage(1, 0, EntityRef(player), 0)` event after 60 updates. It waited for the engine to select `Hit` and reach frame 6, then set only `Sprite.PlaybackSpeed` to zero for inspection. It did not call `Play("Hit")`, force a frame or replace a spritesheet. Playback was restored between cases and on bounded cleanup; callbacks were process-only. This was a type-change fixture, not a fresh menu start or ordinary enemy encounter.

All 22 mod forms and vanilla Isaac logged actual loss of one half-heart, `Hit` frame 6 and sprite scale `(1, 1)` with zero collectibles at arming. Those log assertions are separate from visual coverage:

| Family | Normal frame 6 visually inspected | Tainted frame 6 visually inspected |
|---|---|---|
| Claude | Yes | Yes |
| DeepSeek | Yes | Yes |
| GPT | Yes | Pending |
| Gemini | Pending | Yes |
| Grok | Pending | Pending |
| Qwen | Yes | Pending |
| Llama | Yes | Yes |
| Mistral | Yes | Yes |
| Doubao | Yes | Yes |
| Kimi | Yes | Yes |
| GLM | Yes | Repeat clean case |

Sixteen mod forms plus the Isaac control have inspected screenshots. No obvious oversized full-body replacement was visible in those bounded frame-6 cases. The initial fast sequence advanced before some screenshots could be taken; logging completion does not pass those visual cases. Extra movement and a Bursting Sack pickup overlapped the final tainted GLM observation, so its screenshot is excluded from the clean visual count. The fixture's labels identify cases but are not assertions that the frame is correct. Original screenshots, filtered markers and their hashes remain local; no private logs or extracted vanilla assets are published.

**The oversized hurt-head report remains open.** This does not accept the other Hit frames, recovery, death/fall/revival/jump/carry/flight, costume/size/transform interactions, Reactions-disabled behavior, anatomy or symmetry. Repeat the six pending clean frame-6 cases, then capture the complete sequence with the costume matrix. No artwork or runtime code changed in this observation unit.

FRESH-02 remained blocked at menu navigation: supported Up/W attempts did not select New Run. Continuing the disposable run enabled the animation fixture but supplies no additional fresh-menu or physical DROP acceptance. A pre-existing Stackable Items v2 load error remained outside this mod's scope. Both temporary sequence cleanup and successful game shutdown were observed.
### Acceptance baseline and offline familiar attribution follow-up

After PR #49, main `2ec15efe8cf2ebf40192618fabc73225630aac09` was re-fetched and verified against all 392 installed tracked files. No open PR remained at that baseline. A fresh allowlisted backup was hash-verified. The baseline offline gate passed 143 Lua files, five XML files and 45 stub suites.

A muted Repentance+ v1.9.7.17 test reached File 1's main menu. Return advanced title/file selection, but directional and alternate menu inputs did not move from Continue to New Run. An input-method composition was dismissed; no actual fresh character start followed. This is a blocked input case, not a character failure or acceptance. The game was closed normally and the freshly observed audio values restored.

Source review then reproduced a separate defect: `target_tools.Owner` followed a contact familiar's player spawner/parent and treated it as the player's own damage. The real GPT callback test showed a familiar-only kill incorrectly restoring Verified. Both that regression and a new shared-helper regression fail against 2ec15ef. The fix excludes familiar source entities before following owner links, retaining existing native attack and co-op attribution. The resulting full offline gate passes 144 Lua files, five XML files and 46 suites. No engine fix verification is claimed; real familiar contact/projectile cases, target damage bonuses and native positive controls remain pending in TESTING.md.

The [Entity API reference](https://wofsauge.github.io/IsaacDocs/rep/Entity.html) documents the separate entity type, spawner and parent relationships. These API definitions support the fixture shape; they do not prove which source a particular engine damage event supplies.

### Controlled GPT engine follow-up (PR #50)

Candidate `aae85fd1d84e23d19bcb12a1b6af8e774e8326e8`, tree `ff9ea91c724c731c2c1aa8d23f2025c43f28e81c`, was installed with all 393 tracked files matching Git bytes. Tests used Repentance+ v1.9.7.17 and the same existing mod environment, including the pre-existing Stackable Items v2 load error. Main remained `2ec15ef`; this is branch-candidate evidence, not merged-main acceptance.

A console restart of normal GPT rendered chapter 1 and `Verified Routing 0/3`; observed starting values were damage 4.0250, four red half-hearts, two soul half-hearts and no pocket active. Three actual room-clear callbacks followed by another hostile room changed damage to 2.800. Room changes, enemy freezing and clears were scripted; this is not menu selection or ordinary combat acceptance.

For the focused attribution case, a bounded process-only fixture prepared Fallback and a frozen Gaper, then temporarily supplied a short DROP press/release through `Input.IsActionPressed` for that controller. The original function was restored before damage testing. The visible HUD confirmed `Fallback Check 0/3`. The fixture set the target to one HP and spawned one blue fly at it with a player spawner. A real collision produced a damage event with source type 3 (familiar), amount 7.0, and killed the target. GPT stayed Fallback at 2.800 and showed `Check failed`. The probe did not invoke the mod's damage callbacks directly or mutate its persistent routing state.

An own native tear provided the positive control in a different room. After another synthetic selection, `FireTear` created a tear beside the frozen one-HP target. Its real collision reported source type 2 (tear), amount 2.800. The target died; GPT returned to Verified, Routing 0/3, damage 4.025. These two cases validate this candidate's normal GPT contact-familiar exclusion and own-tear kill path under the stated fixture. They do not validate all familiar variants, projectiles, bombs/lasers/knives, co-op, other target abilities, native keyboard/controller DROP, saves, costumes or animations.

Unsuccessful attempts are retained as limitations: direct helper loading from the console resolved the wrong mod context or unavailable loaders, so it supplied no helper-execution result; an earlier one-pass clear missed subsequent enemies, and its disposable player died after protection expired. Console `Revive` did not resume that death screen, so the process was closed. The first native-tear control in a room with rocks had no target-damage callback and left the target alive; an unobstructed placement produced the successful collision above. None of those failed fixtures is counted as a gameplay pass or an independently confirmed mod defect.

All probes were temporary and did not alter installed source. The game was closed after each block and the freshly observed music/SFX values restored. No new mod-source Lua error appeared in the filtered evidence. The full gate remains distinct offline evidence. PR #50 requires the owner's merge approval; continue unrelated acceptance work from main rather than stacking changes on it.

### Remaining priorities

1. Complete the full hurt/death/fall/revival animation and costume matrix for every form. Retain the standard base-animation geometry; inspect native costume priorities before splitting baked hair/clothing into layers. The oversized-head report is not closed by this audit.
2. Test native weapon damage against actual enemies, especially callback order and other damage writers. Normal Claude's Limited penalty still weakens tears only; knives/Epic Fetus billing and continuous-beam billing remain incomplete. Tainted DeepSeek's Compute/forks remain tear-only. Do not label these gaps fixed by the color change.
3. Test normal DeepSeek's Thought adapters with beams, rings, Ludovico, knives, Dr./Epic Fetus, melee, delayed bursts, Incubus/Twisted Pair, Swarm and 1M Context; check real damage, charge cancellation and save/continue.
4. Exercise all 22 fresh starts and their pocket items, both selection menus, DROP actions in real combat, room transitions, co-op isolation and process-restart saves. Test the 75 collectibles, 12 trinkets and four pills in focused interaction groups rather than inferring coverage from registration.
5. Reproduce third-party errors separately before changing integration behavior. Do not silently disable unrelated installed mods or publish local logs containing private data.

Continue with small fixes and regression tests before more expansion. Preserve the English-only and non-commercial art requirements, update this handoff with exact evidence, back up before runtime replacement, keep the game muted during tests and close it afterward. No Workshop release.
