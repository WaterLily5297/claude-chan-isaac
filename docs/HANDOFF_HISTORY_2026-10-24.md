# Archived development history

This is a historical record, not the current status. Read HANDOFF.md first. Statements about main, installation, counts and unpublished work apply to their individual checkpoints.

# Handoff for Claude and contributors

Updated 2026-10-24 (Japan time), v0.5-dev. PR #5 is merged. Its implementation and the earlier v0.4 observations are separate evidence; passing CI does not establish in-game correctness.

## Native Thought attack candidate (2026-10-24)

This follow-up starts from synchronized PR #17 at `e8639cb`. It adds source adapters for player tears, single-hit lasers, released circle lasers, repeated-hit beams, flying knives and Dr. Fetus bombs. Use first update callbacks for laser/knife/bomb fields, rather than incomplete init data. Discrete attacks share the existing same-frame volley; repeated-hit beams (including Brimstone) and Ludovico use six-gameplay-update windows. This is the candidate's explicit balance rule, not a measured claim about engine tick order.

Continuous windows retain their remaining count and multiplier in the player's saved Rice record. Pause and duplicate updates do not refill them; continue restores only remaining time. Temporary entity damage factors are removed on room/exit cleanup, so save data never holds engine entity references or an unbounded multiplier. Flying knives keep one release multiplier until returning; idle contact and melee swings do not spend Thought. Ordinary bombs and indirect/familiar/enemy sources are excluded. Reflected-laser parents and child bombs cannot claim another primary attack.

Raw Swarm copies are marked as derived. A continuous copy follows the parent's temporary factor, never claims another payment, and loses an expired factor even when updated before its parent. Cleanup reaches a raw child that has not had its first update. 1M Context now snapshots the unboosted continuous baseline: its decay cannot accidentally store a temporary Thought boost forever. Ordinary released tears retain their resolved damage in flight. No costume, flag, scale, steering, collision or weapon-type replacement is introduced.

The native suite fails against the previous Rice module because its first beam receives no Thought. With the adapters it exercises real Rice, food, fork and Context modules using stubbed native entities; full checks pass 60 Lua files, five XML files, deterministic assets and fifteen stub suites. Scope and engine cases are in [NATIVE_THOUGHT.md](NATIVE_THOUGHT.md). Epic Fetus, melee, delayed bursts, familiar ownership, engine-written damage refreshes, cross-mod writer order and actual save/entity timing remain open. Neither this candidate nor Rice First is engine-accepted.

The owner still requests source work and offline validation only. No game launch/control, deployment, new art import or Workshop publication. Runtime remains the previously installed `aa8bd46`; main remains `1143ff1`. The remaining nine tainted forms, forty-nine additional items, Peak / Valley replacement and visual acceptance are still required. Verify publication and exact remote-tree equality separately from this local test record.

## Rice First source candidate (2026-10-24)

The owner now requests source work and offline validation only. Do not launch or control the game until that instruction changes. The last synchronized base is `a5011b9` on PR #16; this follow-up belongs on a separate branch/PR. Publication and exact remote-tree verification must be recorded independently of local checks. Main remains `1143ff1`; installed runtime remains the earlier `aa8bd46`. No deployment, new game test, art import or Workshop release is part of this change.

Normal DeepSeek now starts with one Rice Bowl (cap two), earns one per two distinct hostile-room clears, and spends a bowl on a short DROP release. A two-second intrinsic meal does not heal or change pocket charge; completing it grants full Thought and +0.15 speed for six gameplay seconds. Birthright reduces that meal to one second. Lunch Break remains the separate charged healing active. Both use the shared food timer; another bowl cannot start during a food lockout, and a food-pill refresh delays the intrinsic completion reward until the shared timer expires. Death cancels the pending reward. Movement and vulnerability remain native.

Versioned personal state in `Risk.state.deepseekRice` saves bowls, clear progress, Thought, speed time, pending completion and floor/room award identity. Idle time cannot farm bowls or pocket charges. Room re-entry, repeated clear callbacks and continue cannot pay the same room again. Observed character/slot/seed changes reset that player's economy; unchanged pointer/seed wrappers retain it. New runs and old saves without this schema start with one bowl. Corrupt counters reset the record. Timers do not advance twice in one game frame or while paused. No DeepSeek risk mechanism is restored.

