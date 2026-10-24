# Vanilla costume compatibility

Required by the owner on 2026-10-23 for all eleven normal and eleven tainted forms. All 22 forms and the fifty additional collectibles now exist in source. The 2026-10-24 engine smoke test exercised type changes, three native item additions/removals and damage calls for every form. It does not accept the visual cases below; see ENGINE_AUDIT_2026-10-24.md.

## Art and implementation contract

Register skins through `content/players.xml`; preserve the standard animation, crop cells, pivots and attachment positions. Never replace global vanilla player assets. Let the engine apply item costumes, skin changes, flight, scaling and transformations. Do not restore an untouched illustration every frame, clear item costumes or reset player scale/color. Legitimate vanilla replacements may hide character details; do not draw a second face over them.

Center the underlying face and torso while retaining intentional asymmetric ornaments. Align eyes, mouth, chin and shoulders to the template. A centered bounding box does not prove anatomical symmetry. If an observed overlap requires separate hair/clothing costumes, choose layers and priorities against that specific conflict. Avoid unconditional high-priority overlays and unverified costume suffixes. New item appearance effects must have a reversible lifecycle and leave unrelated costumes intact.

## Current source review and packing correction

Character and item Lua contain no player spritesheet replacement, costume removal or player-scale override. The reaction adapter supplies empty fallback entries only for unsupported characters and preserves explicit support. This is source review, not visual evidence.

Nine added normal skins used head bottom 30 and a complete-character pose in the carry-head cell. The importer now uses a 28x26 head envelope with bottom 27 and places that same front head into the carry cell at offset (16,16). Locally inspected base-animation pivots are (16,28) and (32,44), respectively. This keeps the same head anchor and removes the extra body during carrying. Original-four final sheets are unchanged after their movement pass.

Hair, horns, hats and clothing remain baked into the skins. Mask alignment, profiles, special poses, flight and full replacements still need review and may require more art or separate costumes. Extracted vanilla assets stay local and are not distributed.

## Engine acceptance matrix

Priority regression: the owner reports oversized heads when all characters take damage. At d1c0daf, the thirteen mod poses were 52–58 pixels wide and 46–58 high, versus the measured vanilla 28x32. The source now fits this cell to 28x32, with visible bottom y=55 and horizontal center x=32. Llama's truncated source crop is corrected too. All thirteen rebuilds and outside-cell comparisons pass. See [MOD_CHARACTER_REFERENCES.md](MOD_CHARACTER_REFERENCES.md) for references and evidence limits. Engine acceptance remains open; Death, FallIn, JumpOut and DeathTeleport also reuse this cell. Other special-pose cells remain unchanged and unaccepted.

For each form, start a disposable clean run. Record commit, game version, mod list, case and before/after screenshots. Compare with vanilla Isaac for intended priority: overlapping costumes need not all remain visible.

| Case | Separate setups | Acceptance |
|---|---|---|
| Base anatomy | Stand, walk and shoot in four directions | Centered anatomy, stable eye/mouth anchors, no clipping or floating feet |
| Face and eyes | Sad Onion, Number One, Spoon Bender, Peeper | Intended changes visible and aligned in every direction |
| Accessories | Mom's Contacts, X-Ray Vision, then both | Alignment and engine priority without flickering |
| Weapons | Brimstone, Mom's Knife, Tech X | Charge/fire poses and weapon origins stay attached |
| Body and color | The Virus, Growth Hormones, Experimental Treatment | Expected changes without detached hair/clothing/limbs |
| Flight | Transcendence, Lord of the Pit, temporary Bible flight | Correct wings/body; temporary state ends correctly |
| Scale | Magic Mushroom, Binky, repeated size pills | All layers and weapons scale together |
| Transformations | Guppy, Beelzebub, Seraphim | Transformation layers and flight combine correctly |
| Temporary replacement | The Nail, Mega Mush | Clean activation and return; no stale scale, tint or limbs |
| Carrying | Pick up, carry, walk in four directions, use active item | Head-only carry cell, aligned arms and item attachment |
| Reactions | Pickup, hurt, death, revival, trapdoor, stage transition | Correct poses; repeat with Reactions Port Pack |
| Removal and reroll | Remove test item; D4 and D100 separately | Removed costumes disappear; retained ones remain |
| Continue | Save/exit, close process, restart with layered costumes/flight | Appearance reconstructs without errors |
| Multiplayer / type | Two different mod characters, Clicker, revival changes | No cross-player leaks or stale previous-form art |

Then test face + flight + scale + weapon combinations in opposite pickup orders. Apply the matrix to every available form; absent tainted forms are not passes. Close the muted game afterward.

## Evidence and deployment

Rebuilds and pixel comparisons establish packing structure only. Stubs cannot prove rendering, priority, clipping or symmetry. Offline previews omit costume selection; historical v0.4 observations do not apply to revised skins. The integration base and subsequent color-fix candidate have deployment records outside the repository. Create a fresh verified E:/ba backup before every replacement, never overwrite a running mod, and keep Workshop publication pending.

References: [player registration](https://wofsauge.github.io/IsaacDocs/rep/xml/players.html), [costume layers and priorities](https://wofsauge.github.io/IsaacDocs/rep/xml/costumes2.html). These describe APIs, not engine acceptance.
