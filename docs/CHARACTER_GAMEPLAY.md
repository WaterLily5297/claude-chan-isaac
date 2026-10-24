# Community-meme character gameplay

Revision 2, 2026-10-23. This replaces the capability-based draft after the owner's correction: recognizable community jokes must lead the design. **Design targets, not accepted balance.** Normal DeepSeek now has an intermediate Rice First source implementation (meal economy, save state and initial native attack adapters); full weapon adapters and engine acceptance are pending. Tainted DeepSeek Wenfeng / Wengu has a source implementation for ordinary tears. Other replacement designs remain unimplemented. Source currently registers thirteen forms; nine additional tainted forms remain unimplemented. See MODEL_ROSTER.md and the character modules for actual behavior.

The owner explicitly selected Claude bans and anger at Dario, DeepSeek free rice and Liang Wenfeng / Liang Wengu, and GPT perceived downgrades and Tibo resets. Other families have researched candidates. [COMMUNITY_MEME_RESEARCH.md](COMMUNITY_MEME_RESEARCH.md) distinguishes direct posts, secondary accounts and blocked videos. None of these samples establishes majority opinion or verifies an allegation about a person.

## Shared contract

- Keep the selected portrait identities and English names. Subtitles below are fictional gameplay roles. New code, descriptions, HUD, story and dossiers use English.
- Tap DROP resolves on release; holding it preserves normal dropping. The reusable observer is implemented for current GPT/Gemini modes with a 1–12-gameplay-frame tap window, but the new abilities below are not. Pocket actives retain native input. No target means no resource spend. Test keyboard and controller, including native short-tap pocket cycling.
- All resources and remaining timers belong to one player and survive continue. Pause/menu time does not advance timers. No duplicate reward from door re-entry, spawned children, respawned enemies or fake hits. A unique clear is a newly completed hostile room.
- One paid attack is one volley or one 0.2-second continuous-weapon window. Derived effects cannot recursively pay or trigger themselves. Charge weapons snapshot at release. Normal DeepSeek now has initial native adapters described in NATIVE_THOUGHT.md; delayed bursts, Epic Fetus, melee, familiar ownership and engine acceptance remain required work. Other families still need migration to paid-attack accounting.
- Base stats are Isaac's before items unless specified. Normal starting health: two red and one soul heart; tainted: one red and two soul hearts, except DeepSeek retains one red and one soul heart. New normal forms get one bomb; new tainted forms get one key. Original-four pickups remain until migrated explicitly. No starting pocket active except those named below.
- Listed multipliers replace old form multipliers; do not stack both systems accidentally. Persistent bonuses use cache evaluation. Enemy damage retains owner attribution and recursion guards. Ordinary weapons, flight, scale, costumes and transformations remain native. Never continuously replace the whole player sprite.
- Room effects end on exit without refund. Save uses versioned per-player data, never serialized entity references. Character changes cannot transfer rewards to another form. Bosses, co-op duplicates and save/continue require specific tests.
- At most two resource meters per form; current phase and transient labels are not extra currencies. Failure always preserves a usable main attack. No hidden random shot cancellation, permanent inventory loss or real-time waiting.
- Birthright targets below are also unimplemented. Intrinsic abilities do not count toward the fifty additional collectibles.

## Claude — account survival and appeals

The red stamp and rejection letter carry the ban/Dario frustration joke. The adversary remains a fictional account system, not a real-person enemy.

### Normal: One More Day

Usage runs 0–100. Paid attacks add 4; not firing drains 10 per second. At 100, display Limited for five seconds with 0.4x damage, then reset usage. Otherwise damage is 1x. Two unique combat clears earn one Appeal, cap two; start with one. DROP spends an Appeal to remove 40 usage, but cannot cancel an active Limited penalty. Choose prevention rather than a free recovery after overspending.

Keep pocket Ban Hammer, range +60, shot speed +0.2 and speed -0.1. Each floor without suspension adds +0.2 account-age damage, cap +1.6; suspension resets it. Migrate age to per-player state. Existing Claude risk/encounter co-op behavior needs its own review. Swarm adds one extra 4-point payment per paid attack; Compact keeps its explicit bill. Birthright preserves age through the first suspension each floor without canceling its penalty. HUD: Usage, Appeals; account age belongs in the dossier/status line. Caption: `Another love letter.`

### Tainted: Appeal Pending

Start each floor with 220 Quota and two Appeal Pages, cap two. Registered attacks cost one quota and deal 1.25x damage. At zero, retain a usable 0.5x attack under Suspended. DROP while suspended spends a page and starts six seconds of active-combat review, then restores 60 quota. One review at a time. Exit cancels it without refund. Three unique clears earn a page.

