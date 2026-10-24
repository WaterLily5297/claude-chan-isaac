# Claude handoff: consolidated development checkpoint

Prepared 2026-10-24 (Japan time). Start here. The owner requested an archive, a concrete handoff to Claude, local validation and a GitHub main merge. This is a development checkpoint, not a Workshop release or engine acceptance.

## Authority and evidence

- The latest testing restriction is **source work and offline validation only**. Do not launch/control the game or replace the installed mod until the owner resumes engine testing. The request to merge source does not establish a game-test pass.
- New code, comments, Markdown and player-facing text must be English. Conversation may be Chinese. Historical translated material remains archival, not a requirement to add new translations.
- Preserve collaborators' commits, the old dirty checkout and both uncommitted battle-test drafts. Never restore DeepSeek proxy/IP/risk mechanics.
- Keep changes reviewable; small branches/PRs are preferred. The owner explicitly authorized consolidating and merging this checkpoint to GitHub main. Passing CI is required; do not claim an independent human review.
- No Workshop publication, credential reuse from chat, private-save uploads or unrelated private data. Code is MIT; character art is not. Read resources/ART_LICENSE.md before modifying or importing art.

## Version map

| Layer | Checkpoint / interpretation |
|---|---|
| Previous main | PR #5, 1143ff11d16fe22adb7488689ffcc6e59eba35ab; v0.5 was not engine-accepted |
| Published source base | PR #17, e8639cb2bbcfaa6c7f5c234d93c48de9493a50cd; includes the earlier candidate stack |
| This handoff | Adds native Thought adapters and this consolidated archive above #17; see the containing merge commit and GitHub checks for final identity |
| Installed runtime | Last verified aa8bd46bcc08032c127e064e6ed6239a023bf189, 181 allowlisted files; intentionally older than this source checkpoint |
| Historical engine evidence | Limited v0.4 Repentance+ observations; the later 204861f observation reached the title screen only |

Never infer that an installed commit equals local HEAD. The local delivery includes an external verification record with exact final local/remote hashes and merge/check links; it is not embedded here to avoid self-referential commit hashes. Before resuming, fetch main and inspect the actual commit, tree, worktree status and any newer collaborator changes.

## Implemented source inventory

There are **13 registered forms: 11 normal and 2 tainted**, **21 collectibles**, **6 trinkets**, two pills, the existing Relay Slime enemy and the existing Appeal Queue story system. The requested expansion is **50 additional collectibles**, of which only **Summary Stapler (1/50)** is implemented. Existing collectibles do not count toward that additional fifty. Three meme extras outside the fifty (Ignore All Previous Instructions, Tungsten Cube, Pizza Glue) are implemented in source; see "Meme extras" in EXPANSION_DESIGN.md.

| Family | Existing behavior | Replacement status |
|---|---|---|
| Claude | Usage/limited damage, account age, risk/story, pocket Ban Hammer; tainted weekly quota and Banked Reset | Saved normal usage fixed; new Appeals/Review designs not implemented |
| DeepSeek | Normal Rice First meal economy and Thought; tainted Wenfeng / Wengu Peak/Valley Compute forks | Rice and Peak/Valley source implemented; Thought adapters partial; tainted forks are tear-only |
| GPT | DROP switches Deliberate/Instant damage and firing interval | Downgrade verification and Tibo reset designs not implemented |
| Gemini | DROP switches piercing Prism/homing Echo | Nano Banana/edit-chain replacement not implemented |
| Grok | Movement builds bounded damage momentum | Verification/ratio designs not implemented |
| Qwen | Flawless-room damage chain | Adapter/fine-tune designs not implemented |
| Llama | Every second distinct clear gives blue flies | Release/hype designs not implemented |
| Mistral | Movement plus firing builds tailwind | Pounce/baguette designs not implemented |
| Doubao | Every third distinct clear heals or grants flies | Apology/overpromise designs not implemented |
| Kimi | Flawless clears build pages; damage erases pages | Slides/task-delegation designs not implemented |
| GLM | Active-item uses build room tool links | Tool-call/retry designs not implemented |

The nine added families have **no tainted registration, artwork or implementation yet**. MODEL_ROSTER.md describes current mechanics; CHARACTER_GAMEPLAY.md describes the complete 22-form target. Do not implement a target on top of an old multiplier without removing/reconciling the old loop.

Other completed source changes:

