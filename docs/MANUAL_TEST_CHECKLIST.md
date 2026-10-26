# Quick manual test

Installed build: `f8b2b0b`. No debug tools are required. One or two ordinary runs are enough for an initial report; mark anything you do not encounter **not tried**.
Reply **OK / broken / not tried** for each number. Include the character/form and game version shown on the title screen. For a problem, add the item and the last action; screenshots are optional and should show only the game.
The proposed difficulty pass is not in this installed build. Item 14 asks about the current feel now; repeat it on an approved newer build only after installation is confirmed.

| # | Check | What OK looks like |
|---|---|---|
| 1 | Pick forms you want to try: Claude, DeepSeek, tainted DeepSeek, GPT or another family. | The selected normal/tainted form starts a run; report which ones you actually tried. |
| 2 | First room: body, head and HUD. | One correctly sized character; readable hearts, resource text and story caption. |
| 3 | Tap DROP with one pocket item, when the ability is ready. | The described ability activates once on release and spends only its stated resource. |
| 4 | Tap DROP with two pocket items. | Native pocket selection cycles; the character ability does not fire or spend a resource. |
| 5 | Hold DROP with a droppable card/pill/trinket. | Native dropping still works; releasing the long hold does not trigger the ability. |
| 6 | Use Let's Delve if found. | One native shovel effect where allowed; one six-charge use, including a blocked dig. |
| 7 | Use Six Seven if found. | Six or seven friendly blue flies without a fly-multiplying item; no error. |
| 8 | Tainted DeepSeek: Peak and Valley. | The displayed state/resource changes as described; shooting and movement remain usable. |
| 9 | Pick up an item that normally changes appearance. | The character's fixed design remains; the item's gameplay effect still works. |
| 10 | Gain flight if it occurs. | The character crosses pits without damage; report missing wings separately from broken flight. |
| 11 | Take a hit and, if a run ends, inspect death. | No giant head, clipping, duplicate body or misplaced pose; recovery returns to the normal sprite. |
| 12 | Save, exit and Continue. | Same run/form, inventory and displayed resource return without a crash or reset. |
| 13 | Notice any red error or crash. | None seen during the tested actions; no need to open the console just for this checklist. |
| 14 | Difficulty, for each form you tried. | Report **too easy / fair / too hard**, plus the mechanic responsible. On an approved difficulty build: a little harder, still fair. |

Short reply template: `Build / game version / forms; 1 OK, 2 OK, 3 broken (action...), 4 not tried; 14 fair (form...)`.
Owner observations are recorded at their stated scope; an OK here does not accept all 22 forms, every item or both game editions.

Draft #102 implements character-specific conditions for all 22 forms; **none is in installed f8b2b0b**. After approval and confirmed installation, repeat items 3-5, 12-14 and the relevant family row in [the B1 native matrix](TESTING.md#b1-revision-status-2026-10-26-all-22-draft-features-offline-only). Report whether the condition was understandable, whether its reward/cost matched the HUD, and whether the added choice felt fair. Do not report an unplayed draft as tested.
