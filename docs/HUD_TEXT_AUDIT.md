# HUD text on narrow screens and in co-op

This is an offline audit from 2026-10-28, against `db70b98`. It is the second half of the W2.4 readability work; the first half is [DROP_REFUSALS.md](DROP_REFUSALS.md). It is not an engine observation.

Widths are estimates. `Isaac.RenderText` has no width API, so this audit counts 6 pixels per glyph. That is the same advance the backlog labels already use to centre their text. Native font rendering, HUD offset and the exact positions of the native HUD remain to be observed.

## What was checked

| Text | Where | Result |
|---|---|---|
| Form lines (20 forms other than Claude-chan) | x=50, row 0 of each player's 24 px band | The longest worst case is Qwen-chan's "Adapters ... Installing: stop firing", 74 characters, about 494 px. That passes the edge of a 480-wide screen. The next longest are 63, 61 and 56 characters. |
| Claude-chan and Tainted Claude-chan | Rows 0 and 1, Risk lines below | At most 38 characters; no change. |
| Story captions | x=100, above the highest band | At most 47 characters, about 382 px. They fit 400 and wider. |
| Dossier cards (MAP held in a cleared room) | Text at x=50, portrait centred at x=width-100 | At 480x270 the portrait's left edge was about x=306. The widest card line ends near x=338, so the portrait covered the end of the text. |
| Vertical layout for 1 to 4 players | Shared bands | Already guarded by `hud_layout_test.lua`: no collisions, bands stay above the Risk lines, captions stay above the bands. |

## Changes

- **Long form lines move to row 1.** `HudLayout.DrawPlayer` splits a line at its two-space separators. The part that fits on row 0 stays there, and the rest moves to row 1 of the same player's band. Only Claude-chan otherwise uses row 1. All 20 other forms now draw through it.
  - At 480 wide only Qwen-chan's 74-character line splits.
  - At 400 and 360 wide the other long lines split too.
  - Text, colour and order are unchanged.
- **Dossier portraits keep clear of the text.** `Dossiers.Placement` keeps the portrait's left edge to the right of the widest text line, shrinking the portrait when the screen is narrow. Screens 640 wide and larger keep the original position and scale.
- **Tests.** `hud_layout_test.lua` now covers the split at 480, 400 and 360 wide, the routing of the 20 forms, and dossier placement for all 22 cards at four screen sizes. The form suites stub a 480-wide screen.

## Still open

- **Native HUD corners.** It is not yet observed whether the form lines at x=50 meet the trinket slot (bottom left) or the pocket-item slot and its name (bottom right). This is most likely with a large HUD offset or a second trinket. The mod's text does not follow `Options.HUDOffset`.
- **Real glyph widths.** The default font's real widths, and the Chinese/Japanese font, may differ from the 6 px estimate. Only Claude-chan's usage lines are translated.
- **Engine check.** Co-op with four players, Jacob and Esau, and a narrow window should be checked in the engine.
