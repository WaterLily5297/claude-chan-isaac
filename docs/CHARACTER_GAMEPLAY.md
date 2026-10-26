# Community-meme character gameplay

Revision 2, 2026-10-23; source statuses audited 2026-10-26 through merged #107; see [CHARACTER_COMPLETION.md](CHARACTER_COMPLETION.md) for the per-form evidence and gaps. All 22 additional B1 conditions are implemented, approved for merge and installed in gameplay checkpoint ef7d2dd; native gameplay and balance acceptance remain pending. This replaces the capability-based draft after the owner's correction: recognizable community jokes must lead the design. **Design targets, not accepted balance.** All 22 forms (11 normal, 11 tainted) are implemented in source with offline tests; each "Source status" line below records where the source differs from or refines the target. Tainted DeepSeek's non-tear rule was chosen on 2026-10-24 (see its section). Engine acceptance is pending for every form. See MODEL_ROSTER.md and the character modules for actual behavior.

The owner explicitly selected Claude bans and anger at Dario, DeepSeek free rice and Liang Wenfeng / Liang Wengu, and GPT perceived downgrades and Tibo resets. Other families have researched candidates. [COMMUNITY_MEME_RESEARCH.md](COMMUNITY_MEME_RESEARCH.md) distinguishes direct posts, secondary accounts and blocked videos. None of these samples establishes majority opinion or verifies an allegation about a person.

## Shared contract

- Keep the selected portrait identities and English names. Subtitles below are fictional gameplay roles. New code, descriptions, HUD, story and dossiers use English.
- Tap DROP resolves on a 1-12-frame release only with at most one pocket item. Multiple cards/pills/pocket actives reserve that gesture for native cycling; main/Schoolbag actives are not counted. Seeing a conflict while held cancels the whole gesture until release. Long holds retain native dropping. The shared observer serves all 22 forms; no target means no resource spend. Keyboard/controller acceptance remains pending.
- All resources and remaining timers belong to one player and survive continue. Pause/menu time does not advance timers. No duplicate reward from door re-entry, spawned children, respawned enemies or fake hits. A unique clear is a newly completed hostile room.
- Current source qualification: the broad Continue target above is not fully implemented for live checks, targets, helpers, tasks and several cooldowns. Per-form source descriptions and CHARACTER_COMPLETION.md identify what actually persists. Do not silently add refunds or persistence while reconciling this difference. Normal Claude also deliberately retains debt when the same live pointer/seed leaves and returns to the form; #107 retires only a changed live owner or an observed removed slot.
- One paid attack is one volley or one 0.2-second continuous-weapon window. Derived effects cannot recursively pay or trigger themselves. Charge weapons snapshot at release. Normal DeepSeek now has initial native adapters described in NATIVE_THOUGHT.md; delayed bursts, Epic Fetus, melee, familiar ownership and engine acceptance remain required work. The allowance forms (Claude, tainted Claude, tainted GPT) bill every native weapon through `scripts/characters/paid_attacks.lua`; the DROP-target families count distinct paid hits with `target_tools.lua`.
- Base stats are Isaac's before items unless specified. Normal starting health: two red and one soul heart; tainted: one red and two soul hearts, except DeepSeek retains one red and one soul heart. New normal forms get one bomb; new tainted forms get one key. Original-four pickups remain until migrated explicitly. No starting pocket active except those named below.
- Listed multipliers replace old form multipliers; do not stack both systems accidentally. Persistent bonuses use cache evaluation. Enemy damage retains owner attribution and recursion guards. Ordinary weapons, flight, scale and transformations remain native; item costume layers are cleared so each form keeps its own look (owner, 2026-10-24; `costume_lock.lua`). Never continuously replace the whole player sprite.
- Room effects end on exit without refund. Save uses versioned per-player data, never serialized entity references. Character changes cannot transfer rewards to another form. Bosses, co-op duplicates and save/continue require specific tests.
- At most two resource meters per form; current phase and transient labels are not extra currencies. Failure always preserves a usable main attack. No hidden random shot cancellation, permanent inventory loss or real-time waiting.
- Every Birthright listed below is implemented in source (engine acceptance pending). Intrinsic abilities do not count toward the fifty additional collectibles.

