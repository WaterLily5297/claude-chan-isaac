# In-game test checklist

## Native Thought adapters (source candidate; no engine acceptance)

Follow [NATIVE_THOUGHT.md](NATIVE_THOUGHT.md) for the current adapter table and weapon-specific engine matrix. The owner resumed muted engine testing on 2026-10-24; see [the engine audit](ENGINE_AUDIT_2026-10-24.md) for actual coverage. Ordinary tears, single-hit/released-ring lasers, repeated-hit beams, flying knives and Dr. Fetus now have source paths; Ludovico and repeated-hit beams use six-update windows. The earlier Rice checklist below describes the initial tear-only candidate. Epic Fetus, melee, delayed bursts and Incubus/Twisted Pair now have source adapters; their combat behavior still needs engine acceptance.

Verify actual callback order, damage refresh behavior, charged releases during food lockout, continuous fork update order, 1M Context decay, pause and mid-window save/continue before accepting any native weapon case. Source field assertions do not establish damage dealt, player appearance, steering or engine serialization. This follow-up does not pass the costume matrix.

## Tainted Gemini One More Edit (source candidate; engine acceptance pending)

Select Tainted Gemini-chan: deeper-colour Gemini art, damage 0.9x of Isaac's. HUD reads `DROP: start an edit`. In combat, tap/release DROP near an enemy (within about 180 units): `One more edit`, HUD `Crop 0/3  6s`. Hit it with three separate volleys: Recolor, Export, then `Exported` and one extra hit of double your damage. Tapping again in that room does nothing. In a new room, tap, hit twice, tap again: progress resets. Kill the target early or wait six seconds: the chain ends without the pulse. Birthright: 10 seconds. Save/continue in an exported room keeps it exported. Test Brimstone and 20/20 (each volley or beam window counts once).

## Tainted Grok Quote Without Reading (source candidate; engine acceptance pending)

Select Tainted Grok-chan: deeper-colour Grok art, damage 0.9x. HUD reads `DROP: quote someone`. Tap/release DROP near enemies: `Quoted`, HUD `Ratio 0/3  6s`. Hit other enemies with three separate volleys: Ratio 3/3. Hits on the quoted enemy do not count. After six seconds it takes three extra hits of your damage and `Ratio'd` appears. The HUD then shows the cooldown until ten seconds after you quoted. Kill the quoted enemy early: nothing lands. With Birthright, half the Ratio moves to the nearest survivor once. Save/continue keeps the cooldown.

## Tainted Qwen Final Final Fine-Tune (source candidate; engine acceptance pending)

Select Tainted Qwen-chan: deeper-colour Qwen art. HUD reads `Balanced  Variants 0/3  Awards 0/3`. In a cleared room, tap/release DROP: Heavy (hits harder, fires slower), Tiny (weaker, faster), Balanced. In combat the tap does nothing. Clear new combat rooms with each of the three builds: `Final final version` and +0.2 damage. Repeating a build or re-clearing a room does not count. Three awards at most. A new floor resets everything. Birthright makes each award +0.3. Save/continue keeps build, checklist and awards.

## Tainted Llama Still Waiting (source candidate; engine acceptance pending)

Select Tainted Llama-chan: deeper-colour Llama art, slightly lower damage. HUD reads `Hype 0/3`. Clear new combat rooms: Hype rises to 3 and stops. Tap/release DROP: `Still waiting...`, Hype empties and the HUD shows `Helper 12s` at three Hype. From the spot where DROP was tapped, a weak tear flies at the nearest enemy each second; none with no enemy within range. Leaving the room removes the helper. Birthright makes each Hype five seconds. Check the tears with Brimstone, Technology, knife and Dr. Fetus. Save/continue keeps Hype.

## Tainted Mistral Le Gros Chaton (source candidate; engine acceptance pending)

Select Tainted Mistral-chan: deeper-colour Mistral art, slightly slower and weaker. HUD reads `Baguettes 0/2`. Stand still without firing for two seconds: `Baguette baked`; a third never bakes. Tap/release DROP while aiming: `Baguette!`, and enemies along a 120-unit line take one heavy hit each as the wave passes, over about a second. A rock or wall stops it. The HUD shows a two-second cooldown. Leaving the room mid-wave cancels it. Birthright bakes in 1.5 seconds. Save/continue keeps Baguettes.

## Tainted Doubao I'll Do It Again (source candidate; engine acceptance pending)

