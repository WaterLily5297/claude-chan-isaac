# In-game test checklist

## Native Thought adapters (source candidate; no engine acceptance)

Follow [NATIVE_THOUGHT.md](NATIVE_THOUGHT.md) for the current adapter table and weapon-specific engine matrix. The owner currently permits source/offline work only. Ordinary tears, single-hit/released-ring lasers, repeated-hit beams, flying knives and Dr. Fetus now have source paths; Ludovico and repeated-hit beams use six-update windows. The earlier Rice checklist below describes the initial tear-only candidate. Epic Fetus, melee, delayed bursts and familiar attribution remain unimplemented adapter work.

Verify actual callback order, damage refresh behavior, charged releases during food lockout, continuous fork update order, 1M Context decay, pause and mid-window save/continue before accepting any native weapon case. Source field assertions do not establish damage dealt, player appearance, steering or engine serialization. This follow-up does not pass the costume matrix.

## Tainted DeepSeek Peak / Valley (source candidate; engine acceptance pending)

Start a new run: HUD reads `Compute 12/24  Valley 12.0s  Forks On`. In a hostile room the timer counts down and switches to Peak after twelve seconds, then back. In a cleared room and on the pause menu it must stop. Each new floor starts in Valley with the same Compute. In Valley, stop firing during combat: Compute rises by three per second up to 24 (32 with Birthright). Waiting in a cleared room must not add Compute.

Fire ordinary tears: each paid volley adds two half-damage forks at ±12° and costs 2 in Valley or 4 in Peak. With 20/20, Mutant Spider or Monstro's Lung, check one payment per same-frame volley and judge whether forking every pellet is too strong. Below the cost, only the main tear fires and no tear ever disappears. Tap/release DROP toggles `Saving`; a second tap inside one second is ignored, and holding DROP keeps native trinket dropping. Test pocket cycling with a pocket item.

Save/quit/continue mid-phase and in Saving mode: Compute, phase, remaining time and mode must return unchanged; the toggle cooldown intentionally resets. Test a new run, character change (Clicker), co-op with two tainted DeepSeeks (separate Compute) and death. Brimstone, Technology, knife, Dr. Fetus and Ludovico builds should attack normally with no forks and no Compute cost. Stub coverage is `tests/deepseek_peak_test.lua` and `tests/swarm_resolution_test.lua`; no engine pass is recorded.

## Rice First (source candidate; engine acceptance pending)

Current owner constraint: source work and offline validation only. Keep this engine checklist pending until the owner resumes game testing.

As normal DeepSeek, verify one starting bowl, a two-bowl cap and one bowl per two newly cleared hostile rooms. Re-enter and repopulate a completed room: no extra reward. Test bosses, challenge waves, alternate floors, mirror rooms, two-player co-op and dead/revived players. Wait in an empty room: Thought can fill, but neither bowls nor pocket charge should increase.

Tap/release DROP: spend one bowl and lock directional shooting for two seconds, retaining movement and vulnerability. Verify no healing or pocket-charge change. Completion grants full Thought and +0.15 speed for six seconds. Birthright shortens the intrinsic meal to one second. Holding DROP must keep native dropping without spending rice; short pocket cycling may still happen and requires review. Test pause, disabled controls, transition and death during gestures and meals. A shared Lunch Break lockout blocks intrinsic meals; a food pill extends the shared countdown without a second reward.

Save/quit/restart during a meal, during the speed bonus, at half Thought and after the first of two clears. Verify each player's remaining resources/time and the single reward, including a new run, old save, character change and joining/leaving co-op. Verify speed cache recalculation after expiry and death. Inspect the Thought/Rice HUD alongside existing co-op HUDs and the MAP dossier.

With ordinary tears, charge Thought while moving, then fire four-eye/20/20/Monstro volleys: all same-frame pellets should share the multiplier. Swarm should copy half of the resolved parent damage without a second payment. Native tear size, flags, color and flight must remain intact; normal shots no longer randomly disappear. Test a shot-producing active and two players firing on the same frame.