- Reactions Port Pack fallback covers the registered forms and preserves explicit external support.
- Vibe Coding bills persist; Overloaded clears stale outage deadlines; Opus damage reads the actual wallet during cache evaluation.
- Swarm resolves after character effects, skips cancelled tears and copies native tear fields without recursive payment. DeepSeek forks use the same raw-copy helper.
- Transient roster state survives different Lua wrappers for the same player, with pointer/seed/type guards. Normal Claude usage survives continue.
- GPT/Gemini DROP modes switch on a short release, not press; long holds retain native dropping. Paused/interrupted gestures are cancelled.
- Summary Stapler absorbs a bounded set of ordinary hostile projectiles and emits one native retaliation tear, with charge and Car Battery guards.
- Shared meal state saves per-player countdowns, freezes on pause, preserves movement and prevents duplicate Lunch Break healing. It blocks directional shooting input, not every possible programmatic attack.
- Tainted DeepSeek (Wenfeng / Wengu) replaces legacy forks and random Server Busy deletion. Twelve combat seconds of Valley alternate with twelve of Peak; cleared rooms and pause freeze the timer, and each floor starts in Valley. Compute starts at 12 per run (cap 24, Birthright 32) and carries across floors. A paid tear volley costs 2 (Valley) or 4 (Peak) and forks every tear in it into two native 50% copies at ±12°; insufficient Compute or Saving mode keeps the primary tear without forks. Valley recovers 3 Compute per second only in an uncleared room while not firing, so empty rooms cannot be farmed. DROP tap toggles Forks On / Saving with a one-second transient cooldown. Compute, phase, remaining time and mode are saved per player in `Risk.state.deepseekPeak`. Lasers, knives and bombs neither fork nor pay; they need a bounded equivalent before compatibility acceptance.
- Normal DeepSeek starts with one bowl, cap two, earns one per two unique hostile clears, and spends a short DROP tap on a meal. Completion gives full Thought and temporary speed; the intrinsic bowl does not heal or refill pocket charge. Normal random shot cancellation and idle pocket recharge are removed. Tainted legacy behavior remains until explicitly migrated.
- Thought supports ordinary tears, single-hit/released-circle lasers, flying knives and Dr. Fetus bombs. Repeated beams and Ludovico use six-update windows. Swarm derivatives do not pay twice; 1M Context reads the unboosted continuous baseline; partial-window counts survive continue. See NATIVE_THOUGHT.md for exact limits.

## Art: completed work versus visual acceptance

Eleven normal portraits use the selected ZipZipPipe AI-personification identities. The approved tainted Claude/DeepSeek portraits retain their designs with deeper colors. All 13 gameplay skins, menu busts, stage portraits and clear-room MAP dossiers are wired. The original four also received a movement pass; they were not left as old recolors.

The reported oversized hurt head was addressed in source by packing the shared hurt/special-pose cell to the measured vanilla 28x32 envelope and anchor in all 13 atlases. Llama's source crop was corrected. The optional rebuild/pixel comparison passes; pixels outside the corrected cell remain unchanged. This **does not prove the reported in-game bug is fixed**. Anatomy/symmetry, side profiles, hurt recovery and special poses still require visual acceptance. Baked hair/clothing may conflict with native costume layers.

Art provenance and exact prompts/hashes are in the portrait/sprite/movement JSON records and resources/ART_LICENSE.md. Retain ZipZipPipe credit, DeepSeek's additional original-design credit and applicable non-commercial/share-alike terms. Some Bilibili pages were blocked (HTTP 412); catalog attribution is not fresh direct license verification. Do not copy unlicensed mod artwork or distribute extracted vanilla assets. Public mod references are implementation references, not asset permission.

## Validation completed

The current source passes `bash tools/check.sh`: **66 Lua files, 5 XML files, deterministic asset checks and 17 stub suites**. This checks registration, syntax, frame bounds, item pools and modeled callback behavior. The native Thought regression fails against the prior e8639cb Rice module at its first beam assertion and passes the new adapters. `tests/deepseek_peak_test.lua` drives the real Peak/Valley module; mutating the Peak cost, the empty-room freeze, the duplicate-callback guard or the toggle cooldown each makes it fail. Earlier regressions and exact historical engine observations are preserved in HANDOFF_HISTORY_2026-10-24.md.

Local stubs do not emulate actual native entity lifetimes, damage writers, costume priority, animation, controller input, genuine engine save/restart or all co-op configurations. GitHub CI runs the same offline gate. Record its exact final head and status separately after publication/merge.

## Required tests when the owner resumes game testing

1. Verify the exact installed source and make a fresh, allowlisted, hash-verified backup under the owner's E:/ba workflow before any replacement. Never overwrite a running mod or include saves/private files in a public archive. Keep installed/runtime and source records separate.
2. Mute the game. Test all 13 existing selections and both normal/tainted menus; absent forms are not passes. Check startup, HUD, dossiers, story captions and console errors.
3. Reproduce the reported hurt bug on every form, compare with vanilla Isaac, and inspect every direction, carrying, hurt/recovery, death, revival, falling, jumping, stage transitions and flight. Repeat with and without Reactions Port Pack.
4. Execute COSTUME_COMPATIBILITY.md: face/eye items, skin-color changes, wings, size, transformations, temporary replacements, D4/D100, reverse pickup order and actual restart. Check stable anchors and clean removal of temporary effects.
5. Execute TESTING.md and NATIVE_THOUGHT.md for meals, bowls, unique clears, Car Battery, pause, continue and owner isolation. Test tears, Brimstone, Tech/Tech 2/Tech X, knives, Dr. Fetus, Ludovico, Swarm and 1M Context, including mixed combinations.
6. Test keyboard/controller DROP taps and holds, pocket cycling, pause, disabled controls, new rooms, death and reassignment. Test actual JSON save/exit/process close/restart; co-op join/leave, shared controllers, twins and character changes.
7. Repeat on base Repentance and Repentance+; record exact game/mod versions and evidence per case. Complete ordinary runs and balance checks before release. Close the muted game after testing. File 1's current run is disposable by the owner's prior permission.

