# Model-family roster candidate

This experimental expansion covers eleven model families: Claude, DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Doubao, Kimi, and GLM. It is a declared working roster, not a claim that every current model or provider is represented. Existing normal and tainted Claude/DeepSeek remain; the nine additions currently have normal forms only. Model versions and service products are grouped by family.

The owner requested a new art pass and playable model-inspired mechanics on 2026-10-23. This authorizes development of the expansion while the earlier engine acceptance matrix remains open. No Workshop release is authorized by an offline pass.

## Gameplay

The following are fictional gameplay interpretations, not a performance ranking or literal claims about products. All new interface text is English as requested by the owner.

| Family | Implemented loop | Tradeoff / limit |
|---|---|---|
| Claude | Existing usage, account age and risk; tainted weekly allowance | Existing v0.5 rules, unchanged |
| DeepSeek | Normal Rice First: earn bowls from clears, eat for Thought/speed; tainted Wenfeng / Wengu spends Peak/Valley Compute on tear forks | Normal Thought has initial native tear/laser/knife/fetus-bomb adapters and bounded continuous windows; see NATIVE_THOUGHT.md for remaining adapters and engine acceptance. Direct connection unchanged |
| GPT | Same Name, Smaller Brain: Verified (1.15x) until three unique combat clears of Routing, then the next combat starts in Fallback (0.8x). Tap DROP in Fallback to tag a Sanity Check enemy; three distinct paid hits or its defeat restore Verified | One check per room; leaving fails it. New floor restores Verified. Native firing interval. Implemented in gpt_downgrade.lua, saved in `Risk.state.gptRouting` |
| Gemini | Tap DROP to switch Prism and Echo | Prism: piercing and 1.2x damage; Echo: homing, 0.9x damage and 0.9x interval |
| Grok | Moving builds live momentum over five seconds | Up to 25% damage; standing drains three times faster |
| Qwen | Chain flawless combat-room clears | 6% damage per clear, maximum five; damage taken resets it |
| Llama | Every second unique combat clear gives all living players two blue flies | Personal base damage 10% lower; each Llama has an independent counter |
| Mistral | Moving and firing together builds tailwind | After two seconds, spectral tears; +0.15 movement and +0.25 shot speed |
| Doubao | Prepare a meal every third unique combat clear | Heal one red heart; two blue flies if red health is full |
| Kimi | Flawless combat clears preserve context pages | 4% damage and 25 range per page, maximum six; a hit erases two |
| GLM | Active-item use establishes tool links | 12% damage per link, maximum three, reset on entering another room; pocket Book of Secrets |

Hold MAP in a cleared room to see a full illustration and instructions. Release to close. Combat does not display the large portrait. The dossier currently shows one local player's requested card at a time.

Gemini mode switching and GPT's Sanity Check occur only when a short DROP press is released, after 1–12 gameplay frames. A longer hold never switches modes. The observer leaves native input alone, including trinket dropping and pocket cycling; actual engine combinations still need testing. A key held through start/continue, room transition, pause or control reassignment must be released before a new tap can qualify. The upcoming meme-based replacement designs in CHARACTER_GAMEPLAY.md are not implemented by this input correction.

## State and compatibility

Progress is stored under `Risk.state.modelRoster` by player slot and model key. Modes, clear counters, hit state and awarded room seeds survive save/continue. A fresh run resets them. A changed player type gets fresh state when next used. Slots follow the existing mod's co-op convention; joining/leaving players and character-changing items still need engine tests.

Grok momentum, Mistral wind and GLM's same-frame use guard are transient. They share a record across Lua wrappers via `GetPtrHash`, guarded by `InitSeed` and the observed roster player type. Game start/exit clears the records; momentum and wind also reset on entering another room. These charges are intentionally not saved. The guard detects an observed type change, not an unobserved change away and back between callbacks.