Not firing builds 0–150 Thought, now without the old one-second minimum. The next same-frame player tear volley consumes it for a 1–2x multiplier, before LATE Swarm copies the resolved damage. Repeated callbacks for the same tear do not multiply twice. Native size, flags, flight and player sprites are untouched. Normal random Server Busy deletion and idle pocket recharging are removed; tainted forks/congestion remain legacy until the Peak / Valley migration. Dossier, HUD and the updated EID entries are English.

This is an intermediate gameplay implementation, not completed weapon compatibility. Same-frame volleys do not establish delayed-burst grouping; laser, knife, bomb, Epic Fetus, Ludovico/continuous-window and familiar accounting are still required. Meal input hooks cannot prove suppression of charged releases or programmatic attacks. Do not mark Rice First or all twenty-two forms engine-accepted. The remaining nine tainted forms, forty-nine additional items, art review and native costume acceptance are still open.

Offline evidence: `tests/content_test.lua . OLD_DEEPSEEK_MODULE` fails against `a5011b9` because a normal shot is cancelled. The new Rice suite uses real meal/input/state callbacks with detached Risk save snapshots; the updated Swarm suite checks resolved damage, unchanged native fields, player isolation and retained tainted behavior. Full checks pass: 58 Lua files, five XML files, deterministic assets and fourteen stub suites. These are source/stub results only.

## Meal lifecycle follow-up (2026-10-24)

After the synchronized `413d02d` candidate, the DeepSeek migration review found two shared prerequisites: Lunch Break repeated its healing under Car Battery, and food effects had no saved countdown or input lock. `scripts/meal_break.lua` now owns versioned per-player countdowns in `Risk.state.mealBreaks`. Lunch Break and Brb, Getting Food both start a ninety-gameplay-update meal. Lunch Break refuses another use during an existing meal without spending charge; a food pill can refresh the countdown, retaining its normal heal. Car Battery neither heals nor slows a second time.

Only the four directional shooting actions are overridden, returning the documented boolean or numeric type. The hot input callback performs no room/player scan and no state mutation. Movement, bombs, active/pocket use, DROP and menu input are untouched. Paused input is not overridden. Remaining time survives continue and room/floor transitions; new runs reset it. Duplicate update calls do not advance it twice; an observed dead player or replacement entity cannot pass the timer to a new co-op player. A meal does not shorten a longer existing FireDelay. No character-type changes, blindfold costumes, sprite replacements or REPENTOGON dependency are introduced.

The focused regression fails on `413d02d` at the repeated Car Battery heal, then passes the actual corrected item/pill/input callbacks and detached-save restart scenario. Full checks pass: 56 Lua files, five XML files, deterministic assets and thirteen stub suites. This proves the callback contract, not universal weapon suppression: an already emitted attack remains alive, a charged release may need engine-specific handling, and other mods reading Input directly bypass this hook. Verify the cases in TESTING.md before acceptance. The Rice / Peak-Valley replacement, attack accounting and the remaining expansion are still pending; current DeepSeek thought, busy and slacking mechanics are unchanged. Runtime is still `aa8bd46`; no installation or engine test occurred.

