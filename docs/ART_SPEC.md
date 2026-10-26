# Art specification and production guide

Updated 2026-10-26 from source `8fd6a8c`. The roster has **11 families / 22 forms, 80 collectibles, 12 trinkets and five pill effects**. [ART_STATUS.md](ART_STATUS.md) inventories every bundled image/animation and the native presentations without custom files. That document is the art queue; this one defines how replacements are produced and checked.

This documentation unit specifies the designed-icon pipeline. It does **not** implement that pipeline, redraw an asset or change `tools/check_assets.py`. The current exact placeholder-byte gate remains active until the migration below ships with its own tests. Native art acceptance remains pending.

## Identity, compatibility and rights

Keep the owner's selected ZipZipPipe AI-personification identities for all eleven normal forms. Preserve the retained tainted Claude and DeepSeek designs. The other nine tainted sets currently deepen the normal palette; a distinct identity requires a combined portrait/front/side/back/hurt preview and owner approval before replacement. Merely darkening a sheet does not finish that work.

Center the face and torso around native pivots while preserving intentional asymmetry such as ornaments, hair or held objects. A mechanically mirrored frame is not proof of appealing anatomy. Claude's selected identity retains orange-red hair, the sun/flower ornament, the cream/black/orange dress and book motif. Use the recorded selected portraits for the other families, not a fresh unofficial design substituted without review.

Follow [COSTUME_COMPATIBILITY.md](COSTUME_COMPATIBILITY.md): mod forms keep a fixed look, with item costume layers cleared but native item effects, weapon flags/colours, flight, size and transformations preserved. Keep this policy in the dedicated costume-lock service. Do not add a separate hair costume, replace a player's full sprite every frame, normalize player scale or change player type merely to display art. Native shield cues, giant states and departure restoration still require the O4 cases.

Code and original placeholder item drawing code/art use the project MIT terms. Character designs and their derivatives have separate credited, non-commercial conditions; DeepSeek retains the documented additional credits and CC BY-NC-SA terms. Read [ART_LICENSE.md](../resources/ART_LICENSE.md), [portrait records](portrait-prompts.json), [sprite records](sprite-prompts.json) and [tainted records](tainted-portrait-prompts.json). Do not infer a blanket licence from AI generation or a curator's catalogue. No fresh direct licence verification is claimed here.

Inspect native geometry privately when necessary, then draw original pixels in project-owned sources. Do not commit extracted native PNGs/ANM2, trace or draw over them for redistribution, import unlicensed mod art, use official company logos, or upload private reference collections. Original reference shapes drawn for contact sheets must be clearly labelled as project examples. Workshop remains unauthorized.

## Runtime file contracts

| Asset | Contract and consumer |
|---|---|
| Gameplay sheet | `resources/gfx/characters/costumes/character_<family>chan[_b].png`, 512x512 RGBA; `content/players.xml` selects the sheet. Keep the current native cell layout and animation pivots. |
| Stage/VS portrait | `resources/gfx/ui/stage/playerportrait_<family>chan[_b].png`, 144x144 RGBA. `portrait` and `bigportrait` deliberately reference the same file. There is no required separate big-portrait file. |
| Name strip | `resources/gfx/ui/boss/playername_<family>chan.png`, 128x32 RGBA; shared by normal and tainted forms. English text is permitted here. |
| Dossier | `resources/gfx/ui/dossiers/<family>[_b].png`, 384x576 RGBA, with a matching `.anm2` wrapper. Keep crop, sprite reference and HUD placement aligned. |
| Menu names | `content/gfx/ai_names.png`, 256x352; maintain all eleven family slots and matching wrapper bounds. |
| Menu portraits | `content/gfx/ai_portraits.png`, 704x64; `ai_portraits_b.png`, 704x128. Preserve the current cells and normal/tainted animation mappings. |
| Menu wrappers | `charactermenu.anm2`, `characterportraits.anm2`, `characterportraitsalt.anm2` under `content/gfx`; no out-of-bounds crops or unresolved sheets. |
| Collectible/trinket icon | `resources/gfx/items/{collectibles,trinkets}/<registered_gfx>.png`, exactly 32x32 RGBA8; retain the `items.xml` reference and pool identity. |
| Pills | Five effects use native random pill presentation. No custom per-effect PNG is required by current registration. |
| Relay Slime | Currently tinted/scaled native Clotty, with no bespoke sheet or animation. W1.6 must add explicit art/registration checks when a custom asset is implemented. |

## Player pose geometry

Use [POSE_REVIEW.md](POSE_REVIEW.md) and `tools/check_pose_geometry.py` as the measured packing contract. The earlier broad instruction to fit every complete pose into 28x32 must not override the distinct Death envelopes below.

| Pose | Visible alpha envelope | Ground anchor in the actual crop |
|---|---|---|
| Hit | At most 28x32 | Bottom 55 |
| Upright Death cells | At most 28x33 | Bottom 57 |
| Fallen Death | At most 36x27 | Bottom 59; crop begins at atlas (192,130), so storage-cell bottom is 61 |

The four contracts pass on all 22 sheets after O5. Do not scale those cells back to the old 58px square. Retain the Llama Death-start crop that includes hands and feet. Match geometry at the measured alpha threshold (128); inspect lower-alpha fringes and actual native rendering separately.

Eighteen sheets still use narrowed-front side bodies; both GLM forms have a seated-looking fallen pose. Proper profiles, anatomical cleanup and consistent walk/carry phases are unfinished. Preserve selected identity and alpha/pivot placement while correcting them. The original four have dedicated side profiles, but they also need native animation acceptance.