Select Tainted Doubao-chan: deeper-colour Doubao art. HUD reads `Ready to promise`. Tap/release DROP: `Leave it to me!`, damage rises and the HUD shows `Confident 6s`, which only counts down while enemies remain. After it, `Sorry, you're right`, lower damage for four seconds, then `I'll do it again`. Get hit by an enemy or bullet during Confident: the Apology starts at once and the hit still hurts. Blood donation or IV Bag do not count. Birthright makes the Apology three seconds. Save/continue mid-phase keeps the phase and damage.

## Tainted Kimi You Are the Manager (source candidate; engine acceptance pending)

Select Tainted Kimi-chan: deeper-colour Kimi art, lower damage. HUD reads `Tasks 0/3  Budget 9/9`. In a hostile room, tap/release DROP three times: `You are the manager` and three enemies each take three small hits two seconds apart. A fourth tap does nothing. After that the room's budget is empty. Killing an assigned enemy early frees its slot only. Leave mid-task: the task stops; return and the budget is still spent. Birthright makes pulses stronger. Save/continue keeps budgets but not tasks.

## Tainted GLM Please Retry (source candidate; engine acceptance pending)

Select Tainted GLM-chan: deeper-colour GLM art, slightly lower damage. HUD reads `Retries 0/3`. In a hostile room, tap/release DROP: `Request queued` and `Request Pending 2s`; two seconds later the nearest enemy takes a heavy hit (`Request complete`). DROP is blocked for three seconds from selection. Kill the target before the request lands: `Please retry` and one Retry. With three Retries, a successful request hits at 5x and resets them. Leaving mid-request cancels it with no Retry. With Birthright, a failed request also removes the nearest enemy bullet. Save/continue keeps Retries.

## Tainted GPT Reset Watcher (source candidate; engine acceptance pending)

Select Tainted GPT-chan from the tainted menu: deeper-colour GPT art, one red and two soul hearts, one key. HUD reads `Credits 80/80  Standard  Next Reset 0/3`. Tap/release DROP: `Full Send`, damage 1.5x, and each volley (one 20/20 volley, one Brimstone beam, one Dr. Fetus bomb) costs one Credit. At zero she returns to Standard and a tap cannot re-enter Full Send. Clear three different hostile rooms: `Tibo: Reset Ready`; further clears do not advance while it is banked. The next tap refills Credits and does not toggle the mode. Birthright raises cap and refill to 100. New floor and save/continue keep Credits, mode, progress and the banked reset. Check that no proxy IP / risk HUD appears for her, that a long DROP hold drops trinkets normally, and the MAP dossier. Stub coverage is `tests/gpt_reset_test.lua`.

## Tainted DeepSeek Peak / Valley (source candidate; engine acceptance pending)

Start a new run: HUD reads `Compute 12/24  Valley 12.0s  Forks On`. In a hostile room the timer counts down and switches to Peak after twelve seconds, then back. In a cleared room and on the pause menu it must stop. Each new floor starts in Valley with the same Compute. In Valley, stop firing during combat: Compute rises by three per second up to 24 (32 with Birthright). Waiting in a cleared room must not add Compute.

Fire ordinary tears: each paid volley adds two half-damage forks at ±12° and costs 2 in Valley or 4 in Peak. With 20/20, Mutant Spider or Monstro's Lung, check one payment per same-frame volley and judge whether forking every pellet is too strong. Below the cost, only the main tear fires and no tear ever disappears. Tap/release DROP toggles `Saving`; a second tap inside one second is ignored, and holding DROP keeps native trinket dropping. Test pocket cycling with a pocket item.

Save/quit/continue mid-phase and in Saving mode: Compute, phase, remaining time and mode must return unchanged; the toggle cooldown intentionally resets. Test a new run, character change (Clicker), co-op with two tainted DeepSeeks (separate Compute) and death. Brimstone, Technology, knife, Dr. Fetus and Ludovico builds should attack normally with no forks and no Compute cost. Stub coverage is `tests/deepseek_peak_test.lua` and `tests/swarm_resolution_test.lua`; no engine pass is recorded.

## Normal GPT Same Name, Smaller Brain (source candidate; engine acceptance pending)

Start a new run: HUD reads `GPT-chan: Verified  Routing 0/3` and damage is 1.15x. Clear three different hostile rooms: Routing reaches 3/3. Re-entering a cleared room or clearing a room that never had enemies adds nothing. The next room with enemies must announce `Fallback` and drop damage to 0.8x. Firing rate stays native (the old Deliberate / Instant modes are gone).

