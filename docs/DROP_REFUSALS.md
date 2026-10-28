# When DROP does nothing

Offline source audit, 2026-10-27, against `e1d5ec3`. This is the first part of the W2.4 readability work: for each of the 22 forms, it lists when a DROP tap is refused and whether the player sees why. It changes no code. It is a reference for manual testing (check 3 in [MANUAL_TEST_CHECKLIST.md](MANUAL_TEST_CHECKLIST.md)): if DROP seems to do nothing, check this table before reporting a bug.

## Shared rules for every form

[drop_tap.lua](../scripts/characters/drop_tap.lua) decides whether a tap happened at all. None of these show a cue:

- Holding two or more pocket items (cards, pills, pocket actives). Native cycling owns DROP.
- A hold longer than 12 frames (0.4 s). Native dropping owns the long hold.
- Paused game, disabled controls, a dead player or a co-op ghost.
- A press already held when the room, form, controller or run changed. Release and tap again.
- When a form's own condition is false during the press, the press is forgotten. Tapping again after the condition becomes true works.

## Per-form conditions

"Silent" means DROP does nothing and no text appears. "No target" means no eligible enemy within the stated radius: nothing is spent and no text appears.

| Form | DROP does nothing when | Cue today |
|---|---|---|
| Claude-chan | No Appeals left, Usage is 0, or a usage limit is active. | Silent |
| Tainted Claude-chan | Quota is above 0, no Pages left, or a Review is already running. | Silent |
| DeepSeek-chan | No bowls, a meal is already running, or you are moving. | Silent |
| Tainted DeepSeek-chan | Within one second of the last Peak/Valley toggle. | Silent |
| GPT-chan | Already Verified, this room's Sanity Check is spent, or a check is running; no target within 200. | Silent |
| Tainted GPT-chan | Standard mode with no Credits, and no banked reset to claim. A banked reset is claimed only outside combat; in combat DROP only toggles Full Send. | Silent |
| Gemini-chan | No Paint left; no target within 180. | Silent |
| Tainted Gemini-chan | This room's edit chain already exported; no target within 180. | Silent (the HUD shows "Exported") |
| Grok-chan | Not in combat, this room's check is spent, or a check is running; no target within 220. | Silent |
| Tainted Grok-chan | The ten-second cooldown is running; no target within 220. | Silent |
| Qwen-chan | Never refused: DROP always cycles the next adapter. | Always shows the choice |
| Tainted Qwen-chan | In combat. Outside combat, a pinned build refuses with its clears left. | Silent in combat; pinned build shows "Pinned: clear N new combat rooms" |
| Llama-chan | No Releases left. In combat the Release is kept. | Silent at 0; combat shows "Prepare the release between fights" |
| Tainted Llama-chan | No Hype. | Silent |
| Mistral-chan | No charged Pounce: move while firing to charge one. | Silent |
| Tainted Mistral-chan | No Baguettes, or the wave cooldown is running. | Silent |
| Doubao-chan | No Apology token. A qualifying enemy hit grants one. | Silent ("Apology ready" shows when granted) |
| Tainted Doubao-chan | Confident or the following recovery is still running. | Silent |
| Kimi-chan | Fewer Slides than the deck cost; no enemy within 220. | Silent |
| Tainted Kimi-chan | Not in combat, three tasks already assigned, or this room's nine-pulse budget would be exceeded; no unassigned target within 220. | Silent |
| GLM-chan | Queue below 3/3, or a pass is already active. | Silent |
| Tainted GLM-chan | Not in combat, or the three-second cooldown is running; no target within 200. | Silent |

Most refusals rely on the resource text already drawn in the HUD (Appeals, Quota, Paint, Slides and so on). Only Tainted Qwen-chan and Llama-chan explain a refusal in words, and no form says "no target in range".

## Open follow-up

Adding refusal cues is a later, separate change. It touches the shared tap rule. Today a press during a refused state is forgotten, so a cue would need the tap to be accepted first and then explained. It also needs a decision on how noisy the HUD may be in co-op. Any cue would be text only: no value, cost or cooldown would change. The narrow-screen and co-op string audit (the other half of W2.4) is in [HUD_TEXT_AUDIT.md](HUD_TEXT_AUDIT.md).