Delayed burst, Brimstone, Technology, Mom's Knife, Dr. Fetus, Epic Fetus, Ludovico, persistent lasers and familiar ownership still need attack adapters; do not mark those cases passed from ordinary-tear tests. In particular, a persistent tear is not yet divided into six-frame windows. Full native-weapon compatibility remains a required next implementation step, not a claimed result. Tainted DeepSeek now uses Peak / Valley Compute; see its own section below.

Offline coverage is in `tests/deepseek_rice_test.lua`, `tests/content_test.lua` and `tests/swarm_resolution_test.lua`. The real modules are invoked with stubbed engine entities and detached Risk snapshots. This does not establish actual engine JSON, callback timing, analog controls, item visuals or save-slot identity.

## Shared food countdown (engine acceptance pending)

Use Lunch Break as normal DeepSeek and as a vanilla character, then use Brb, Getting Food. Verify the three-second directional shooting lock while movement, vulnerability, bombs, active/pocket use and DROP remain available. Use Car Battery: one heal, one slowdown, one meal only. A second Lunch Break use during a meal must preserve charge and grant no extra heal; a food pill can refresh the meal. Verify a longer existing shooting cooldown is not shortened.

Save/quit/restart at one second and just before expiry. Each player must retain only their own remaining time; pause and menu time must not advance it. Cross rooms/floors, die/revive, change character, leave/join co-op and test two players sharing a controller. No permanent lock, wrong-owner lock or forgotten timer is acceptable. Test keyboard and analog aiming separately, including pause-menu confirmation.

Repeat while charging Brimstone, Technology X, Monstro's Lung and Chocolate Milk, and with Mom's Knife, Dr. Fetus, Epic Fetus, continuous lasers, Ludovico, Marked, familiars and a shot-producing active. Record whether a charged release leaks through, whether existing controlled attacks remain steerable and whether another input mod bypasses or overrides the hook. Existing attacks are not deleted and programmatic FireTear calls are not intercepted. These cases are deliberately not passed by the input stub. Evaluate the intended distinction between blocking new normal shots and preserving already-emitted/active-item attacks before accepting the Rice ability that now uses this service.

Offline `tests/meal_break_test.lua` uses the real item/pill/input modules plus detached save snapshots. It covers typed hook returns, non-shooting pass-through, Car Battery, overlap, exact countdown expiry, duplicate updates, pause, continue, migration and player identity. The old item module from `413d02d` fails its first Car Battery assertion. Actual engine JSON, charged-release timing and co-op slot identity remain unverified.

## DROP tap/hold compatibility (engine acceptance pending)

For GPT and Gemini separately, test keyboard and controller: a short press must leave mode unchanged while down and switch once on release; a long hold must drop the intended vanilla trinket/pocket pickup without switching. Repeat when holding multiple pocket items, including native short-tap cycling. The observer does not suppress that cycling, so record any undesirable double action rather than marking it passed from Lua coverage.

Test releases after pause, hidden-HUD pause, a big-book animation, disabled controls, room/floor transition, death/revive, save/quit/continue, controller reassignment and character change. No interrupted gesture may switch mode. Once controls return, release and make a fresh tap to verify recovery. Repeat with two players on separate controllers, then supported shared-controller/twin arrangements and other input mods. Verify the chosen mode persists across continue but an unfinished press does not. The 1–12-frame threshold is a source rule, not a measured vanilla drop threshold; assess actual feel and latency before acceptance.

The helper and real roster callback tests cover release timing, long holds, interruption cancellation, fresh wrappers and player/controller isolation. The updated roster regression fails against the previous model_roster.lua at 5f97401 before its release assertion, then passes with this correction. No native input hooks or inventory-drop calls are installed. These facts do not prove native dropping or controller behavior in the engine.

## Hurt-pose correction (source fixed, engine acceptance pending)

The owner reports all characters developing an oversized head after damage. Exact runtime revision and item setup were not captured. Source now corrects the measured shared-cell envelope/anchor in all thirteen skins and restores Llama's full source pose. No current-engine reproduction or acceptance is claimed. Compare every form with vanilla Isaac at the same scale, then repeat real damage with face costumes, flight, size items and transformations. Capture pre-hit, all Hit frames and recovery. Check pivot stability, full-body pose, costume retention and no stale color/scale. Also test Death, FallIn, JumpOut and DeathTeleport, which reuse this cell. Repeat without and with Reactions Port Pack. Historical v0.4 evidence does not pass this case.