In Fallback, tap/release DROP near an enemy (within about 200 units) to tag it as a Sanity Check; the HUD shows `Check 0/3`. Tapping with no enemy nearby spends nothing. Hit it with three separate volleys: Verified returns and Routing resets. A 20/20 or Mutant Spider volley must count once, as must a Brimstone beam within one fifth of a second. Kill a tagged enemy with your own hit: Verified returns immediately. Let another player or a familiar kill it, or leave the room: the check fails and Fallback stays until the next room. Birthright needs two hits. Holding DROP keeps native trinket dropping; test pocket cycling with a pocket item.

Save/quit/continue in Fallback: Fallback, Routing and the spent room check return unchanged, and a second tag in the same room is refused. A new floor restores Verified with Routing 0. Test co-op with two GPTs (separate Routing and checks), character change (Clicker) and death. Stub coverage is `tests/gpt_downgrade_test.lua`; no engine pass is recorded.

## Normal Mistral Le Chat (source candidate; engine acceptance pending)

Speed is +0.1 over Isaac. Move while firing for two seconds: HUD goes from `Charge N%` to `Pounce Ready`. Stand still for a second and it is lost. Tap/release DROP while aiming at enemies within about 80 units: each one in that line takes double your damage once, `Pounce!` appears, and `Cooldown 3s` follows. Enemies behind you, off to the side, beyond reach or behind rocks and walls are not hit. You do not move or gain invincibility. Birthright reaches about 110 units. Save/continue keeps a ready Pounce. There is no swipe animation yet; note how readable it is. Stub coverage is `tests/mistral_pounce_test.lua`.

## Normal GLM Number in Queue (source candidate; engine acceptance pending)

New run: HUD reads `GLM-chan: Number in queue 0/3`, with no pocket item. Each combat clear adds one, up to three; re-clearing a room or peaceful rooms add none. At three the HUD says `Your turn! Tap DROP`. Tap/release DROP: `Access granted`, `Access 2 room(s)`. The next two hostile rooms you have not entered yet this floor each give +20% damage while you stay in them (`Access active`). Rooms already visited and peaceful rooms do not use the pass. The Queue does not move until the pass is used up and you have left its last room. Birthright gives three rooms. Save/continue inside a boosted room keeps the bonus without spending again. Test two GLMs in co-op. Stub coverage is `tests/glm_queue_test.lua`.

## Normal Kimi Another Slide Deck (source candidate; engine acceptance pending)

New run: HUD reads `Kimi-chan: Slides 0/6  Cost 3`. Each combat clear adds a Slide, up to six; re-clearing a room or peaceful rooms add none. With three Slides, tap/release DROP near enemies: `Another slide deck`, up to three nearest enemies within about 220 units get a light blue tint and slow down for four seconds, and HUD shows `Presenting 4s`. Your hits on them deal 15% more; a partner's hits do not. Tapping with no enemy nearby or fewer than three Slides spends nothing. A second deck replaces the first. Leaving the room ends it without refund. Birthright makes the cost two. Check the tint is readable and never covers the screen. Test two Kimis in co-op. Stub coverage is `tests/kimi_slides_test.lua`.

## Normal Doubao Sorry, You're Right (source candidate; engine acceptance pending)

New run: HUD reads `Doubao-chan: No apology needed`. Get hit by an enemy or its bullet in a hostile room: `Apology ready`, then `Apology Ready 6s` counting down. A second hit in the same room grants nothing, even after the token expires. Blood Donation, IV Bag, Curse Room doors, spikes and your own bombs must not grant one. Tap/release DROP within six seconds: `Sorry, you're right.`; enemies within about 100 units are tinted and slowed for two seconds, and up to four nearby enemy bullets vanish. The hit's damage stays. Leaving the room drops the token. With Birthright the token reads `Apology Ready` and lasts until room exit. Save/continue keeps the token and the spent-room flag. Test two Doubaos in co-op. Stub coverage is `tests/doubao_apology_test.lua`.

## Normal Llama Please Stay Open (source candidate; engine acceptance pending)

