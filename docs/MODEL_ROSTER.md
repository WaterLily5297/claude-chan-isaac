# Model-family roster candidate

This experimental expansion covers eleven model families: Claude, DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi, and GLM. It is a declared working roster, not a claim that every current model or provider is represented. Existing normal and tainted Claude/DeepSeek remain; the nine additions now have normal and tainted source implementations (offline only). Model versions and service products are grouped by family.

The owner requested a new art pass and playable model-inspired mechanics on 2026-10-23. This authorizes development of the expansion while the earlier engine acceptance matrix remains open. No Workshop release is authorized by an offline pass.

## Gameplay

The [all-22-form completion audit](CHARACTER_COMPLETION.md) maps the current loops, Birthright fixtures, save boundaries and remaining work. Every form remains open for native acceptance; source coverage is not a finished gameplay rating.

All 22 B1 feature revisions below are implemented in owner-approved, merged PR #102 and covered by offline regressions. They preserve baseline numerical benefits and are installed in gameplay checkpoint ef7d2dd. Native gameplay and balance are not yet accepted. Full rules and baseline comparison: [DIFFICULTY_FEATURES.md](DIFFICULTY_FEATURES.md).

All 22 forms use the shared DROP rule: short release with at most one pocket item. Multiple cards/pills/pocket actives disable the ability and leave native selection untouched. Inventory changes during a held gesture cannot rearm it; release first. Long holds remain native. Main/Schoolbag actives are outside this pocket count. This is source behavior; physical input acceptance is pending.

The following are fictional gameplay interpretations, not a performance ranking or literal claims about products. All new interface text is English as requested by the owner.

| Family | Normal form: B1 | Tainted form: B1 |
|---|---|---|
| Claude | Usage and Appeals retain their original costs; later floors offer a marked-target-last review for the +0.2 account-age award | Tainted reviews require six combat seconds without attacking. Shooting pauses them; native zero-Quota attacks remain available. Suspension and Birthright retain their existing rules |
| DeepSeek | Rice requires standing still; movement cancels and refunds its Bowl once without a meal reward. Other food lockouts stay separate | Tainted Peak reserves up to four Compute and returns it at the next Valley/floor within the total cap. Fork prices/output and the non-tear 1.3x rule remain unchanged; neither form uses proxy risk |
| GPT | Verified 1.15x / Fallback 0.8x remain. Off-target paid attacks erase one Sanity Check hit; the selected target wins for mixed or delayed piercing hits | Tainted Standard / Full Send 1.5x and 80 Credits remain; banked Tibo resets can be claimed only in cleared rooms. Combat DROP still toggles modes |
| Gemini | Eight-second Paint dries for its first second at native damage, then gives 1.2x owner damage (Birthright 1.3x). Owner kills still leave a peel | Tainted Crop/Recolor/Export retains its three paid hits and 2x pulse, but later steps need at least 30 degrees of repositioning around the target |
| Grok | A fact check fails after one continuous second without direct sight. Existing 1.3x target/0.9x other damage and +0.15 speed verification remain | Tainted own-only quoted-target attacks lose one Ratio; other-target hits win for mixed attacks. Six-second pulse, cap three, ten-second cooldown and Birthright transfer remain |
| Qwen | An Adapter is spent on new combat entry; one continuous second without attacking installs the original Range/Tempo/Power bonus | Tainted build choices pin through two new combat clears. New floors select Balanced and release the pin. Original build coefficients and three-variant awards remain |
| Llama | Releases can be spent only in cleared rooms; combat attempts retain the resource. Original native blue-fly counts, recipients and Birthright remain | Tainted stationary demos fire only while the owner is within 120 units. Lifetime and cadence continue outside, without catch-up or new billing; native tears remain 0.5x |
| Mistral | Pounce stores movement direction when charged; aim cannot redirect it. Recharging in another direction replaces it. Original 2x damage, range, idle loss and cooldown remain | Tainted Baguettes bake only in hostile combat while stationary and not firing. Cleared rooms pause partial baking; exit discards it. Stored bread, 2.5x wave and Birthright remain |
| Doubao | Apology slow uses a 120-degree aim cone within 100 units; bullet removal remains radial. Last aim is saved, initially Down. No health refund | Tainted hostile clear during Confident starts Apology immediately. Recovery carries into the next fight; clearing during Apology cannot extend it. Existing multipliers/durations remain |
| Kimi | The presentation slows its three-member audience, but only the current speaker takes +15% owner damage. Focus advances in original nearest-first order without extending time | Tainted paid owner hits pause only the assigned task for one refreshable second. Helpers and partners do not pause it; pulse damage, slots and nine-pulse room budget remain |
| GLM | Redeem Queue 3 before another new hostile room or fall to Queue 2 once. Revisits and safe rooms do not miss the call; Access Pass values stay unchanged | Tainted requests need a surviving target within 200 units and direct sight at completion. Connection timeout deals no damage or Retry gain and keeps existing stacks; early-death Retry rules remain |

Hold MAP in a cleared room to see a full illustration and instructions. Release to close. Combat does not display the large portrait. The dossier currently shows one local player's requested card at a time.

Gemini's Paint, GPT's Sanity Check, Grok's fact check, Qwen's adapter pick, Llama's Release, Mistral's Pounce, Doubao's Apology, Kimi's presentation and GLM's Access Pass occur only when a short DROP press is released, after 1–12 gameplay frames. A longer hold never switches modes. The observer leaves native input alone, including trinket dropping and pocket cycling; actual engine combinations still need testing. A key held through start/continue, room transition, pause or control reassignment must be released before a new tap can qualify. The B1 feature revision changes only the intrinsic conditions described above; physical-input acceptance still requires an engine session.