References: [input callback contract](https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html#mc_input_action), [dynamic shooting FAQ](https://wofsauge.github.io/IsaacDocs/rep/faq/Lua.html#how-do-i-prevent-the-player-from-shooting-arbitrarily). The vanilla FAQ's type-change workaround was not used because it would disturb the requested costume and character compatibility.

## Completed GitHub checkpoint before the meal follow-up

The owner's explicit request to synchronize GitHub supersedes the earlier GitHub input-conflict hold. The synchronization candidate collects the six local commits through `63a580b`: Claude usage persistence, head/carry alignment, Summary Stapler, community-meme designs, hurt-pose packing and DROP tap/hold compatibility. It is based on the published `01a0f2d` candidate and preserves main's `1143ff1` history. Earlier references below to unpublished source describe those work sessions, not the status of this synchronization candidate.

GitHub synchronization completed at `ea89932` on `codex/synchronized-candidate`, tracked by [PR #15](https://github.com/WaterLily5297/claude-chan-isaac/pull/15) above #14. All 197 tracked files have the same Git tree as the preserved local candidate `55a3a0f` (`0588d8d656c773fe7a055e21243098ce6b4f1f00`); after verification, the clean local working branch was aligned to the same remote commit. The authenticated web upload produced different commit IDs without changing file contents. [CI run 39979921392](https://github.com/WaterLily5297/claude-chan-isaac/actions/runs/39979921392) passed for that candidate. This follow-up updates only this synchronization record; its own remote head and checks must still be verified independently. Main remains `1143ff1`; source publication, CI status and runtime deployment are separate checkpoints. The installed runtime remains `aa8bd46`; this synchronization does not install or validate the game. The independent game-control interruption remains unresolved. No private saves, local backup contents or credentials are included.

## DROP tap/hold compatibility (2026-10-24)

GPT/Gemini previously switched mode on the press edge, including when the player intended to hold DROP to discard a trinket. Their shared observer now accepts a release 1–12 gameplay frames after an observed new press, with no action on press or after a longer hold. It reads IsActionPressed and never installs an input override or calls an inventory-drop function. Native input remains available; short-tap pocket cycling can still occur alongside the custom action and needs engine review.

Pending gestures are transient, keyed by player pointer with seed, character type and controller guards. They reset on new run/continue, exit, room/floor transitions, disabled controls, death, unsupported character, player loss and observed pause. The render callback cancels a paused gesture even with a hidden HUD, when gameplay updates may be stopped. A button already held when observation begins must be released and pressed again. Existing selected modes remain saved; no schema or balance change and no DeepSeek risk mechanism.

The real roster callback regression fails against 5f97401 because pressing DROP changes damage from 13.5 to 8.5 before release. The corrected module passes the release/hold, hidden-HUD pause, room boundary, continue and co-op cases. A focused helper suite covers timing boundaries, same-frame duplicates, fresh wrappers, seed/type/controller changes, death, disabled input and frame rollback. Full checks pass: 54 Lua files, five XML files, deterministic assets and twelve stub suites. These are offline input observations; actual keyboard/controller timing, dropping, pocket cycling and mod interoperability remain unverified. Source is unpublished and uninstalled.

## Hurt-pose packing correction

The thirteen registered skins now fit the shared hurt-pose cell into the measured vanilla 28x32 envelope, horizontally centered and ending at local y=55 relative to pivot (32,56). The earlier generic 58px fit enlarged the whole pose and placed it too low. Llama additionally used a source crop ending through its face; its hurt source now includes the existing hands and feet. This is deterministic packing of the same generated art, not a redraw, new source image or costume override.

The new `tools/verify_hurt_poses.py` failed on all thirteen previous atlases at d1c0daf. It now passes the measured envelope/anchor checks, exact byte rebuilds from the recorded source hashes and an outside-cell pixel comparison for all thirteen registered skins. The before/after engineering preview was inspected, including the Llama crop correction and one squash/stretch sample. Full standard checks pass: 52 Lua files, five XML files, deterministic assets and eleven stub suites. The optional Pillow review tool is separate from CI, which does not execute this geometry review.

Only pixels inside (128,192)-(192,256) changed. The inspected base animation also reuses that cell in Death, FallIn, JumpOut and DeathTeleport, so those transitions join Hit in pending engine acceptance. Other special cells are unchanged and may need separate size/pose repair. This fixes the source packing defect but does not prove item-costume interaction, engine interpolation or current runtime behavior. No runtime installation, GitHub update or game automation occurred.

## Community-meme design and public character references

The owner explicitly corrected the capability-based design: prioritize Claude bans/Dario frustration, DeepSeek rice and Liang Wenfeng/Wengu, and GPT perceived downgrade/Tibo reset. CHARACTER_GAMEPLAY.md revision 2 now defines twenty-two proposed loops with resources, input, drawbacks, persistence and Birthright targets. Other families remain researched candidates with confidence/access limits in COMMUNITY_MEME_RESEARCH.md. No claim of majority consensus, watched blocked videos or completed gameplay implementation.

EXPANSION_DESIGN.md tracks fifty additional collectibles, with rice assigned to DeepSeek and the Tibo reset item to GPT. Only Summary Stapler is implemented, locally at c7488d8; forty-nine further items and nine tainted forms are still designs. Existing dossiers must continue describing actual code until each family migration lands.

MOD_CHARACTER_REFERENCES.md pins three public template/tool repositories and records their license boundaries. They were read, not executed or imported. Local vanilla Hit frames use a 64px complete-pose cell at (128,192), pivot (32,56), with squash/stretch. The previous 58px fit matched the owner's oversized-head report; the later source correction is recorded above. Engine acceptance is still pending. Earlier head/carry fixes did not cover this cell.

Latest fetched main remains 1143ff1. Local work is ahead of the last verified remote candidate 01a0f2d and installed runtime aa8bd46. No runtime overwrite, new backup, GitHub mutation, game test or Workshop publication occurred during this research. Existing game-control and GitHub input-conflict holds remain unresolved; do not bypass them with a different control channel.

## Summary Stapler candidate

Summary Stapler is the first of the requested fifty additional collectibles: four charges, nearest twelve ordinary hostile projectiles within 120 units, one native speed-6 tear at multiplier 1 + count/4. Empty use and Car Battery do not discharge. The damage multiplier is supplied at FireTear creation; resolved flags, damage, scale and color are not overwritten afterward. Existing character limits/forks apply, including possible DeepSeek cancellation after defensive absorption. The icon extends the established geometric item-art system.

This brings the local source to eighteen collectibles and thirteen forms. Forty-nine further collectibles and nine tainted forms remain unimplemented. These changes are unpublished and uninstalled. No current engine acceptance or Workshop release.

Offline validation passes: 52 Lua files, five XML files, deterministic assets and eleven stub suites. New cases cover empty use, Car Battery, radius/count boundaries, deterministic nearest selection, special/friendly/source-less exclusion, co-op ownership and native-shot handoff. An integration fixture invokes the real Claude, DeepSeek and Swarm callbacks after the modeled native multiplier, preserving limits, cancellation and fork inheritance. It does not establish engine callback timing or actual projectile flags.

## Costume alignment and expanded scope

Latest scope: eleven normal and eleven tainted forms, richer mechanics and fifty additional collectibles. The scope remains in progress as recorded above. The owner requires vanilla item appearance compatibility; see [COSTUME_COMPATIBILITY.md](COSTUME_COMPATIBILITY.md).

The nine added normal skins now share the reviewed head envelope/baseline and a head-only carry cell. This corrects packing geometry, not proven facial-overlay alignment. Original-four final sheets, body cells and unrelated poses are unchanged. The candidate builds on the unpublished save fix; GitHub and runtime have not received either update. Older records do not establish current synchronization.

Validation: all thirteen atlases rebuild byte-for-byte; original-four files are unchanged and the nine other sheets differ only in the seven head cells and carry-head region. The offline front/carry comparison visibly removes the oversized carry character. Full checks pass: 50 Lua files, five XML files, assets and ten stub suites. Some hair/hat silhouettes still obscure small bodies; anatomy, asymmetry, clothing and costume occlusion remain art-review work. No runtime files were modified.

## Normal Claude usage persistence

Normal Claude's usage and five-second penalty previously lived only in `GetData`, allowing save/continue to discard them. They now live in `Risk.state.claudeUsage`, keyed by player slot. `ccUsage` remains an alias to the same saved table so Compact, Banked Reset and Swarm keep their existing behavior. The game-start callback binds aliases after Risk loads state and before the first shot/item use. New runs clear saved meters; old saves without a meter start at zero. Inactive callbacks no longer mutate usage. Tainted weekly accounting is unchanged.

The new process-style regression fails on `01a0f2d` with "continue must not erase an active usage limit". After the fix it covers separate co-op meters, remaining penalty frames, wrapper identity, immediate item-use/save, character-type changes, penalty expiry, drain cadence, fresh runs and old saves. Existing Swarm coverage still verifies double billing and limited child damage. Full offline checks pass: 50 Lua files, five XML files, assets and ten stub suites. SaveData/LoadData are exercised with detached snapshot serialization; actual engine JSON, restart, player-slot stability, Clicker and twin/subplayer behavior remain acceptance work.

The [Entity.GetData documentation](https://wofsauge.github.io/IsaacDocs/rep/Entity.html#getdata) confirms that entity data does not survive exiting to the menu. This change preserves game-frame countdowns, not real-world elapsed time, and does not change weapon coverage or claim engine acceptance.

## Original four-character movement polish

The owner requested the original characters receive the same visual care as the expanded roster. Normal and tainted Claude/DeepSeek now use newly generated head, walking and carrying parts that retain the selected portrait identities. Profiles face right, rear heads contain hair rather than faces, firing has a separate expression, and carrying bodies have raised arms. The carry-head cell now contains only a head rather than a complete character.

`tools/pack_original_movement.py` mechanically packs the four reviewed 1536x1024 sources. `docs/original-movement-prompts.json` records the exact built-in image-tool prompts; `docs/roster-art-manifest.json` records source and final hashes. Source images are preserved in the local deliverable `original-movement-sources/`. Rebuilding all thirteen atlases requires `pack_selected_sprites.py SOURCE --movement-source MOVEMENT_SOURCE`, so the earlier importer cannot silently discard this polish.

The owned game's bundled extractor supplied the base player animation layout into a local scratch directory. No vanilla textures or extracted animation files are committed. The self-contained review page generated by `tools/preview_original_movement.py OUTPUT --before-ref 8530b5a` uses the observed crop positions and pivots for a simplified movement comparison. It is offline visual evidence only: no interpolation, item overlays, engine input or current runtime acceptance. Special poses and effects remain unchanged; shared front/back body animation, carry overlays, flying, hurt/death and costume compatibility remain pending. Portraits, mechanics and other nine families are unchanged.

## Forked tear property inheritance follow-up

At `aa8bd46`, tainted DeepSeek forks and Subagent Swarm children copied damage/color but omitted the natural tear's effect flags, scale, flight arc and effect parameters. Both paths now use a shared `tear_fork` helper to copy `TearFlags`, `Scale`, `Height`, `FallingSpeed`, `FallingAcceleration`, `HomingFriction` and `KnockbackMultiplier` alongside the existing half damage and color. `ResetSpriteScale` updates the child animation for its copied size. Spawn ownership, fan angles, raw spawning and callback order remain unchanged; child creation does not call `FireTear` recursively.

The property regression fails on `aa8bd46` with "fork loses native tear effects" and passes after the fix. It covers a vanilla Swarm holder, tainted DeepSeek with/without Swarm, normal Deep Think plus Swarm, cancellation, parent preservation and the existing four-character limits/ownership cases. Full offline checks pass: 49 Lua files, five XML files, asset checks and nine stub suites. This is field-level stub evidence. Actual homing, piercing, spectral, explosive, splitting, orbiting and controlled tear behavior remains unverified. Lasers, knives, bombs, familiar attribution and private third-party tear data are still separate compatibility work. See [EntityTear](https://wofsauge.github.io/IsaacDocs/rep/EntityTear.html) for the copied fields.

The latest engine launch attempt was interrupted by the owner's physical Escape key. A subsequent read-only process check found the installed game running, but no menu, character or gameplay observation was made. Do not record an engine pass or assume the game is closed. This follow-up has not been deployed; close the game and create a fresh verified backup of the actually installed `aa8bd46` allowlist before replacing runtime files.

## Roster callback identity follow-up

The roster expansion at `0573b2f` keyed transient charge by weak Lua object references. Different wrappers for the same engine player could split Grok momentum, Mistral tailwind and GLM's same-frame active-use guard. Transient records now use `GetPtrHash`, with initialization-seed and observed roster-type checks for pointer reuse and character changes. They retain no entity references and reset on game start and exit. Persistent mode/progress storage and the original four character modules are unchanged.

The new multi-wrapper Grok regression fails on `0573b2f` (10 damage instead of 12.5) and passes with this fix. Offline coverage also checks cache/HUD agreement, garbage collection, Mistral's 60-update boundary, GLM duplicate callbacks and Car Battery, separate co-op players, room/run resets, reused pointers and observed roster-type changes. The full suite passes: 48 Lua files, five XML files, asset checks and nine stub suites. This is not an engine reproduction or gameplay acceptance. In-game charge stability, active-item interactions, character changes and co-op remain pending. See [GetPtrHash API documentation](https://wofsauge.github.io/IsaacDocs/rep/GlobalFunctions.html#getptrhash).

## Model roster and portrait expansion: engine acceptance pending

The owner's latest request prioritizes redesigned portraits and playable mainstream model families. The expansion now covers eleven normal families plus the existing two tainted characters: Claude, DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi, and GLM. The nine additions have normal forms only. All new code, documentation and UI text is English as requested. See [MODEL_ROSTER.md](MODEL_ROSTER.md) for the implemented mechanics, limits and evidence boundaries.

The owner confirmed exactly eleven families, selected ZipZipPipe's AI-personification designs for normal portraits, and retained the generated tainted designs with slightly deeper colors. Eleven source illustrations were hash-checked against the public source catalog and adapted with the built-in image tool for transparency and logo replacement. These are edited derivatives, not untouched author originals. All thirteen selected portraits now feed selection busts, stage portraits and clear-room MAP dossiers. Source URLs, input hashes and exact edit prompts are in `portrait-prompts.json` and `tainted-portrait-prompts.json`.

All thirteen gameplay skins have been regenerated using the selected ZipZipPipe portraits as identity references. Hair, clothing and accessories now correspond to those portraits. `tools/pack_selected_sprites.py` packs reviewed source frames into 512x512 engine atlases with binary alpha and transparent gutters. Gemini body-frame repair replaces accidental light orbs with clothed headless bodies. The original normal and tainted Claude/DeepSeek sheets were also redrawn at the owner's request; tainted forms retain the approved crimson/black-gold and deep teal/white designs. Directional accuracy, alternate arm poses, lower special poses and engine animation acceptance remain unfinished; identity alignment is not animation acceptance. The discarded fifteen-family draft is preserved locally as commit `2909e8a` on `codex/model-roster-generated-draft`; it was not installed or published.

The candidate incorporates fixes #6-#10. Offline checks pass: 48 Lua files, five content XML files, eleven-family asset registration and nine stub suites. Gameplay, save/restart, all poses, weapons and co-op remain unverified in the engine. The last recorded engine observation remains startup of the earlier four-fix build `204861f`. Installation of this candidate is tracked separately through a private hash-verified deployment record; it does not establish gameplay acceptance. No Workshop publication or independent reviewer approval is claimed.

Artist-source access limitation: Bilibili returned HTTP 412 during direct checking. The source catalog records the author's sharing/recreation statement, and the existing project records non-commercial design terms. Preserve that distinction and do not relabel all art as MIT or a blanket Creative Commons license.

For the first installation, make and hash-verify a fresh backup of the prior `204861f` application files using the owner's private backup workflow. For later updates, back up the exact currently installed commit. Do not overwrite saves, another mod or the preserved `215df90` drafts. Record the exact installed candidate commit separately. Fetch main before publishing; main was still `1143ff1` when this work began.

## Earlier integration candidate: offline checks only

This local candidate combines tainted reaction fallback protection (#6), Vibe Coding bill persistence (#7), Overloaded run reset (#8), Swarm shot resolution (#9), and Opus wallet-cache correction (#10), all based on main `1143ff1`. The source changes merge together; overlapping documentation additions were retained. The combined suite passes 45 Lua syntax checks, five XML files, deterministic asset checks and all eight stub suites. Individual PR CI results do not constitute CI or engine evidence for this combined tree. All gameplay acceptance rows remain pending. No new item or character content is included, and no separate contributor has reviewed these follow-up fixes.

Before the roster request, the four-fix candidate `204861f` was installed and reached the Repentance+ title screen. The five-fix candidate had not been installed or launched. Direct keyboard input, the system on-screen keyboard, and temporary windowed/focus-pause settings did not establish controlled entry into a run. The game was closed and temporary preferences restored. A working game-control path remains required before recording character, save/continue, animation, weapon or co-op acceptance. The later owner request authorizes development of new content while this evidence gap remains open.

The owner now also permits direct work on main. Keep changes reviewable and preserve collaborators' work; this permission does not change the backup, engine-evidence or Workshop release gates.

## Tainted reaction-pack compatibility follow-up

- Reactions Port Pack fallback protection now includes both normal and both tainted characters. Unknown tainted characters previously received the pack's default Isaac reaction costume.
- Existing explicit character support, vanilla entries and default costumes are preserved. No other mod's files or configuration are changed.
- A focused stub regression failed on the previous implementation and passes with the fix; the complete `bash tools/check.sh` suite also passes (41 Lua files, XML/assets and four stub suites).
- This fix still needs a game check of both tainted characters during a reaction animation. It has not been independently reviewed or merged. Do not infer a visual pass from the stub regression.

## v0.5-dev (Claude session, 2026-10-23) - not yet run in game

### Overloaded run-lifecycle follow-up

The v0.5 baseline keeps the outage deadline in module-local state, while the game frame counter resets for a new run. Quitting during an outage could therefore weaken tears in a later run for much longer than two seconds. The follow-up clears the deadline on game start and exit. A focused stub test reproduces the failure on `1143ff1` and passes after the fix, covering the 60-frame boundary, dropping the trinket, a new run and continue. The full offline suite passes (42 Lua files, five stub suites). Actual engine verification remains pending; this adds no new gameplay content and does not change the intended outage duration.

### Subagent Swarm shot-resolution follow-up

The baseline registers Swarm before the character firing callbacks. It creates children before DeepSeek can cancel a busy shot and before Claude applies limited damage, allowing the children to survive or bypass the parent's penalty. Swarm now keeps its existing early usage billing but creates children at `CallbackPriority.LATE`, skipping removed tears and copying the damage/color after this mod's normal-priority character callbacks. A focused regression fails on `1143ff1` and passes with the fix for normal/tainted busy cancellation, Deep Think, both Claude limits, the additive fork count and player isolation. Full offline checks pass (42 Lua files, five stub suites). This does not add laser/knife/bomb support or complete tear-flag inheritance. Engine verification, including priority/removal behavior and interaction with other mods' late callbacks, remains pending.

### Opus Mode wallet-cache follow-up

Opus Mode previously calculated cached damage from the last player-update notification flag. A cache evaluation before that update could use the wrong multiplier after acquisition, a coin change, or reacquisition following a reroll. Damage now reads the player's current coin count directly; billing and notification transitions are unchanged. The focused regression fails on main `1143ff1` and passes with the fix, covering empty and funded wallets, stale flags, item removal/reacquisition and separate players. These are stub checks, not evidence of actual engine callback timing. In-game acquisition, coin pickup/spending, D4 and continue still require validation. The previously prepared combined fixes #6-#9 have reached the Repentance+ title screen, but gameplay input has not been established; startup does not satisfy the four-character acceptance gate.

Owner requests: normal and tainted versions of both characters; DeepSeek-chan is unrelated to IPs, so her design was revisited; fix the sprites; fix bugs; item/character changes from X/Bilibili memes. Branch `claude/meme-update`.

- **DeepSeek-chan redesign.** `Risk:IsActive()` is false when every player is DeepSeek-chan (normal or tainted): risk reads 0, never rises, no IP roll, no ban story, HUD shows 直连. In co-op with anyone else the system runs normally. Her own mechanics: Deep Think, Server busy, pocket **Lunch Break**. The Support Ticket is no longer her pocket item (still a shop item).
- **Tainted characters** via `players.xml` `bSkinParent`; IDs `Constants.Player.CLAUDE_CHAN_B` / `DEEPSEEK_CHAN_B` (`GetPlayerTypeByName(name, true)`). Tainted Claude-chan: weekly tear quota (`Risk.state.weeklyUsed`), pocket Banked Reset. Tainted DeepSeek-chan: forked tears, busier servers. Research (Isaac Blueprints, tainted-unlock tutorial): without REPENTOGON there is no way to lock a modded tainted character in the menu, so they should be selectable immediately; an unlock would need an init-time `ChangePlayerType` swap back to the normal character plus a saved flag. The tainted toggle (E / RB) may still require a save with vanilla tainted characters unlocked. Not yet observed in game.
- **Claude-chan account age** (`Risk.state.accountAge`).
- **Sprites:** cell spill, cut-off side head and DeepSeek's walking bodies fixed (`tools/fix_character_cells.py`); tainted art is a recolour (`tools/make_tainted_art.py`). Everything the friend observed in game below was on the *pre-fix* atlases.
- **Items:** 529 Overloaded lets you shoot at 50% during outages; Vibe Coding waives the bill after a no-hit floor.
- **Bug fixes:** banned Relay Slimes don't split; Thinking Cleared drains only on first visits; The Constitution ignores self-inflicted damage.
- **Runtime probe** now needs a Claude-chan run and swaps a Support Ticket into her pocket. Its recorded passes below were on the v0.4 DeepSeek build.
- Stub tests cover all of the above (`bash tools/check.sh`). In-game checks: `docs/TESTING.md` "v0.5 focused checks".

## Historical v0.4 implementation (superseded where noted above)

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

## Historical v0.4 actual validation (not a v0.5 pass)

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

- Normal Repentance, local co-op and complete runs to Mom remain to be checked. The former DeepSeek no-hit risk bonus was removed in v0.5 and must not be restored to satisfy an obsolete fixture. The Car Battery and positive-risk insufficient-funds cases above have historical v0.4 engine evidence; repeat them on v0.5.
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
