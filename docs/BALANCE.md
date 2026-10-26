# Balance sheet

Character figures include the unapproved B1 candidate; the full baseline comparison is in [DIFFICULTY_PASS.md](DIFFICULTY_PASS.md). Item figures are unchanged. Installed `f8b2b0b` retains the baseline character values.

Every tunable number in the mod, next to vanilla reference points. **Nothing here has been playtested yet.** Use this during the in-game test to decide what to change, then edit the constant named in the "Where" column.

## Vanilla reference (Repentance)

| Vanilla item | Damage effect | Quality |
|---|---|---|
| Cricket's Head / Magic Mushroom | ×1.5 | 4 |
| Haemolacria | ×1.5 (confirmed by the wiki) | 4 |
| Polyphemus | ×2, much slower tears | 3 |
| Sacred Heart | ×2.3 +1, homing, slower tears | 4 |
| 20/20 | 2 tears at ×0.8 each (~1.6× output) | 3 |
| Soy Milk | ×0.2, tears ×5.5 | 1 |
| Almond Milk | ×0.3, tears ×4 | 2 |

These are from memory (the wiki is blocked from this environment), except Haemolacria. Verify in game if a comparison matters.

## Damage items in this mod

| Item | Effect | Average output | Compared to vanilla | Watch for | Where |
|---|---|---|---|---|---|
| Opus Mode (Q3, shop) | ×1.8, 1 coin / 10 tears; ×0.6 at 0 coins | ×1.8 while you have coins | Stronger than Cricket's Head, but costs money | Too strong if coins are plentiful late game | `opus_mode.lua` `OPUS_MULT`, `TEARS_PER_COIN` |
| 9.9 Yuan Relay (Q2, devil) | ×1.5, 30% of rooms ×0.5 | ×1.2 expected | Weaker than a ×1.5 item; risk +15 | Probably fine; maybe too weak for a devil deal | `cheap_relay.lua` `SWAP_CHANCE` |
| Subagent Swarm (Q3, devil) | +2 tears at ±15°, 50% damage | up to ×2 if all hit | Like a stronger 20/20 | **Likely too strong** up close; consider 40% | `subagent_swarm.lua` `SUBAGENT_DAMAGE` |
| Ultrathink (Q2, active) | +1/+2/+3.2 for the room, 5 s recharge | +3.2 after ~10 s | Very strong in long fights | Boss fights may be trivial | `ultrathink.lua` `LEVELS` |
| 1M Context (Q2) | Range +5, damage decays to 30% over 3 s | ~×0.7 at mid range | A trade-off item | Fine | `million_context.lua` |
| Silent Update (Q1) | ×0.8–×1.3 per floor | ×1.05 expected | Neutral gamble | Fine | `silent_update.lua` |
| The Constitution (Q3, angel) | ×0.9, speed −0.1, +1 soul heart, block 1 hit/floor | ×0.9 | Defensive item | Fine | `constitution.lua` |
| Hardcoded Output (trinket) | Every tear = 3.5 | — | Good early, bad late | Fine | `hardcoded_output.lua` |
| Thinking Cleared (trinket) | +1 damage, active −1 charge/room | +1 | — | Too strong if you have no active item | `thinking_cleared.lua` |
| Agentic (transformation) | Flight, fire delay ×0.8, +0.5 | — | Similar to vanilla transformations | Fine | `transformation.lua` |
| Claude-chan usage limit | 4 usage / tear, −5 / s; limit = 40% damage for 5 s | Hits after ~17 s of nonstop fire | — | **Too punishing in boss fights?** | `claude_chan.lua` `USAGE_PER_TEAR`, `LIMIT_FRAMES` |

## Difficulty systems

| System | Now | Watch for | Where |
|---|---|---|---|
| Risk per floor | shared users / 10 + stage number | Risk ~70 by floor 8 with one hit per floor | `risk.lua` `RollIp` |
| Enemy HP | ×1 at risk 0 → **×3 at risk 100** | **Likely too harsh** stacked with vanilla scaling and hydra; consider ×2 max (`1 + risk / 100`) | `enemy_scaling.lua` |
| Hydra respawns | from risk 40, 10% → 50% | Combined with ×3 HP, late rooms may drag | `constants.lua` `HYDRA_MIN_RISK`, `hydra.lua` |
| Relay Slime | from risk 30, 25% of rooms, 1 → 7 slimes | Fine | `relay_slime.lua` |
| Suspended | risk 90+: damage ×0.75 | Can snowball: harder rooms → more hits → more risk | `risk.lua` `SUSPEND_AT` |
| Misbans | 20% of bans, +3 risk each | Fine | `ban_hammer.lua` |

## Suggested first tweaks (only if the test agrees)

1. Enemy HP cap: ×3 → ×2.
2. Subagent Swarm: 50% → 40% damage.
3. Claude-chan's usage limit: if boss fights feel bad, drop `USAGE_PER_TEAR` from 4 to 3.
# v0.4 prototype additions

- **Support Ticket:** shop active, six room charges, three coins for risk -20. A failed use preserves both coins and charge. Car Battery does not charge twice. Unlike the automatic Appeal Form trinket, this requires a manual decision before suspension.
- **DeepSeek-chan:** two red hearts, one soul heart, three coins, one key; pocket Support Ticket. Damage x0.85 and firing interval x0.85 approximately preserve basic tear DPS while encouraging safe rooms. A room without any player taking damage reduces shared risk by two extra points, once per team. Balance has not been evaluated over a full run.

# v0.5-dev characters (untested in game)

| Character | Numbers | Watch for | Where |
|---|---|---|---|
| DeepSeek-chan | Damage ×0.9; Rice First Thought +0.18× per second idle, max ×1.9 after 5 s | No proxy risk; Rice rewards stopping attacks. No random shot deletion. | `deepseek_rice.lua` Thought policy |
| Tainted DeepSeek-chan | Damage ×0.8; paid volley forks 2 × 50% (≈ ×1.6 if all hit); Compute 12 start, cap 24 (32 Birthright); cost 2 Valley / 4 Peak; Valley +2.5/s in combat while not firing; 12 s phases | Multi-shot items fork every pellet for one payment; Peak may feel empty; Saving may be rarely worth it | `deepseek_peak.lua` constants |
| Claude-chan (One More Day) | 4 usage per volley (8 with Swarm); drain 10/s when not firing; Limited 0.4× for 5 s; Appeals start 1, cap 2, +1 per 2 unique clears, −40 usage each | Faster idle drain may make Limited rare; multi-shot volleys now cost the same as one tear | `claude_chan.lua` constants |
| Tainted Claude-chan | Damage ×1.2; 220 Quota per floor (1 per volley), then Suspended 0.5x with Page reviews (+60) | Long floors (Womb+) may run out; boss rooms after the quota | `claude_chan_b.lua` `QUOTA`, `REVIEW_QUOTA` |
| Claude-chan account age | +0.15 damage per floor, max +1.2 | Rewards clean play; suspension reset may snowball with ×0.75 | `claude_chan.lua` `AGE_*` |
| Lunch Break | 6 charges: +1 red heart, enemies slowed 3 s, no shooting 3 s | Heal per room-clear may be strong | `lunch_break.lua` |
| 529 Overloaded | Shooting allowed during the 2 s outage at 50% | Now strictly good; may need a downside | `overloaded.lua` `MANUAL_DAMAGE` |