New run: HUD reads `Llama-chan: Releases 1/2  Next 0/2`, damage 0.95x. Solo, tap/release DROP: four blue flies, Releases 0/2. In co-op each living player gets two flies (at most four players). Clears no longer give flies automatically; every two unique combat clears add a Release (cap 2). Birthright gives Llama two extra flies per Release. Save/continue keeps Releases and progress. Stub coverage is `tests/llama_release_test.lua`.

## Normal Qwen Everyone's Base Model (source candidate; engine acceptance pending)

New run: HUD reads `Qwen-chan: Adapters 1/2  Next Range  Active none`. Tap/release DROP to cycle Next through Range, Tempo and Power; nothing is spent. Walk into a new room with enemies: one Adapter is spent and `Active` shows the pick (Range +60, Tempo faster fire, Power +10% damage) until you leave. Re-entering a room you already fought in never spends. With no Adapters stats are normal. Every two unique combat clears add one (cap 2, Birthright 3). Save/continue mid-room keeps the active pick and does not spend again. Stub coverage is `tests/qwen_adapter_test.lua`.

## Normal Grok Is This True? (source candidate; engine acceptance pending)

In a hostile room, tap/release DROP near an enemy (about 220 units): `Is this true?` appears and the HUD shows `Check 0/3  6s`. In a cleared room, or with no enemy nearby, nothing happens and the room's check is not spent. For six seconds your damage to that enemy is 1.3x and to every other enemy 0.9x; a partner's damage is unchanged. Three separate volleys (a 20/20 volley or a 0.2-second Brimstone window counts once) or killing it yourself shows `Verified` and +0.15 speed until you leave the room. Timeout or another killer gives nothing. A second tap in the same room does nothing, including after save/continue. With Birthright, verifying removes the three nearest enemy bullets. Check on-hit effects with the re-dealt damage. Stub coverage is `tests/grok_check_test.lua`.

## Normal Gemini Nano Banana (source candidate; engine acceptance pending)

New run: HUD reads `Gemini-chan: Paint 2/3`. Tap/release DROP near an enemy (about 180 units): Paint drops by one and the HUD shows `Edit 8s`. With no enemy nearby nothing is spent. Your tears, Brimstone, knives and bombs should deal 20% more to the painted enemy only; a co-op partner's damage is unchanged. Check that damage numbers, i-frames, knockback and on-hit effects behave normally with the re-dealt hit, including other damage mods. Kill the painted enemy yourself: a yellow slowing creep appears for four seconds and slows enemies; a second peel removes the first. Leaving the room ends the mark without refund. Each unique combat clear adds one Paint up to three. Birthright makes it 30%. Save/continue keeps Paint; the live mark is intentionally dropped. Stub coverage is `tests/gemini_paint_test.lua`.

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

## Fifty-row backlog acceptance (pending)

Rows 02-50 (`scripts/items/backlog/`). Offline suites: `tests/backlog_items_test.lua`, `tests/backlog_more_test.lua`. In game, per item: spawn it, read the EID, check the icon, use or trigger it once and confirm no console error.

- Every active: Car Battery adds nothing; targeted actives keep their charge in an empty room; Void/wisp uses are harmless.
- Primes (Rice Cooker, Wengu Clock, Base Model, Quote Retort, Next Time Again, Rate-Limit Valve): one boosted attack each with tears, Brimstone, Technology, knives, Dr. Fetus and Ludovico; multi-shot volleys boost every tear once.
- Guards (One Bowl Only, Sold Out, Release Soon, Token Recall): an ordinary enemy shot is absorbed; champion/special shots, contact, Blood Donation and IV Bag are not.
- Unique clears (Routing Receipt, Final Final Weights, Herd Bell, Please Come Back, Smiling Correction, Overtime Slides, Queue Ticket): re-entering, continuing and boss rooms count once; Glowing Hourglass behavior is recorded.
- Saved state: save/exit/continue keeps Anniversary Cake, Tibo Reset, Error Budget and counters; a new run resets them; co-op players stay separate.
- Helpers: Unchanged Preview decoys draw nearby enemies and Stand-Up Meeting recalls them; Open Weights flies are native blue flies.
- Stats: Tiny Variant, Another Adapter, Slipstream Boots, Edge Compass, Live Wire and Cache Cartridge do not change sprite size or fight other stat items.

## Meme extras batch 1 acceptance (pending)

