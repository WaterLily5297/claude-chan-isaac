# Model-family roster candidate

This experimental expansion covers eleven model families: Claude, DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi, and GLM. It is a declared working roster, not a claim that every current model or provider is represented. Existing normal and tainted Claude/DeepSeek remain; the nine additions currently have normal forms only. Model versions and service products are grouped by family.

The owner requested a new art pass and playable model-inspired mechanics on 2026-10-23. This authorizes development of the expansion while the earlier engine acceptance matrix remains open. No Workshop release is authorized by an offline pass.

## Gameplay

The following are fictional gameplay interpretations, not a performance ranking or literal claims about products. All new interface text is English as requested by the owner.

| Family | Implemented loop | Tradeoff / limit |
|---|---|---|
| Claude | Existing usage, account age and risk; tainted weekly allowance | Existing v0.5 rules, unchanged |
| DeepSeek | Normal Rice First: earn bowls from clears, eat for Thought/speed; tainted Wenfeng / Wengu spends Peak/Valley Compute on tear forks | Normal Thought has initial native tear/laser/knife/fetus-bomb adapters and bounded continuous windows; see NATIVE_THOUGHT.md for remaining adapters and engine acceptance. Direct connection unchanged |
| GPT | Same Name, Smaller Brain: Verified (1.15x) until three unique combat clears of Routing, then the next combat starts in Fallback (0.8x). Tap DROP in Fallback to tag a Sanity Check enemy; three distinct paid hits or its defeat restore Verified | One check per room; leaving fails it. New floor restores Verified. Native firing interval. Implemented in gpt_downgrade.lua, saved in `Risk.state.gptRouting`. Tainted Reset Watcher: DROP toggles Standard / Full Send (1.5x for one of 80 Credits per attack); three clears bank a Tibo reset that refills Credits (gpt_reset.lua) |
| Gemini | Nano Banana: tap DROP to spend Paint (start 2, cap 3, +1 per unique combat clear) marking the nearest enemy within 180 units for eight seconds | Owner damage to it is 1.2x (Birthright 1.3x); owner kill leaves a four-second slowing peel. One mark and peel per owner. Implemented in gemini_paint.lua, saved in `Risk.state.geminiPaint` Tainted One More Edit: base 0.9x; DROP starts a six-second chain on the nearest enemy within 180 units, three distinct paid hits export one 2x pulse, once per room (gemini_edit.lua) |
| Grok | Is This True?: once per hostile room, tap DROP to check the nearest enemy within 220 units for six seconds | Owner damage 1.3x to it, 0.9x to others; three paid hits or its defeat give +0.15 speed for the room. Implemented in grok_check.lua, saved in `Risk.state.grokCheck` Tainted Quote Without Reading: base 0.9x; DROP quotes the nearest enemy within 220 units for six seconds (ten-second cooldown); paid hits on others build Ratio (cap 3), landing as 1x pulses at expiry (grok_ratio.lua) |
| Qwen | Everyone's Base Model: tap DROP to pick Range / Tempo / Power; a newly entered hostile room spends one Adapter on it | +60 range, 0.9x firing interval or 1.1x damage for that room only. Start 1, cap 2 (Birthright 3), one per two unique combat clears. Implemented in qwen_adapter.lua, saved in `Risk.state.qwenAdapter` Tainted Final Final Fine-Tune: cleared-room DROP cycles Heavy (1.3x damage, 1.2x interval), Tiny (0.85x, 0.8x) or Balanced, locked in combat; unique clears with all three builds give +0.2 damage for the floor, max three (qwen_finetune.lua) |
| Llama | Please Stay Open: tap DROP to spend a Release (start 1, cap 2, one per two unique combat clears) | Each living player, up to four, gains two blue flies; solo gets four; Birthright +2 for the owner. Base damage 0.95x. Implemented in llama_release.lua, saved in `Risk.state.llamaRelease` Tainted Still Waiting: base 0.9x; unique clears add Hype (cap 3); DROP spends all Hype on a stationary helper firing a 0.5x tear per second for four seconds per Hype, removed on room exit (llama_hype.lua) |
| Mistral | Le Chat: move while firing for two seconds to charge a Pounce; tap DROP to swipe forward | 2x owner damage once per enemy in an 80-unit line (Birthright 110), walls block, three-second cooldown; standing still one second loses it. Speed +0.1. Implemented in mistral_pounce.lua |
| Doubao | Sorry, You're Right: the first enemy-caused hit in each room grants an Apology token; tap DROP to spend it | Slows enemies within 100 units for two seconds and removes the four nearest enemy bullets; token lasts six seconds (Birthright: until room exit); no health refund |
| Kimi | Another Slide Deck: each unique combat clear earns a Slide, cap six; tap DROP to present | Spends three Slides (Birthright two) on the three nearest enemies within 220 units: four seconds of slowing and +15% owner damage to them; no audience, no spend |
| GLM | Number in Queue: each unique combat clear advances the Queue, max three; at three, tap DROP to redeem an Access Pass | +20% damage in each of the next two new hostile rooms (Birthright three); the Queue pauses while the pass is active; revisits neither spend nor stack it |

Hold MAP in a cleared room to see a full illustration and instructions. Release to close. Combat does not display the large portrait. The dossier currently shows one local player's requested card at a time.

Gemini's Paint, GPT's Sanity Check, Grok's fact check, Qwen's adapter pick, Llama's Release, Mistral's Pounce, Doubao's Apology, Kimi's presentation and GLM's Access Pass occur only when a short DROP press is released, after 1–12 gameplay frames. A longer hold never switches modes. The observer leaves native input alone, including trinket dropping and pocket cycling; actual engine combinations still need testing. A key held through start/continue, room transition, pause or control reassignment must be released before a new tap can qualify. The upcoming meme-based replacement designs in CHARACTER_GAMEPLAY.md are not implemented by this input correction.

## State and compatibility

`scripts/characters/model_roster.lua` now holds only identities, dossier lines and the tear tint; it keeps no state. Each family's module saves its own versioned per-player table in `Risk.state` (for example `gptRouting`, `kimiSlides`, `glmQueue`), keyed by player slot and guarded by pointer, `InitSeed` and player type. A fresh run resets them; a changed player type or replacement entity gets fresh state. Live marks, decks and charges are transient. Joining/leaving players and character-changing items still need engine tests. A legacy `Risk.state.modelRoster` table in an old save is ignored.

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

Engine acceptance is pending: all eleven normal selections plus both tainted selections; every direction and special pose; MAP dossier; mode controls with trinkets; item rerolls and costumes; actual application restart; base Repentance and Repentance+; weapon families; and co-op. No Workshop publication.

## Research boundaries

The roster is the owner's explicit eleven-family selection, not a claim of exhaustive market coverage. Mechanics are fictional gameplay interpretations. Engine interfaces were checked against [IsaacDocs players.xml](https://wofsauge.github.io/IsaacDocs/rep/xml/players.html), [EntityPlayer](https://wofsauge.github.io/IsaacDocs/rep/EntityPlayer.html), and [Level](https://wofsauge.github.io/IsaacDocs/rep/Level.html).
