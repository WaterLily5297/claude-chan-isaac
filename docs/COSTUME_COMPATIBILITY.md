# Vanilla costume compatibility

Required by the owner on 2026-10-23 for all eleven normal and eleven tainted forms. All 22 forms and the fifty additional collectibles now exist in source. The 2026-10-24 engine smoke test exercised type changes, three native item additions/removals and damage calls for every form. It does not accept the visual cases below; see ENGINE_AUDIT_2026-10-24.md.

## Fixed look (owner, 2026-10-24)

The owner replaced the earlier "let the engine apply item costumes" rule: every mod form should keep its own character skin while item mechanics continue to apply. Native scale, tint, weapon animation and full-body replacement effects still require separate compatibility checks; the lock does not replace those engine systems. `scripts/characters/costume_lock.lua` calls `ClearCostumes` on mod forms only. It clears when the collectible count, temporary effect count, trinkets or player type change, after an active item, card or pill use, on every new room and on game start/continue. Each trigger clears for three frames because costumes can land a frame late, and a 30-frame sweep catches item-state costumes. Lock state lives in `GetData` and is never saved. When a player leaves a mod form (Clicker, revival), the restoration helper calls `AddCostume` for held collectibles. It does not explicitly rebuild transformation, temporary-effect, trinket or externally supplied costume layers. This attempt to restore held costumes is not proof that every native or modded layer returns correctly.

The service uses the native `ClearCostumes` API and does not itself remove items, alter stats, set flight/scale or cancel transformations. That source structure is not engine acceptance: item mechanics, native replacements and other mods' layers must still be observed. Known visual risks to record include hidden flight wings, Holy Mantle or other effect layers, a one-frame costume flash after pickup/use, and reverted skin-colour changes delivered through costumes. A hidden layer and a broken gameplay effect are separate findings. Vanilla Isaac must retain normal costume behavior as the control.

## Art and implementation contract

Register skins through `content/players.xml`; preserve the standard animation, crop cells, pivots and attachment positions. Never replace global vanilla player assets. Let the engine apply skin changes, flight, scaling and transformation effects; item costume layers are cleared by the fixed-look lock above. Do not restore an untouched illustration every frame or reset player scale/color. Legitimate vanilla replacements may hide character details; do not draw a second face over them.

Center the underlying face and torso while retaining intentional asymmetric ornaments. Align eyes, mouth, chin and shoulders to the template. A centered bounding box does not prove anatomical symmetry. If an observed overlap requires separate hair/clothing costumes, choose layers and priorities against that specific conflict. Avoid unconditional high-priority overlays and unverified costume suffixes. New item appearance effects must have a reversible lifecycle. Keep broad costume clearing confined to the fixed-look service for mod forms; other item code must leave unrelated costume layers intact, including on vanilla characters.

## Current source review and packing correction

Character and item Lua contain no player spritesheet replacement or player-scale override; costume removal is limited to `costume_lock.lua`. The reaction adapter supplies empty fallback entries only for unsupported characters and preserves explicit support. This is source review, not visual evidence.

Nine added normal skins used head bottom 30 and a complete-character pose in the carry-head cell. The importer now uses a 28x26 head envelope with bottom 27 and places that same front head into the carry cell at offset (16,16). Locally inspected base-animation pivots are (16,28) and (32,44), respectively. This keeps the same head anchor and removes the extra body during carrying. Original-four final sheets are unchanged after their movement pass.

Hair, horns, hats and clothing remain baked into the skins. Mask alignment, profiles, special poses, flight and full replacements still need review and may require more art or separate costumes. Extracted vanilla assets stay local and are not distributed.

## Engine acceptance matrix

Priority regression: the owner reports oversized heads when all characters take damage. At d1c0daf, the thirteen mod poses were 52–58 pixels wide and 46–58 high, versus the measured vanilla 28x32. The source now fits this cell to 28x32, with visible bottom y=55 and horizontal center x=32. Llama's truncated source crop is corrected too. All thirteen rebuilds and outside-cell comparisons pass. See [MOD_CHARACTER_REFERENCES.md](MOD_CHARACTER_REFERENCES.md) for references and evidence limits. Engine acceptance remains open; Death, FallIn, JumpOut and DeathTeleport also reuse this cell. Other special-pose cells remain unchanged and unaccepted.

