# Public character-mod references

Reviewed 2026-10-23 at the owner's request. Public reference repositories were cloned into local scratch storage, read only, and not executed or vendored. No third-party sprite, animation file or source module was imported into the mod. These are reference patterns, not proof of compatibility with this project's Repentance+ runtime.

## Pinned references

| Reference | Revision | Useful finding | Reuse status |
|---|---|---|---|
| [catinsurance/isaac-character-template](https://github.com/catinsurance/isaac-character-template) | `bebc0f368d1ab54a5553d7cf22aa91d052bb50e8` | README warns that starting costumes can disappear after reroll/transformation sequences. The tainted players.xml uses costumeSuffix and costume; normal Lua illustrates AddNullCostume. Examine lifecycle as well as initial appearance. | No root LICENSE found in inspected checkout. Reference only; do not infer permission to copy art/code. |
| [manaphoenix/IsaacTemplates](https://github.com/manaphoenix/IsaacTemplates) | `3b5219e2ccd4a830451838c8ba764e45f2731685` | Character template separates skin registration, null costumes, stat cache and starting items. The optional starting-item costume removal must not be copied indiscriminately: the owner wants vanilla item visuals preserved. | Root CC0-1.0 license inspected. Do not assume this transfers ownership of embedded vanilla artwork or every third-party asset. No imports made. |
| [wofsauge/IsaacTools](https://github.com/wofsauge/IsaacTools) | `384e3542ce9d46419d14aeb995c9030cfcce3212` | Character-sheet generator focuses on MissingNo/teleport sections. Useful reminder that a skin atlas contains effect-specific regions beyond the obvious head/walk frames. It is not a general hurt-pose repair tool. | No root LICENSE found in inspected checkout. Reference only; no generator execution or asset import. |

Additional discovery: [Eevee Reunited demo](https://github.com/BenevolusGoat/eevee-reunited-demo) and its author's [older compatibility discussion](https://steamcommunity.com/workshop/filedetails/discussion/2653691445/5017567849300416231/?ctp=2). This supplies historical examples of custom attacks and size/animation conflicts, not a current Repentance+ bug claim. Its code and license were not audited; no Pokemon artwork is proposed for reuse.

## Local vanilla hurt-frame inspection

The owner's report: all characters show an oversized head after taking damage. Exact engine build/character-item combinations were not captured. This is user-reported engine evidence, not a successful reproduction on the latest local source.

The locally extracted base player animation has an eight-frame Hit animation using layer 12. Its crop is (128, 192), size 64 by 64, with pivot (32, 56). Frames apply 80/120, 120/80, 94/104 and 100/100 percent X/Y squash/stretch. The crop contains a complete hurt pose, not a head intended to fill a 64-pixel square. No extracted vanilla assets are committed.

At d1c0daf, tools/pack_selected_sprites.py fitted all special-pose sources to a 58-pixel square inside 64-pixel cells. Its hurt cell therefore used a much larger envelope than ordinary heads. The importer also centered the pose instead of matching the hurt pivot's ground anchor. This was a concrete packing mismatch consistent with the report, **not an engine-verified complete root cause**. The later repair uses a 28x32 envelope and visible bottom y=55 for this cell only. Llama's separately observed truncated pose also needed a corrected source crop.

Offline measurement at alpha >= 128 confirms a 28x32 visible vanilla hurt pose, ending one pixel above the pivot. In the previous candidate, twelve mod poses were 58 pixels wide; Qwen was 52. Heights ranged from 46 to 58 pixels and bottom offsets from -1 to +5 relative to the pivot. All thirteen repaired poses now fit the measured envelope and bottom anchor. These bounds include accessories and do not by themselves prove anatomical correctness. The measurement report contains geometry only, not extracted vanilla pixels.

The inspected base animation reuses this crop in Hit, Death, FallIn, JumpOut and DeathTeleport. Pixel isolation therefore limits the changed atlas area, not the number of affected animation names. All five need engine checks. No global animation file or vanilla texture is included or replaced.

## Applying the references

1. Measure vanilla hurt-pose alpha bounds and head/body proportions, then compare all thirteen current skins at the same crop, pivot and animation scale. Do not enlarge small sprites merely because a special-effect cell is large.
2. Keep special poses separate from head-only carry cells. A shared importer must encode each animation's meaning and anchor, not one generic fit rule.
3. Keep the base body, head and optional accessories separate where the engine expects layers. Do not mask item cosmetics with a full-body always-on overlay or repeatedly replace the player animation.
4. Review costume add/remove events on reroll, item acquisition/removal, revive, form change and continue. Preserve vanilla collectibles' costume ownership; do not copy template priorities 99/100 or RemoveCostume calls without justification.
5. Check real damage and then recovery with flight, head/body modifiers, size changes, transformations, pickup/carry and death. Repeat with two different co-op players and identical-character duplicates. Include D4 and Mom's Knife, then laser, bomb and multishot weapon builds.

## Evidence status

Reference inspection, vanilla XML geometry, source hurt-cell correction and offline before/after review: completed. Deployment and current engine acceptance: pending. tools/verify_hurt_poses.py checks all registered skins, source hashes, exact rebuilds and unchanged pixels outside the shared cell. Its preview samples normal scale and the initial 80%/120% squash/stretch, not the entire engine animation or costume system. Earlier head/carry changes did not repair this cell. The source fix does not authorize Workshop publication or establish GitHub/runtime synchronization.
