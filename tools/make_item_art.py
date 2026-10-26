"""Produce and check registered item icons without replacing character artwork.

Standard library only. The manifest explicitly partitions placeholder and
designed icons. --write regenerates from drawing code, never from an edited PNG;
--check is read-only. Native presentation and aesthetic quality require review.
"""
import argparse
from collections import Counter
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import struct
from typing import Callable
import xml.etree.ElementTree as ET
import zlib

import make_placeholders as legacy
from check_pose_geometry import read_rgba

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = 'docs/item-art-manifest.json'
ICON_ROOT = 'resources/gfx/items'
SCHEMA_VERSION = 1


@dataclass(frozen=True)
class Design:
    draw: Callable
    version: int
    palette: tuple
    description: str
    author: str
    provenance: str
    contact_sheet: str
    palette_exception: str = ''


# Add reviewed original drawing functions in a focused art batch. An empty
# mapping does not promote any of the legacy pictures to designed status.
DESIGNS = {}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def icon_path(value):
    require(isinstance(value, str) and re.fullmatch(
        r'(collectibles|trinkets)/[a-z0-9_]+\.png', value),
        f'Invalid icon path: {value!r}')
    return value


def registrations(root):
    """Validate registration and pools independently of artwork production."""
    xml = ET.parse(root / 'content/items.xml').getroot()
    require(xml.tag == 'items' and xml.get('gfxroot') == 'gfx/items/',
            'Expected items XML with gfx/items/ root')
    result, names = {}, set()
    for item in xml:
        name, gfx = item.get('name'), icon_path(item.get('gfx'))
        require(item.tag in ('active', 'passive', 'trinket'), 'Unknown item kind')
        require(isinstance(name, str) and name.strip(), 'Missing registered name')
        require(name not in names and gfx not in result, 'Duplicate item name or gfx')
        expected_folder = 'trinkets' if item.tag == 'trinket' else 'collectibles'
        require(gfx.startswith(expected_folder + '/'), f'{name}: wrong icon folder')
        names.add(name)
        result[gfx] = {'name': name, 'kind': item.tag}
    require(result, 'No item registrations')
    collectibles = {v['name'] for v in result.values() if v['kind'] != 'trinket'}
    for item in ET.parse(root / 'content/itempools.xml').iter('Item'):
        require(item.get('Name') in collectibles, f'Undefined collectible pool entry: {item.get("Name")}')
    return result


def registry(root):
    entries = json.loads((root / MANIFEST).read_text(encoding='utf-8'))
    require(isinstance(entries, dict) and entries.get('schema_version') == SCHEMA_VERSION,
            'Unsupported item-art manifest schema')
    require(isinstance(entries.get('entries'), list), 'Expected item-art entries list')
    registered = registrations(root)
    result, names = {}, set()
    for entry in entries['entries']:
        require(isinstance(entry, dict), 'Invalid item-art entry')
        gfx = icon_path(entry.get('gfx'))
        require(gfx not in result, f'Duplicate manifest path: {gfx}')
        require(gfx in registered, f'Unknown manifest path: {gfx}')
        require(entry.get('name') == registered[gfx]['name'], f'{gfx}: registered name mismatch')
        require(entry['name'] not in names, 'Duplicate manifest name')
        require(entry.get('status') in ('placeholder', 'designed'), f'{gfx}: unknown artwork status')
        names.add(entry['name'])
        result[gfx] = entry
    require(set(result) == set(registered), 'Manifest is missing registered icons')
    return result


def placeholder_pixels(gfx):
    key = PurePosixPath(gfx).stem
    require(key in legacy.SPRITES, f'No placeholder producer: {gfx}')
    folder = 'trinkets' if key in legacy.TRINKETS else 'collectibles'
    require(gfx == f'{folder}/{key}.png', f'Placeholder kind mismatch: {gfx}')
    grid = legacy.render(legacy.SPRITES[key]())
    if key in legacy.PIXEL_SYMMETRIC:
        for row in grid:
            for x in range(legacy.SIZE // 2):
                row[legacy.SIZE - 1 - x] = row[x]
    return legacy.rgba(grid)


def png_bytes(pixels):
    def chunk(tag, data):
        return (struct.pack('>I', len(data)) + tag + data
                + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff))
    raw = b''.join(b'\0' + bytes(v for pixel in row for v in pixel) for row in pixels)
    header = struct.pack('>IIBBBBB', len(pixels[0]), len(pixels), 8, 6, 0, 0, 0)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', header)
            + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))


def visible_palette(pixels):
    return sorted({'#%02x%02x%02x' % tuple(p[:3]) for row in pixels for p in row if p[3]})


def pixel_contract(pixels, palette, designed):
    require(len(pixels) == 32 and all(len(row) == 32 for row in pixels), 'Expected 32x32 pixels')
    require(all(len(p) == 4 and all(type(v) is int and 0 <= v <= 255 for v in p)
                for row in pixels for p in row), 'Expected RGBA8 values')
    require(all(p[3] in (0, 255) for row in pixels for p in row), 'Undeclared alpha; hard edges required')
    visible = [(x, y) for y, row in enumerate(pixels) for x, p in enumerate(row) if p[3]]
    require(visible, 'Empty icon')
    require(len(visible) < 1024, 'Opaque icon background')
    require(set(visible_palette(pixels)) <= set(palette), 'Undeclared visible colour')
    if designed:
        require(all(0 < x < 31 and 0 < y < 31 for x, y in visible),
                'Designed icon needs a transparent outer margin')


def contact_path(root, relative):
    require(isinstance(relative, str) and relative.startswith('docs/art/')
            and '\\' not in relative and ':' not in relative
            and '..' not in PurePosixPath(relative).parts,
            'Contact sheet must be a repository path under docs/art/')
    require((root / relative).is_file(), 'Missing contact sheet')
    return relative