## Claude — account survival and appeals

The red stamp and rejection letter carry the ban/Dario frustration joke. The adversary remains a fictional account system, not a real-person enemy.

### Normal: One More Day

Usage runs 0–100. Paid attacks add 4; not firing drains 10 per second. At 100, display Limited for five seconds with 0.4x damage, then reset usage. Otherwise damage is 1x. Two unique combat clears earn one Appeal, cap two; start with one. DROP spends an Appeal to remove 40 usage, but cannot cancel an active Limited penalty. Choose prevention rather than a free recovery after overspending.

Keep pocket Ban Hammer, range +60, shot speed +0.2 and speed -0.1. Each later floor offers a review in the first new fight with at least two vulnerable enemies. Defeat the marked target last for +0.2 account-age damage, cap +1.6; simultaneous deaths count. Early defeat, leaving or an unavailable target misses only this floor. Completing while Suspended gives no award; the existing suspension reset and Birthright shield remain. Migrate age to per-player state. Existing Claude risk/encounter co-op behavior needs its own review. Swarm adds one extra 4-point payment per paid attack; Compact keeps its explicit bill. Birthright preserves age through the first suspension each floor without canceling its penalty. HUD: Usage, Appeals; account age belongs in the dossier/status line. Caption: `Another love letter.`

Source status (scripts/characters/claude_chan.lua): implemented for every native weapon. Tear volleys, laser starts and Dr. Fetus bombs pay once per frame; `scripts/characters/paid_attacks.lua` bills each further 0.2-second window of a held repeated-hit beam or a steered Ludovico tear, each knife throw, each melee swing hitbox and each Epic Fetus rocket. Limited is a 0.4x damage-stat multiplier through cache evaluation, so it weakens every weapon; the triggering volley keeps the damage it was fired with, and an item that ends Limited (Banked Reset) restores damage on the next update. Account age is per player in `claudeUsage[slot].age`; a save with the old shared `accountAge` hands it to every Claude present on continue. Suspension is still the shared account state; each Claude judges it once with its own Birthright shield. The caption appears when an Appeal is filed. An Appeal at zero usage is refused rather than wasted. Engine acceptance pending.

### Tainted: Appeal Pending

Start each floor with 220 Quota and two Appeal Pages, cap two. Registered attacks cost one quota and deal 1.25x damage. At zero, retain a usable 0.5x attack under Suspended. DROP while suspended spends a page and starts six seconds of active-combat review while not attacking, then restores 60 quota. Shooting pauses it without cancelling or spending another page. One review at a time. Exit cancels it without refund. Three unique clears earn a page.

Keep pocket Banked Reset for immediate refill. Using it cancels any pending review without returning the page; no double payout. Swarm costs one extra quota per paid attack. New floor refills quota and pages; continue does not. Birthright restores 90 per completed review. HUD: Quota, Appeal Pages, transient `Under Review: Ns`. The contrast is preserving an old account versus surviving repeated suspensions.

Source status (scripts/characters/claude_chan_b.lua): implemented and replaces the 220-tear weekly limit. Tears, laser starts and Dr. Fetus bombs share one Quota payment per frame; held beams, Ludovico windows, knife throws, swings and Epic Fetus rockets pay through the shared paid-attack observer. Damage uses cache evaluation (1.25x, 0.5x Suspended), so every weapon gets the multiplier. Saved per player in `Risk.state.claudeAppeal`. Engine acceptance pending.

## DeepSeek — rice and peak/valley scheduling

Rice belongs here as a defining joke. Liang Wenfeng / Liang Wengu is rendered as Peak / Valley wordplay. Neither form receives proxy, IP, risk or risk-scaled enemy mechanics.

### Normal: Rice First

Base damage 0.9x. Not firing charges up to five seconds of Thought; the next paid attack consumes it for up to 2x damage. Moving is allowed. Start with one Rice Bowl, cap two; earn one per two unique clears. Stand still and tap DROP to spend one on a two-second Lunch, then receive full Thought and +0.15 speed for six seconds. Voluntary movement cancels the intrinsic meal and refunds its single Bowl once, without a meal reward. Movement is never blocked. A later food effect retains its own lockout. Waiting in an empty room cannot farm bowls.