The owner's manual-test installation is `28fed37`; newer source-only fixes do not change its evidence. Agent-run engine testing remains deferred. During manual testing or later authorized automated testing, start a disposable clean run for each form and repeat the matching setup on vanilla Isaac. Record the source and installed commits, game version, mod list, case and before/after screenshots. On mod forms, item costume layers should clear under the fixed-look contract while the item mechanics still work. The Isaac control should show normal costume behavior and engine priority. Record any brief flashes or hidden gameplay feedback separately; do not mark an item mechanically broken solely because its costume is suppressed.

| Case | Separate setups | Acceptance |
|---|---|---|
| Base anatomy | Stand, walk and shoot in four directions | Centered anatomy, stable eye/mouth anchors, no clipping or floating feet |
| Face and eyes | Sad Onion, Number One, Spoon Bender, Peeper | Mod skin anchors remain stable after clearing; tear, stat and familiar effects work; Isaac shows native face changes |
| Accessories | Mom's Contacts, X-Ray Vision, then both | Mod form does not retain accessory layers or flicker; item effects work; Isaac retains normal costume priority |
| Weapons | Brimstone, Mom's Knife, Tech X | Charge/fire poses and weapon origins stay attached |
| Body and color | The Virus, Growth Hormones, Experimental Treatment | Item stats/effects work without detached art; distinguish costume colour suppression from native tint/scale behavior |
| Flight | Transcendence, Lord of the Pit, temporary Bible flight | Native flight and its expiry work, body/weapon anchors stay intact; record hidden wings separately and check Isaac's native layers |
| Scale | Magic Mushroom, Binky, repeated size pills | All layers and weapons scale together |
| Transformations | Guppy, Beelzebub, Seraphim | Transformation mechanics and flight work with mod costume layers cleared; Isaac retains native transformation visuals |
| Effect feedback | Holy Mantle and temporary shields, separately | Shield protection and expiry work; record hidden feedback layers independently and compare with Isaac |
| Temporary replacement | The Nail, Mega Mush | Clean activation and return; no stale scale, tint or limbs |
| Carrying | Pick up, carry, walk in four directions, use active item | Head-only carry cell, aligned arms and item attachment |
| Reactions | Pickup, hurt, death, revival, trapdoor, stage transition | Correct poses; repeat with Reactions Port Pack |
| Removal and reroll | Remove test item; D4 and D100 separately | Mod skin settles without stale costume layers; effects track the resulting inventory; Isaac retains only appropriate native costumes |
| Continue | Save/exit, close process, restart with items, transformations and flight | Mod skin and mechanics reconstruct without errors; record late costume flashes; Isaac's native layers return normally |
| Multiplayer / type | Two different mod forms plus a vanilla partner; Clicker and revival changes | No cross-player clearing or stale form art; leaving a mod form restores held collectible costumes; record missing transformation, temporary, trinket or external layers separately |

Then test face + flight + scale + weapon combinations in opposite pickup orders. Apply the matrix to all 22 forms and the vanilla control; a representative-form sample is not acceptance for untested forms. Close the muted game afterward.

## Evidence and deployment

Rebuilds and pixel comparisons establish packing structure only. Stubs cannot prove rendering, priority, clipping or symmetry. Offline previews omit costume selection; historical v0.4 observations do not apply to revised skins. The integration base and subsequent color-fix candidate have deployment records outside the repository. Create a fresh verified E:/ba backup before every replacement, never overwrite a running mod, and keep Workshop publication pending.

References: [player registration](https://wofsauge.github.io/IsaacDocs/rep/xml/players.html), [costume layers and priorities](https://wofsauge.github.io/IsaacDocs/rep/xml/costumes2.html). These describe APIs, not engine acceptance.
