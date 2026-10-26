# B1: modest character difficulty proposal

Status: implemented candidate, **awaiting owner approval before merge**. Baseline: `aef6de9` (PR #99), whose gameplay matches installed `f8b2b0b`. Nothing from this proposal is installed or engine-accepted. The owner's checklist reply supplied no usable gameplay observations; it is not a balance verdict.

The aim is a little less benefit from each existing loop, with no new penalties. Health, starting pickups, native item rules, weapon accounting, transformations and input are unchanged. In particular, tainted DeepSeek retains its approved 1.3x non-tear boost, normal GLM has no forced Book of Secrets, and fixed looks plus the multi-pocket DROP restriction stay in place.

## Baseline and comparison method

Health below is **whole hearts**: R red, S soul, B black. The mod XML uses half-heart units: `hp=4, armor=2` means 2R+1S. All 22 forms have zero black hearts. Pickups are coins/bombs/keys. Stat modifiers are relative to the native pre-item/cache value, not a fixture's artificial damage of 10. D damage, I firing interval (`MaxFireDelay + 1`), V movement speed, Rg range units, SS shot speed. Unlisted modifiers are unchanged native defaults; colors do not change combat stats. BR means Birthright. At a fresh start, normal Claude has zero account age; Qwen starts with Range selected but inactive, and tainted Qwen starts Balanced.

Sources: baseline `content/players.xml`, each named character module in `scripts/characters/`, `model_roster.lua`, and the bundled vanilla `resources-dlc3/players.xml`, inspected privately. No extracted vanilla files or artwork are included. The [players.xml API reference](https://wofsauge.github.io/IsaacDocs/rep/xml/players.html) confirms health units. Lua, rather than XML, supplies this mod's cache modifiers and three pocket actives.

Vanilla references are the closest useful comparison by starting health or play pattern, not claims of identical DPS or overall difficulty. Isaac's XML gives 3R and a bomb; Cain 2R and a key; Judas 1R and three coins; Eve 2R; Samson 3R; Lilith 1R+2B and `canShoot=false`. Their native items/unlocks and other strengths matter. This audit cannot prove any complete form clearly stronger than vanilla without ordinary runs. Equal total health with more soul hearts is also not equal survivability. The table identifies benefits worth trimming while preserving each identity.

## All 22 baseline forms

| Form | Starting health; pickups; pocket | Starting stat modifiers | Baseline meme loop and limits | Closest vanilla reference; implication |
|---|---|---|---|---|
| Claude | 2R+1S; 0/1/0; Ban Hammer | V -0.1, Rg +60, SS +0.2 | +0.2 D per floor, eight-floor cap +1.6; suspension resets age (BR protects first/floor). Usage +4/paid attack, +8 with Swarm; idle drain 10/s; at 100, 0.4x D for 5s. Appeals start 1/cap 2, +1/2 clears, remove 40 Usage. | Isaac: same total health/bomb, different heart mix; growth and pocket utility accompany speed loss and Usage/Risk penalties. Trim growth. |
| Tainted Claude | 1R+2S; 0/1/0; Banked Reset | D 1.25x while funded, Rg +60, SS +0.2 | 220 Quota/floor, cost 1/attack (2 Swarm); zero Quota gives 0.5x D. Pages start/cap 2, +1/3 clears; a 6s combat review refunds 60 (BR 90). Exit cancels review. | Judas: funded offensive bonus with more total starting health, but a distinct depletion penalty; trim funded damage, keep recovery usable. |
| DeepSeek | 2R+1S; 3/0/1; Lunch Break | D 0.9x | Thought charges over 150 idle frames to 2x next-attack damage. Bowls start 1/cap 2, +1/2 clears; 2s meal (BR 1s) gives full Thought and V +0.15 for 6s. No healing or proxy risk. | Cain: both start with a key; DeepSeek has an extra soul heart and coins but reduced base D. Trim stored burst, not basic shooting. |
| Tainted DeepSeek | 1R+1S; 0/0/0; none | D 0.8x | 12s Valley/12s Peak in combat; Compute start 12/cap 24 (BR 32), idle Valley +3/s; cost 2/4 for two 0.5x forks at +/-12 degrees. Non-tears pay for 1.3x. Saving toggle cooldown 1s. | Eve: equal total health, different mix; lower base damage trades for paid extra output. Trim recovery rather than the approved non-tear rule. |
| GPT | 2R+1S; 0/1/0; none | Verified D 1.15x | Three unique clears fill Routing; next combat starts Fallback 0.8x. One check/room within 200: three paid hits (BR two) or owner defeat verifies. Floor resets Verified. | Isaac: same total health/bomb; alternates a benefit and deficit. Trim only Verified. |
| Tainted GPT | 1R+2S; 0/0/1; none | Standard D 1x | 80 Credits (BR 100), Full Send 1.5x costs 1/attack; three clears bank a Tibo refill, progress pauses until claimed. No Credits means Standard. | Judas: offensive boost with resource gating and more starting health; trim funded damage without changing credit rules. |
| Gemini | 2R+1S; 0/1/0; none | Native defaults | Paint start 2/cap 3, +1/clear; mark nearest within 180 for 8s, owner D 1.2x (BR 1.3x). Owner defeat leaves one 4s slowing peel. | Isaac: same total health/bomb; repeatable targeted amplification is the additional benefit to trim. |
| Tainted Gemini | 1R+2S; 0/0/1; none | D 0.9x | Within 180, three paid hits in 6s (BR 10s) export one 2x pulse, once/room. Retarget erases progress; early defeat ends chain. | Isaac: equal total health; reduced base D pays for a conditional burst. Reduce burst slightly, retain the three-hit challenge. |
| Grok | 2R+1S; 0/1/0; none | Native defaults | Once/room check within 220 for 6s: target D 1.3x, others 0.9x. Three paid hits/owner defeat end modifiers and grant V +0.15 for room; BR removes up to three bullets within 120. | Isaac: focused bonus has an off-target cost. Trim the focused reward only. |
| Tainted Grok | 1R+2S; 0/0/1; none | D 0.9x | Quote within 220 for 6s, cooldown 10s. Paid hits on others build Ratio cap 3; expiry deals one 1x pulse/stack. BR transfers half once after early defeat. | Isaac: lower base D with delayed burst; keep timing and target risk, trim each pulse. |
| Qwen | 2R+1S; 0/1/0; none | Native defaults until Adapter activates | Start 1/cap 2 Adapters (BR 3), +1/2 clears. One new hostile room spends one for Rg +60, I 0.9x or D 1.1x. No stacking; selection previews the next room. | Isaac: same total health/bomb; selective room bonuses. Reduce the two offensive choices without reducing Range. |
| Tainted Qwen | 1R+2S; 0/0/1; none | Balanced D/I 1x | Safe-room switch: Heavy D 1.3x/I 1.2x, Tiny D 0.85x/I 0.8x, Balanced; locked in combat. Clear with all three variants for +0.2 D before build multiplier (BR +0.3), max three awards/floor. | Isaac: equal total health; modes have tradeoffs, while set awards accumulate. Trim awards, retain mode identity. |
| Llama | 2R+1S; 0/1/0; none | D 0.95x | Releases start 1/cap 2, +1/2 clears. Solo gives four blue flies; co-op gives two each to at most four living players; BR gives owner two more. | Isaac: same total health/bomb, reduced basic D and shared fly utility. An integer fly reduction is too coarse; choose a small base-D trim. |
| Tainted Llama | 1R+2S; 0/0/1; none | D 0.9x | Hype +1/clear, cap 3; spend all for stationary helper, 4s/stack (BR 5s), one native 0.5x tear/s, target within 400. One helper, removed on exit. | Lilith: equal total health with soul rather than black hearts; direct shooting plus a temporary helper differs from native familiar dependence. Trim helper damage only. |
| Mistral | 2R+1S; 0/1/0; none | V +0.1 | Move and fire for 2s to charge; idle 1s loses it. Pounce deals 2x once/target along 80-unit line (BR 110), width 20; walls block; cooldown 3s. | Cain: movement-oriented comparison; Mistral has one more total heart but its extra attack needs positioning. Trim swipe, not movement. |
| Tainted Mistral | 1R+2S; 0/0/1; none | D 0.9x, V -0.1 | Stand without firing 2s (BR 1.5s) to bake, cap 2. Wave travels 120 at 4 units/frame, width 24, 2.5x once/target; walls block, cooldown 2s. | Isaac: equal total health with lower basic stats and a stationary charge cost. Trim only the wave. |
| Doubao | 2R+1S; 0/1/0; none | Native defaults | First real enemy hit/hostile room grants token for 6s (BR until exit). Spend to slow within 100 for 2s at 0.5 speed and remove four nearest bullets. No heal/damage cancellation. | Samson: damage-triggered utility, same total starting health; this is already defensive and conditional. Shorten slow modestly, keep bullet relief. |
| Tainted Doubao | 1R+2S; 0/0/1; none | Ready D 1x | Confident 6s at 1.35x, then Apology 4s at 0.85x (BR 3s). Combat-only timers; enemy hit ends Confident early. | Eve: alternates stronger/weaker states; more starting health but timed exposure. Trim the high phase, keep low phase unchanged. |
| Kimi | 2R+1S; 0/1/0; none | Native defaults | +1 Slide/clear, cap 6; cost 3 (BR 2) marks nearest three within 220 for 4s, 0.6 slow and 1.15x owner damage. No audience means no spend. | Isaac: same total health/bomb, limited multi-target utility. Trim amplification, retain crowd control. |
| Tainted Kimi | 1R+2S; 0/0/1; none | D 0.85x | Up to three tasks on targets within 220; each has three 0.6x pulses (BR 0.7x), 2s apart; nine scheduled pulses/room. Exit cancels with no refund. | Lilith: indirect-output comparison with direct shooting retained; lower base D and finite task budget. Trim pulses without lowering budget. |
| GLM | 2R+1S; 0/1/0; none | Native defaults | Three clears redeem pass for next two new hostile rooms (BR three) at 1.2x D. Queue pauses while pass active; revisits cannot spend or stack. | Isaac: same total health/bomb, occasional room bonus; no forced starting active. Trim pass strength. |
| Tainted GLM | 1R+2S; 0/0/1; none | D 0.9x | Request within 200 takes 2s, cooldown 3s; survivor receives 2x +1x/Retry (cap three). Early defeat adds Retry; BR removes one bullet on failure. Exit cancels. | Isaac: lower basic D, delayed burst and target risk. Trim baseline request while keeping Retry's reward. |

## Proposed values for approval

Every other baseline value above stays unchanged. Relative reductions here describe only the selected benefit, not whole-run damage or difficulty.

| Form | Baseline -> candidate | Reason |
|---|---|---|
| Claude | Age +0.20 -> +0.15/floor; cap +1.60 -> +1.20 | Less free growth; no added suspension penalty. |
| Tainted Claude | Funded damage 1.25x -> 1.20x | 4% less funded output; recovery stays usable. |
| DeepSeek | Full Thought 2x -> 1.9x; partial bonus scales by 0.9 | 5% less full burst; no extra waiting. |
| Tainted DeepSeek | Valley recovery 3/s -> 2.5/s (10 -> 12 frames/point) | Slightly tighter Compute economy; 1.3x off-peak stays. |
| GPT | Verified 1.15x -> 1.10x | Trim the strong state; Fallback unchanged. |
| Tainted GPT | Full Send 1.50x -> 1.40x | Smaller credit-funded burst. |
| Gemini | Mark 1.20x -> 1.15x; BR 1.30x -> 1.25x | Keep marking and peel utility. |
| Tainted Gemini | Export 2x -> 1.8x | 10% smaller finishing pulse. |
| Grok | Checked target 1.30x -> 1.25x | Keep off-target penalty and verification speed. |
| Tainted Grok | Per-Ratio pulse 1x -> 0.9x | 10% smaller delayed burst. |
| Qwen | Tempo I 0.90x -> 0.92x; Power D 1.10x -> 1.08x | Small reductions to both offensive options. |
| Tainted Qwen | Award +0.20 -> +0.15; BR +0.30 -> +0.25 | Less floor scaling, same three-variant task. |
| Llama | Base D 0.95x -> 0.92x | About 3.2% less basic output; retain useful integer fly counts. |
| Tainted Llama | Helper tear 0.50x -> 0.45x | 10% less helper damage; same duration/cadence. |
| Mistral | Pounce 2x -> 1.8x | 10% smaller swipe; movement preserved. |
| Tainted Mistral | Wave 2.50x -> 2.25x | 10% smaller wave; no longer charge. |
| Doubao | Slow 2s -> 1.5s (60 -> 45 frames) | Less follow-up safety, same four-bullet removal. |
| Tainted Doubao | Confident 1.35x -> 1.30x | Trim high phase, no harsher Apology. |
| Kimi | Presentation 1.15x -> 1.12x | Slightly less focus damage; slow retained. |
| Tainted Kimi | Pulse 0.60x -> 0.55x; BR 0.70x -> 0.65x | Modest task-output reduction, same budget. |
| GLM | Access Pass 1.20x -> 1.15x | Less room bonus, same queue timing. |
| Tainted GLM | Request base 2x -> 1.8x; +1x/Retry unchanged | Smaller reliable component; cap total 5x -> 4.8x. |

## Persistence, validation and remaining tests

No saved resource cap is reduced. Existing Quota, Credits, Compute, Age and award counts remain valid. Qwen's saved award count uses the candidate reward when caches recalculate. A legacy normal-DeepSeek paid 2x continuous window is accepted only for its saved remaining updates, then expires; new payments use at most 1.9x. Tainted DeepSeek's old recovery remainder (0-9) remains valid under the new 0-11 range and completes at twelve frames, without a resource reset.

Regression expectations intentionally change in the real-module suites for all 22 forms, with native adapters/composition expectations updated to the new factor. New boundaries pin Claude's eight-floor cap and repeat cache evaluation, Valley's eleven-versus-twelve-frame recovery and old remainder, and a legacy paid Thought window's expiry. These model callback sequences; they cannot prove actual native restart, item composition or gameplay balance. No child-laser implementation changed.

Run `bash tools/check.sh`. The updated suites must reject the old numerical baseline and pass the candidate. Full gate and baseline-differential outcomes are recorded in TESTING.md before the PR is ready. EID, dossier text, roster, current design records and numeric lines in all three READMEs follow the candidate; standalone items with similar names keep their rules.

After approval and a separately authorized installation, repeat manual checklist item 14 per tested form: **too easy / fair / too hard**, plus the responsible mechanic. Compare early and late rooms, funded/depleted states, Birthright, ordinary attacks and a representative native weapon. A short DROP with multiple pockets must still be native-only. Keep any build/game-version observations distinct from this offline proposal.
