# Handoff for Claude and contributors

Updated 2026-10-23 (Japan time), v0.4-dev. This is a Codex implementation handoff. No separate Claude session reviewed these changes; no Claude CLI or connected Claude service was available.

## v0.5-dev (Claude session, 2026-10-23) - not yet run in game

Owner requests: normal and tainted versions of both characters; DeepSeek-chan is unrelated to IPs, so her design was revisited; fix the sprites; fix bugs; item/character changes from X/Bilibili memes. Branch `claude/meme-update`.

- **DeepSeek-chan redesign.** `Risk:IsActive()` is false when every player is DeepSeek-chan (normal or tainted): risk reads 0, never rises, no IP roll, no ban story, HUD shows 直连. In co-op with anyone else the system runs normally. Her own mechanics: Deep Think, Server busy, pocket **Lunch Break**. The Support Ticket is no longer her pocket item (still a shop item).
- **Tainted characters** via `players.xml` `bSkinParent`; IDs `Constants.Player.CLAUDE_CHAN_B` / `DEEPSEEK_CHAN_B` (`GetPlayerTypeByName(name, true)`). Tainted Claude-chan: weekly tear quota (`Risk.state.weeklyUsed`), pocket Banked Reset. Tainted DeepSeek-chan: forked tears, busier servers. Research (Isaac Blueprints, tainted-unlock tutorial): without REPENTOGON there is no way to lock a modded tainted character in the menu, so they should be selectable immediately; an unlock would need an init-time `ChangePlayerType` swap back to the normal character plus a saved flag. The tainted toggle (E / RB) may still require a save with vanilla tainted characters unlocked. Not yet observed in game.
- **Claude-chan account age** (`Risk.state.accountAge`).
- **Sprites:** cell spill, cut-off side head and DeepSeek's walking bodies fixed (`tools/fix_character_cells.py`); tainted art is a recolour (`tools/make_tainted_art.py`). Everything the friend observed in game below was on the *pre-fix* atlases.
- **Items:** 529 Overloaded lets you shoot at 50% during outages; Vibe Coding waives the bill after a no-hit floor.
- **Bug fixes:** banned Relay Slimes don't split; Thinking Cleared drains only on first visits; The Constitution ignores self-inflicted damage.
- **Runtime probe** now needs a Claude-chan run and swaps a Support Ticket into her pocket. Its recorded passes below were on the v0.4 DeepSeek build.
- Stub tests cover all of the above (`bash tools/check.sh`). In-game checks: `docs/TESTING.md` "v0.5 focused checks".

## Implemented content

- PR #1 (collaboration/CI) and PR #2 (RORICO444 item icons) were reviewed and merged, preserving contribution history. PR #2 was retargeted from `setup/collaboration` to `main` after #1 merged.
- Support Ticket: six-charge shop active; pay 3 coins for risk -20. Insufficient coins or zero risk preserve money and charge. Car Battery cannot bill twice.
- DeepSeek-chan: 2 red hearts and 1 soul heart, 3 coins, 1 key, pocket Support Ticket, damage x0.85, firing interval x0.85, blue tears. A no-hit room reduces shared risk by two extra points once for the team.
- The Appeal Queue: four original captions in en/zh/ja. `Risk.state.storySeen` is a saved bitmask. Approval unlocks its caption in the next room, while stages 3 and 5 retain their own approved-route dialogue. Captions do not pause the game or replace vanilla endings.
- Both characters have generated custom atlases, portraits, names and selection assets. See `ART_GENERATION.md` for prompts, provenance and frame importing. These are first-pass game sprites, not downloaded Bilibili artwork.
- Optional Reactions Port Pack compatibility registers empty fallback costume lists for these two characters only. It preserves explicitly supplied character support, sounds/music and other players. Without this, that pack gives unknown characters a default Isaac face. Never fix this by clearing every player costume or editing another mod.
- DeepSeek clothing is mapped into the base body cells. Claude's rear heads and headless walking bodies were regenerated as isolated parts and fitted inside engine cells after runtime testing exposed cropping and miniature heads in the original atlas.
- Silent Update seeds its floor RNG before drawing, including the pre-start `MC_POST_NEW_LEVEL` callback, and preserves the saved multiplier on continue.
- Windows checks skip Python Store stubs and force UTF-8. Asset checks cover deterministic item icons, dimensions, pools, character paths and ANM2 bounds.

- Fixed simultaneous caption triggers: room and floor events now queue chapters instead of overwriting them. Pending keys live in `Risk.state.storyPending` and survive save/load; their seen bits are set when they begin. Legacy saves remain supported.

## Actual validation

