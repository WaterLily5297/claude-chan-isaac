# Eleven families, twenty-two forms, fifty additional items

Owner-requested scope, 2026-10-23. This is the target design, not an implementation inventory. Current code has thirteen forms. Only Summary Stapler from the fifty-item table is implemented locally, with offline tests; none of this expansion has engine acceptance. Existing mechanics remain until their replacements are implemented and migrated deliberately. Values below are initial balance targets, not claims about real model performance.

Normal designs retain the selected ZipZipPipe identities. Tainted designs are alternate fictional roles, not interchangeable dark recolors. Existing tainted Claude/DeepSeek identities remain approved; the other nine require original derivative artwork and documented source terms. No complete artist-authored set of those nine darker variants has been verified.

## Character loops

[CHARACTER_GAMEPLAY.md](CHARACTER_GAMEPLAY.md), revision 2, replaces the preliminary capability-based roles. The owner requested community-meme identities: Claude bans/appeals, DeepSeek rice and peak/valley wordplay, GPT downgrade and Tibo reset, followed by eight researched candidates. That document specifies all twenty-two proposed loops, input, resource caps, drawbacks, Birthright targets and persistence boundaries. They are not implemented or approved balance results.

See [COMMUNITY_MEME_RESEARCH.md](COMMUNITY_MEME_RESEARCH.md) for source quality and access limits, and [MOD_CHARACTER_REFERENCES.md](MOD_CHARACTER_REFERENCES.md) for public mod patterns and the unresolved hurt-pose issue. Do not retain a second contradictory character table here.

## Tainted art directions

These palettes are design targets, not downloaded or licensed third-party alternatives. Keep faces readable and value contrast between skin, hair and clothing. Preserve normal-design credit and the separate DeepSeek terms. Use the same engine-compatible anatomy under accessories.

| New tainted form | Palette and silhouette |
|---|---|
| GPT | Black plum coat, silver hair, muted jade lining; retain small dragon horns; reset notices hang at the waist |
| Gemini | Midnight indigo with restrained violet/cyan highlights; two eclipse ornaments; retain cat identity |
| Grok | Oxblood and charcoal with dark honey hair; compact courier jacket, readable twin-tail silhouette |
| Qwen | Ink indigo and aged jade; narrow calligraphy ribbons and a simplified dark hat |
| Llama | Charcoal wool with warm ivory face and small moss accents; soft alpaca ears remain readable |
| Mistral | Burnt orange, burgundy and gunmetal; reduced hat brim and one feather; storm cape kept out of body anchors |
| Doubao | Deep violet and petrol teal; small apology-note tabs; brighter cyan only at small accessory edges |
| Kimi | Midnight blue and tarnished silver; crescent clasp, office-manager sleeves, concise moon-maid silhouette |
| GLM | Ink black, smoky white and dark jade; fox ears and three small queue tickets; no official logo |

All heads need front/fire/right/right-fire/rear/rear-fire views and an anchor-consistent carry head. Body cycles need stable shoulders and feet. Flying, hurt, death, pickup, stage transition and vanilla costume cases are mandatory, not optional polish. See [COSTUME_COMPATIBILITY.md](COSTUME_COMPATIBILITY.md).

## Fifty additional collectibles

Four items per family (44) plus six shared items (50). These are not fifty recolored stat upgrades. A = active with room charge count; P = passive. Unless marked **local implementation**, entries are designs only. Pool placement, icons, exact cooldowns and interactions require per-item implementation and review. Existing seventeen collectibles are excluded from this count.