Keep pocket Lunch Break's explicit charged heal/lockout as a separate active. The intrinsic bowl gives no healing and cannot activate during either lunch lockout. Remove random Server Busy shot deletion only when this replacement is implemented and tested. Birthright reduces Lunch to one second. HUD: Thought, Rice. Caption: `One bowl per customer.`

### Tainted: Wenfeng / Wengu

Base damage 0.8x. Alternate twelve active-combat seconds of Valley and twelve of Peak, with visible timer. Start each floor in Valley. Empty rooms freeze the timer; continue preserves it. Start a new run with 12 Compute, cap 24. Valley recovers 3 Compute per second when not firing. Paid attacks add two native half-damage forks when affordable: cost 2 in Valley, 4 in Peak. Insufficient Compute suppresses only the extra forks.

DROP toggles Forks On / Saving with a one-second cooldown. Saving keeps the primary attack and spends nothing. Entering Peak reserves up to four available Compute, unavailable until the next Valley or floor. Return the reservation once within the total cap; new floors preserve Compute while resetting phase. Forks cannot fork recursively; non-tear builds need an equivalent bounded damage budget before compatibility acceptance. Birthright raises the cap to 32. HUD: Compute, phase/timer, mode label. The decision is when computation is cheap, not whether a proxy is safe.

Source status (scripts/characters/deepseek_peak.lua): implemented for ordinary tears. Valley recovery counts only in uncleared rooms, matching the frozen timer, so idling in an empty room cannot refill Compute. One payment covers a same-frame volley and every tear in it forks once. The toggle cooldown is transient. Non-tear weapons follow the rule chosen on 2026-10-24 (the owner delegated it to the DeepSeek off-peak-discount meme): a laser start or 0.2-second beam window, knife throw, melee swing, Dr. Fetus bomb or Epic Fetus rocket pays the same phase price and, when paid, its hits are re-dealt at 1.3x (two half-damage forks landed on one target), sharing the frame's payment with tears. Saving or too little Compute leaves native damage and spends nothing. Ludovico tears keep the tear rule. PEAK-CHILD-LASER-01 lets validated laser children share the parent's resolved boost and current paid/unpaid window without spending Compute or extending expiry. Known children remain excluded after Parent removal, and room/run or player-binding changes invalidate their transient decision. Both this follow-up and the later BACKLOG-LASER-INIT-01 item-prime correction are included in installed `8fd6a8c` (gameplay checkpoint `ef7d2dd`). Installation is not native ancestry or gameplay acceptance.

## GPT — downgrade and Tibo reset

The downgrade complaint and Codex reset ritual are separate memes. A fictional reset restores an allowance; it does not assert that actual quota resets fix model quality.

### Normal: Same Name, Smaller Brain

Start each floor Verified at 1.15x damage. Each unique combat clear adds one Routing mark, cap three. At three, the next combat begins in announced Fallback at 0.8x damage. DROP in Fallback tags the nearest vulnerable enemy within 200 units as a Sanity Check, once per room. Three distinct paid attacks that damage it, or its owner-attributed defeat, restore Verified and clear Routing. A distinct off-target paid attack erases one hit, minimum zero. The selected target wins for a mixed attack, including a delayed piercing hit; helper/unpaid/partner hits do not contradict. Bosses can satisfy the three-hit route without dying.

Derived effects cannot count multiple times for one attack. Failed verification leaves Fallback until the next room's attempt. Floor transition restores Verified; continue does not. Birthright requires only two paid hits. HUD: Verified / Fallback, Routing, transient Check progress. The player can actively correct the downgrade instead of suffering a silent random debuff.

Source status (scripts/characters/gpt_downgrade.lua): implemented and replaces the old Deliberate / Instant modes. A unique combat clear is a room seen with enemies while the player was present, once per floor. An attack is a registered tear volley (shared by its same-frame derived copies), a Dr. Fetus bomb, or one six-update window of a laser or knife; unregistered split tears and familiars do not count. The defeat route needs the owner's damage on the same or previous update. A spent check is saved per room, so continue cannot grant a second attempt. Engine acceptance pending.

