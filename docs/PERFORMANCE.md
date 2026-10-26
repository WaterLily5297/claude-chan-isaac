# Offline performance measurements

## GPT and tainted Grok binding allocation (2026-10-27)

The measured source baseline is `7b96386`. Run from the repository root:

```sh
texlua tools/profile_target_hotpaths.lua . 6000
```

The tool loads the real `gpt_downgrade.lua` and `grok_ratio.lua` modules and uses Lua debug introspection to obtain each update callback's binding closure. It supplies cached game/player stand-ins, warms the binder twenty times, then invokes it 6,000 times with unchanged identities. All players either match the module's form or are unrelated. GPT's award set is empty. No complete update, rendering, native engine work or active ability is exercised.

Garbage collection is stopped only during each measured loop. Heap growth therefore estimates temporary allocation pressure in this Lua interpreter; it is neither retained memory nor evidence of a leak. CPU time is printed for local diagnosis, with no CI timing threshold or frame-rate claim. The recorded local interpreter is Lua 5.3 via `texlua`; other Lua versions/builds may allocate differently.

Both modules produced the following results independently. Values are KiB over all 6,000 calls, not per frame:

| Players | Form match | Baseline heap growth | Revised heap growth | Baseline type calls | Revised type calls |
|---|---|---:|---:|---:|---:|
| 1 | No | 1921.875 | 843.750 | 12000 | 6000 |
| 1 | Yes | 2017.602 | 939.477 | 18000 | 6000 |
| 4 | No | 5718.750 | 1406.250 | 48000 | 24000 |
| 4 | Yes | 6095.727 | 1783.227 | 72000 | 24000 |

All eight binding scenarios made zero entity-scan calls. That observation applies only to the isolated binder, not the whole character callback or mod. The retained per-slot identity snapshot is now reused only while pointer, seed and character type match. A changed slot receives a fresh snapshot; missing slots still retire state. The player type is read once per player per binding pass. The two replacement maps and all existing state validation remain, so this is a bounded reduction rather than removal of all per-frame allocation.

The two real-module gameplay suites retain all earlier assertions and add stable-account, occupied-slot swap, departure/rejoin and pointer-only replacement controls. These new behavior controls also pass on the baseline: this unit optimizes existing semantics rather than fixing a newly claimed gameplay failure. Separate private faults retaining absent-slot state or reusing a stale identity snapshot fail the departure control in each module. Existing seed/type/Continue, duplicate-frame, Birthright and attack-order tests remain intact.

## Attack-choice history

The same tool separately loads the unchanged real `attack_choices.lua`. A proxy counts numeric entry reads inside `Resolve`; it does not time the instrumented representation. Synthetic unique keys bypass weapon attribution entirely.

| Supplied scenario | Retained entries | Entry reads during Resolve |
|---|---:|---:|
| Append and resolve 600 alternating unfavorable/favorable attacks | 600 | 1199 total |
| Resolve the unchanged ledger 6000 times | 600 | 0 |
| Repeat 600 already-recorded keys without upgrading them | 600 | 0 |
| Upgrade the first attack after all 600 were resolved | 600 | 600 |
| Append one Birthright-style half marker and resolve | 601 | 2 |

Ordinary unchanged resolution already avoids replay. Appending needs only the new suffix plus the prior accumulated value. Revising an early attack still replays the suffix to preserve historical clamps and half markers; duplicate hits do not add entries. No ledger truncation, attack-key, billing or transfer-rule change is included.

The 600-entry sequence is a synthetic stress case, not an observed attack rate. GPT retains its ledger until its current check ends; Grok retains it for its quote. This tool does not establish a native maximum lifetime/history size, sample child-shot ancestry, or validate E2. Whole-mod entity scans, large GPT award sets, collector pauses, live ability updates and native multiplayer/performance remain follow-ups. Installed `8fd6a8c` is preserved and still owner-untried.