| # | Family / item | Type | Intended behavior and limit |
|---|---|---|---|
| 01 | Claude / Summary Stapler | A4 | **Local implementation.** Absorb at most twelve ordinary hostile bullets within 120 units; one speed-6 native tear at 1 + count/4 damage multiplier. Empty use keeps charge; Car Battery cannot repeat. |
| 02 | Claude / Rejection Letter | P | After a real enemy hit, remove up to three nearby ordinary hostile bullets. Once per room; no cancellation of the original hit or reward from self-damage. |
| 03 | Claude / Dario's Red Stamp | A6 | Stamp one vulnerable enemy for four seconds: slow it and disable contact damage from that enemy only. Bosses are slowed without contact immunity. No target means no spend; no real-person enemy. |
| 04 | Claude / Anniversary Cake | P | Each floor completed without a suspension or enemy-caused hit adds +0.15 damage, cap +0.6. Losing a streak resets only this item bonus, not inventory or character age. |
| 05 | DeepSeek / Rice Cooker | A4 | Take a three-second lunch with firing disabled but movement intact; then prime one 2x paid attack for seven seconds. No healing, thought/quota reset or invulnerability; Car Battery cannot double the meal. |
| 06 | DeepSeek / One Bowl Only | P | First consumed red-heart pickup in each new room primes one guard against an ordinary hostile bullet. Max one guard; at most three grants per floor. Full-health non-consumption does not count. |
| 07 | DeepSeek / Wengu Clock | A3 | For six seconds, gain +30% damage after two consecutive seconds without firing. The buff ends on the first paid attack; empty-room waiting cannot extend the six-second window. |
| 08 | DeepSeek / Seven-Second Memory | P | First paid hit stores one target for seven seconds. A later paid hit on that same target within the window adds one 0.5x pulse and clears the mark. Seven-second cooldown; no recursive pulse or multiple marks. |
| 09 | GPT / Sanity Test | A4 | Mark the nearest vulnerable enemy for six seconds. Three distinct paid hits trigger one 3x pulse. Early death or timeout loses the attempt; no target preserves charge. |
| 10 | GPT / Routing Receipt | P | After three unique combat clears, gain +20% damage for the next combat room. Re-entry does not advance routing; progress and pending buff survive continue. |
| 11 | GPT / Tibo Reset | A12 | Once per floor, grant +20% damage for the next two new combat rooms and refill only the owner tainted-GPT Credits if that form is implemented. Other forms still get the buff. Does not reset Claude quota, actives or the world; repeat use on that floor preserves charge. |
| 12 | GPT / Same Model Badge | P | First two seconds in a new hostile room give +25% damage, followed by four seconds at -10%, then baseline. Always show phase; never silently alter the displayed model identity. |
| 13 | Gemini / Nano Banana | A4 | Paint one target for six seconds. Its owner-attributed defeat creates a four-second slowing peel. Max one paint and one peel; bosses can be painted; empty use preserves charge. |
| 14 | Gemini / One More Finger | P | Every fifth paid attack adds one small 0.3x native tear, max once per 0.5 seconds. No recursive extra fingers; does not replace hands, costumes or the primary weapon. |
| 15 | Gemini / Undo Brush | A4 | Remove up to six ordinary hostile bullets within 90 units. Each removed bullet grants +0.02 speed for four seconds, max +0.12. No save, health, inventory or terrain rollback. |
| 16 | Gemini / Unchanged Preview | A6 | Create two six-second decoys at safe nearby positions. Only decoys receive a generic sketch effect; never duplicate pickups or player sprites. Max two per owner. |
| 17 | Grok / Is This True? | A3 | Challenge one enemy for six seconds: +35% owner damage to it, -15% to others. Killing it returns one charge; no target means no discharge. |
| 18 | Grok / Live Wire | P | Gain +0.15 speed while a hostile projectile is nearby; no per-projectile stacking and no permanently stored speed. |
| 19 | Grok / Quote Retort | P | After real damage, next attributed attack within four seconds gains +50%; one hit only, cannot stack or trigger on fake damage. |
| 20 | Grok / Community Note | P | Three distinct paid attacks on one enemy expose it for three seconds of +15% owner damage. One exposure per target, at most six targets per room; no derived-effect progress. |
| 21 | Qwen / Base Model | P | First successful charged active use in each room primes one 1.3x paid attack. Ignore zero-charge/timed uses and battery duplicates; no free active recharge. |
| 22 | Qwen / Another Adapter | A4 | Cycle a room-local bonus between +60 range, +0.15 speed and +15% damage. One active bonus; each successful use replaces it and advances the saved next choice. |
| 23 | Qwen / Final Final Weights | P | Two unique flawless clears prime +20% damage for the next hostile room. A hit resets unbanked progress only; one banked reward and no door farming. |
| 24 | Qwen / Tiny Variant | P | Gain +0.15 speed and -10% damage. Use cache modifiers; do not change player sprite scale or native size-item ownership. |
| 25 | Llama / Open Weights | A4 | Grant two blue flies to each living player, max four recipients; solo receives four. Car Battery does not repeat. Existing familiars remain untouched. |
| 26 | Llama / Herd Bell | P | Existing blue flies gather closer before launching; when none exist, every third unique clear grants one. No infinite helper reproduction. |
| 27 | Llama / Please Come Back | P | After three unique combat clears without using a charged active, add one charge to the primary active if eligible. Reset progress after reward or successful active use. No timed-active or zero-charge farming. |
| 28 | Llama / Release Soon | A6 | Schedule three ordinary-projectile guards for two seconds later. Max three guards, expire after eight seconds; exit cancels pending creation without refund. No permanent shield bank. |
| 29 | Mistral / Emergency Baguette | A4 | Forward bread-shaped line strike, 3x owner damage once per target. Walls stop it; no player movement or contact immunity. |
| 30 | Mistral / Slipstream Boots | P | Moving for two seconds adds +0.15 speed; a sharp turn drops a single one-second slowing gust, three-second cooldown. |
| 31 | Mistral / Very Large Kitten | A6 | One stationary fictional cat effect pushes ordinary hostile bullets away for three seconds, max twelve affected per pulse, two pulses per second. No giant player sprite or collision change. |
| 32 | Mistral / Edge Compass | P | Near an outer wall, gain +0.25 shot speed; bonus ends away from the wall. Avoid per-frame cache refresh when state is unchanged. |
| 33 | Doubao / Instant Apology | A4 | Slow nearby vulnerable enemies for two seconds and erase up to four ordinary hostile bullets. No healing or cancellation of an already taken hit. |
| 34 | Doubao / Next Time Again | P | First real enemy-caused hit in a room primes +50% damage on one paid attack within four seconds. One reward per room; no self-damage or repeated-hit stacking. |
| 35 | Doubao / Confident Answer | A4 | Six seconds of +25% damage followed by four seconds of -10%. Cannot overlap cycles; show the phase. Does not change appearance or refund charges if the room ends. |
| 36 | Doubao / Smiling Correction | P | After taking real enemy damage, a later unique flawless clear gives two blue flies. One pending correction, no health refund; fake hits do not qualify. |
| 37 | Kimi / Slide Deadline | A4 | Mark up to three targets for eight seconds; defeat all for +15% owner damage for that room. One batch, owner attribution, no target means no charge. |
| 38 | Kimi / Citation Thread | P | First attributed hit marks a target; hitting a second target grants +10% damage against the first for three seconds. Max two references. |
| 39 | Kimi / Overtime Slides | P | Every third unique combat clear primes a two-second slowing outline on up to three nearby enemies in the next hostile room. Never cover the screen with a presentation. |
| 40 | Kimi / Stand-Up Meeting | A6 | Recall up to three owned temporary task helpers for one 2x damage burst per helper at their locations. Never remove vanilla familiars; no eligible helper means no charge. |
| 41 | GLM / Queue Ticket | P | Every fourth unique combat clear adds one charge to an eligible primary active. One reward per four rooms; no benefit to timed/zero-charge actives and no re-entry farming. |
| 42 | GLM / Sold Out | A4 | Grant one ordinary-projectile guard for four seconds and +0.15 speed while it lasts. The guard blocks once; replacing it does not stack or extend the maximum duration. |
| 43 | GLM / Please Retry | A6 | Schedule three native 0.6x tears at half-second intervals along original aim. Cancel pending requests on room exit, death or type change. No recursive requests or skipped charge. |
| 44 | GLM / Access Pass | P | First successful charged active use on each floor grants +15% damage for the current combat room, or the next new hostile room if used while clear. One pending reward; no Car Battery duplicate. |
| 45 | Shared / Cache Cartridge | P | Revisit a cleared room to gain +0.15 speed until entering combat; no clear rewards, charges or damage farming. |
| 46 | Shared / Token Recall | A4 | Retrieve up to three owner-created ordinary tears and gain one temporary guard per tear, max three for four seconds. Ignore other players and special projectiles. |
| 47 | Shared / Checkpoint Pin | A6 | Place a marker for five seconds; reuse returns to the safe marker position within the same room. Never restore health, inventory or saved state. |
| 48 | Shared / Rate-Limit Valve | P | After two seconds not firing, next attack gains +30% damage. Consumed once; does not reset Claude usage or tainted quota. |
| 49 | Shared / Consensus Coin | P | Two different owned damage sources hitting the same target within two seconds cause one 0.5x pulse; one pulse per target, no recursive trigger. |
| 50 | Shared / Error Budget | P | First real hit each floor spends the budget and grants +0.2 speed for that room. Does not cancel damage; budget state survives continue. |