def produce(root, entry, designs=None):
    """Return canonical record/PNG from a declared status and drawing source."""
    designs = DESIGNS if designs is None else designs
    gfx, status = icon_path(entry['gfx']), entry['status']
    if status == 'placeholder':
        pixels = placeholder_pixels(gfx)
        palette = visible_palette(pixels)
        drawing = {'file': 'tools/make_placeholders.py', 'function': PurePosixPath(gfx).stem, 'version': 1}
        author = 'Project contributors; see resources/ART_LICENSE.md'
        provenance = 'Existing original procedural placeholder; no external pixels.'
        description = 'Legacy placeholder for ' + entry['name'] + '; designed artwork pending.'
        contact, exception = None, ''
    else:
        require(status == 'designed' and gfx in designs, f'{gfx}: missing designed producer')
        d = designs[gfx]
        require(type(d.version) is int and d.version > 0, 'Invalid drawing version')
        require(all(isinstance(v, str) and v.strip() for v in
                    (d.description, d.author, d.provenance)), 'Missing design provenance or meaning')
        palette = list(d.palette)
        require(palette and len(set(palette)) == len(palette)
                and all(isinstance(c, str) and re.fullmatch(r'#[0-9a-f]{6}', c) for c in palette),
                'Invalid declared palette')
        require(len(palette) <= 16 or (isinstance(d.palette_exception, str) and d.palette_exception.strip()),
                'More than 16 declared colours need a documented reason')
        contact = contact_path(root, d.contact_sheet)
        pixels = d.draw()
        drawing = {'file': 'tools/make_item_art.py', 'function': d.draw.__name__, 'version': d.version}
        author, provenance, description, exception = d.author, d.provenance, d.description, d.palette_exception
    pixel_contract(pixels, palette, status == 'designed')
    png = png_bytes(pixels)
    record = {'name': entry['name'], 'gfx': gfx, 'status': status, 'drawing': drawing,
              'author': author, 'license': 'MIT', 'provenance': provenance,
              'size': [32, 32], 'alpha': [0, 255], 'palette': palette,
              'palette_exception': exception, 'sha256': hashlib.sha256(png).hexdigest(),
              'description': description, 'contact_sheet': contact}
    return record, png


def check(root=ROOT, designs=None):
    entries = registry(root)
    on_disk = {p.relative_to(root / ICON_ROOT).as_posix() for p in (root / ICON_ROOT).rglob('*.png')}
    require(on_disk == set(entries), 'Missing or unregistered icon files')
    for gfx, entry in entries.items():
        path = root / ICON_ROOT / gfx
        data = path.read_bytes()
        require(data[:8] == b'\x89PNG\r\n\x1a\n' and len(data) >= 33, f'{gfx}: not PNG')
        require(struct.unpack('>II', data[16:24]) == (32, 32), f'{gfx}: expected 32x32')
        require(data[24:26] == bytes([8, 6]), f'{gfx}: expected RGBA8')
        _, _, rows = read_rgba(path)
        pixels = [[tuple(row[x:x+4]) for x in range(0, 128, 4)] for row in rows]
        expected, png = produce(root, entry, designs)
        pixel_contract(pixels, expected['palette'], entry['status'] == 'designed')
        require(data == png, f'{gfx}: pixels/PNG differ from deterministic producer')
        require(entry == expected, f'{gfx}: manifest metadata/hash differs from producer')
    # Retain the original silhouette gate independently of designed silhouettes.
    for name in legacy.SYMMETRIC:
        grid = legacy.SPRITES[name]()
        require(all((grid[y][x] != '.') == (grid[y][31-x] != '.')
                    for y in range(32) for x in range(16)), f'Asymmetric legacy silhouette: {name}')
    return dict(Counter(entry['status'] for entry in entries.values()))


def write(root=ROOT, out=None, designs=None):
    """Regenerate only registered paths; validate all producers before writing."""
    entries = registry(root)
    generated = [produce(root, entry, designs) for entry in entries.values()]
    destination = root / ICON_ROOT if out is None else Path(out)
    require(out is None or destination.resolve() != (root / ICON_ROOT).resolve(),
            'Export must not target canonical icons; use write without out')
    for record, png in generated:
        path = destination / record['gfx']
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(png)
    # An export never changes the canonical manifest.
    if out is None:
        manifest = {'schema_version': SCHEMA_VERSION, 'entries': [r for r, _ in generated]}
        (root / MANIFEST).write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')


def initialize(root=ROOT):
    path = root / MANIFEST
    require(not path.exists(), 'Manifest already exists; refusing to replace statuses')
    entries = [{'name': v['name'], 'gfx': gfx, 'status': 'placeholder'}
               for gfx, v in registrations(root).items()]
    records = [produce(root, entry)[0] for entry in entries]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps({'schema_version': SCHEMA_VERSION, 'entries': records}, indent=2) + '\n', encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument('--check', action='store_true')
    action.add_argument('--write', action='store_true')
    action.add_argument('--init-manifest', action='store_true')
    parser.add_argument('--out', type=Path, help='Export icons without updating the manifest (with --write)')
    args = parser.parse_args()
    if args.out is not None:
        if not args.write:
            parser.error('--out requires --write')
        require(args.out.resolve() != (ROOT / ICON_ROOT).resolve(), 'Use --write without --out for canonical icons')
    if args.check:
        print('  OK: registered item artwork, metadata, deterministic pixels and pools:', check())
    elif args.write:
        write(out=args.out)
    else:
        initialize()


if __name__ == '__main__':
    main()