- Ignore All Previous Instructions: charmed target fights for you for 8 s and is not re-targeted by Car Battery; bosses only confused; empty room keeps charge; check with Compact and You're Absolutely Right!.
- Tungsten Cube: damage/speed in the stat HUD, knockback with tears, Brimstone, Technology, Mom's Knife and Dr. Fetus; stacking with D4/D100 rerolls.
- Pizza Glue: slowing tint and effect on tears; shot speed change; no effect on lasers/knives/bombs; Swarm and Peak/Valley fork copies; continue keeps the native item RNG sequence.

## Meme extras batches 4-5 acceptance (pending)

- Seahorse Emoji: wisp appears, fights and is removed on room exit; save/exit mid-room (untracked wisp risk); Book of Virtues and other wisp items unaffected.
- Temperature Dial: toggle text and damage; each listed flag visibly applies; interaction with other tear-flag items; continue keeps the temperature.
- Deep Research: full reveal including secret and super secret rooms; Curse of the Lost/Unknown display.
- As an AI Language Model: removal of each curse type mid-floor (Darkness, Lost, Unknown, Maze, Blind, Giant), Labyrinth kept, continue does not refuse twice.
- System Prompt Leak: compass reveal on each floor and on mid-floor pickup.
- Disgrace Loop: freeze on bosses and freeze-immune enemies; Holy Mantle hits; co-op once per player.
- Rolled Back: stat HUD, horse pill detection, room change rollback, continue mid-room drops the bonus.

## Meme extras batch 3 acceptance (pending)

- Strawberry: count with 20/20, Inner Eye, Mutant Spider, Monstro's Lung and Summary Stapler tears; interaction with Hardcoded Output, DeepSeek Thought/forks and Swarm copies; red tint over item colors.
- Golden Gate Claude: spectral tears over rocks and through poop/fires as vanilla Ouija Board; range stat display; tint with Ipecac/Spoon Bender; caption frequency.

## Meme extras batch 2 acceptance (pending)

- Claudius's Discount: shop items, hearts, keys and restocks priced 2+ refund once; 1-coin items do not; devil deals, free items and Keeper are unaffected; Steam Sale and coin-cost items from other mods; new floor charge once, and not again on continue.
- One Small Rock a Day: rocks broken by bombs, tears (Terra/Ipecac), enemies and stomps; tinted/special/spiked rocks; full health and soul-only characters; continue on the same floor does not restore the rock.
- Stuck in Mt. Moon: callback order on continue, curse rooms, red rooms, and the vanilla map display after the effect.
- 9.11 > 9.9: whether the game passes pill color (horse pill), PHD/False PHD, pill identification text, continue and co-op.

## Summary Stapler acceptance (pending)

Give Summary Stapler in a disposable run. Verify four room charges, empty use preserving charge, nearest-first absorption capped at twelve within 120 units, and exclusion of special-flag/variant, friendly, player/familiar, dead or source-less projectiles. Aim diagonally and use without shooting; check the speed-6 native tear and base damage multiplier 1 + count/4. Car Battery must neither absorb a second batch nor fire again. Verify co-op ownership and both active slots.

Test homing, piercing, spectral, explosive, split/orbit/controlled tear items and Tractor Beam. Brimstone, knives, lasers and bombs must remain the primary weapon; the active emits a separate tear and must not replace their appearance. Check native callback timing with Swarm, Claude's usage/limited damage, tainted quota, Deep Think, and DeepSeek cancellation/forks. Successful absorption consumes charge even if character logic cancels the retaliation. Test save/restart with the item charged and discharged, room transition, reroll/removal and the costume matrix. Special modded projectiles that look ordinary may need explicit compatibility rules; generic filtering does not prove every other mod is safe.

## Vanilla item appearance acceptance (pending)

Run the per-form matrix in [COSTUME_COMPATIBILITY.md](COSTUME_COMPATIBILITY.md): isolated items, mixed pickup orders, flight, scale, transformations, removal, reroll, restart and co-op/type changes. The nine added normal skins have an offline head/carry alignment correction; this is not engine acceptance. Existing four-character art and the planned nine tainted forms require the same matrix. Record screenshots and exact versions; Lua tests and texture dimensions cannot establish visual compatibility.

## Normal Claude Appeals (source candidate; engine acceptance pending)

HUD shows `Usage N%  Appeals 1/2` on a new run. Fire single tears and a 20/20 or Mutant Spider volley: each volley adds 4 usage (8 with Subagent Swarm), not 4 per pellet. Stop firing: usage drains 10 per second; holding fire stops the drain. The volley that reaches 100 keeps full damage, then Limited weakens tears for five seconds.