## State and compatibility

LLAMA-HELPER-01 keeps tainted Llama's helper position, native 0.5x tears, cadence and duration, but excludes those shots from Opus billing, attack-prime consumption and backlog paid-attack triggers. Primary shots and Summary Stapler keep their existing accounting. This source correction is offline-only; native callback timing and item/weapon interactions remain unaccepted.

`scripts/characters/model_roster.lua` now holds only identities, dossier lines and the tear tint; it keeps no state. Each family's module saves its own versioned per-player table in `Risk.state` (for example `gptRouting`, `kimiSlides`, `glmQueue`), keyed by player slot and guarded by pointer, `InitSeed` and player type. A fresh run resets them; a changed player type or replacement entity gets fresh state. Live marks/decks are transient; Qwen installation/pin, Mistral stored direction, Doubao aim and Peak reservation use primitive versioned saves. Claude review stores scalar target/room identity. Target-choice histories end with their live check/quote. Joining/leaving players and character-changing items still need engine tests. A legacy `Risk.state.modelRoster` table in an old save is ignored.

Normal Claude's account is an explicit exception to the form-change reset rule: the same live pointer and initialization seed retain their debt after leaving and returning to the form. A different live owner retires the slot's account, and an observed removed slot is pruned. Continue clears transient identities before rebinding saved accounts to recreated players. This owner-isolation correction is source-only; installed `8fd6a8c` does not contain it, and native revival/co-op ordering still needs testing.

DROP gestures use a separate reusable observer with pointer/seed/type/controller identity. Pending input never enters Risk.state. New run/continue, exit, room/floor changes, loss of control, death and observed pause cancel a gesture. Selected mode persistence is unchanged. This observes [held action state](https://wofsauge.github.io/IsaacDocs/rep/Input.html#isactionpressed) and [pause state](https://wofsauge.github.io/IsaacDocs/rep/Game.html#ispaused); it does not consume the native action or claim support for unobserved controller events.

Damage, firing interval, range, speed and tear flags use engine cache callbacks. The new roster does not generate extra tears recursively. Cache-based damage applies to weapon types that use player damage, but this is not proof of Brimstone, Technology, knife, bomb or familiar compatibility. Tear flags have the normal engine's weapon-specific limits. Reactions Port Pack fallback registration covers all registered characters while preserving explicit support.

Doubao ignores fake damage and deliberate self-damage flagged `DAMAGE_NO_PENALTIES` (Blood Donation, IV Bag, sacrifice rooms); whether every vanilla self-damage source sets that flag needs engine confirmation.

Roster families are outside the proxy IP / risk account: their hits never add risk or spoil a clean room, and suspension never reduces their damage. Their tear color is a tint multiplied into the current color, preserving item colors and offsets. Other mods cancelling a later damage callback remain an engine integration case.

## Art and provenance

The normal portraits use ZipZipPipe's AI-personification series: Claude, DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Seed / Doubao, Kimi and GLM. The eleven original files were verified against their catalog SHA-256 values. The built-in image tool made transparent adaptations and replaced explicit company emblems under the repository's existing art rule. These derivatives retain the recognizable designs; they are not byte-identical original illustrations. Both tainted portraits retain the owner's approved generated designs, with slightly deeper colors.

All thirteen gameplay sheets now follow the selected portrait identities: hair, costume palette and signature accessories. The built-in image tool generated the art; `tools/pack_selected_sprites.py` crops and packs frames without drawing replacement art. Directional animation and special-pose acceptance remain pending. Some alternate poses reuse headless walking frames. The four original characters also received newly drawn gameplay sheets, preserving their selected designs. See [art terms](../resources/ART_LICENSE.md), [source and edit records](portrait-prompts.json), and [tainted prompts](tainted-portrait-prompts.json). No video frames, voices, private material or official avatar downloads are bundled.

## Evidence

Offline coverage drives each family's real module: numerical bounds, continuation with recreated entities and module state, co-op separation, duplicate room awards, fresh runs and unchanged DeepSeek identification. Asset checks verify file existence, PNG dimensions and animation frame bounds. These tests do not establish attractive animation, game feel, real JSON restart persistence or a successful engine run.

Distinct-wrapper fixtures additionally verify that charge survives callback reference changes and garbage collection and that cache/HUD values agree. Pointer reuse with a new initialization seed and observed roster-type changes reset temporary charge. The multi-wrapper Grok case fails before the identity fix on `0573b2f` and passes afterward. These fixtures model documented reference behavior; they do not reproduce actual engine timing.

Engine acceptance is pending: all eleven normal and eleven tainted selections; every direction and special pose; MAP dossier; mode controls with trinkets; item rerolls and costumes; actual application restart; base Repentance and Repentance+; weapon families; and co-op. No Workshop publication.

## Research boundaries

The roster is the owner's explicit eleven-family selection, not a claim of exhaustive market coverage. Mechanics are fictional gameplay interpretations. Engine interfaces were checked against [IsaacDocs players.xml](https://wofsauge.github.io/IsaacDocs/rep/xml/players.html), [EntityPlayer](https://wofsauge.github.io/IsaacDocs/rep/EntityPlayer.html), and [Level](https://wofsauge.github.io/IsaacDocs/rep/Level.html).