- `bash tools/check.sh` passes under Lua 5.3 (`texlua`) and Python 3.10 on Windows: all four Lua tests, syntax, XML and assets. CI runs the same checks. Regression cases include item boundaries, Car Battery, co-op shared risk, floor seeding, early approval, saved chapters and optional reaction-pack fallbacks.
- Repentance+ 1.9.7.17 loaded both custom characters in the existing mod installation with the owner's other mods enabled. Claude's front/rear appearance and DeepSeek's front/rear/right shooting appearance were inspected. Blue DeepSeek tears, orange Claude tears and Claude's usage-limit HUD were observed. The final corrected Claude rear silhouette rendered complete.
- Both portraits appeared on Continue. DeepSeek continued with its custom skin; Claude also continued with custom art and without repeating the already-seen first chapter.
- Actual pocket-item input changed DeepSeek from 3 coins / risk 2 to 0 coins / risk 0. A subsequent use attempt at 2 coins / zero risk retained 2 coins and exactly 6 pocket charges, confirmed through `GetActiveCharge(SLOT_POCKET)`.
- A stage-3 transition after early approval displayed its approved-route second chapter. The final subtitle position (`screen height - 105`) was checked on a later stage-3 transition: it was separated from Loadout's fixed bottom prompt. EID occupies the upper area; the original EID/subtitle overlap was removed.
- A Claude D4 use with an added passive completed without a mod error and retained custom art; this is a single smoke case, not comprehensive costume coverage.
- Test aiming and pocket use used temporary session-only input callbacks through the game's debug console. They were never installed or committed; the final callback was removed before shutdown.
- Steam's Cloud sync-failed warning was accepted only after the owner explicitly authorised proceeding. It remains a Steam sync issue, not a mod fix. Tests remained muted; the game was closed normally afterward.

- A subsequent Repentance+ engine probe passed positive-risk insufficient funds (2 coins / risk 50 / 6 charges retained), Car Battery (6 to 3 coins / risk 50 to 30 / charge 0), simultaneous room/floor captions (seen=9, pending=1), and the actual mod JSON save/load path (seen=11, pending=0 after resuming). The queued second chapter rendered with approved-route dialogue.
- `tests/runtime_probe.lua` is an explicit developer tool for disposable stage-1 DeepSeek runs. Invoke through the named custom callback documented in TESTING.md. Its fixtures change coins/risk, add Car Battery, change floor and round-trip only this mod's run data. It is never invoked by ordinary gameplay. Input callbacks are removed on completion, failure or early exit; duplicate invocation is refused. The guard/exit paths have regression coverage.

## Remaining release checks

- Normal Repentance, local co-op, complete runs to Mom and the no-hit bonus in real combat remain to be checked. The Car Battery and positive-risk insufficient-funds cases above now have engine evidence; additional synergies remain open.
- Inspect all walking/shooting directions, hurt/death/flying frames, boss/stage transition portraits, skin-colour items, transformations and more D4 outcomes. The art is usable first-pass work, not final animation polish. Separate hair costumes may be needed to preserve the design through skin-changing items.
- Check the final chapter and approved caption with ordinary room transitions, and test all languages at different screen/HUD settings. Saved-state logic has regression coverage; only a subset of chapters has been observed in game.
- The pre-existing `stackable items v2` startup error (`resources/scripts/main.lua:154: table index is nil`) still occurs. Another existing mod's entities2 assertion and resource-cache shutdown warnings are unrelated. Do not change or disable unrelated mods without checking with the owner.
- Do not publish a Workshop release yet. Design-license/permission evidence and the full acceptance milestone in `GOALS.md` are still open.

## Next work

1. Fetch and review remote changes before editing. Reuse the existing source/runtime locations; do not create duplicate mod folders. Back up the installed previous version using the owner's local backup workflow before any overwrite.
2. Work through the release checks above, keeping actual observations separate from stub tests. Test muted and close owned game sessions afterward.
3. The next content ideas are Offline Cache, Gemini-chan and the neutral Queue Clerk in `STORY.md`. Implement one small feature at a time, with en/zh/ja text and a specific game test.
4. Work through branches/PRs and update this handoff with meaningful project-state changes. Keep source, GitHub and runtime assets synchronized.

## Boundaries and conventions

`main.lua` loads modules onto one shared mod object. Constitution's damage cancellation must register before risk damage bookkeeping. Run state belongs in `Risk.state`. Use seeded RNG; no network calls or telemetry during gameplay. Use content XML, not global vanilla-resource replacements.

Code/item icons are MIT. Character design/art terms are separate in `resources/ART_LICENSE.md`; credits include ZipZipPipe and 上善无形. No official logos. Enemies are infrastructure and abuse mechanisms, not populations. Keep notes, credentials, personal images, saves, machine paths and backup contents outside GitHub.

The owner supplied Bilibili video BV1yUJZ6WEpg as inspiration. Its public page/API could not be retrieved in this session, so no downloadable-file or licence inspection is claimed and no video pixels were used. Do not operate login dialogs or use credentials supplied in chat.

## Vibe Coding persistence follow-up (2026-10-23)

On the v0.5 baseline `1143ff1`, the floor-hit flag lived only in `player:GetData()`. A continuation recreates that data, incorrectly waiving the next floor's API bill. The follow-up stores flags by player slot in the existing shared `Risk.state` save and ignores startup `NEW_LEVEL` callbacks until the run state has loaded. It does not enable risk mechanics for DeepSeek-chan.

The new lifecycle regression fails on the baseline and passes with the fix. It covers fresh entity/module state after continue, separate player bills, no-hit floors, startup ordering and a new run. The smoke serializer stub now preserves nested tables without aliasing. All offline checks pass (42 Lua files and five stub suites). These are simulated lifecycle checks; real application-restart persistence and co-op roster changes still need engine verification.