DROP gestures use a separate reusable observer with pointer/seed/type/controller identity. Pending input never enters Risk.state. New run/continue, exit, room/floor changes, loss of control, death and observed pause cancel a gesture. Selected mode persistence is unchanged. This observes [held action state](https://wofsauge.github.io/IsaacDocs/rep/Input.html#isactionpressed) and [pause state](https://wofsauge.github.io/IsaacDocs/rep/Game.html#ispaused); it does not consume the native action or claim support for unobserved controller events.

Damage, firing interval, range, speed and tear flags use engine cache callbacks. The new roster does not generate extra tears recursively. Cache-based damage applies to weapon types that use player damage, but this is not proof of Brimstone, Technology, knife, bomb or familiar compatibility. Tear flags have the normal engine's weapon-specific limits. Reactions Port Pack fallback registration covers all registered characters while preserving explicit support.

Damage cancelled by this mod's earlier Constitution callback does not reach roster bookkeeping. Fake damage and deliberate self-damage flagged `DAMAGE_NO_PENALTIES` (Blood Donation, IV Bag, sacrifice rooms) are ignored; whether every vanilla self-damage source sets that flag needs engine confirmation.

Roster families are outside the proxy IP / risk account: their hits never add risk or spoil a clean room, and suspension never reduces their damage. Their tear color is a tint multiplied into the current color, preserving item colors and offsets. Other mods cancelling a later damage callback remain an engine integration case. GLM counts active-use callbacks, excludes Car Battery repeats, and deduplicates a frame; this is not an engine-wide guarantee that every third-party item consumed a charge.

## Art and provenance

The normal portraits use ZipZipPipe's AI-personification series: Claude, DeepSeek, GPT, Gemini, Grok, Qwen, Llama, Mistral, Seed / Doubao, Kimi and GLM. The eleven original files were verified against their catalog SHA-256 values. The built-in image tool made transparent adaptations and replaced explicit company emblems under the repository's existing art rule. These derivatives retain the recognizable designs; they are not byte-identical original illustrations. Both tainted portraits retain the owner's approved generated designs, with slightly deeper colors.

All thirteen gameplay sheets now follow the selected portrait identities: hair, costume palette and signature accessories. The built-in image tool generated the art; `tools/pack_selected_sprites.py` crops and packs frames without drawing replacement art. Directional animation and special-pose acceptance remain pending. Some alternate poses reuse headless walking frames. The four original characters also received newly drawn gameplay sheets, preserving their selected designs. See [art terms](../resources/ART_LICENSE.md), [source and edit records](portrait-prompts.json), and [tainted prompts](tainted-portrait-prompts.json). No video frames, voices, private material or official avatar downloads are bundled.

## Evidence

Offline coverage tests each new mechanic, numerical bounds, mode/hit continuation with recreated entities and module state, co-op separation, duplicate room awards, Car Battery duplication, fresh runs and unchanged DeepSeek identification. Asset checks verify file existence, PNG dimensions and animation frame bounds. These tests do not establish attractive animation, game feel, real JSON restart persistence or a successful engine run.

Distinct-wrapper fixtures additionally verify that charge survives callback reference changes and garbage collection, cache/HUD values agree, and GLM deduplicates callbacks for one player while allowing another player's use. Pointer reuse with a new initialization seed and observed roster-type changes reset temporary charge. The multi-wrapper Grok case fails before the identity fix on `0573b2f` and passes afterward. These fixtures model documented reference behavior; they do not reproduce actual engine timing.

Engine acceptance is pending: all eleven normal selections plus both tainted selections; every direction and special pose; MAP dossier; mode controls with trinkets; item rerolls and costumes; actual application restart; base Repentance and Repentance+; weapon families; and co-op. No Workshop publication.

## Research boundaries

The roster is the owner's explicit eleven-family selection, not a claim of exhaustive market coverage. Mechanics are fictional gameplay interpretations. Engine interfaces were checked against [IsaacDocs players.xml](https://wofsauge.github.io/IsaacDocs/rep/xml/players.html), [EntityPlayer](https://wofsauge.github.io/IsaacDocs/rep/EntityPlayer.html), and [Level](https://wofsauge.github.io/IsaacDocs/rep/Level.html).
