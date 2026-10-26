# F12: charged-use replacement ambiguity

Source baseline: `35d7ac6`, inspected on 2026-10-27. **Reproduced offline; not fixed or accepted in the engine.** The production observer and all item rules remain unchanged in this unit. Do not treat this report or a successful diagnostic exit as a compatibility pass.

## Reproduce the current observation

```sh
texlua tools/probe_charged_use.lua .
```

The [diagnostic](../tools/probe_charged_use.lua) loads the real backlog common service and all family modules through the existing [fixture](../tests/lib/backlog_env.lua). It calls the actual Red Stamp handler with no target (which returns `Discharge=false`) or a supplied nearby target (which returns `Discharge=true`). Then it supplies an inventory/charge transition before the next update. Seven cases run in each slot 0-3, for 28 rows.

The observer records the player's slot item and combined ordinary/Battery charge during `MC_PRE_USE_ITEM`. It later emits `activeUsed` if either the item ID changed or combined charge fell. It never reads the handler's return table. The observer's same-slot snapshots are therefore insufficient to distinguish all of the supplied histories.

| Supplied history | Handler discharge | Item ID changes | Total charge before / after | Current events per slot |
|---|---|---|---|---:|
| Refused, unchanged inventory | false | No | 8 / 8 | 0 |
| Refused, different item with equal charge | false | Yes | 8 / 8 | 1 |
| Refused, different item with lower charge | false | Yes | 8 / 0 | 1 |
| Refused, item removed | false | Yes | 8 / 0 | 1 |
| Refused, original full item moved to another slot | false | Yes | 8 / 8 | 1 |
| Accepted, same item spends Battery charge | true | No | 8 / 4 | 1 |
| Accepted, item subsequently removed | true | Yes | 8 / 0 | 1 |

All four slots produce the same results in this fixture. Each emitted event primes Base Model, resets Please Come Back progress from two to zero, spends Access Pass's first-use marker and changes supplied combat-room damage from 3.5 to 4.025. When no event is emitted, those values stay at their baseline. These are real listener effects under supplied callbacks, not native co-op or discharge timing evidence.

The accepted/removal case deliberately removes Red Stamp **after** its real successful handler; Red Stamp does not remove itself. It represents a possible endpoint that must be distinguished from refusal/removal, not a claim about a specific native consumable. Similarly, the swap and replacement assignments do not emulate Schoolbag, rerolls, Butter! or another mod's callbacks. Their reachability and ordering in the supported game builds remain unobserved.

## Why the two local predicate experiments are not shipped

Two isolated copies of `common.lua` were run through all 28 rows. No production file was replaced during those experiments.

| Observation predicate | Refused equal-charge replacement / swap | Refused lower-charge replacement / removal | Accepted same-item discharge | Accepted then removed |
|---|---:|---:|---:|---:|
| Current: changed item **or** lower charge | 1 | 1 | 1 | 1 |
| Candidate A: lower charge only | 0 | 1 | 1 | 1 |
| Candidate B: same item **and** lower charge | 0 | 0 | 1 | 0 |

Removing the item-change shortcut alone leaves the lower-charge false observations. Requiring the same item suppresses those cases but also rejects the accepted/removal control. Candidate B is not proven compatible with successful self-consuming, replacing or dropped actives. Neither candidate establishes a complete fix, so neither changes shipped behavior here. This is a concrete evidence gap rather than authorization to narrow the existing successful-use contract.

## API evidence and next implementation boundary

The base [callback documentation](https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html#mc_use_item) documents the `Discharge` and `Remove` fields on the handler result. Its [pre-use callback](https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html#mc_pre_use_item) runs before activation; it is not a completed-use verdict. [`USE_OWNED`](https://wofsauge.github.io/IsaacDocs/rep/enums/UseFlag.html) describes ownership, not proof that the eventual use spent charge.

REPENTOGON separately documents [`MC_POST_USE_ITEM`](https://repentogon.com/enums/ModCallbacks.html#mc_post_use_item), including discharge/removal arguments. Its documentation warns that discharge may still happen afterward. This extension cannot be assumed in base Repentance/Repentance+; the diagnostic adds no dependency, extension callback or installed probe.

Before replacing the observer, collect a bounded native sequence for ordinary and refused uses, equal/lower-charge replacements, slot swaps and a confirmed self-consuming room-charge active. Record anonymous player slot/seed identity, frame, callback kind, supplied item/flags/slot, item IDs and both charge bars at pre-use, use and subsequent updates. Where an extension is actually present, capture its completion verdict separately; do not infer its presence from an API website. Preserve the existing no-duplicate, co-op, special/zero/timed, Car Battery, second-bar and room/floor cleanup cases.

Implementation must reject proven refused uses without losing successful native consumptions or attributing another slot's charge. An explicit completion path for project-owned handlers may be possible, but it must account for nested callbacks and other handlers rather than treating `MC_USE_ITEM` notification itself as success. A new fallback policy for ambiguous external uses requires a concrete proposal and owner decision; no such policy is silently selected here.

This unit is offline tooling and evidence only. The 70 Lua gameplay suites and their expectations are unchanged; the diagnostic is syntax-checked, not another passing gameplay suite. F12 and its three item rows remain open. Installed `8fd6a8c` remains owner-untried and untouched, with no runtime/game/settings/save access or fresh game-state observation. Continue independent hardening work while native evidence is unavailable; no repeated availability question is needed this session.