Keep pocket Banked Reset for immediate refill. Using it cancels any pending review without returning the page; no double payout. Swarm costs one extra quota per paid attack. New floor refills quota and pages; continue does not. Birthright restores 90 per completed review. HUD: Quota, Appeal Pages, transient `Under Review: Ns`. The contrast is preserving an old account versus surviving repeated suspensions.

## DeepSeek — rice and peak/valley scheduling

Rice belongs here as a defining joke. Liang Wenfeng / Liang Wengu is rendered as Peak / Valley wordplay. Neither form receives proxy, IP, risk or risk-scaled enemy mechanics.

### Normal: Rice First

Base damage 0.9x. Not firing charges up to five seconds of Thought; the next paid attack consumes it for up to 2x damage. Moving is allowed. Start with one Rice Bowl, cap two; earn one per two unique clears. DROP spends one to take a two-second Lunch: stop firing but retain movement and vulnerability, then receive full Thought and +0.15 speed for six seconds. Waiting in an empty room cannot farm bowls.

Keep pocket Lunch Break's explicit charged heal/lockout as a separate active. The intrinsic bowl gives no healing and cannot activate during either lunch lockout. Remove random Server Busy shot deletion only when this replacement is implemented and tested. Birthright reduces Lunch to one second. HUD: Thought, Rice. Caption: `One bowl per customer.`

### Tainted: Wenfeng / Wengu

Base damage 0.8x. Alternate twelve active-combat seconds of Valley and twelve of Peak, with visible timer. Start each floor in Valley. Empty rooms freeze the timer; continue preserves it. Start a new run with 12 Compute, cap 24. Valley recovers 3 Compute per second when not firing. Paid attacks add two native half-damage forks when affordable: cost 2 in Valley, 4 in Peak. Insufficient Compute suppresses only the extra forks.

DROP toggles Forks On / Saving with a one-second cooldown. Saving keeps the primary attack and spends nothing. New floors preserve Compute while resetting phase. Forks cannot fork recursively; non-tear builds need an equivalent bounded damage budget before compatibility acceptance. Birthright raises the cap to 32. HUD: Compute, phase/timer, mode label. The decision is when computation is cheap, not whether a proxy is safe.

Source status (scripts/characters/deepseek_peak.lua): implemented for ordinary tears. Valley recovery counts only in uncleared rooms, matching the frozen timer, so idling in an empty room cannot refill Compute. One payment covers a same-frame volley and every tear in it forks once. The toggle cooldown is transient. Non-tear weapons neither fork nor pay until a bounded equivalent exists. Engine acceptance pending.

## GPT — downgrade and Tibo reset

The downgrade complaint and Codex reset ritual are separate memes. A fictional reset restores an allowance; it does not assert that actual quota resets fix model quality.

### Normal: Same Name, Smaller Brain

Start each floor Verified at 1.15x damage. Each unique combat clear adds one Routing mark, cap three. At three, the next combat begins in announced Fallback at 0.8x damage. DROP in Fallback tags the nearest vulnerable enemy within 200 units as a Sanity Check, once per room. Three distinct paid attacks that damage it, or its owner-attributed defeat, restore Verified and clear Routing. Bosses can satisfy the three-hit route without dying.

Derived effects cannot count multiple times for one attack. Failed verification leaves Fallback until the next room's attempt. Floor transition restores Verified; continue does not. Birthright requires only two paid hits. HUD: Verified / Fallback, Routing, transient Check progress. The player can actively correct the downgrade instead of suffering a silent random debuff.

Source status (scripts/characters/gpt_downgrade.lua): implemented and replaces the old Deliberate / Instant modes. A unique combat clear is a room seen with enemies while the player was present, once per floor. An attack is a registered tear volley (shared by its same-frame derived copies), a Dr. Fetus bomb, or one six-update window of a laser or knife; unregistered split tears and familiars do not count. The defeat route needs the owner's damage on the same or previous update. A spent check is saved per room, so continue cannot grant a second attempt. Engine acceptance pending.

### Tainted: Reset Watcher

Start a new run with 80 Credits, cap 80. DROP toggles Standard (1x damage, free) and Full Send (1.5x, one credit per paid attack). At zero return to Standard. Every three unique clears earns Reset Ready, max one. When ready, DROP consumes the reset and refills credits before any mode toggle. Room progress pauses while a reset is banked.

Floor changes and continue preserve credits, progress and banked reset. Real time does nothing. Spend an allowance before claiming the reset, or claim early for immediate pressure. Birthright raises the cap/refill to 100. HUD: Credits, Next Reset 0/3, `Tibo: Reset Ready`. No network requests.

