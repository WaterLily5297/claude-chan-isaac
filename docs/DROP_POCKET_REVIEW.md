# O1: separate character abilities from pocket cycling

Reviewed 2026-10-26 against main `2182cb1`, after D1/PR #93. The owner selected option B: retain short DROP but disable abilities with multiple pocket items. This source correction includes offline regressions; native acceptance remains pending. The installed `e1ff4d1` build is preserved.

## Original finding

At main `2182cb1`, a player trying to select a card or pocket active could also spend a character ability on the same DROP gesture. All 22 form modules use the shared `scripts/characters/drop_tap.lua`; the old tracker read ACTION_DROP and accepted a release after 1-12 updates without checking pocket contents or consuming native input. Individual forms add their own readiness conditions. For example, normal DeepSeek spent a bowl and started its meal on that result. A short release alone therefore did not separate ability use from native cycling.

The initial audit test at `440dc6e` covered real Rice, MealBreak and DropTap modules. With a modeled card/pocket-active or card/pill pair, native DROP hooks return nil and a short release spends the bowl. The fixture supplies a pocket rotation before or after the mod update and confirms both outcomes coexist, while a second controller remains unaffected. Its long-hold control preserves the bowl and returns no native input override. This establishes the source conflict, **not** the engine's selection order, controller timing or physical dropping.

## API evidence and limits

- The community-maintained [Repentance ButtonAction reference](https://wofsauge.github.io/IsaacDocs/rep/enums/ButtonAction.html) identifies ACTION_DROP as value 11; the [Input reference](https://wofsauge.github.io/IsaacDocs/rep/Input.html#isactionpressed) describes IsActionPressed as a held-state query.
- The [Repentance input callback reference](https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html#mc_input_action) distinguishes reading input from overriding engine polls. Returning nil leaves a poll unchanged; input hooks do not alter custom code reading the Input class. The existing meal callback only suppresses directional shooting.
- The extension's official [REPENTOGON pocket-swap callback documentation](https://repentogon.com/enums/ModCallbacks.html#mc_pre_player_pocket_items_swap) explicitly ties pocket swapping to DROP, including empty slots. It supplies a cancellable swap callback. **REPENTOGON is not a project requirement**; this callback cannot be assumed present in base Repentance or Repentance+.
- [IsaacScript's maintained ButtonAction definitions](https://isaacscript.github.io/isaac-typescript-definitions/enums/buttonaction/#drop) also record card switching and other native uses of DROP. This is supporting implementation documentation, not an engine test of this mod.

The references justify treating the overlap as real risk, but they do not determine the exact native swap timing on the owner's build. We have no new engine observation. E4 must test both keyboard and controller, and both supported game variants where available.

## Owner decision and implementation

The owner chose **plain short DROP with abilities disabled for multiple pocket items** on 2026-10-26. MAP + DROP was proposed and declined; it is not implemented. The trade-off is explicit: carrying a card plus pocket active, multiple cards/pills, or both pocket actives makes the character ability unavailable until the inventory is reduced.

The shared tracker counts occupied card/pill slots 0-3 plus active slots SLOT_POCKET and SLOT_POCKET2. Main and Schoolbag active slots do not count. [GetCard/GetPill](https://wofsauge.github.io/IsaacDocs/rep/EntityPlayer.html#getcard) document slots 0-3; [ActiveSlot](https://wofsauge.github.io/IsaacDocs/rep/enums/ActiveSlot.html) defines the two pocket-active slots. The base API warns that GetPocketItem returns unusable userdata, so the implementation uses the concrete getters instead. It does not add a REPENTOGON dependency.

Once multiple pocket items are observed during a press or its release, the whole gesture is cancelled. Using/dropping an item while still holding DROP does not rearm it; the next clean press after release may use the ability. Checks precede same-frame deduplication so a later callback can observe a changed inventory. Existing identity, pause, ghost, death and long-hold rules remain. No native input override, item removal, charge change or saved state is added.

## Offline evidence

The expanded `tests/drop_tap_test.lua` fails on main `2182cb1` at the card + pocket-active assertion. It covers every card/pill slot pairing, both pocket actives, empty/single-item controls, exclusion of main/Schoolbag actives, press/hold/release/same-frame inventory changes, rearming and co-op isolation. Existing timing/interruption cases remain.

The real Rice/Meal/DropTap regression in `tests/deepseek_rice_test.lua` now asserts that a supplied native pocket rotation leaves the bowl and meal state unchanged; it also keeps the native poll, second-controller and long-hold controls. The rotation is still modeled, not an engine observation. Older form fixtures now explicitly expose empty native pocket getters rather than relying on missing methods. EID coverage requires the restriction for all 22 forms in every registered language, and the shared MAP dossier and all three READMEs explain it.

The full gate passes 67 offline suites, 177 tracked Lua files, five XML files and deterministic assets. Five focused mutations fail: missing extra consumable slots, missing the temporary pocket active, losing cancellation, ignoring same-frame inventory changes and rejecting a single pocket item. The initial broader run exposed two incomplete older fixtures; their missing getter stubs were corrected before the passing run. No native behavior was inferred from those fixture repairs.

## Remaining engine acceptance

Run E4 on keyboard/controller with the exact game/mod version: card + pocket active, two cards, card + pill, both pocket-active slots, slots 2/3, empty/one item, inventory changes while held, long holds, pause, rooms, death/ghost and co-op reassignment. Check that native selection/use/drop remains unchanged and ability resources do not move during a multi-pocket gesture. Then remove/use the extra item, release and verify the next short tap can use the ability.

Test base Repentance and Repentance+ separately where available, plus MAP dossiers, EID and input mods. Schoolbag/Marked and other native uses of DROP are outside the selected pocket-count policy and remain explicit engine cases. Inventory changes entirely between sampled callbacks cannot be reconstructed by this observer. Source tests do not establish exact native swap timing, physical input, HUD readability or normal-run usability. Installed e1ff4d1 remains unchanged; this source change does not authorize game input or deployment.
