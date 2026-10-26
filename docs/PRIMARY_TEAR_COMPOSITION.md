# Ordinary primary-tear composition

W4, 2026-10-27. Baseline 5cb7a59. This is offline evidence from six real item modules with supplied players, cache inheritance and callback dispatch. Production code already passes; this unit closes a coverage gap and changes no gameplay rule, value, priority, asset or save shape. Installed 8fd6a8c remains owner-untried and untouched.

## Source behavior captured

[The integration suite](../tests/primary_tear_composition_test.lua) selects the six explicit registrations from [main.lua](../main.lua) in their existing relative order. It runs their actual cache, fire and update callbacks, with the real ThoughtAttacks baseline helper. It does not execute the rest of main or model native dispatch timing.

| Stage | Existing result in the supplied ordinary-tear sequence |
|---|---|
| Cache | 1M Context adds 200 range; Golden Gate adds 60 range, spectral and a tint; Pizza Glue subtracts 0.1 shot speed for the supplied single copy. Supplied native colour and flags seed the tear. |
| Hardcoded Output on fire | Damage becomes 3.5. This callback is not a guarantee against later modifiers. |
| Pizza Glue on fire | The supplied successful roll adds slow and glaze. Already-slow tears consume no roll or additional glaze. |
| Strawberry on fire | Every third player tear doubles current damage, multiplies inherited scale by 1.2 and adds its tint. With Hardcoded Output, this produces 7 before age decay. |
| Blueberry on fire | Its independent third-tear counter adds QUADSPLIT and blue tint without removing existing flags. |
| 1M Context on update | The first update snapshots the completed fire result; subsequent updates use that baseline. Ordinary damage is baseline times max(0.3, 1-age/90). The existing formula reaches 30% at frame 63, despite the source comment's three-second description. Ludovico is excluded. |

For Hardcoded Output plus Strawberry plus Context, the third supplied tear starts at 7, becomes 14/3 at frame 30 and 2.1 at frame 63. Other supplied tears start at 3.5 and floor at 1.05. Repeating an update at the same age does not compound the decay. These are observed source outcomes, not a newly approved fixed-output precedence rule.

## Coverage and fault sensitivity

All 64 subsets of the six items run with two interleaved owners, six tears each and different incoming damage: 768 ordinary primary tears. First updates at frame 0 or 1 are followed by ages 30, 62, 63, 90 and 180, each dispatched twice. Assertions check damage, retained baseline, scale, all seven colour channels, native homing/piercing plus added flags, and RNG/counter isolation. Rebuilt cache input is also supplied twice for one owner.

Additional controls cover already-slow tears, a first update delayed to frame 30, a Ludovico tear, a familiar-like non-player owner and an orphan tear. Alpha, nonzero additive colour offsets and the original shared colour object are checked explicitly. No acquisition/removal/rebase or Continue policy is invented.

Seven isolated faulty source copies fail the new suite: Hardcoded registered after Strawberry, repeated baseline resnapshotting that compounds rot, a shared Strawberry counter, Golden Gate dropping inherited offsets, Blueberry replacing flags, Pizza Glue rerolling already-slow tears and Context rotting Ludovico. These probes establish new-suite sensitivity only; no claim is made that the older suites miss all seven faults.

The full gate now runs 72 Lua suites, with 189 tracked Lua files, 11 scanner cases, 13 item-art groups, six thumbnail groups, five XML files, assets/poses, ten art sheets and inventory freshness. All existing suites and assertions are unchanged. The previous `native_tear_color` suite covers character identity tint callbacks; this new suite supplies the actual four-item tint composition evidence. Item ledger links now distinguish those scopes.

## Remaining verification

Native callback order, actual damage dealt, colours/rendering, split descendants, flags and real cache rebuilds remain unaccepted. The fixture supplies inherited native properties; it does not load Ipecac, Spoon Bender, transformations or third-party mods. Backlog primes, character Thought payment, Opus, Swarm and other damage writers are outside this six-module fixture. Other suites retain their own narrower evidence.

After a fresh owner-authorized engine window, observe ordinary shots with Hardcoded/Strawberry/Context, then add the three tint/flag items. Record damage at age boundaries, native size/colour effects, flags and two-player counters. Actual split-child behavior is a separate case. Do not change child/Parent/derived-shot billing without native E2 evidence. No runtime, game, settings or saves were accessed for this offline unit; all broad completion rows stay open.
