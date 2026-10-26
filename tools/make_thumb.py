"""Export a deterministic 512x512 local preview from the registered Ban Hammer.

Usage: python tools/make_thumb.py --out work/previews/ban-hammer.png [--check]
Standard library only. This exports an item preview, not a final cover or upload.
"""

import argparse
from pathlib import Path

import make_item_art as art

ROOT = Path(__file__).resolve().parent.parent
GFX = 'collectibles/ban_hammer.png'
BG = (40, 32, 30, 255)
SIZE = 512


def render(root=ROOT):
    """Validate the selected registry entry and source PNG before rendering."""
    root = Path(root)
    entry = art.registry(root)[GFX]
    canonical, png = art.produce(root, entry)
    art.require(entry == canonical, 'Ban Hammer manifest metadata is stale')
    source = root / art.ICON_ROOT / GFX
    art.require(source.read_bytes() == png, 'Ban Hammer source icon differs from its producer')
    width, height, rows = art.read_rgba(source)
    art.require((width, height) == (32, 32), 'Expected a 32x32 Ban Hammer icon')
    scale, pixels = SIZE // width, []
    for row in rows:
        line = []
        for x in range(width):
            rgba = row[4*x:4*x+4]
            alpha = rgba[3]
            colour = tuple((rgba[i]*alpha + BG[i]*(255-alpha)) // 255 for i in range(3)) + (255,)
            line.extend([colour] * scale)
        pixels.extend([line] * scale)
    return art.png_bytes(pixels)


def export(output, root=ROOT, check=False):
    output, root = Path(output).resolve(), Path(root).resolve()
    art.require(output.suffix.lower() == '.png', 'Preview output must be a PNG path')
    protected = tuple((root / name).resolve() for name in ('resources', 'content', 'docs/art'))
    art.require(not any(output.is_relative_to(folder) for folder in protected),
                'Preview output cannot replace game assets or art review sheets')
    png = render(root)
    if check:
        art.require(output.is_file() and output.read_bytes() == png,
                    'Preview is missing or differs from the current registered icon')
    else:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_bytes(png)
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True, help='Explicit local PNG destination')
    parser.add_argument('--check', action='store_true', help='Compare an existing output without writing')
    args = parser.parse_args()
    try:
        path = export(args.out, check=args.check)
    except (OSError, ValueError, KeyError) as error:
        parser.error(str(error))
    print(f"{'checked' if args.check else 'wrote'} {path}")


if __name__ == "__main__":
    main()
