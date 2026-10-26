# E2 laser ancestry observer: preparation, not engine evidence

`tests/laser_ancestry_probe.lua` is an explicitly loaded observation tool. It is not included by main.lua and loading it alone registers nothing. It has not been run in either game edition. Installed f8b2b0b includes the tool, verified on 2026-10-26. The authorized session did not reach gameplay because window recovery failed; the owner then requested keeping this installation while unavailable. See ENGINE_AUDIT_2026-10-26.md. Do not launch or send input until the owner is available again.

The older `tests/runtime_probe.lua` is unsuitable for E2: it replaces a pocket item, changes coins/risk and floors, adds Car Battery and exercises mod saves. The local files named child_laser_probe and child_laser_followup_probe are offline callback fixtures, not native observations. Do not treat their output as E2 evidence.

## Capture contract

- Explicit Start registers six temporary callbacks: laser init/update, update clock, new room, new run and exit. No input, entity fields, inventory, stats, charge, room state or save data is modified. Only the observer's own Lua state and callback registrations change; output uses Isaac.DebugString.
- Each laser init/update logs the game frame and immediate laser, Parent and SpawnerEntity pointer hash, index, InitSeed, Type/Variant/SubType and entity FrameCount. Nil links remain nil. The observer neither infers an owner nor remembers a previous Parent; it stores no entity references.
- Labels are short ASCII tokens. Source is a required full commit supplied by the operator from the verified installation receipt; `source_declared` is not an independent runtime hash check. Record actual game version separately.
- Each capture stops at 900 game frames or 2000 sample attempts, or on a room/run change, exit, manual Stop or read/setup error. Every stop unregisters its callbacks. The clock also ends a case with no lasers. A process crash cannot guarantee a final stop record.
- Only one observer may be active, including when the module is loaded twice. A new capture resets its counters. Existing mod callbacks continue normally and may run before this late-registered observer.

Missing fields at init, callbacks before Start, fields changed by earlier callbacks, event limits and logger overhead constrain the observation. A missing child link in a bounded capture does not prove the engine never creates one. A cap/error stop is an incomplete case. Never start another billing fix from an offline fixture or from a missing observation alone.

## Authorized session procedure

First obtain owner availability and permission for installation/testing. Verify a fresh allowlisted E:/ba backup before replacement, record canonical installed file hashes and source, use disposable File 1, mute the session and preserve other mods/saves. Follow the existing deployment workflow; do not copy this file ad hoc into the installed mod.

Start a real test run and record the game edition/version, player form, exact items, relevant other mods and test action. Replace the placeholder below with the full installed source commit from the verified receipt. The placeholder is intentionally rejected by Start.

```text
lua CCAncestryProbe = include("tests.laser_ancestry_probe")
lua print(CCAncestryProbe:Start("techx_splits", "FULL_VERIFIED_INSTALLED_COMMIT"))
```

Check that Start returned true and a `CCANCESTRY ... event=start` line exists before firing. Capture one setup at a time within the same muted session:

| Case label | Native action and evidence to retain |
|---|---|
| techx_splits | Fire Tech X rings with the exact splitting setup recorded; identify primary rings and any observed children. |
| angelic_prism | Fire through Angelic Prism; record the actual item IDs and reflected/split entities. If another Prism mod is involved, record it as a separate case. |
| trisagion | Fire Trisagion, first alone and then with the exact intended split/reflection combination documented. |
| brimstone_tech | Fire the actual Brimstone/Technology combination; record held/released input and resulting laser variants. |

End each capture before changing the setup:

```text
lua CCAncestryProbe:Stop()
```

Check for `event=stop` and its reason. Start the next case with its own label and the same verified source. The tool does not grant items, fire weapons, navigate menus, restart runs or create the scenario. If a scenario cannot be exercised, mark it untested. After the final case, stop the observer, close the game and restore the owner's settings; record what was actually verified.

## Evidence and interpretation

Extract only the bounded CCANCESTRY lines relevant to the case into local evidence. Retain a start line, ordered init/update samples, stop reason and the capture's actual action count. Raw machine logs, saves and private paths must not be uploaded. Review and redact excerpts before putting reproducible observations into a dated ENGINE_AUDIT document.

Correlate entities using pointer hash, index and InitSeed together, retaining both game frame and entity FrameCount. Compare init and earliest available update fields. Show the actual Parent/Spawner link for any claimed child and distinguish missing init, nil link, inaccessible data and cap/error termination. Record screenshots or other native observations for the weapon scenario; log text alone does not prove which gameplay action produced it.

Only actual captured callbacks may establish that a modeled ancestry case occurs. E2 remains incomplete until the requested scenarios are observed on the recorded source/game version. This tool does not establish damage, billing, menu, input, save, art or gameplay acceptance. Repeat relevant cases in both Repentance and Repentance+ before claiming both supported.

## Offline verification and API boundaries

`tests/laser_ancestry_probe_test.lua` checks inert loading, filters on case/source metadata, scalar snapshots, nil/changed links, one active observer, duration/event bounds, cleanup on room/run/exit/manual/read/setup/logger failure, and no main.lua activation. These supplied entities are a test of the observer only; they are not ancestry evidence and add no billing policy.

Community API documentation: [laser callbacks](https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html#mc_post_laser_init) warn that init fields can be incomplete; [Entity](https://wofsauge.github.io/IsaacDocs/rep/Entity.html) documents the identity/link/frame fields; [DebugString](https://wofsauge.github.io/IsaacDocs/rep/Isaac.html#debugstring) writes to the engine log. These references do not prove callback ordering or native behavior in this mod.