Offline reproduction requires Pillow plus the recorded generated sources, kept outside the repository. Run `python tools/verify_hurt_poses.py SOURCE_DIRECTORY MOVEMENT_SOURCE_DIRECTORY REVIEW_OUTPUT_DIRECTORY --before-ref d1c0daf`. This fails the geometry contract on the old thirteen skins and passes the corrected ones, verifying source/packed hashes, exact atlas rebuilding and pixel equality outside the shared hurt cell. It writes an engineering comparison and JSON evidence; it neither installs files nor runs the game. CI's standard asset checks do not execute this optional source-dependent review.

## Summary Stapler acceptance (pending)

Give Summary Stapler in a disposable run. Verify four room charges, empty use preserving charge, nearest-first absorption capped at twelve within 120 units, and exclusion of special-flag/variant, friendly, player/familiar, dead or source-less projectiles. Aim diagonally and use without shooting; check the speed-6 native tear and base damage multiplier 1 + count/4. Car Battery must neither absorb a second batch nor fire again. Verify co-op ownership and both active slots.

Test homing, piercing, spectral, explosive, split/orbit/controlled tear items and Tractor Beam. Brimstone, knives, lasers and bombs must remain the primary weapon; the active emits a separate tear and must not replace their appearance. Check native callback timing with Swarm, Claude's usage/limited damage, tainted quota, Deep Think, and DeepSeek cancellation/forks. Successful absorption consumes charge even if character logic cancels the retaliation. Test save/restart with the item charged and discharged, room transition, reroll/removal and the costume matrix. Special modded projectiles that look ordinary may need explicit compatibility rules; generic filtering does not prove every other mod is safe.

## Vanilla item appearance acceptance (pending)

Run the per-form matrix in [COSTUME_COMPATIBILITY.md](COSTUME_COMPATIBILITY.md): isolated items, mixed pickup orders, flight, scale, transformations, removal, reroll, restart and co-op/type changes. The nine added normal skins have an offline head/carry alignment correction; this is not engine acceptance. Existing four-character art and the planned nine tainted forms require the same matrix. Record screenshots and exact versions; Lua tests and texture dimensions cannot establish visual compatibility.

## Normal Claude usage save acceptance (pending)

As normal Claude, save with a partially filled meter, close the process, restart and continue. The meter must resume rather than clear. Repeat during the five-second limited-damage interval and confirm the remaining game-frame countdown and 40% damage. Repeat with two Claude players at different usage levels, with Swarm (including the first continued shot), after Compact, and immediately after Banked Reset. Continue must preserve the item changes and keep players independent. Verify a fresh run resets both meters and an older save without usage fields loads safely. Check Clicker away/back, co-op join/leave, and supported twin/subplayer forms separately; the slot-keyed stub does not prove their engine identity behavior. The penalty expires through gameplay frames; offline wall-clock time is not credited.

## Original character movement revision (engine acceptance pending)

Inspect normal and tainted Claude/DeepSeek at actual gameplay scale. Check idle and firing faces in all directions, mirrored left profiles, rear silhouettes, body/head attachment during walking, and carrying an item while walking. Confirm the carry-head frame does not produce a second body. Test body visibility against dark rooms and with costumes. Compare save/continue appearance, then inspect retained flying, hurt, death and special poses for style and alignment differences. The offline preview and atlas checks do not complete these tests.

## Fork property inheritance acceptance (pending)

Test tainted DeepSeek alone, Isaac holding Subagent Swarm, tainted DeepSeek with Swarm, and normal DeepSeek's fully charged Deep Think with Swarm. Compare the natural tear and its children using Spoon Bender, Cupid's Arrow, Ouija Board, My Reflection, Ipecac and Cricket's Body. Check actual tracking, piercing, wall passage, trajectory/range, explosions and bounded splitting; copied flags alone do not prove those effects work in the engine. Deep Think children should display the boosted size and retain half the resolved parent damage. No DeepSeek shot is randomly removed any longer.

