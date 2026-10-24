# Engine compatibility audit: 2026-10-24

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