## Meme extras (outside the fifty)

Owner request of 2026-10-24: more meme items that stay compatible with the original game. These do not count toward or replace any backlog row, and they use only native systems (cache stats, vanilla tear flags, native charm/confusion, item RNG). Proposal list: A Ignore All Previous Instructions, B Tungsten Cube, C Claudius's Discount, D Pizza Glue, E One Small Rock a Day, F Stuck in Mt. Moon, G Strawberry, H 9.11 > 9.9 pill, I Golden Gate Claude. Only the rows marked local implementation exist in source.

| Item | Type / pool | Behavior and limit |
|---|---|---|
| Ignore All Previous Instructions | A4, treasure | **Local implementation.** Nearest vulnerable, non-friendly, non-charmed enemy within 200 units is charmed for 8 s; a boss is confused for 2 s instead. No target keeps charge. Car Battery's second use picks the next target. Differs from Compact, which confuses the whole room and clears bullets. |
| Tungsten Cube | P, shop | **Local implementation.** +0.8 damage and -0.15 speed per copy (speed floor 0.1, never raises a lower value); native knockback tear flag applies to every weapon that reads player tear flags. |
| Pizza Glue | P, treasure | **Local implementation.** Each fired tear has a 25% chance (+2.5% per luck, 10-50%) to gain the native slowing flag, using the item's per-player native RNG; -0.1 shot speed per copy. Tears only: lasers, knives and bombs are not rolled. Already-slow tears consume no roll. |