Also test Tiny Planet, Anti-Gravity, Eye of the Occult and Ludovico separately: these flags can depend on engine-managed motion or controller state that is not recreated by copying fields. Record unsupported behavior explicitly rather than claiming universal tear compatibility. Recheck both Claude limits, two-player ownership, split-shot growth, other mods' tear-init callbacks and frame time under high fire rate. The new regression verifies property transfer and existing spawn counts only; it provides no FPS or engine-pass evidence.

## Eleven-family expansion acceptance (all pending)

Offline coverage is described in `MODEL_ROSTER.md`; it does not tick these boxes.

- Select all eleven normal families and both existing tainted characters. Check the correct name, bust, stage portrait and full MAP dossier. No missing textures or duplicate menu entries.
- Inspect every new skin facing front, right, rear and left, while walking, firing, holding an item, flying, hurt and dead. Check for clipping, stray neighboring pixels, incorrect back views and doubled heads. Alternate arm poses remain provisional.
- For GPT and Gemini, tap DROP through both modes, then save/quit/close/restart/continue. The mode must persist. Check the original DROP behavior with held trinkets and controller input.
- For Grok and Mistral, reach maximum movement/firing charge, stop, change rooms, and start a new run. Temporary charge must reset and stay bounded.
- For Qwen and Kimi, build progress, take a hit, save and continue before clearing. The room must not count as flawless. The Constitution's refused hit must not break progress.
- For Llama and Doubao, reach the reward threshold, save/continue, and revisit the same room. Rewards must not duplicate. Include dead players, two holders and a non-holder in co-op.
- For GLM, use the pocket Book of Secrets, Car Battery, a zero-charge item and an item with a custom use callback. Links must stay at three or fewer and reset when leaving the room.
- For callback identity, compare Grok's HUD momentum with its damage increase through repeated cache refreshes; confirm Mistral gains spectral tears at full wind and loses them when stopping. Repeat with two players and character-changing effects. For GLM, duplicate use callbacks in one frame must add only one link per player while separate players can each gain a link. Distinct-wrapper stub coverage passes; these engine checks remain pending.
- Check Brimstone, Technology, Mom's Knife, Dr. Fetus, Epic Fetus, multishot, familiars, D4, transformations, costume-changing items, EID and Reactions Port Pack. Cache-based code alone is not compatibility evidence.
- Repeat in base Repentance and Repentance+, finish full runs, then close the game. Do not publish to Workshop before acceptance and art-permission review.

Offline tests, historical v0.4 engine observations, and v0.5 runtime validation are separate evidence. See HANDOFF.md for their scope. The checks below are acceptance targets, not claims that they passed.

## Setup

1. Put the folder in `…/The Binding of Isaac Rebirth/mods/claude-chan-isaac/`.
2. `options.ini` → `EnableDebugConsole=1`.
3. Start the game, open the mods menu and check **Claude-chan: Risk Control** is enabled.
4. In a run, press `~`. **Any red text in the console is an error. Copy it exactly and send it to Claude.**

Useful console commands: `giveitem <name>` for items, `giveitem t<name>` for trinkets (e.g. `giveitem t529 Overloaded`), `stage 2` to change floor, `debug 3` for god mode, `luamod claude-chan-isaac` to reload after a fix.

## Checklist

