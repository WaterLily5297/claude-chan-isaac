# In-game test checklist

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

### API checked against the community docs (wofsauge/IsaacDocs, 2026-10-22)

These calls exist with the signatures the mod uses, so they shouldn't crash: `GridEntityDoor:TryUnlock(player, force)`, `IsLocked()`, `Open()`; `EntityPickup:TryOpenChest(player)`; `Entity:AddCharmed(ref, -1)` (−1 = permanent, the ally follows you between rooms); `AddConfusion`, `AddFreeze`; `Room:SetClear`, `GetFrameCount`, `GetCenterPos`; `EntityPlayer:SetPocketActiveItem`, `GetActiveCharge`, `SetActiveCharge`, `AddSoulHearts`, `HasTrinket`; `EntityTear:AddTearFlags`; `MC_USE_PILL (effect, player, flags)`; `MC_USE_ITEM` returning `true` plays the use animation; `MC_ENTITY_TAKE_DMG` returning a value skips later callbacks (so The Constitution's refused hit adds no risk).

What the docs can't tell us is whether the gameplay *feels* right. That's what this checklist is for.

## v0.4 focused checks

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
| C7 | Tainted DeepSeek-chan: shoot | Every shot comes out as 3 tears in a fan; still no risk HUD | |
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