Tap/release DROP at about 60 usage: one Appeal is spent, usage drops by 40, caption `Appeal filed / Another love letter.`. A tap at zero usage, at zero Appeals or during Limited must spend nothing. Holding DROP must keep native trinket dropping; check pocket cycling with a second pocket item. Clear two new hostile rooms: +1 Appeal (cap 2); re-entering a cleared room or clearing an empty room gives nothing.

Get Birthright and reach 90+ risk: `Banned again / Birthright kept your account age`, age unchanged and the Suspended penalty still applies. A second suspension on the same floor resets age; the next floor renews the shield. Save/continue while suspended must not reset age. Save/continue mid-progress keeps Appeals and the clear count. Co-op with two Claude-chans keeps separate usage and Appeals. With Brimstone or Technology, each laser start bills 4 usage (once per frame with tears); a held Tech 2 beam pays once; Dr. Fetus bombs bill; knives and placed bombs do not. Tainted Claude pays Quota the same way. Stub coverage: `tests/claude_appeals_test.lua`, `tests/claude_usage_save_test.lua`, `tests/swarm_resolution_test.lua`.

## Normal Claude usage save acceptance (pending)

TIMER-01 source candidate adds per-player/frame deduplication and explicit pause/death freezes for Limited and idle drain. The expanded `claude_usage_save_test.lua` fails against main `2ec15ef` when a duplicate wrapper callback reduces the timer twice. It also checks two-player isolation, exact expiry over active frames, paused/dead callbacks, revival without catch-up, drain deduplication and fresh/continued runs at the same frame. The older 149-step countdown fixture now advances 149 actual frame values rather than invoking one frame repeatedly. These are offline assertions, not evidence that the engine normally invokes duplicate callbacks.

Engine retest pending: reach Limited naturally, verify the five-second countdown over active gameplay updates, pause/resume, die/revive, and save/continue mid-countdown. Confirm idle drain stays ten per second, held fire blocks drain, two Claudes remain independent, and pause/death interrupts DROP without consuming an Appeal after recovery. If using an explicit duplicate-callback fixture, distinguish it from normal engine delivery. Do not close timer acceptance from this regression alone.

As normal Claude, save with a partially filled meter, close the process, restart and continue. The meter must resume rather than clear. Repeat during the five-second limited-damage interval and confirm the remaining game-frame countdown and 40% damage. Repeat with two Claude players at different usage levels, with Swarm (including the first continued shot), after Compact, and immediately after Banked Reset. Continue must preserve the item changes and keep players independent. Verify a fresh run resets both meters and an older save without usage fields loads safely. Check Clicker away/back, co-op join/leave, and supported twin/subplayer forms separately; the slot-keyed stub does not prove their engine identity behavior. The penalty expires through gameplay frames; offline wall-clock time is not credited.

## Original character movement revision (engine acceptance pending)

Inspect normal and tainted Claude/DeepSeek at actual gameplay scale. Check idle and firing faces in all directions, mirrored left profiles, rear silhouettes, body/head attachment during walking, and carrying an item while walking. Confirm the carry-head frame does not produce a second body. Test body visibility against dark rooms and with costumes. Compare save/continue appearance, then inspect retained flying, hurt, death and special poses for style and alignment differences. The offline preview and atlas checks do not complete these tests.

## Fork property inheritance acceptance (pending)

Test tainted DeepSeek alone, Isaac holding Subagent Swarm, tainted DeepSeek with Swarm, and normal DeepSeek's fully charged Deep Think with Swarm. Compare the natural tear and its children using Spoon Bender, Cupid's Arrow, Ouija Board, My Reflection, Ipecac and Cricket's Body. Check actual tracking, piercing, wall passage, trajectory/range, explosions and bounded splitting; copied flags alone do not prove those effects work in the engine. Deep Think children should display the boosted size and retain half the resolved parent damage. No DeepSeek shot is randomly removed any longer.

Also test Tiny Planet, Anti-Gravity, Eye of the Occult and Ludovico separately: these flags can depend on engine-managed motion or controller state that is not recreated by copying fields. Record unsupported behavior explicitly rather than claiming universal tear compatibility. Recheck both Claude limits, two-player ownership, split-shot growth, other mods' tear-init callbacks and frame time under high fire rate. The new regression verifies property transfer and existing spawn counts only; it provides no FPS or engine-pass evidence.

