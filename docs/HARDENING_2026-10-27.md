# Scheduled review after four source units

Reviewed source: `123e77874d4f0c8d44d27d837c51b387de117b01`, after #121-#124. The previous scheduled review was #120 at `5e3f392`. This review adds offline integration coverage and records the remaining limits. No new production defect is claimed, and no gameplay, balance, save schema, art or installation change is made.

## Reviewed changes

| Unit | Review finding | Evidence and remaining limit |
|---|---|---|
| #121: I Panicked | The repeat bit skips pickup collection while retaining both damage passes and ordinary-use cleanup. No room-wide suppression state was added. | Existing [item suite](../tests/meme_batch_test.lua) checks supplied drops and flags. The new pair fixture also checks unrelated active callbacks between the two damage calls. Actual native damage/drop/charge order remains open. |
| #122: fourth icon batch | Only ten existing item PNGs and their drawing/registry records changed, with two new review sheets. The other 82 registry entries and character art remained outside that batch. | [Batch 04](ITEM_ART_BATCH_04.md) preserves the isolation evidence. Both current 1x/4x sheets were viewed again on their light/dark fields. The gate checks deterministic pixels/metadata and all eight sheets. This is no new owner aesthetic or native appearance acceptance. |
| #123: pending Birthright | The four real character modules still implement deployment-time Gemini/Llama durations, Mistral's live threshold and Kimi's per-pulse multiplier. Their room/start/exit paths retain the existing transient effects; the test unit changed none of that source. | [Timing matrix](BIRTHRIGHT_TIMING.md) and its fault comparisons remain correctly scoped. Pending-effect booleans do not establish actual item pickup, special-player identity, native continuation or helper billing. No persistence policy is added. |
| #124: Ignore Instructions | The primary exclusion is separate per live owner/slot, consumed on a repeat and cleared on room/start. Unmatched repeats retain prior selection. Ordinary confused bosses remain eligible; this is not a global confusion filter. | The focused suite checks identity/lifecycle boundaries. The new pair fixture checks that the other active's callbacks leave pairing intact and that a first target removed by damage does not obstruct the next target. Native pairing and recursive same-owner/same-slot calls remain open. |

Across the reviewed four units, the only changed production Lua paths are `scripts/eid.lua`, `scripts/items/i_panicked.lua` and `scripts/items/ignore_instructions.lua`. Character, shared billing/save/costume modules, main initialization order and XML registration are unchanged. The current integration suite uses the same relative module initialization order as main.lua.

## New integration evidence

The old isolated `meme_items` and `meme_batch` fixtures invoke callbacks by event without applying their optional item filter. They can therefore miss a handler registered for the wrong item or for every item. [active_pair_test.lua](../tests/active_pair_test.lua) loads both real modules together and applies the registered item filter when supplying MC_USE_ITEM arguments. An unrelated active must run neither handler, and each known item must run only its own handler.

The suite covers 28 supplied sequences:

- Twenty-four sequences combine four active slots, the same/separate owners, and three orders: complete status pair then damage pair; status/damage primaries then their repeats; damage/status primaries then their repeats.
- Four more sequences remove the status item's first boss with the partner's damage active before the status repeat. The surviving boss receives the second status, the dead boss is not hit again, and the supplied death drop survives the damage repeat.

Assertions run after each callback, not just at final totals. They check target attribution/counts, damage attribution/counts, initial loose-pickup removal, preservation of later and protected pickups, captions and return fields. Damage/death/drop events and callback orders are explicitly supplied fixtures; they do not model actual charge discharge, status resistance, native reward scheduling, Void aggregation or every co-op identity.

Four isolated faults replace one module's item filter with the other item's ID or remove that filter. Each faulty copy passes its existing isolated suite but fails the new filtered dispatch assertion. Production files are never replaced by these private copies. The unmodified production modules pass the new suite; this demonstrates a previous test gap rather than a confirmed live registration bug.

## Gate and queue

The shared gate now contains 71 Lua suites, 11 Python scanner cases, 13 item-art groups and six thumbnail groups, with 188 tracked Lua files, five XML files, deterministic assets/poses and eight review sheets. Every prior suite/assertion remains unchanged. The 401-callback/109-field source inventory is unchanged; all 206 tracked art paths and production/tooling/XML retain their pre-review content.

Installed `8fd6a8c` remains owner-untried and preserved. No runtime, game, settings or saves are accessed. All broad character/item acceptance rows stay open. F12's charged-use completion/removal ambiguity is still unresolved; this review does not retry rejected predicates or treat returned use fields as native completion evidence. No child-laser/Parent/derived-shot billing change, new synergy, selected character identity or Workshop release is authorized by this review.

Next: another icon batch, a focused W2/W4 gap, then an independent W3 finding. Repeat scheduled hardening after three to five substantive units or a concrete failure. Whole-mod performance, native weapon/special-player/Continue behavior and actual art presentation remain separate unfinished work.
