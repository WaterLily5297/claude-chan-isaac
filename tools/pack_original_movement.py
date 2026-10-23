"""Pack four reviewed image-tool movement sheets without drawing new artwork.

Run after pack_selected_sprites.py, with the directory containing claude.png,
deepseek.png, claude_b.png and deepseek_b.png. Keep the generated source files
and their recorded hashes. Only movement cells and the carry head are replaced;
special poses and effects are retained. This is not engine acceptance evidence.
"""
import argparse
import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ROWS = {
    'claude': (0, 240, 472, 715, 1024),
    'deepseek': (0, 282, 500, 742, 1024),
    'claude_b': (0, 250, 466, 700, 1024),
    'deepseek_b': (0, 265, 490, 730, 1024),
}
# Ten engine body frames are filled by a six-frame generated movement cycle.
CYCLE = (0, 1, 2, 3, 4, 5, 4, 3, 2, 1)


def parts(source, key, row, limit):
    """Cut at transparent gutters, then use a shared scale for each row."""
    y0, y1 = ROWS[key][row:row + 2]
    alpha = source.getchannel('A')
    cuts = [0]
    for nominal in range(256, 1536, 256):
        def score(x):
            pixels = alpha.crop((x, y0, x + 1, y1)).tobytes()
            return (sum(a >= 128 for a in pixels), abs(x - nominal))
        cuts.append(min(range(nominal - 32, nominal + 33), key=score))
    cuts.append(1536)
    pieces = []
    for left, right in zip(cuts, cuts[1:]):
        piece = source.crop((left, y0, right, y1))
        bounds = piece.getchannel('A').point(lambda a: 255 if a >= 128 else 0).getbbox()
        if not bounds:
            raise ValueError(f'Missing {key} row {row} frame at {left}')
        pieces.append(piece.crop(bounds))
    scale = min(limit[0] / max(p.width for p in pieces),
                limit[1] / max(p.height for p in pieces))
    return [p.resize((max(1, round(p.width * scale)),
                      max(1, round(p.height * scale))), Image.Resampling.NEAREST)
            for p in pieces]


def pack(atlas, source, key):
    if source.size != (1536, 1024) or source.mode != 'RGBA':
        raise ValueError(f'{key}: expected the reviewed 1536x1024 RGBA source')
    out = atlas.convert('RGBA').copy()
    heads = parts(source, key, 0, (28, 26))
    front = parts(source, key, 1, (20, 18))
    side = parts(source, key, 2, (20, 18))
    carry = parts(source, key, 3, (24, 22))

    def place(piece, x, y, cell=32, bottom=25):
        target = Image.new('RGBA', (cell, cell))
        target.alpha_composite(piece, ((cell - piece.width) // 2, bottom - piece.height))
        out.paste(target, (x, y))

    for i, head in enumerate(heads):
        place(head, i * 32, 0, bottom=27)
    place(heads[0], 256, 0, bottom=27)
    for i, phase in enumerate(CYCLE):
        # Vanilla WalkDown/Up use row 1 followed by the two cells at (192, 0).
        x, y = (i * 32, 32) if i < 8 else ((i - 2) * 32, 0)
        place(front[phase], x, y, bottom=26)
        place(carry[i % 3], x + 256, y, bottom=26)
        # WalkLeft/Right use row 2 followed by the first two cells in row 3.
        x, y = (i * 32, 64) if i < 8 else ((i - 8) * 32, 96)
        place(side[phase], x, y, bottom=26)
        place(carry[3 + i % 3], x + 256, y, bottom=26)
    # PickupWalk uses a 64px head cell with pivot (32,44), not a full body.
    place(heads[0], 256, 128, cell=64, bottom=43)
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    args = parser.parse_args()
    manifest_path = ROOT / 'docs/roster-art-manifest.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    for key in ROWS:
        source_path = args.source / (key + '.png')
        gamekey = key.replace('_b', 'chan_b') if key.endswith('_b') else key + 'chan'
        target = ROOT / f'resources/gfx/characters/costumes/character_{gamekey}.png'
        result = pack(Image.open(target), Image.open(source_path), key)
        result.save(target, optimize=True)
        record = next(entry for entry in manifest if entry['key'] == key)
        record['movement_source_sha256'] = hashlib.sha256(source_path.read_bytes()).hexdigest()
        record['packed_sprite_sha256'] = hashlib.sha256(target.read_bytes()).hexdigest()
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print('Packed four movement revisions; engine acceptance remains pending.')


if __name__ == '__main__':
    main()