### Tainted: Reset Watcher

Start a new run with 80 Credits, cap 80. DROP toggles Standard (1x damage, free) and Full Send (1.5x, one credit per paid attack). At zero return to Standard. Every three unique clears earns Reset Ready, max one. In a cleared room, DROP consumes a banked reset and refills credits before any mode toggle. In combat it toggles modes and keeps the reset. Room progress pauses while a reset is banked.

Floor changes and continue preserve credits, progress and banked reset. Real time does nothing. Prepare enough Credits before combat; a banked reset cannot refill mid-fight. Birthright raises the cap/refill to 100. HUD: Credits, Next Reset 0/3, `Tibo: Reset Ready`. No network requests.

Source status (scripts/characters/gpt_reset.lua): implemented and registered with the deeper-colour tainted GPT art. A paid attack is a registered tear volley, a laser init or a Dr. Fetus bomb, one payment per frame, plus the shared observer's held-beam and Ludovico windows, knife throws, swings and Epic Fetus rockets, so Full Send is never free on a non-tear build. Engine acceptance pending.

## Remaining eight families: researched candidates

These roles are concrete proposals. Their source strength varies; do not present all as equally established community memes. All unspecified form multipliers are 1x. Room damage bonuses apply only to their owner. Birthright does not add an unrelated second system.

### Gemini — Nano Banana / One More Edit

**Normal:** Start with two Paint, cap three; earn one per unique clear. DROP spends one to paint the nearest hostile within 180 units for eight seconds. The first second dries at native damage, then owner damage is +20% for the remaining mark time. Its defeat leaves a four-second slowing banana peel. Max one mark and one peel per owner; replacement discards the previous effect. Bosses can be painted. Birthright: +30% marked damage after drying. HUD: Paint.

Source status (scripts/characters/gemini_paint.lua): normal form implemented and replaces Prism / Echo. The bonus re-deals the owner's damage once at the higher value with a recursion guard, so other mods' damage callbacks see one cancelled and one re-dealt hit. The peel is vanilla black player creep (slows enemies) tinted yellow. Paint carries across floors; awards reset per floor. Engine acceptance pending.

**Tainted:** Base damage 0.9x. DROP starts a six-second Edit chain on a target within 180 units. Three distinct paid hits advance Crop, Recolor, Export; the third adds one 2x damage pulse. The first sets the player bearing; later steps need at least 30 degrees of movement around the target. Zero separation sets no bearing. Other hits retain native damage. One completed chain per room. DROP can erase progress and retarget. Early target death does not complete a partial chain; select again. Bosses need not die. Birthright extends the timer to ten seconds. HUD: edit step/timer. The banana name is documented; the endless-edit exaggeration is original parody.

Source status (scripts/characters/gemini_edit.lua): implemented and registered with the deeper-colour tainted Gemini art. Steps count distinct paid attacks like GPT's Sanity Check, so one multi-tear volley or one 0.2-second beam window is one step. The pulse is a direct hit credited to the player. Engine acceptance pending.

### Grok — Is This True? / Quote Without Reading

**Normal:** Once per hostile room, DROP challenges the nearest vulnerable target within 220 units for six seconds. Owner damage is 1.3x to it, 0.9x to others. Its defeat or three distinct paid hits verifies it, ends the modifiers and grants +0.15 speed for that room. Timeout or one continuous second without direct line of sight ends the check unverified. Restoring sight resets the obstruction timer. Birthright: verification removes up to three nearby ordinary hostile bullets once. HUD: Check progress/timer.

Source status (scripts/characters/grok_check.lua): normal form implemented and replaces movement momentum. Damage modifiers re-deal the owner's hit once behind a recursion guard, like Gemini. "Nearby" bullets means the three nearest projectiles within 120 units. Engine acceptance pending.

