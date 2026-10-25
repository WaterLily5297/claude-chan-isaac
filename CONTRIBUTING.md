# Contributing

Start with docs/HANDOFF.md for current implementation, missing work and evidence boundaries. The source checkpoint contains 22 forms, 79 collectibles (including all 50 requested additions), 12 trinkets and four pills. Source completeness is not gameplay acceptance. New code, comments, Markdown and UI text must be English.

## Workflow

1. Fetch main, inspect status and preserve collaborator changes and local drafts.
2. Use a focused main-based branch and PR for one mechanic, item or fix, with no stacked base branches. The owner permits the agent to merge its own compatible fix after the required checks pass when no blocking bug or open design decision remains. Do not treat this as release approval.
3. Implement the change and meaningful offline regression coverage. Run `bash tools/check.sh` using Lua 5.3+ (texlua works) and Python 3.9+; CI runs the same gate.
4. Update HANDOFF.md, TESTING.md and relevant design/status records. Say exactly what is implemented, simulated, tested in the engine or still planned.
5. Publish the branch, verify remote file-tree equality and CI, then merge only within the owner's authorization. Never overwrite or force-reset shared history.

The installed manual-test checkpoint is `220d542`, including PRs #89 and #90; all 433 tracked files were verified after the owner-authorized deployment and a fresh backup of 432 prior files. BACKLOG-LASER-INIT-01 is a later source-only correction and is not installed. Preserve the manual-test build during source follow-ups. Another deployment requires owner authorization and a fresh verified allowlisted backup. Consult the local receipt and HANDOFF.md, preserve saves/other mods, and keep source tests distinct from native acceptance. Agent-run engine testing remains deferred; mute and close the game after any later authorized automated test.

## New content checklist

- Add the module, constant ID, XML registration and relevant item pools.
- Wire main.lua in the correct callback order. Constitution's damage cancellation precedes risk bookkeeping; derived shots must use resolved parent effects without recursive payment.
- Add an English description, EID entry and any HUD/dossier instructions.
- Supply an icon/sprite with explicit provenance and valid frame geometry. Update deterministic generation or manifests where applicable.
- Add only useful regression cases, run the full offline gate, and describe remaining engine cases.
- Update CHANGELOG.md, current documentation and the expansion inventory. Intrinsic character abilities do not count toward fifty additional collectibles.

## State, compatibility and content rules

Persistent data belongs in versioned per-player Risk.state tables, not player:GetData(). Do not serialize entity references. Guard duplicate callbacks, pause, restart, player/seed/type changes, fake damage and co-op isolation. Use seeded RNG for reproducible gameplay.

Preserve native weapon behavior, size, flight and transformation effects. The owner's fixed-look contract applies to all 22 mod forms: `scripts/characters/costume_lock.lua` clears their costume layers while item mechanics must continue to work. Vanilla characters retain native costume behavior; leaving a mod form attempts to restore held collectible costumes, but transformation layers are not rebuilt by that helper. Keep costume clearing in this dedicated service, and verify its visual and mechanical limits with `docs/COSTUME_COMPATIBILITY.md` and TESTING.md COSTUME-LOCK-01. Do not replace full player sprites every frame, reset player scale/color or change player types merely to block shooting. DeepSeek must not regain proxy/IP/risk mechanics.

Community jokes guide fictional mechanics; they do not establish factual claims about people or majority opinion. No real-person/nationality enemies, no Grok July 2025 offensive-content references, and no official company logos. The mod remains free/non-commercial. Code is MIT; art/design terms and attribution are in resources/ART_LICENSE.md. Never upload private saves, credentials or unlicensed reference art. Workshop publication requires separate acceptance and authorization.