## Implementation and performance gates

Each item needs registration, pool, English description, original icon/provenance, tests, documentation and engine acceptance. Do not register the forty-nine designs as empty collectible shells. Use native damage/cache/weapon interfaces; do not force character sprites or overwrite another item's appearance. Weapon-independent effects must retain player/familiar ownership and handle lasers, knives and bombs explicitly. Tear-only behavior must say so.

Persistent resources live in saved per-player state with a versioned migration. Temporary tasks store remaining gameplay frames and room identity when continuation matters, never raw entity references in JSON. Exiting/re-entering, restarting, changing character and joining co-op must not refill resources or duplicate rewards. Failed/cancelled actives and Car Battery require explicit behavior. RNG is seeded and item-specific; no global random reseed on continue.

Use event-driven callbacks. Cache player ownership/state within one callback, not forever. Bounded target lists should replace repeated whole-room scans every frame. Helper budgets are shared per owner: no more than twelve simultaneous expansion helpers and no unbounded nested forks. A cap may defer an extra visual effect, but must not silently erase earned rewards. Profile before making numerical performance claims.

Roll out in small reviewable branches: character state framework, then one family or item per change. Engine checks and art acceptance remain separate from stub/CI passes. The source, GitHub and runtime revisions must be recorded separately until synchronized; no Workshop release yet.

## Research ledger

- Bilibili [BV1X66uB7EjX](https://www.bilibili.com/video/BV1X66uB7EjX/) and [BV1o3ADzZEmg](https://www.bilibili.com/video/BV1o3ADzZEmg/) were found through search for swarm discussions. Direct reads returned HTTP 412 on 2026-10-23. Titles are leads only; no playback, transcript, frames or audio were acquired.
- [Kimi's official Agent Swarm help](https://www.kimi.com/en/help/agent/agent-swarm) describes task decomposition and coordinated subagents. The manager and task-item proposals translate coordination into bounded game tasks; no advertised agent count or benchmark is copied into balance claims.
- [Claude context editing documentation](https://platform.claude.com/docs/en/build-with-claude/context-editing) distinguishes clearing selected context from summary-based compaction. Summary Stapler is a fictional compression tradeoff, not a claim that context management refills a usage quota.
- The community-meme ledger records the newer source review. Item mechanics are original proposals, not factual capability claims or quotations from unavailable videos. References provide inspiration, not redistribution rights.