**Tainted:** Base damage 0.9x. DROP selects a target within 220 units for six seconds. Paid hits on other eligible targets build Ratio, once per attack, cap three. An attack hitting only the quote loses one Ratio, minimum zero. Other-target hits win for the same attack, including delayed hits; helpers/unpaid/partner hits are ignored. At expiry the selected target receives one pulse of 1x player damage per stack; early death wastes the pulse. No retarget during the interval; ten-second cooldown from selection. Birthright transfers half the budget to one nearest surviving hostile if the original died. HUD: Ratio, pending timer. This contrasts focused verification with spreading a claim; Grok and the parody account Gork remain distinct.

Source status (scripts/characters/grok_ratio.lua): implemented and registered with the deeper-colour tainted Grok art. Ratio counts distinct paid attacks (one volley or one 0.2-second beam window). Pulses are direct player hits. The Birthright transfer searches 220 units around where the quoted target died. Engine acceptance pending.

### Qwen — Everyone's Base Model / Final Final Fine-Tune

**Normal:** Start with one Adapter, cap two; two unique clears earn one. DROP cycles the next adapter: Range (+60), Tempo (0.9x firing interval), Power (1.1x damage). Entering a new hostile room spends one adapter; one continuous second without attacking installs its room bonus. Firing restarts installation. Leaving discards the spent adapter. No adapter means normal stats. One active bonus, no stacking; preview next and current separately. Birthright: cap three. HUD: Adapters, selected/active labels.

Source status (scripts/characters/qwen_adapter.lua): normal form implemented and replaces the flawless chain. A "new hostile room" is one not yet seen in combat this floor, so re-entering an unfinished fight does not spend twice. Engine acceptance pending.

**Tainted:** DROP in a cleared room chooses Heavy (1.3x damage, 1.2x firing interval), Tiny (0.85x damage, 0.8x interval) or Balanced (1x). A new selection is pinned through two new combat clears; safe rooms, duplicate awards and revisits cannot release it. A new floor selects Balanced and releases the pin. Three unique clears using three different builds grant +0.2 damage for the floor, max three awards. Repeating a build does not advance the three-bit checklist; award resets it. New floor clears progress/bonus. Birthright: +0.3 per award. HUD: Build, Variants 0/3. The source is community enthusiasm for variants and derivatives, not an accusation that another product is stolen.

Source status (scripts/characters/qwen_finetune.lua): implemented and registered with the deeper-colour tainted Qwen art. A clear counts the build active when the room's award fires. The award bonus is flat damage added before the build multiplier. Engine acceptance pending.

### Llama — Please Stay Open / Still Waiting

**Normal:** Start with one Release, cap two; earn one every two unique clears. In a cleared room, DROP spends one to grant two blue flies to each living player, max four recipients; solo gets four flies. Base damage 0.95x. Flies cannot generate release progress; duplicate Llamas own separate budgets. Birthright gives the owner two extra flies. HUD: Releases.

Source status (scripts/characters/llama_release.lua): normal form implemented and replaces the automatic flies. Recipients are the first four living players in slot order. Engine acceptance pending.

**Tainted:** Base damage 0.9x. Start with zero Hype, cap three; each unique clear adds one. DROP spends all hype to create one stationary helper for four seconds per stack. It fires one native 0.5x tear per second. Max one helper; replacement discards remaining duration. Room exit removes it. Birthright: five seconds per stack. HUD: Hype. The contrast is sharing a small release now versus saving anticipation for a longer release, without claims about Meta's future policy.

Source status (scripts/characters/llama_hype.lua): implemented and registered with the deeper-colour tainted Llama art. The helper is a position, not an entity; the shared derived-shot path still calls native `FireTear` at that position with a 0.5x damage multiplier. Helper shots do not bill Opus Mode, consume primed attack bonuses or advance backlog paid-attack triggers; primary shots and Summary Stapler keep their normal accounting. It fires only while the owner stays within 120 units of the origin; lifetime and cadence continue outside, with no catch-up shots on return. Duration and Birthright are unchanged. LLAMA-HELPER-01 is an offline correction; native callback timing, tear effects and weapon replacements still need engine acceptance.

### Mistral — Le Chat / Le Gros Chaton