## Remaining eight families: researched candidates

These roles are concrete proposals. Their source strength varies; do not present all as equally established community memes. All unspecified form multipliers are 1x. Room damage bonuses apply only to their owner. Birthright does not add an unrelated second system.

### Gemini — Nano Banana / One More Edit

**Normal:** Start with two Paint, cap three; earn one per unique clear. DROP spends one to paint the nearest hostile within 180 units for eight seconds, giving +20% owner damage to it. Its defeat leaves a four-second slowing banana peel. Max one mark and one peel per owner; replacement discards the previous effect. Bosses can be painted. Birthright: +30% marked damage. HUD: Paint.

Source status (scripts/characters/gemini_paint.lua): normal form implemented and replaces Prism / Echo. The bonus re-deals the owner's damage once at the higher value with a recursion guard, so other mods' damage callbacks see one cancelled and one re-dealt hit. The peel is vanilla black player creep (slows enemies) tinted yellow. Paint carries across floors; awards reset per floor. Engine acceptance pending.

**Tainted:** Base damage 0.9x. DROP starts a six-second Edit chain on a target within 180 units. Three distinct paid hits advance Crop, Recolor, Export; the third adds one 2x damage pulse. One completed chain per room. DROP can erase progress and retarget. Early target death does not complete a partial chain; select again. Bosses need not die. Birthright extends the timer to ten seconds. HUD: edit step/timer. The banana name is documented; the endless-edit exaggeration is original parody.

### Grok — Is This True? / Quote Without Reading

**Normal:** Once per hostile room, DROP challenges the nearest vulnerable target within 220 units for six seconds. Owner damage is 1.3x to it, 0.9x to others. Its defeat or three distinct paid hits verifies it, ends the modifiers and grants +0.15 speed for that room. Timeout gives nothing. Birthright: verification removes up to three nearby ordinary hostile bullets once. HUD: Check progress/timer.

Source status (scripts/characters/grok_check.lua): normal form implemented and replaces movement momentum. Damage modifiers re-deal the owner's hit once behind a recursion guard, like Gemini. "Nearby" bullets means the three nearest projectiles within 120 units. Engine acceptance pending.

**Tainted:** Base damage 0.9x. DROP selects a target within 220 units for six seconds. Paid hits on other targets build Ratio, once per attack, cap three. At expiry the selected target receives one pulse of 1x player damage per stack; early death wastes the pulse. No retarget during the interval; ten-second cooldown from selection. Birthright transfers half the budget to one nearest surviving hostile if the original died. HUD: Ratio, pending timer. This contrasts focused verification with spreading a claim; Grok and the parody account Gork remain distinct.

### Qwen — Everyone's Base Model / Final Final Fine-Tune

**Normal:** Start with one Adapter, cap two; two unique clears earn one. DROP cycles the next adapter: Range (+60), Tempo (0.9x firing interval), Power (1.1x damage). Entering a new hostile room spends one adapter to apply that choice for the room. No adapter means normal stats. One active bonus, no stacking; preview next and current separately. Birthright: cap three. HUD: Adapters, selected/active labels.

Source status (scripts/characters/qwen_adapter.lua): normal form implemented and replaces the flawless chain. A "new hostile room" is one not yet seen in combat this floor, so re-entering an unfinished fight does not spend twice. Engine acceptance pending.

**Tainted:** DROP in a cleared room chooses Heavy (1.3x damage, 1.2x firing interval), Tiny (0.85x damage, 0.8x interval) or Balanced (1x). Choice locks in combat. Three unique clears using three different builds grant +0.2 damage for the floor, max three awards. Repeating a build does not advance the three-bit checklist; award resets it. New floor clears progress/bonus. Birthright: +0.3 per award. HUD: Build, Variants 0/3. The source is community enthusiasm for variants and derivatives, not an accusation that another product is stolen.

### Llama — Please Stay Open / Still Waiting

**Normal:** Start with one Release, cap two; earn one every two unique clears. DROP spends one to grant two blue flies to each living player, max four recipients; solo gets four flies. Base damage 0.95x. Flies cannot generate release progress; duplicate Llamas own separate budgets. Birthright gives the owner two extra flies. HUD: Releases.

**Tainted:** Base damage 0.9x. Start with zero Hype, cap three; each unique clear adds one. DROP spends all hype to create one stationary helper for four seconds per stack. It fires one native 0.5x tear per second. Max one helper; replacement discards remaining duration. Room exit removes it. Birthright: five seconds per stack. HUD: Hype. The contrast is sharing a small release now versus saving anticipation for a longer release, without claims about Meta's future policy.

