# Gameplay sheet audit (2026-10-27)

This is an offline audit of the 22 gameplay sheets in `resources/gfx/characters/costumes/`, against `e24ad5b`. It is not an engine observation. The owner has not tested the installed `8fd6a8c`, and this change does not touch that installation.

The audit looked at the twelve complete-pose cells: 64x64 cells at y=128..319 and x=0..255. These are the cells behind Hit, Death, pickup, teleport, jump and the other shared animations listed in [POSE_REVIEW.md](POSE_REVIEW.md). Each sheet was checked for detached fragments, one-pixel lines, flat cut edges and pixels left below the pose rows. Each flagged cell was then inspected at 3x.

## Fixed in this change: crop leftovers

[clean_pose_cells.py](../tools/clean_pose_cells.py) removes two kinds of leftovers and draws nothing:

- A floating one-pixel line under the feet.
- A small detached fragment of a neighbouring pose that hugs a cell's left or right edge.

[pack_selected_sprites.py](../tools/pack_selected_sprites.py) now runs it as its last step. [check_pose_geometry.py](../tools/check_pose_geometry.py) runs the same detector in the gate on all 22 sheets.

| Sheet | Cells | Removed |
|---|---|---|
| Tainted Claude-chan | (128,128) | 15 px red speck from the neighbouring pose |
| Qwen-chan and tainted | (128,256), (192,256) | Two 1 px lines under the feet, 75 px |
| Mistral-chan and tainted | (64,128), (192,192) | Two edge slivers, 14 px |
| Doubao-chan and tainted | (128,128), (64,192), (64,256), (128,256) | Twin-tail slivers from the neighbouring pose, 115 px |

Every changed pixel became transparent, and no other pixel changed. The four packed hashes in [roster-art-manifest.json](roster-art-manifest.json) and the three tainted skin hashes in [tainted-roster-art-manifest.json](tainted-roster-art-manifest.json) were updated. The six unaffected tainted skins keep their bytes. Running the cleaner again changes nothing.

## Open: poses cut by their source crop

These cells show a straight cut through the body. The generated source pose was taller or wider than the crop box, so the packer fitted a partial body into the cell. The fix is to re-crop from the private source atlases with corrected boxes, as was done earlier for Llama's Death-start cell. The packed sheet alone cannot fix them, because the cut-off parts were never packed.

| Sheet | Cut cells | What is missing |
|---|---|---|
| Tainted Claude-chan | (0,256), (64,256), (128,256), (192,256) | Lower body below the chest; the skirt and feet remain as unused pixels at y=320..335 |
| Tainted Claude-chan | (192,128) fallen, (192,192) | Right side of the hair and body |
| Claude-chan | (192,192), (192,256) | Right edge of the hair |
| Llama-chan and tainted | (64,192), (192,192), (0,256), (64,256), (128,256), (192,256) | Lower body; the feet remain as unused pixels at y=320..331 |
| Doubao-chan and tainted | (192,192), (192,256) | Right edge of the twin tail |

Death-start (0,192) is not in the list. Hit (128,192) is only flagged on Claude-chan's right hair edge, and its contracts still pass. Native animation names for the (64,192), (192,192) and y=256 cells are not recorded in this repository. Confirming which animations show these cuts needs the privately extracted player animation file and `tools/preview_character_poses.py`.

## Open: pixels left below the pose rows

The packer clears only y<320 before fitting cells. Below that, every sheet keeps the generated atlas at its original scale. That is intended for the lower layout, which holds ghost, beam and group art. In the cases above, it also keeps the bottom of the source's third pose row at y=320..335.

These pixels are harmless if no native crop starts in that band. If one does, they would appear as loose feet at the top of that frame. This needs the same native animation check. Do not clear the band blindly, because the lower layout may also start there.

## Notes, no change

- The original four sheets have soft-alpha edges in their head and walking cells (about 2,400 pixels with alpha 1..127 per sheet), from the movement pass. The nine newer sheets use hard alpha. [ART_SPEC.md](ART_SPEC.md) requires hard alpha for item icons only. Check soft edges only if the native view shows fringes.
- Dossiers and stage portraits touch the top and bottom image edges by design (full-height fit). Menu cells do not touch their cell edges.
- The narrowed-front side bodies, GLM's seated fallen pose and the oversized-hurt-head report stay open as recorded in [ART_STATUS.md](ART_STATUS.md).