**Normal:** Speed +0.1. Moving and firing for two seconds charges one Pounce. DROP spends it on an 80-unit forward line swipe, 2x owner damage once per target; walls stop it, cooldown three seconds. No player teleport or contact immunity. Standing for one second loses an unused pounce. Birthright: 110-unit reach. HUD: Pounce Ready.

Source status (scripts/characters/mistral_pounce.lua): normal form implemented and replaces tailwind. Forward is the movement direction stored when charge completes, shown in the HUD. Later aiming does not redirect it; a full charge in another direction replaces it. Legacy ready charges migrate with an explicit Down direction. The line accepts up to 20 units on either side of its center, plus the enemy's size; `Room:CheckLine` in projectile mode stops it at walls and rocks. The cooldown blocks charging. The swipe shows tinted vanilla dust poofs (`scripts/characters/feedback.lua`) at its midpoint and on each hit; there is no dedicated swipe sprite. Engine acceptance pending.

**Tainted:** Speed -0.1, damage 0.9x. Stand without firing in hostile combat for two seconds to store one Baguette, cap two. DROP spends one on a slow forward shockwave, max travel 120 units, damage 2.5x once per target; walls stop it, cooldown two seconds. Birthright: 1.5-second charge. Cleared rooms pause partial baking; room exit discards it. HUD: Baguettes. A particular satire thread supports the giant-kitten/baguette joke; the approved portrait stays intact. Put exaggeration in the bread effect, not an enlarged hurt head or collision box.

Source status (scripts/characters/mistral_baguette.lua): implemented and registered with the deeper-colour tainted Mistral art. The shockwave is a moving point checked each frame, not an entity; golden vanilla dust poofs mark it every 24 units. There is no dedicated bread sprite. Engine acceptance pending.

### Doubao — Sorry, You're Right / I'll Do It Again

**Normal:** First real enemy-caused hit in each hostile room grants one Apology token for six seconds, cap one. DROP spends it to slow enemies in a 120-degree aim cone within 100 units for two seconds; removal of up to four ordinary hostile bullets stays radial. With no aim, use the saved last direction, initially Down; the HUD names it before use. No health refund or cancellation of the original hit. Self-damage, fake damage and donation machines do not qualify. Birthright: token lasts until room exit. HUD: Apology Ready.

Source status (scripts/characters/doubao_apology.lua): normal form implemented and replaces the meal. A hit qualifies when its source is a projectile or a non-friendly enemy, it is not fake or no-penalty damage, and the room is not clear. Only one hit per room counts, even if the first token expires unused. The four nearest projectiles within 100 units are removed. Spending the Apology shows a pink vanilla dust poof at the player, plus the slow tint and a caption. Engine acceptance pending.

**Tainted:** DROP starts six seconds of Confident at 1.35x damage, followed by four seconds of Apology at 0.85x, then becomes ready. Timers advance only in hostile combat. Default damage is 1x when ready. An enemy hit or hostile room clear during Confident ends it early and starts Apology; recovery carries into the next fight. Clearing during Apology does not restart it. The ability never cancels damage. Birthright: Apology lasts three seconds. HUD: phase/timer. This is a deliberate overpromise/recovery cycle, not a second rice character. Indexed titles support the apology motif; no exact unviewed audio quote is claimed.

Source status (scripts/characters/doubao_again.lua): implemented and registered with the deeper-colour tainted Doubao art. The hit rule matches normal Doubao's qualifying-hit rule. The phase is saved so a continued run keeps its multiplier. Engine acceptance pending.

### Kimi — Another Slide Deck / You Are the Manager

**Normal:** Each unique clear earns one Slide, cap six. DROP spends three to mark up to three nearest vulnerable enemies within 220 units for four seconds; slow them and increase owner damage by 15% against the current speaker only. Focus advances in the original nearest-first order after death or unavailability, never backward and never extending the timer. No targets means no spend. One presentation per owner; a new one replaces the old. Use a subtle outline, never an opaque screen-covering slide. Birthright: cost two. HUD: Slides.