### Mistral — Le Chat / Le Gros Chaton

**Normal:** Speed +0.1. Moving and firing for two seconds charges one Pounce. DROP spends it on an 80-unit forward line swipe, 2x owner damage once per target; walls stop it, cooldown three seconds. No player teleport or contact immunity. Standing for one second loses an unused pounce. Birthright: 110-unit reach. HUD: Pounce Ready.

**Tainted:** Speed -0.1, damage 0.9x. Stand without firing for two seconds to store one Baguette, cap two. DROP spends one on a slow forward shockwave, max travel 120 units, damage 2.5x once per target; walls stop it, cooldown two seconds. Birthright: 1.5-second charge. HUD: Baguettes. A particular satire thread supports the giant-kitten/baguette joke; the approved portrait stays intact. Put exaggeration in the bread effect, not an enlarged hurt head or collision box.

### Doubao — Sorry, You're Right / I'll Do It Again

**Normal:** First real enemy-caused hit in each hostile room grants one Apology token for six seconds, cap one. DROP spends it to slow enemies within 100 units for two seconds and remove up to four ordinary hostile bullets there. No health refund or cancellation of the original hit. Self-damage, fake damage and donation machines do not qualify. Birthright: token lasts until room exit. HUD: Apology Ready.

**Tainted:** DROP starts six seconds of Confident at 1.35x damage, followed by four seconds of Apology at 0.85x, then becomes ready. Timers advance only in hostile combat. Default damage is 1x when ready. An enemy hit during Confident ends it early and starts Apology; it never cancels the damage. Birthright: Apology lasts three seconds. HUD: phase/timer. This is a deliberate overpromise/recovery cycle, not a second rice character. Indexed titles support the apology motif; no exact unviewed audio quote is claimed.

### Kimi — Another Slide Deck / You Are the Manager

**Normal:** Each unique clear earns one Slide, cap six. DROP spends three to mark up to three nearest vulnerable enemies within 220 units for four seconds; slow them and increase owner damage by 15%. No targets means no spend. One presentation per owner; a new one replaces the old. Use a subtle outline, never an opaque screen-covering slide. Birthright: cost two. HUD: Slides.

**Tainted:** Base damage 0.85x. Three task slots. DROP assigns an idle slot to the nearest unassigned target within 220 units. Each task deals three 0.6x pulses, two seconds apart. Max three concurrent tasks and nine scheduled pulses per room. Early death releases the slot but not its spent budget. Exit cancels tasks; re-entry does not reset budget. Birthright: pulses 0.7x. HUD: Tasks, room budget. Office-drudge videos are leads; swarm orchestration is documented, but this does not prove a dominant community joke.

### GLM — Number in Queue / Please Retry

**Normal:** Each unique clear advances Queue, max three. At three, DROP redeems an Access Pass: +20% damage for the next two new hostile rooms. Queue pauses while the pass is active. It cannot stack or expire through cleared-room revisits. Birthright: three rooms. HUD: Queue or remaining Access rooms. No real purchases or real-time waiting.

**Tainted:** Base damage 0.9x. DROP selects a hostile within 200 units and schedules a two-second request. If it survives in the room, deal 2x damage and consume all Retry stacks, adding 1x per stack (cap three; max 5x total). Early target death instead gives one Retry. One pending request; three-second cooldown from selection. Exit cancels without earning a stack. Birthright: a failed request also removes one nearby ordinary hostile bullet. HUD: Retries, Request Pending. Retries are bounded and deterministic, not a random missing-shot mechanic.

## Implementation order and evidence

1. Validate the corrected hurt-pose packing in the engine, including all five animations reusing its cell. The thirteen source atlases and offline checks are corrected; engine acceptance remains separate. The earlier physical-input interruption still prevents resumed game automation until resolved.
2. Implement attack accounting, tap/hold controls and per-player migrations before promising native-weapon compatibility. Do not show proposed dossiers on characters still running old code.
3. Replace one family per reviewable change, starting with the owner's Claude, DeepSeek and GPT anchors. Each needs explicit old-behavior removal, English UI, save migration and a repeatable engine scenario.
4. Register new tainted forms only when their mechanics and art exist. The fifty additional collectible budget lives in EXPANSION_DESIGN.md; only Summary Stapler is implemented locally so far.
5. Test every form with continue, co-op duplicates, type changes, pause, re-entry, boss-only rooms and vanilla visual modifiers. Offline tests are not engine passes. No Workshop release before acceptance.