## Eleven-family expansion acceptance (all pending)

Offline coverage is described in `MODEL_ROSTER.md`; it does not tick these boxes.

- Select all eleven normal families and both existing tainted characters. Check the correct name, bust, stage portrait and full MAP dossier. No missing textures or duplicate menu entries.
- Roster-only and DeepSeek-plus-roster runs show no IP/risk HUD. With Claude in co-op, a roster player's hit adds no risk and suspension lowers only Claude's damage. Blood Donation, IV Bag and a sacrifice room never grant Doubao an Apology. Roster tears keep Ipecac/Spoon Bender colors under the family tint.
- Inspect every new skin facing front, right, rear and left, while walking, firing, holding an item, flying, hurt and dead. Check for clipping, stray neighboring pixels, incorrect back views and doubled heads. Alternate arm poses remain provisional.
- For GPT and Gemini, tap DROP through both modes, then save/quit/close/restart/continue. The mode must persist. Check the original DROP behavior with held trinkets and controller input.
- For Grok and Mistral, reach maximum movement/firing charge, stop, change rooms, and start a new run. Temporary charge must reset and stay bounded.
- For Kimi, save and continue right after a clear, then revisit the room. The Slide must not be awarded twice.
- For Llama, reach the reward threshold, save/continue, and revisit the same room. Rewards must not duplicate. Include dead players, two holders and a non-holder in co-op.
- For GLM, redeem an Access Pass, save/continue inside a boosted room and on a new floor. The pass must not spend twice or stack.
- For callback identity, compare Grok's HUD momentum with its damage increase through repeated cache refreshes; confirm Mistral gains spectral tears at full wind and loses them when stopping. Repeat with two players and character-changing effects. Distinct-wrapper stub coverage passes; these engine checks remain pending.
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
- Roster arcs: start a run as any non-Claude family (normal or tainted) and see its chapter 1, then chapter 2 at stage 3 and chapter 3 at stage 5. With Claude in co-op, both captions show without overlapping. Save and continue mid-caption: it does not repeat, and a queued one still plays. Offline suite: `tests/story_roster_test.lua`.
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
| C10 | Tainted Claude-chan: shoot ~220 volleys on one floor | HUD `Quota N/220  Pages 2/2` drops by one per volley (two with Subagent Swarm); at zero `Suspended`, half damage, grey-tinted tears; DROP tap starts `Under Review: 6s` (frozen in cleared rooms/pause, cancelled by leaving) then +60 Quota; next floor refills; Banked Reset refills and cancels a review | |

### Repeatable manual engine probe

Use only a disposable, owned stage-1 **Claude-chan** run (since v0.5-dev; the probe puts a Support Ticket into her pocket slot, replacing the Ban Hammer for that run). The passes below were recorded on the v0.4 build in a DeepSeek-chan run, before the redesign. In the game debug console run:

```lua
lua Isaac.RunCallback("ClaudeChan:RunRuntimeProbe")
```

Close the console and let the simulation run for about 13 seconds. This sets test coins/risk, uses the real pocket-item input, adds Car Battery, changes to stage 3 and round-trips this mod's run data. It does not change other mods' settings. Do not invoke it in a run you intend to preserve. Normal gameplay never calls it. A duplicate probe is rejected; input is removed on completion, failure or game exit.

The probe must print `CCQA PASS` for insufficient funds (2/50/6), Car Battery (3/30/0), simultaneous captions (one pending), queue save/load (seen=11, pending=0), and completion. These assertions passed in Repentance+ 1.9.7.17 on 2026-10-23. They use the active shared Risk object, never a fresh `include("scripts.risk")`. The save/load case exercises the real mod JSON persistence and story-start handler; it does not replace a full application-restart/save-slot test.

## Native Thought adapters: bursts, familiars, melee, Epic Fetus

Offline suite: `tests/thought_adapters_test.lua`. In game, as normal DeepSeek-chan with full Thought:

- Cursed Eye: one charged burst spends Thought once and every tear of the burst is boosted.
- Incubus or Twisted Pair: copies fired with a boosted volley are boosted; copies alone never spend Thought.
- The Forgotten's club and Spirit Sword: each swing spends once; holding the weapon spends nothing.
- Epic Fetus: each rocket spends once and its explosion deals the boosted damage; Dr. Fetus bombs are not boosted twice.
- Pause or leave the room mid-burst: no extra payment and no lasting damage change.
