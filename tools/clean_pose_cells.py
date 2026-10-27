"""Remove crop leftovers from the complete-pose cells of a packed character sheet.

Usage: python3 tools/clean_pose_cells.py [--check]

Each complete pose is cropped from a generated source row, so a crop can catch
a sliver of the neighbouring pose or a one-pixel line from the row below. This
removes only two kinds of pixels and draws nothing:

1. A floating line: a horizontal run of 12 or more opaque pixels with nothing
   below it in the cell and almost nothing above it.
2. An edge sliver: a detached fragment under 80 pixels lying entirely within
   eight pixels of the cell's left or right edge.

Only the twelve pose cells at y=128..319, x=0..255 are touched; heads, walking
bodies and the carry head at (256,128) are not. The helpers use the standard
library so tools/check_pose_geometry.py can run the same detector in the gate.
Without --check, the thirteen packed sheets are cleaned in place; afterwards
run tools/make_roster_tainted_art.py --skins-only and update the packed hashes.
"""

POSE_CELLS = [(column * 64, 128 + row * 64) for row in range(3) for column in range(4)]
CELL = 64
LINE_MIN = 12
EDGE = 8
SLIVER_MAX = 80


def floating_lines(opaque, x0, y0):
    """Yield (y, first, last) runs that sit alone at the bottom of a cell."""
    for y in range(y0, y0 + CELL):
        x = x0
        while x < x0 + CELL:
            if not opaque(x, y):
                x += 1
                continue
            start = x
            while x < x0 + CELL and opaque(x, y):
                x += 1
            run = range(start, x)
            if len(run) < LINE_MIN:
                continue
            below = y + 1 < y0 + CELL and any(opaque(i, yy) for i in run for yy in range(y + 1, y0 + CELL))
            above = sum(opaque(i, y - 1) for i in run) if y > y0 else 0
            if not below and above * 4 <= len(run):
                yield y, start, x - 1


def fragments(opaque, x0, y0):
    """Return the cell's 8-connected components, largest first."""
    seen, blobs = set(), []
    for y in range(y0, y0 + CELL):
        for x in range(x0, x0 + CELL):
            if (x, y) in seen or not opaque(x, y):
                continue
            stack, points = [(x, y)], []
            seen.add((x, y))
            while stack:
                cx, cy = stack.pop()
                points.append((cx, cy))
                for nx in (cx - 1, cx, cx + 1):
                    for ny in (cy - 1, cy, cy + 1):
                        if (x0 <= nx < x0 + CELL and y0 <= ny < y0 + CELL
                                and (nx, ny) not in seen and opaque(nx, ny)):
                            seen.add((nx, ny))
                            stack.append((nx, ny))
            blobs.append(points)
    return sorted(blobs, key=len, reverse=True)


def edge_slivers(opaque, x0, y0):
    """Yield small detached fragments hugging the cell's left or right edge."""
    for points in fragments(opaque, x0, y0)[1:]:
        xs = [x - x0 for x, _ in points]
        if len(points) < SLIVER_MAX and (max(xs) < EDGE or min(xs) >= CELL - EDGE):
            yield points


def leftovers(opaque):
    """List every pixel the cleaner would remove, cell by cell."""
    found = []
    for x0, y0 in POSE_CELLS:
        points = [(x, y) for y, a, b in floating_lines(opaque, x0, y0) for x in range(a, b + 1)]
        removed = set(points)
        remaining = lambda x, y: opaque(x, y) and (x, y) not in removed
        points += [p for blob in edge_slivers(remaining, x0, y0) for p in blob]
        if points:
            found.append(((x0, y0), points))
    return found


def clean(image):
    """Clear the leftovers in place on a Pillow RGBA image; return the pixel count."""
    px = image.load()
    total = 0
    for _, points in leftovers(lambda x, y: px[x, y][3] >= 128):
        for x, y in points:
            px[x, y] = (0, 0, 0, 0)
        total += len(points)
    return total


def main():
    import sys
    from pathlib import Path
    from PIL import Image
    root = Path(__file__).resolve().parent.parent
    keys = ('claudechan', 'deepseekchan', 'claudechan_b', 'deepseekchan_b', 'gptchan', 'geminichan',
            'grokchan', 'qwenchan', 'llamachan', 'mistralchan', 'doubaochan', 'kimichan', 'glmchan')
    for key in keys:
        path = root / f'resources/gfx/characters/costumes/character_{key}.png'
        image = Image.open(path).convert('RGBA')
        if '--check' in sys.argv:
            px = image.load()
            found = leftovers(lambda x, y: px[x, y][3] >= 128)
            print(key, ', '.join(f'{cell}: {len(points)}px' for cell, points in found) or 'clean')
            continue
        count = clean(image)
        if count:
            image.save(path, optimize=True)
        print(f'{key}: removed {count} pixel(s)')


if __name__ == '__main__':
    main()