| # | Test | Expected | OK? |
|---|---|---|---|
| 1 | Character select | Claude-chan is listed with the custom character artwork | |
| 2 | Start as Claude-chan | Ban Hammer in the pocket slot; orange tears; IP + Risk + Usage on the bottom-left | |
| 3 | Shoot non-stop for ~20 s | "Usage limit reached", grey weak tears for 5 s, then meter resets | |
| 4 | `stage 2`, `stage 3` | New IP each floor, risk goes up | |
| 5 | Get hit / clear a room without a hit | Risk +1 / −1 | |
| 6 | Risk ≥ 40, kill enemies | Some come back red, only once each | |
| 6b | Risk ≥ 30 (`stage 4`+), enter new rooms | Sometimes a big green Clotty; killing it gives 2 smaller, then 2 smaller each again (7 total) | |
| 7 | Use Ban Hammer in a room with many enemies | Non-boss enemies die, "BANNED", none come back; sometimes "misban(s) - appeal pending" and risk goes up | |
| 8 | `giveitem Residential IP` | Risk −30 once | |
| 9 | `giveitem Compact`, use it | Enemy shots vanish, enemies confused; Claude-chan usage +50 | |
| 10 | `giveitem You're Absolutely Right!`, get hit | That enemy becomes friendly for 5 s | |
| 11 | `giveitem 9.9 Yuan Relay`, change rooms | Sometimes "Model quietly downgraded"; risk +15 once | |
| 12 | `giveitem Ultrathink`, use 3× in one room | think / megathink / ultrathink, damage goes up; resets next room | |
| 13 | `giveitem 1M Context` | Long range; far tears do less damage | |
| 14 | `giveitem t529 Overloaded`, fight | Every 20 s enemies freeze for 2 s; you can still shoot, but those tears are weaker ("coding manually") | |
| 15 | `giveitem Silent Update`, change floors | "Changelog: no changes", damage changes | |
| 16 | `giveitem --dangerously-skip-permissions` | Locked doors/chests open; sometimes "rm -rf" deletes pickups | |
| 17 | `giveitem All Tests Passing`, use with enemies alive | Doors open, enemies stay. **Do the doors stay open?** | |
| 18 | `giveitem tHardcoded Output` | Tears always deal 3.5 | |
| 18b | `giveitem tThinking Cleared`, change rooms | Damage +1; active item loses a charge per room | |
| 18c | `giveitem Vibe Coding`, shoot, `stage 2` with coins | Tears get mixed effects, a few fly backwards. Got hit on the floor: coins −25% on the new floor. No hit: "Made no mistakes", no bill | |
| 18d | As Claude-chan, hit the usage limit, then `giveitem Banked Reset` and use it | Usage meter back to 0, risk −25 | |
| 18e | `giveitem Subagent Swarm`, shoot | 3 tears per shot in a fan; Claude-chan's meter fills about twice as fast | |
| 18f | Console `giveitem p<n>` is awkward for modded pills; instead find pills in a run, or check they appear in the pill pool | "Cat-girl Mode" doubles fire rate at lower damage for the room; "Brb, Getting Food" heals and pauses shooting | |
| 18g | `giveitem tWelcome Notice`, use Ban Hammer | "WELCOME!", regular enemies become allies and stay allies | |
| 18h | `giveitem tStatus Page` | HUD says "Risk: all systems operational"; risk still rises, a bit slower | |
| 18i | `giveitem The Constitution`, take 2 hits on one floor | +1 soul heart; first hit shows "I can't help with that" and does no damage or risk; second hit lands | |
| 18j | `giveitem Ultrathink`, `giveitem Compact`, `giveitem Vibe Coding` | "Agentic!" with a sound; you can fly over rocks and pits; tears faster | |
| 18k | Push risk to 90+ (many floors / misbans) | "Account suspended", damage drops; when risk falls below 90 damage returns | |
| 18l | Same, holding `giveitem tAppeal Form` | "Appeal approved", trinket gone, risk 50, no damage drop | |
| 18m | `giveitem Opus Mode` with a few coins, shoot | Big damage; coins tick down every 10 tears; at 0 coins "Out of credits" and weak damage; pick up a coin and damage comes back | |
| 19 | Save & quit, continue | Risk, IP and Silent Update value are kept | |
| 19b | Set the game language to 简体中文 (or 日本語), start a run | HUD shows 风控值 / リスク値 in that language. If it's still English, the CJK font path is wrong: tell Claude | |
| 20 | With EID installed | Item descriptions show (try Chinese/Japanese in EID settings) | |

Items most likely to need fixes: **#17** (doors may re-close while enemies are alive) and the placeholder Relay Slime (#6b).