## Known risks and unfinished compatibility

- Epic Fetus, melee/sword/bone, delayed multi-frame bursts and familiar accounting lack Thought adapters. The current shared-volley rule covers same-frame attacks only.
- A scalar CollisionDamage field cannot distinguish every other mod's relative multiplier from an engine base refresh. Current logic treats a changed value as a fresh base; writer order and same-numeric refresh need engine review. A derived continuous child updated before a fresh parent window can receive its new factor one update late.
- Save/exit callback order and persistence of actual native entities are not reproduced by stubs. Verify every position in the six-update window and exit during knife flight; do not claim a permanent-factor fix solely from fixtures.
- Meal input hooks do not remove emitted attacks or intercept all programmatic shots. Charged releases, analog/Marked aiming, familiars and other input mods need explicit behavior decisions and testing.
- Claude shared account/risk state remains an older design. Tainted DeepSeek forks only ordinary tears; Brimstone, Technology, knives, Dr. Fetus and Ludovico builds get no forks or cost yet, and the fork volley rule (every same-frame tear forks once per payment) needs balance review with multi-shot items. Co-op slot changes and character transformations may expose state ownership gaps. Do not reintroduce DeepSeek risk to make an obsolete test pass.
- Hurt packing is source-corrected, but native costume/scale compatibility and visual quality remain unaccepted. Some alternate poses reuse simpler source poses.
- Existing runtime_probe.lua contains historical/destructive disposable-run fixtures and is never an automatic test. Review its guards and assumptions for the chosen current character before explicit use.
- Old README/history sections may describe earlier behavior; current authority is this handoff, MODEL_ROSTER.md and actual source. Historical commits include a few noisy web-entry commit titles; verified file trees were preserved rather than rewriting shared history.

## Development direction and prioritized backlog

The desired identity is recognizable **community-meme gameplay with meaningful choices**, not generic model capability rankings. Claude uses account bans/appeals, DeepSeek rice and Peak/Valley wordplay, GPT downgrade/Tibo-reset jokes. Research confidence varies; COMMUNITY_MEME_RESEARCH.md must distinguish viewed sources, indexed titles, secondary reports and blocked videos. Never claim that a few posts establish majority opinion. Use fictional mechanisms and captions, not unverified factual accusations or real-person enemies.

1. Stabilize the current 13 forms and native compatibility. Finish missing attack accounting and source-level lifecycle issues; then collect engine evidence when allowed.
2. Tainted DeepSeek Peak/Valley has a source implementation (tear forks only). Next: Claude appeals/quota and GPT downgrade/reset. Save resources/timers per player; preserve a usable main attack and avoid hidden random deletion.
3. Migrate the other eight normal loops and implement the nine missing tainted forms one focused PR at a time. Follow CHARACTER_GAMEPLAY.md, including explicit Birthright behavior, resource caps, room deduplication and bounded derived damage.
4. Complete the **49 remaining additional collectibles** from the fifty-row backlog. Include icon provenance, constants, XML/pools, entrypoint, English EID/UI, relevant tests and handoff evidence in each change. Intrinsic abilities do not count as collectibles.
5. Create the nine missing tainted portraits/skins, slightly darker and aligned with the selected identities. Improve existing anatomy and special poses based on measured engine failures. Use licensed original assets or authorized derivatives with records.
6. Expand story after stable mechanics and art. Preserve the existing queue/save semantics and readable English captions; do not replace vanilla endings. Workshop remains gated on gameplay, art/license review and explicit publication authorization.

## File map and Claude starting procedure

Read CLAUDE.md, CONTRIBUTING.md, this handoff, TESTING.md and resources/ART_LICENSE.md. Then read MODEL_ROSTER.md (actual behavior), CHARACTER_GAMEPLAY.md (target), EXPANSION_DESIGN.md (item backlog), COMMUNITY_MEME_RESEARCH.md (evidence), COSTUME_COMPATIBILITY.md and NATIVE_THOUGHT.md (acceptance gaps).

Core registration is main.lua, scripts/constants.lua and content/*.xml. Saved data lives in scripts/risk.lua and versioned per-player tables. Rice and attack adapters are scripts/characters/deepseek_rice.lua and thought_attacks.lua; shared services are meal_break.lua, characters/drop_tap.lua and tear_fork.lua. Tests are explicit offline stubs; runtime_probe.lua is separate. tools/check.sh is the pre-commit/CI gate.

Fetch current main, inspect status before editing, verify the checkpoint and retain all local drafts. Start from the merged source; do not reinstall the older runtime over it. Run the offline gate once to establish the baseline. Choose one incomplete compatibility/mechanic task, implement it on a small branch, add meaningful regressions, and update evidence in the same PR. No engine automation until the owner resumes testing.

The local-only delivery additionally records the preserved dirty checkout, current worktree, runtime and backup locations. Those private machine details and source reference collections are intentionally excluded from the public handoff.
