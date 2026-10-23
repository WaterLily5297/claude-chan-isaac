# Native Thought attack adapters

This is a source candidate for normal DeepSeek, following PR #17. The owner currently permits source work and offline validation only. No engine acceptance is claimed. Existing 0.9x base damage, Rice meals and ordinary items remain native.

## Current source rules

| Native attack | Observation | Thought rule |
|---|---|---|
| Ordinary player tear | POST_FIRE_TEAR | One same-frame volley, snapshot multiplier for the tear's flight |
| Single-hit laser | First POST_LASER_UPDATE with positive damage | One same-frame volley, snapshot multiplier |
| Released circle laser, without the Ludovico flag | First laser update | One snapshot for the released ring |
| Repeated-hit beam, including Brimstone | Laser updates | Shared six-gameplay-update windows |
| Ludovico tear or circle beam | Tear/laser updates and native HasTearFlags | Shared six-update windows; continuing attacks block idle Thought recharge |
| Flying knife | First update observing IsFlying | Snapshot once per throw; remove the factor when it returns |
| Dr. Fetus bomb | First positive ExplosionDamage update with IsFetus | Snapshot one same-frame volley; do not affect ordinary placed bombs |

All adapters use a directly identified player. A non-player spawner does not fall back through a familiar to bill its owner. Parent-only attribution is accepted only when that parent itself is a player. Reflected-laser ancestry, detached reflected beams and bomb-child ancestry cannot pay again. This intentionally does not establish familiar or every synergy's attribution.

The repeated-hit beam rule is a balance choice: only the initial 0.2-second window receives stored Thought, unless a later Rice reward supplies more Thought. A finite Brimstone beam is also a repeated-hit beam under this rule. It is not a promise of 2x damage for the entire beam lifetime. An ongoing controlled attack cannot recharge itself by releasing the aim buttons. Ordinary travelling tears and a thrown knife do not prevent idle recharge solely by remaining alive.

Six-update windows share one per-player payment and multiplier. They preserve remaining time across continue, pause without advancing, and expire without regenerating Thought from their own activity. A window is a saved scalar budget, not a saved entity reference. Room changes discard the room's window. Character/identity changes and death reset it alongside the Rice economy. Older Rice saves without window fields start with no active window.

## Damage composition and lifecycle

Transient entity records remember the unboosted value and the last value written. An unchanged write is never multiplied again. A different positive value is treated as a fresh unboosted value from the engine or another writer. This is an explicit integration assumption: arbitrary mods that instead multiply the already-boosted value, or coincidentally write the same numeric value as the prior result, cannot be distinguished by inspecting a shared scalar. Do not claim universal cross-mod damage compatibility from these tests.

1M Context cooperates through `ThoughtAttacks.BaseDamage`: continuous decay snapshots the unboosted baseline, while discrete projectiles retain their resolved flight multiplier. Swarm/tainted raw forks are tagged as derived. A continuous fork refers to its parent's transient factor, does not pay or mark the player as firing, and cannot retain an expired window when updated first. When a fresh window begins, a child updated before its parent can receive the parent's new factor one update later; actual collision ordering remains an engine case.

Temporary continuous/knife factors are removed on return, room change and pre-exit cleanup only if the field still matches this module's last write. Another writer's changed value is not overwritten during cleanup. Cleanup also reaches freshly copied children before their first update. EntityPtr references and callback records stay transient; only scalar window count/factor are stored with Rice state. Actual game save order, continued entities and engine damage refreshes must be observed before acceptance.

No adapter changes player types, player sprites, tears' visual scale, tear flags, color, steering, collision classes, flight arcs, bomb radius or weapon selection. No extra damage callback or replacement projectile is generated. Existing native attacks are not deleted by the food lockout; charged releases and programmatic attacks during a meal remain unverified.

## Offline evidence and remaining engine matrix

`tests/native_thought_test.lua` invokes the real Rice, shared food, raw fork and 1M Context modules. Against `e8639cb`'s Rice module its first laser assertion fails. The candidate passes native entity callback fixtures for shared volleys, six-update expiry, duplicate calls, pause, partial-window continue, positive-damage initialization, direct/co-op ownership, knife return/rethrow, ordinary-bomb exclusion, parent/child update order, immediate-exit cleanup, parent removal, modeled engine base refresh and Context decay. Full checks contain 60 Lua files, five XML files and fifteen stub suites.

When game testing resumes, record exact source/runtime versions and test these cases independently:

- Technology, Technology 2, Brimstone, Technology X and Ludovico, including mixed pickups: confirm actual OneHit, circle, parent and high-bit flag behavior, release timing and damage dealt. Do not infer type classification from the displayed sprite alone.
- Mom's Knife: charge, release, return, contact, multiple knives and room transitions. Test knife+Brimstone and knife+Ludovico separately.
- Dr. Fetus: ordinary and multi-shot bombs, bomb synergies, child bombs, native explosion damage/radius and player attribution.
- Ludovico and repeated beams with Swarm and 1M Context, in both update orders where observable. Confirm no permanent amplification, duplicate payment or visual/steering replacement.
- Pause and save/continue in each of the six window positions. Confirm remaining time, unboosted serialization, no permanent factor and no lost/duplicated Rice reward. Test exit during a flying knife separately; entity persistence is not modeled by the stub.
- Reactions Port Pack, native transformations/size/flight items and other mods that write projectile damage. Existing costume and hurt-pose acceptance remains open.

Epic Fetus effects, melee/sword/bone attacks, delayed multi-frame bursts and familiar ownership still need adapters. They must not be marked supported by this change. Claude usage/quota and tainted DeepSeek computation still need their own migration; this module is not a claim that all forms now share complete native attack accounting.

API references: [initialization callback caveats](https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html#mc_post_laser_init), [laser fields](https://wofsauge.github.io/IsaacDocs/rep/EntityLaser.html), [knife flight](https://wofsauge.github.io/IsaacDocs/rep/EntityKnife.html#isflying), [fetus bomb fields](https://wofsauge.github.io/IsaacDocs/rep/EntityBomb.html), [Ludovico flag](https://wofsauge.github.io/IsaacDocs/rep/enums/TearFlags.html). These document API contracts, not this candidate's engine results.
