"""Give the nine newer roster skins a readable, stable walk cycle.

The nine image-tool bodies were packed from slightly different generated frames,
so their ten walk cells jitter and show no legs or stride. This pass keeps one
existing body per direction, lifts it two pixels and draws two small legs under
it in a fixed vanilla-style cycle: the body bobs at the stride extremes, front
legs alternate, side legs swing. Leg colors are sampled from each body's own
outline and lightest skin-like pixel. No external pixels are used.

Usage: python tools/animate_roster_walk.py [--check]
--check rebuilds in memory and fails if a committed atlas differs. Run after
pack_selected_sprites.py (and before any later per-cell correction). This is
offline art work, not engine acceptance.
"""
import argparse
import hashlib
from io import BytesIO
import json
import math
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
KEYS = ('gpt', 'gemini', 'grok', 'qwen', 'llama', 'mistral', 'doubao', 'kimi', 'glm')
LIFT = 1          # pixels the body moves up to make room for legs
CUT = 3           # bottom body rows (old blurred feet) replaced by legs
GROUND = 26       # body cells stand on this row, matching pack_original_movement
FRAMES = 10


def opaque(image):
    return image.getchannel('A').point(lambda a: 255 if a >= 128 else 0).getbbox()


def palette(body):
    """Return (outline, leg, shoe) colors taken from the body itself."""
    raw = body.tobytes()
    pixels = [tuple(raw[i:i + 4]) for i in range(0, len(raw), 4) if raw[i + 3] >= 128]
    outline = min(pixels, key=lambda p: p[0] + p[1] + p[2])
    def skin(p):
        r, g, b = p[:3]
        return r > 150 and r >= g >= b and r - b > 25
    skins = [p for p in pixels if skin(p)]
    leg = max(skins, key=lambda p: p[0] + p[1]) if skins else (232, 196, 176, 255)
    shoe = tuple(max(0, min(255, round(c * 0.55 + o * 0.45)))
                 for c, o in zip(body.getpixel((16, 16))[:3], outline[:3])) + (255,)
    return outline[:3] + (255,), leg[:3] + (255,), shoe


def stride(i):
    """Forward offset of the lead leg for frame i of a ten-frame cycle."""
    return round(2 * math.sin(2 * math.pi * i / FRAMES))


def draw_leg(cell, x, top, length, colors, shade=False):
    outline, leg, shoe = colors
    if shade:
        leg = tuple(round(c * 0.75) for c in leg[:3]) + (255,)
    for y in range(top, top + length):
        cell.putpixel((x - 1, y), outline)
        cell.putpixel((x, y), leg if y < top + length - 1 else shoe)
        cell.putpixel((x + 1, y), outline)
    cell.putpixel((x, top + length), outline)


def frame(body, colors, i, side):
    """Compose one 32x32 walk cell from a cleaned body."""
    s = stride(i)
    bob = 1 if abs(s) == 2 else 0
    cell = Image.new('RGBA', (32, 32))
    legs = Image.new('RGBA', (32, 32))
    top = GROUND - CUT - LIFT - 1 + bob
    center = 16
    if side:
        # Back leg first and darker, then the lead leg in front of it.
        draw_leg(legs, center - s, top, GROUND - top - 1, colors, shade=True)
        draw_leg(legs, center + s, top, GROUND - top - 1, colors)
    else:
        # Front/rear: legs alternate lifting by one pixel.
        lift_left = 1 if s > 0 else 0
        lift_right = 1 if s < 0 else 0
        draw_leg(legs, center - 3, top, GROUND - top - 1 - lift_left, colors)
        draw_leg(legs, center + 2, top, GROUND - top - 1 - lift_right, colors)
    trimmed = body.copy()
    trimmed.paste(Image.new('RGBA', (32, 32 - (GROUND - CUT))), (0, GROUND - CUT))
    cell.alpha_composite(legs)
    cell.alpha_composite(trimmed, (0, -LIFT + bob))
    return cell


def squeeze(body):
    """Narrow a front body into a side-facing silhouette (75% width)."""
    box = opaque(body)
    piece = body.crop(box)
    width = max(6, round(piece.width * 0.75))
    piece = piece.resize((width, piece.height), Image.Resampling.NEAREST)
    out = Image.new('RGBA', (32, 32))
    out.alpha_composite(piece, ((32 - width) // 2, box[1]))
    return out


def animate(atlas):
    out = atlas.convert('RGBA').copy()
    front = out.crop((0, 32, 32, 64))
    carry = out.crop((256, 32, 288, 64))
    colors = palette(front)
    side = squeeze(front)
    side_carry = squeeze(carry)
    for i in range(FRAMES):
        # Cell order matches pack_original_movement: WalkDown/Up use row 1
        # then (192,0)/(224,0); WalkLeft/Right use row 2 then row 3.
        x, y = (i * 32, 32) if i < 8 else ((i - 2) * 32, 0)
        out.paste(frame(front, colors, i, False), (x, y))
        out.paste(frame(carry, colors, i, False), (x + 256, y))
        x, y = (i * 32, 64) if i < 8 else ((i - 8) * 32, 96)
        out.paste(frame(side, colors, i, True), (x, y))
        out.paste(frame(side_carry, colors, i, True), (x + 256, y))
    return out


def encode(image):
    blob = BytesIO()
    image.save(blob, format='PNG', optimize=True)
    return blob.getvalue()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    manifest_path = ROOT / 'docs/roster-art-manifest.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    for key in KEYS:
        record = next(entry for entry in manifest if entry['key'] == key)
        target = ROOT / f'resources/gfx/characters/costumes/character_{key}chan.png'
        if args.check:
            assert hashlib.sha256(target.read_bytes()).hexdigest() == record['packed_sprite_sha256'], key
            continue
        if 'walk_cycle' in record:
            raise SystemExit(f'{key}: already animated; rebuild from pack_selected_sprites.py first')
        target.write_bytes(encode(animate(Image.open(target))))
        record['walk_cycle'] = 'tools/animate_roster_walk.py'
        record['packed_sprite_sha256'] = hashlib.sha256(target.read_bytes()).hexdigest()
    if not args.check:
        manifest_path.write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print('Animated nine walk cycles; engine acceptance remains pending.')


if __name__ == '__main__':
    main()
