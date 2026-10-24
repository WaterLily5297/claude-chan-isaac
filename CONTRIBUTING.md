# Contributing

Start with docs/HANDOFF.md for current implementation, missing work and evidence boundaries. The source checkpoint contains 22 forms, 75 collectibles (including all 50 requested additions), 12 trinkets and four pills. Source completeness is not gameplay acceptance. New code, comments, Markdown and UI text must be English.

## Workflow

1. Fetch main, inspect status and preserve collaborator changes and local drafts.
2. Use a focused branch and PR for one mechanic, item or fix. The owner authorized the current consolidation merge; do not treat this as release approval.
3. Implement the change and meaningful offline regression coverage. Run `bash tools/check.sh` using Lua 5.3+ (texlua works) and Python 3.9+; CI runs the same gate.
4. Update HANDOFF.md, TESTING.md and relevant design/status records. Say exactly what is implemented, simulated, tested in the engine or still planned.
5. Publish the branch, verify remote file-tree equality and CI, then merge only within the owner's authorization. Never overwrite or force-reset shared history.

The owner resumed muted engine testing on 2026-10-24. Use the documented backup/deployment workflow, mute the game, record source/runtime/game versions and close the game afterward. Do not clone directly over the installed mod or assume passing CI means gameplay acceptance.

## New content checklist

- Add the module, constant ID, XML registration and relevant item pools.
- Wire main.lua in the correct callback order. Constitution's damage cancellation precedes risk bookkeeping; derived shots must use resolved parent effects without recursive payment.
- Add an English description, EID entry and any HUD/dossier instructions.
- Supply an icon/sprite with explicit provenance and valid frame geometry. Update deterministic generation or manifests where applicable.
- Add only useful regression cases, run the full offline gate, and describe remaining engine cases.
- Update CHANGELOG.md, current documentation and the expansion inventory. Intrinsic character abilities do not count toward fifty additional collectibles.

## State, compatibility and content rules

Persistent data belongs in versioned per-player Risk.state tables, not player:GetData(). Do not serialize entity references. Guard duplicate callbacks, pause, restart, player/seed/type changes, fake damage and co-op isolation. Use seeded RNG for reproducible gameplay.

Preserve native weapons, item costumes, size, flight and transformations. Do not replace full player sprites every frame, clear unrelated costumes or change player types merely to block shooting. DeepSeek must not regain proxy/IP/risk mechanics.

Community jokes guide fictional mechanics; they do not establish factual claims about people or majority opinion. No real-person/nationality enemies, no Grok July 2025 offensive-content references, and no official company logos. The mod remains free/non-commercial. Code is MIT; art/design terms and attribution are in resources/ART_LICENSE.md. Never upload private saves, credentials or unlicensed reference art. Workshop publication requires separate acceptance and authorization.