Overloaded lifecycle acceptance (pending): trigger an outage late in a disposable run, quit during its two-second window, then start a new run without closing the application and acquire the trinket. Tears must have normal damage until that new run's first outage. Also test save/continue, dropping the trinket during an outage, and normal recovery at two seconds. Offline lifecycle coverage does not mark these engine checks as passed.

Subagent Swarm resolution acceptance (pending): test both DeepSeek characters with Swarm in a populated room. Neither DeepSeek form may randomly remove a shot; a normal shot after five seconds of Deep Think must give children half its boosted damage. On both Claude characters, children must deal half the already-limited parent's damage and share its grey color. Check normal DeepSeek plus Swarm produces three total tears, while tainted DeepSeek plus Swarm produces five when Compute pays for the forks (three in Saving mode or when Compute is short), with no recursive growth. In co-op, a non-holder must not gain children from the holder. Also test another mod's late tear callback; this mod's late registration does not establish universal ordering across third-party callbacks. These assertions have stub coverage only, not a recorded engine pass.

### Opus Mode immediate wallet state

Acquire Opus Mode at zero coins and inspect the damage stat before and after the next player update; its multiplier should be x0.6 throughout. Repeat with positive coins for x1.8. Pick up a coin, spend the last coin, and trigger a damage-cache refresh in the same frame: the refreshed value must use the current wallet. Reroll away and reacquire the item after changing the wallet, and repeat after a real save/quit/continue. In co-op, check each owner separately. The regression uses stub cache calls and stale notification flags; it does not prove the game's callback order or cover weapon-family billing.

### API checked against the community docs (wofsauge/IsaacDocs, 2026-10-22)

These calls exist with the signatures the mod uses, so they shouldn't crash: `GridEntityDoor:TryUnlock(player, force)`, `IsLocked()`, `Open()`; `EntityPickup:TryOpenChest(player)`; `Entity:AddCharmed(ref, -1)` (−1 = permanent, the ally follows you between rooms); `AddConfusion`, `AddFreeze`; `Room:SetClear`, `GetFrameCount`, `GetCenterPos`; `EntityPlayer:SetPocketActiveItem`, `GetActiveCharge`, `SetActiveCharge`, `AddSoulHearts`, `HasTrinket`; `EntityTear:AddTearFlags`; `MC_USE_PILL (effect, player, flags)`; `MC_USE_ITEM` returning `true` plays the use animation; `MC_ENTITY_TAKE_DMG` returning a value skips later callbacks (so The Constitution's refused hit adds no risk).

What the docs can't tell us is whether the gameplay *feels* right. That's what this checklist is for.

## v0.4 focused checks

### Vibe Coding persistence acceptance (pending)

In a disposable run, hold Vibe Coding and 40 coins, take a hit, save and quit, close the application, then continue and change floors. Coins must remain 40 on continue and become 30 on the next floor. Repeat without a hit: coins stay 40. On the following no-hit floor no second bill is due. Repeat with two players: only the damaged holder pays. Include The Constitution's refused first hit, and check a fresh run does not inherit the previous run's hit flag. The lifecycle regression is stub coverage; it does not mark these engine checks as passed.

### Other v0.4 checks

- *(v0.4 DeepSeek-chan check superseded by the v0.5 redesign below.)*
- `giveitem Support Ticket`: with 2 coins or risk 0, no coins/charge spent; with 3 coins and positive risk, spend 3 and lower risk by up to 20. Repeat with Car Battery.
- See story chapters at run start, stage 3, stage 5, and the next room after successful review. Save and continue: completed chapters stay completed. Hide the HUD: captions hide too.
- Inspect both custom character skins, four head directions, all movement/hurt/death poses, character select, stage/boss portraits and names. Check D4 and costume interactions. **Initial custom-art runtime checks passed in Repentance+; the complete animation/costume matrix is pending. See HANDOFF.md for exact observations.**
- Subtitle position was moved above the lower HUD after observing EID overlap; confirm it with EID enabled.
- Use Support Ticket on the first floor, then reach stage 3 and stage 5: both later chapters must still appear with their approved-route dialogue. Continue after all four chapters: none should repeat.
- Repentance+ 1.9.7.17 gameplay startup was observed on 2026-10-23. This is not evidence of a full-run pass, normal Repentance compatibility or local co-op correctness.

