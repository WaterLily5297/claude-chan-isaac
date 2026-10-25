# O1: separate character abilities from pocket cycling

Reviewed 2026-10-26 against main `2182cb1`, after D1/PR #93. This is a source/API audit with an offline reproduction, not a control change or native acceptance. The installed `e1ff4d1` build is preserved.

## Finding

A player trying to select a card or pocket active can also spend a character ability on the same DROP gesture. Every one of the 22 form modules uses the shared `scripts/characters/drop_tap.lua`; it reads ACTION_DROP, accepts a release after 1-12 updates and returns true without checking pocket contents or consuming native input. Individual forms add their own readiness conditions. For example, normal DeepSeek spends a bowl and starts its meal on that result. A short release alone therefore does not separate ability use from native cycling.

The current test covers real Rice, MealBreak and DropTap modules. With a modeled card/pocket-active or card/pill pair, native DROP hooks return nil and a short release spends the bowl. The fixture supplies a pocket rotation before or after the mod update and confirms both outcomes coexist, while a second controller remains unaffected. Its long-hold control preserves the bowl and returns no native input override. This establishes the source conflict, **not** the engine's selection order, controller timing or physical dropping.

## API evidence and limits

- The community-maintained [Repentance ButtonAction reference](https://wofsauge.github.io/IsaacDocs/rep/enums/ButtonAction.html) identifies ACTION_DROP as value 11; the [Input reference](https://wofsauge.github.io/IsaacDocs/rep/Input.html#isactionpressed) describes IsActionPressed as a held-state query.
- The [Repentance input callback reference](https://wofsauge.github.io/IsaacDocs/rep/enums/ModCallbacks.html#mc_input_action) distinguishes reading input from overriding engine polls. Returning nil leaves a poll unchanged; input hooks do not alter custom code reading the Input class. The existing meal callback only suppresses directional shooting.
- The extension's official [REPENTOGON pocket-swap callback documentation](https://repentogon.com/enums/ModCallbacks.html#mc_pre_player_pocket_items_swap) explicitly ties pocket swapping to DROP, including empty slots. It supplies a cancellable swap callback. **REPENTOGON is not a project requirement**; this callback cannot be assumed present in base Repentance or Repentance+.
- [IsaacScript's maintained ButtonAction definitions](https://isaacscript.github.io/isaac-typescript-definitions/enums/buttonaction/#drop) also record card switching and other native uses of DROP. This is supporting implementation documentation, not an engine test of this mod.

The references justify treating the overlap as real risk, but they do not determine the exact native swap timing on the owner's build. We have no new engine observation. E4 must test both keyboard and controller, and both supported game variants where available.

## Owner decision

The next-session instruction explicitly reserves changes to the ability gesture for the owner. The current source and player-facing controls remain unchanged pending that decision.

| Option | Player interaction | Trade-off |
|---|---|---|
| **A: MAP + short DROP (recommended)** | Plain DROP cycles pockets and long DROP retains native dropping. Hold MAP before pressing DROP; release DROP within the existing short-tap window to use the ability. | Abilities remain available while carrying cards/actives, but need a two-button gesture. A narrowly scoped native swap guard is required for the chord; merely checking MAP would still allow the original double action. MAP already opens dossiers and may interact with EID. |
| B: plain DROP only when nothing can cycle | Keep the current short-tap gesture, but reject the ability whenever more than one pocket item can be selected. Native cycling/dropping stays untouched. | Smallest control change, but abilities become unavailable while carrying a card plus pocket active or multiple cards/pills. Pocket eligibility must include all supported slots and inventory changes during the gesture; a naive active-slot-only check is insufficient. |

Recommend A because carrying a card should not disable a form's main mechanic. This is a proposal, not an implemented or verified binding. A double-tap alone is not recommended: both taps can still cycle native pockets unless additional filtering delays or changes normal input.

## Acceptance contract for an approved implementation

1. Keep plain native cycling, card/pill/active use and long-hold dropping. Limit any chord swap guard to the eligible local mod player and the relevant native poll; never globally suppress DROP or other players' input.
2. Arm only after a release; cancel on pause, disabled controls, ghost/death, controller/type/seed changes, room/run transitions or modifier loss. Never fire after an interrupted chord or long hold. Preserve one ability per gesture.
3. Cover card + pocket active, two cards, card + pill, empty/one item, both pocket active slots, pickup/use while held and co-op. Check input poll order, MAP dossiers, EID and other input mods. Do not infer those outcomes from the current modeled rotation.
4. Update all 22 forms' control descriptions through shared services, dossiers, EID, MODEL_ROSTER/CHARACTER_GAMEPLAY, all three READMEs and TESTING. Replace the known-conflict characterization with assertions for the chosen behavior; keep the hold/interruption tests.
5. Run E4 physically on keyboard and controller with an exact game/mod version. This audit leaves the native compatibility issue open and does not authorize game input or runtime replacement.