Source status (scripts/characters/kimi_slides.lua): normal form implemented and replaces flawless-clear pages. The +15% applies only to the owner's damage against the current speaker, re-dealt like Gemini's Paint; a brighter tint marks that speaker. The outline is a light blue slow tint. The deck ends early once every presented enemy is gone. Engine acceptance pending.

**Tainted:** Base damage 0.85x. Three task slots. DROP assigns an idle slot to the nearest unassigned target within 220 units. Each task deals three 0.6x pulses, two seconds apart. A paid owner hit on its target pauses only that task for one second; repeated hits refresh rather than stack. Helpers/direct task pulses and partners do not pause it. Max three concurrent tasks and nine scheduled pulses per room. Early death releases the slot but not its spent budget. Exit cancels tasks; re-entry does not reset budget. Birthright: pulses 0.7x. HUD: Tasks, room budget. Office-drudge videos are leads; swarm orchestration is documented, but this does not prove a dominant community joke.

Source status (scripts/characters/kimi_manager.lua): implemented and registered with the deeper-colour tainted Kimi art. Pulses are direct owner-sourced damage, not tears. The budget is spent at assignment, so a target dying early does not refund it. Each assignee gets a fading light-blue tint at assignment and on each pulse; it never hides the enemy. Engine acceptance pending.

### GLM — Number in Queue / Please Retry

**Normal:** Each unique clear advances Queue, max three. At three, redeem with DROP before the next new hostile room or Queue falls to two once; revisits and peaceful rooms do not miss the call. DROP redeems an Access Pass: +20% damage for the next two new hostile rooms. Queue pauses while the pass is active. It cannot stack or expire through cleared-room revisits. Birthright: three rooms. HUD: Queue or remaining Access rooms. No real purchases or real-time waiting.

Source status (scripts/characters/glm_queue.lua): normal form implemented and replaces tool links and the pocket Book of Secrets. A new hostile room is the first combat in a room not yet entered in combat this floor; a pass redeemed mid-fight starts with the next one. Clears are paused while pass rooms remain or the current room is boosted. Engine acceptance pending.

**Tainted:** Base damage 0.9x. DROP selects a hostile within 200 units and schedules a two-second request. If it survives within 200 units and direct line of sight at completion, deal 2x damage and consume all Retry stacks, adding 1x per stack (cap three; max 5x total). A connection timeout deals no damage and neither gains nor spends Retries; normal cooldown remains. Early target death instead gives one Retry. One pending request; three-second cooldown from selection. Exit cancels without earning a stack. Birthright: early target death/removal also removes one nearby ordinary hostile bullet; connection timeouts do not. HUD: Retries, Request Pending. Retries are bounded and deterministic, not a random missing-shot mechanic.

Source status (scripts/characters/glm_retry.lua): implemented and registered with the deeper-colour tainted GLM art. Retries are deterministic and bounded. The request damage is direct owner-sourced damage. The requested enemy gets a fading violet tint for the two seconds, and a completed request shows a violet poof. Engine acceptance pending.

## Completion order and evidence

1. All 22 forms, their approved B1 conditions and Birthright branches exist in source. [CHARACTER_COMPLETION.md](CHARACTER_COMPLETION.md) records actual loops, test coverage and remaining gaps; no row is closed by registration alone.
2. Fix confirmed text/implementation discrepancies in focused PRs, and extend meaningful weapon, save and co-op fixtures. Keep existing values and B1 rules; reconcile ambiguous persistence targets before changing behavior.
3. All 50 requested backlog collectibles are implemented within the 80-collectible source inventory, alongside 12 trinkets and five pills. The item-by-item completion audit is separate work; see [EXPANSION_DESIGN.md](EXPANSION_DESIGN.md) and [ITEMS.md](ITEMS.md).
4. Mechanical art corrections and geometry checks do not close appearance acceptance. [ART_STATUS.md](ART_STATUS.md) tracks profiles, GLM's fallen pose, nine derived tainted identities, item icons and effects. Preserve approved identities and the fixed-look contract.
5. Observe fresh starts/combat, physical DROP, native weapons, real Continue, special-player transitions and visuals only in an authorized engine block with a fresh owner-away window. Preserve installed `8fd6a8c` until separately authorized replacement. No Workshop release before acceptance.