## v0.5 focused checks (characters)

With Reactions Port Pack enabled, trigger a pickup/reaction for each of the four characters. Their custom skins must remain visible instead of receiving the pack's default Isaac face. Explicit character support supplied by the pack must remain intact. The tainted fallback regression currently has stub coverage; in-game visual verification remains pending.

| # | Test | Expected | OK? |
|---|---|---|---|
| C1 | Character select: press E (keyboard) / RB (controller) to switch to the tainted menu | Tainted Claude-chan (crimson) and Tainted DeepSeek-chan (teal) are listed with their menu portraits. Per the Isaac Blueprints tainted-unlock tutorial, without REPENTOGON a modded tainted character **can't be locked in the menu**, so they should be selectable from the start; the tainted toggle itself may need a save that has unlocked vanilla tainted characters. **If they don't appear, tell Claude** | |
| C2 | Walk and shoot in all four directions as each of the 4 characters | Heads are never clipped at the edges, no stray hair bits next to heads; DeepSeek-chan faces sideways when walking sideways (no more front-facing slide) | |
| C3 | Start as DeepSeek-chan | HUD says "Direct connection - no proxy needed" (直连・无需代理), no IP/risk line; enemies are not tougher on later floors; pocket item is Lunch Break | |
| C4 | DeepSeek-chan: stop shooting for 3-5 s, then shoot | Big tear, HUD "Thought for N s" (已深度思考（用时N秒）) | |
| C5 | DeepSeek-chan in a room with many enemies | Some shots don't come out, HUD "Server busy, please try again later" | |
| C6 | Use Lunch Break | +1 red heart, enemies slowed, you can't shoot for 3 s | |
| C6b | DeepSeek-chan: clear a room, then stand still ~5 s | HUD "Slacking off... Lunch Break +1" (摸鱼中……), pocket charge +1; nothing happens while moving or in a fight | |
| C7 | Tainted DeepSeek-chan: shoot | With enough Compute each volley comes out as 3 tears in a fan and the HUD Compute drops by 2 (Valley) or 4 (Peak); at low Compute or in Saving mode only the main tear fires; still no risk HUD | |
| C8 | Co-op: Claude-chan + DeepSeek-chan | Risk HUD and IP are back (the system only sleeps when everyone is DeepSeek-chan) | |
| C9 | Claude-chan: `stage 2`, `stage 3` without reaching risk 90 | HUD "Account age: 2 floor(s)", damage up a little; reach 90+ risk: "Banned again", age back to 0 | |
| C10 | Tainted Claude-chan: shoot ~220 times on one floor | HUD "Weekly limit 220 / 220", "Weekly limit reached", weak grey tears; next floor resets; pocket Banked Reset refills it | |

### Repeatable manual engine probe

Use only a disposable, owned stage-1 **Claude-chan** run (since v0.5-dev; the probe puts a Support Ticket into her pocket slot, replacing the Ban Hammer for that run). The passes below were recorded on the v0.4 build in a DeepSeek-chan run, before the redesign. In the game debug console run:

```lua
lua Isaac.RunCallback("ClaudeChan:RunRuntimeProbe")
```

Close the console and let the simulation run for about 13 seconds. This sets test coins/risk, uses the real pocket-item input, adds Car Battery, changes to stage 3 and round-trips this mod's run data. It does not change other mods' settings. Do not invoke it in a run you intend to preserve. Normal gameplay never calls it. A duplicate probe is rejected; input is removed on completion, failure or game exit.

The probe must print `CCQA PASS` for insufficient funds (2/50/6), Car Battery (3/30/0), simultaneous captions (one pending), queue save/load (seen=11, pending=0), and completion. These assertions passed in Repentance+ 1.9.7.17 on 2026-10-23. They use the active shared Risk object, never a fresh `include("scripts.risk")`. The save/load case exercises the real mod JSON persistence and story-start handler; it does not replace a full application-restart/save-slot test.