Preview all forms at 1x and enlarged nearest-neighbour scale. Include idle/shoot heads, front/back/side walking, carrying, Hit and all Death cells. Shared complete-pose cells also serve pickup, teleport, jump, trapdoor, appear and other special sequences: consult the full list in POSE_REVIEW rather than inferring their success from four envelopes. Offline crops do not model native interpolation, tint, ghost rendering, costume order, collision size or flight.

## Item-icon style

The target is readable beside native pickups at the game's scale, using original project pixels. An icon should identify the object and suggest its existing effect without needing its name. The following requirements apply to new designed icons; legacy placeholder differences are tracked until each icon migrates.

| Property | Designed-icon requirement |
|---|---|
| Canvas | Exactly 32x32, 8-bit RGBA PNG. Transparent background, nonempty visible silhouette, hard pixel edges; alpha only 0 or 255. No antialiasing or blurred resampling. |
| Silhouette | Aim for roughly 24-28px across, with transparent breathing room. Judge at 1x before adding detail; use recognizably different silhouettes for unrelated effects. Do not force every object to be mirror-symmetric. |
| Outline | Dark, usually one pixel around the visible object, with selective interior separation. Shared project ink `#080000` is the starting point. Avoid a doubled dark border after compositing. |
| Material ramps | Three or four shades per main material: shadow, base, light, optional highlight. Prefer two or three materials and at most 16 declared visible colours including ink/accent. Palette exceptions need a documented visual reason. |
| Lighting | Light from the top-left, shadow toward the bottom-right. Keep a coherent light source when an item has several parts. |
| Meaning | One primary object and, where needed, one restrained effect cue. A stapler can bind a bullet bundle; rice items should read as rice/cooker/bowl without text labels. Preserve distinctions among similar family items. |
| Text and branding | No letters, digits, readable UI screenshots, company emblems or logos inside icons. Item names remain in pickup/EID text. Symbol-like objects must work as silhouettes rather than typography. |
| Colour | Separate materials by value as well as hue. Do not use colour alone to distinguish two otherwise identical icons. Check against light and dark preview backgrounds. |
| Resampling | Author at 32x32; enlarge previews with nearest-neighbour only. Do not shrink a detailed portrait into an icon. |

The existing Hardcoded Output digits are a recorded migration issue, not a reason to silently fail all legacy icons in a documentation change. Existing recognizable object icons may need refinement rather than replacement with an unrelated metaphor. New art does not authorize changing a registered name, effect, charge, quality or pool weight.

## Reproducible item pipeline: selected, implementation pending

Use **deterministic drawing code**, extending the project's existing reproducible approach. Commit the drawing source and generated PNGs, not private generation sessions. The planned source is `tools/make_item_art.py`; the planned per-icon registry is `docs/item-art-manifest.json`. These files do not yet exist. Keep character production and its existing manifests separate.

Each designed-icon entry will record its exact registered name/gfx path, status, drawing function/version, author/provenance and applicable terms, declared palette and alpha contract, output SHA-256, semantic description and contact-sheet reference. Track explicit `placeholder` versus `designed` status; never infer a designed icon merely because a file was manually overwritten. A `designed` entry is production status, not owner or engine acceptance.

Migration order:

1. Add the registry/producer and meaningful validator regressions. Cover unknown/duplicate paths, a missing registration, invalid dimensions/colour type, empty/opaque backgrounds, undeclared colours or alpha, stale output and invalid pool references. Demonstrate old-check failure for a valid designed icon and rejection of malformed candidates.
2. Update `tools/check_assets.py` to dispatch explicitly by registry status. Legacy placeholders must still equal `make_placeholders.py` output. Designed entries must satisfy their geometry/palette/transparency/provenance contract and match their own deterministic producer, **not** placeholder bytes. The two sets must partition every registered icon with no gaps or overlap.
3. Verify registered collectible pool names and all item gfx references independently of artwork status. Preserve existing player, menu, manifest and pose checks. Reject unexplained asset changes; do not make a broad hash update solely to silence the gate.
4. Migrate about ten icons in a focused main-based PR. Keep all other PNGs byte-identical, provide the source and previews, and update ART_STATUS, art terms as needed, HANDOFF, TESTING and CHANGELOG. Do not count this guide as implementation of those checks.
5. After the required full gate, final-head CI and review, merge under the standing source policy. Runtime installation is a separate authorized, backed-up action; an icon PR must not overwrite the owner's manual-test installation.

## Review package and acceptance

Every icon batch supplies a labelled contact sheet at actual 1x and nearest-neighbour 4x, on light and dark backgrounds, beside a few **original project-drawn reference shapes**. Labels belong outside the icon. List each icon's current effect/meme, intended visual cue, provenance and changed files. Include before/after comparisons and the deterministic output check. Do not use extracted game icons in the public comparison sheet.

Review silhouette and material separation at 1x, outline thickness, light direction, unintended text/logos, repeated motifs, transparent margins and distinction from neighbouring items. Confirm that non-target files stayed unchanged. Character corrections additionally show front/side/back/hurt/death samples and preserve the selected face, hair and costume identity.

The offline gate covers file contracts, deterministic production and relevant regressions. Native acceptance separately covers menu starts, room pickup presentation, pedestals/EID, light/dark rooms, size/flight/weapon combinations, hit/death/special animations and co-op HUD placement. Record exact build and game version for observed cases. The owner's oversized-hurt-head report remains open in the engine until those cases are observed.

Generic placeholder item replacements and geometric repairs can proceed without a new approval round. Replacing an owner-approved look or any character identity requires a concrete preview and approval. No gameplay/balance or Workshop approval is implied by this style guide.
