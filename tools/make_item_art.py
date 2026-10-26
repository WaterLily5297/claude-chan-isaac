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


# Original 32px object drawings. Shared ramps run shadow -> body -> light.
# These shapes are authored here; no native or third-party image is sampled.
INK = '#080000'
STEEL = ('#4e4955', '#96929b', '#d9d4cf')
WOOD = ('#684033', '#a76b43', '#e0a66b')
ORANGE = ('#96382d', '#e16c3c', '#ffb66b')
PAPER = ('#9f896a', '#d9c9a4', '#fff1d0')
BLUE = ('#285362', '#4c9ba8', '#a0dfd6')
GOLD = ('#8e5c27', '#d5a044', '#ffe091')
PINK = ('#874155', '#d28289', '#ffbdaf')
PURPLE = ('#44324e', '#826b93', '#c4abc9')


class Canvas:
    def __init__(self):
        self.grid = legacy.clear()

    def rect(self, x0, y0, x1, y1, colour):
        legacy.rect(self.grid, x0, y0, x1, y1, colour)

    def poly(self, points, colour):
        legacy.poly(self.grid, points, colour)

    def line(self, x0, y0, x1, y1, colour, width=1):
        legacy.line(self.grid, x0, y0, x1, y1, colour, width)

    def oval(self, cx, cy, rx, ry, colour):
        legacy.ellipse(self.grid, cx, cy, rx, ry, colour)

    def finish(self):
        # Outline only the exterior, not every material patch. Interior edges
        # are drawn deliberately so adjacent layers do not acquire double ink.
        grid = [row[:] for row in self.grid]
        for y in range(32):
            for x in range(32):
                if self.grid[y][x] == '.' and any(
                    0 <= x+dx < 32 and 0 <= y+dy < 32 and self.grid[y+dy][x+dx] != '.'
                    for dx, dy in ((1,0),(-1,0),(0,1),(0,-1))):
                    grid[y][x] = INK
        return legacy.rgba(grid)


def hammer_art():
    c = Canvas()
    c.poly([(8,26),(18,12),(22,15),(12,29)], WOOD[0])
    c.poly([(8,26),(18,12),(20,13),(10,28)], WOOD[1])
    c.line(10,25,18,14,WOOD[2])
    c.line(11,24,14,26,INK)
    c.poly([(6,9),(11,3),(27,12),(22,19)], STEEL[0])
    c.poly([(7,8),(11,3),(27,12),(25,14)], STEEL[2])
    c.poly([(9,9),(12,5),(25,12),(22,16)], ORANGE[1])
    c.poly([(9,9),(22,16),(21,18),(8,11)], ORANGE[0])
    c.line(12,6,22,11,ORANGE[2])
    c.poly([(6,9),(8,6),(11,8),(8,12)], STEEL[1])
    c.poly([(23,12),(26,13),(23,17),(21,16)], STEEL[1])
    c.line(8,7,9,7,STEEL[2])
    c.line(23,13,24,13,STEEL[2])
    return c.finish()


def compact_art():
    c = Canvas()
    c.rect(4,7,7,26,STEEL[0]); c.rect(25,7,27,26,STEEL[0])
    c.rect(4,7,5,25,STEEL[2]); c.rect(25,7,25,24,STEEL[1])
    c.poly([(8,11),(21,9),(25,12),(25,22),(9,24)], PAPER[0])
    c.poly([(8,11),(21,9),(24,11),(10,13)], PAPER[2])
    c.poly([(9,13),(24,11),(24,21),(9,23)], PAPER[1])
    for y in (15,18,21): c.line(10,y,22,y-2,PAPER[0])
    c.line(11,14,22,12,PAPER[2]); c.line(10,17,16,16,PAPER[2])
    c.poly([(16,11),(19,10),(19,22),(16,22)], BLUE[0])
    c.rect(16,12,17,21,BLUE[1]); c.line(16,12,17,11,BLUE[2])
    c.poly([(3,4),(25,4),(28,6),(28,9),(3,9)], STEEL[0])
    c.rect(4,5,25,6,STEEL[2]); c.rect(4,7,26,8,STEEL[1])
    c.rect(3,25,28,27,STEEL[0]); c.rect(4,25,27,25,STEEL[2])
    c.rect(6,28,9,28,STEEL[0]); c.rect(23,28,26,28,STEEL[0])
    return c.finish()


def stapler_art():
    c = Canvas()
    c.poly([(5,24),(22,21),(27,23),(27,27),(5,28)], STEEL[0])
    c.poly([(6,24),(23,22),(26,24),(6,26)], STEEL[2])
    c.line(7,27,25,25,STEEL[1])
    c.poly([(22,16),(26,17),(26,23),(22,22)], STEEL[0])
    c.rect(23,18,24,21,STEEL[1])
    for x,y in ((8,21),(12,20),(16,19)):
        c.oval(x,y,2,3,BLUE[0]); c.oval(x-0.5,y-0.5,1.5,2,BLUE[1]); c.rect(x-1,y-2,x-1,y-1,BLUE[2])
    c.poly([(4,7),(7,4),(25,11),(27,15),(24,18),(5,12)], ORANGE[0])
    c.poly([(4,7),(7,4),(25,11),(23,13)], ORANGE[2])
    c.poly([(5,8),(23,14),(24,17),(5,11)], ORANGE[1])
    c.line(7,13,21,17,STEEL[0]); c.line(8,13,20,16,STEEL[2])
    c.oval(24,15,1.5,1.5,STEEL[0]); c.rect(23,14,23,14,STEEL[2])
    return c.finish()


def ultrathink_art():
    c = Canvas()
    c.poly([(11,20),(22,20),(21,26),(13,27)], GOLD[0])
    c.rect(12,23,21,25,GOLD[1]); c.line(13,23,20,23,GOLD[2])
    c.line(13,25,21,25,INK); c.rect(14,27,19,28,STEEL[0])
    c.rect(15,27,18,27,STEEL[2])
    c.oval(16,13,11,10,PINK[0])
    for cx,cy,rx,ry in ((10,9,4,4),(16,7,4,4),(22,10,4,4),(9,15,4,4),(16,15,6,7),(23,15,4,4)):
        c.oval(cx,cy,rx,ry,PINK[1])
    c.line(7,10,8,7,PINK[2]); c.line(8,7,11,6,PINK[2])
    c.line(14,5,18,5,PINK[2]); c.line(21,7,23,9,PINK[2])
    c.line(13,7,13,11,PINK[0]); c.line(13,11,10,12,PINK[0])
    c.line(18,8,18,12,PINK[0]); c.line(18,12,22,13,PINK[0])
    c.line(8,17,12,17,PINK[0]); c.line(12,17,12,20,PINK[0])
    c.line(16,14,16,19,PINK[0]); c.line(19,17,22,17,PINK[0])
    c.line(19,17,19,20,PINK[0]); c.rect(14,15,14,17,PINK[2])
    c.rect(3,7,3,9,GOLD[2]); c.rect(27,5,28,5,GOLD[1])
    return c.finish()


def swarm_art():
    c = Canvas()
    c.line(15,19,8,14,BLUE[0],2); c.line(18,18,23,13,BLUE[0],2)
    c.line(8,14,7,11,BLUE[2]); c.line(22,14,24,11,BLUE[1])
    for x,y in ((7,5),(25,3)):
        c.poly([(x,y),(x-3,y+5),(x-2,y+8),(x+2,y+8),(x+3,y+5)],ORANGE[0])
        c.poly([(x,y),(x-2,y+5),(x-1,y+7),(x+1,y+7),(x+2,y+4)],ORANGE[1])
        c.line(x-1,y+3,x-1,y+5,ORANGE[2])
    c.poly([(16,13),(10,22),(10,25),(13,28),(19,28),(22,25),(22,22)],ORANGE[0])
    c.poly([(16,14),(11,22),(12,25),(15,27),(18,26),(20,22)],ORANGE[1])
    c.line(14,19,12,23,ORANGE[2]); c.rect(13,24,14,24,ORANGE[2])
    return c.finish()


def constitution_art():
    c = Canvas()
    c.poly([(7,3),(25,6),(25,28),(6,26),(4,23),(4,6)],WOOD[0])
    c.poly([(7,5),(24,8),(24,26),(8,24)],PAPER[0])
    c.line(8,24,24,26,PAPER[2]); c.line(9,26,23,28,PAPER[0])
    c.poly([(7,3),(25,6),(24,24),(7,22)],PAPER[1])
    c.poly([(7,3),(25,6),(24,8),(8,6)],PAPER[2])
    c.poly([(5,6),(7,3),(9,6),(8,23),(6,25),(4,22)],WOOD[1])
    c.line(6,7,6,21,WOOD[2]); c.line(9,7,8,22,WOOD[0])
    c.poly([(14,9),(21,10),(21,15),(17,19),(13,15)],GOLD[0])
    c.poly([(14,10),(20,11),(19,15),(17,17),(14,14)],GOLD[1])
    c.line(14,10,19,11,GOLD[2]); c.line(14,11,14,14,GOLD[2])
    c.poly([(15,23),(14,28),(17,27),(19,29),(20,24)],PINK[0])
    c.oval(17,22,4,4,PINK[0]); c.oval(16,21,3,3,PINK[1])
    c.line(14,20,16,19,PINK[2]); c.rect(17,22,18,23,PINK[0])
    return c.finish()


def lunch_art():
    c = Canvas()
    c.poly([(7,25),(23,25),(26,28),(9,28)],PINK[0])
    c.line(10,27,22,27,PINK[1])
    c.line(20,3,28,12,WOOD[0],2); c.line(18,5,25,13,WOOD[0],2)
    c.line(20,3,27,11,WOOD[2]); c.line(18,5,24,12,WOOD[1])
    c.oval(16,15,12,5,BLUE[0])
    c.oval(16,13,10,5,PAPER[0])
    for x,y in ((9,11),(13,9),(18,9),(22,11),(13,13),(18,13)):
        c.oval(x,y,3,2.5,PAPER[1]); c.line(x-1,y-1,x,y-1,PAPER[2])
    c.poly([(4,15),(27,15),(25,22),(21,26),(10,26),(6,22)],BLUE[0])
    c.poly([(5,16),(24,16),(23,22),(19,24),(10,24),(7,21)],BLUE[1])
    c.poly([(5,16),(10,17),(10,22),(8,21)],BLUE[2])
    c.line(5,15,26,15,PAPER[2]); c.line(7,16,24,16,BLUE[2])
    c.rect(12,26,20,27,BLUE[0]); c.line(13,26,18,26,BLUE[1])
    return c.finish()


def cooker_art():
    c = Canvas()
    c.line(10,3,9,4,PAPER[1]); c.line(9,4,11,6,PAPER[2])
    c.line(20,2,19,4,PAPER[1]); c.line(19,4,20,6,PAPER[2])
    c.rect(9,27,12,28,STEEL[0]); c.rect(21,27,24,28,STEEL[0])
    c.rect(3,15,6,20,STEEL[0]); c.rect(26,15,28,20,STEEL[0])
    c.rect(3,15,5,16,STEEL[1]); c.rect(27,16,28,17,STEEL[1])
    c.poly([(6,12),(25,12),(27,16),(26,25),(23,27),(8,27),(5,24),(5,16)],PAPER[0])
    c.poly([(6,14),(24,14),(24,25),(9,26),(6,23)],PAPER[1])
    c.poly([(6,14),(10,14),(9,23),(7,22)],PAPER[2])
    c.oval(16,12,11,4,STEEL[0]); c.oval(15,11,10,3,STEEL[1])
    c.line(7,10,21,9,STEEL[2]); c.rect(12,7,21,9,STEEL[0])
    c.rect(13,7,20,7,STEEL[2]); c.rect(13,8,15,8,STEEL[1])
    c.rect(11,18,21,23,STEEL[0]); c.rect(12,19,20,22,BLUE[0])
    c.rect(12,19,18,20,BLUE[1]); c.line(12,19,15,19,BLUE[2])
    c.rect(23,19,24,21,ORANGE[0]); c.rect(23,19,23,20,ORANGE[2])
    return c.finish()


def recall_art():
    c = Canvas()
    c.poly([(13,8),(21,7),(27,13),(27,22),(22,28),(13,28),(8,23),(8,14)],GOLD[0])
    c.poly([(13,8),(21,8),(26,13),(25,22),(21,26),(13,26),(9,22),(9,14)],GOLD[1])
    c.line(13,9,20,9,GOLD[2]); c.line(11,11,9,16,GOLD[2])
    c.poly([(15,13),(21,12),(23,16),(22,22),(16,23),(13,19)],PURPLE[0])
    c.poly([(16,14),(20,14),(21,17),(20,21),(16,21),(14,18)],PURPLE[1])
    c.line(16,14,19,14,PURPLE[2])
    c.line(17,18,11,18,BLUE[0],3); c.line(11,18,6,14,BLUE[0],3)
    c.line(6,14,7,9,BLUE[0],3)
    c.line(16,17,11,17,BLUE[2]); c.line(11,17,7,13,BLUE[1])
    c.poly([(9,4),(6,8),(7,11),(10,12),(12,9)],BLUE[0])
    c.poly([(9,5),(7,8),(8,10),(10,10),(11,8)],BLUE[1])
    c.rect(8,7,8,8,BLUE[2]); c.rect(3,6,3,7,BLUE[1])
    c.rect(4,4,4,4,BLUE[2])
    return c.finish()


def delve_art():
    c = Canvas()
    c.poly([(5,26),(9,23),(15,26),(15,29),(4,29)],WOOD[0])
    c.poly([(6,26),(10,24),(14,27),(7,28)],WOOD[1])
    c.rect(7,25,8,25,WOOD[2])
    c.line(12,10,23,21,WOOD[0],4); c.line(12,10,22,20,WOOD[1],2)
    c.line(12,10,22,20,WOOD[2])
    c.poly([(4,4),(11,2),(17,8),(12,13),(7,11),(3,7)],WOOD[0])
    c.poly([(4,4),(10,3),(15,8),(12,11),(8,10),(4,7)],WOOD[1])
    c.line(5,4,10,3,WOOD[2]); c.line(10,3,14,7,WOOD[2])
    # The D handle's opening is transparent, not a painted rectangle.
    c.poly([(6,5),(10,5),(13,8),(11,10),(8,8)],'.')
    c.poly([(18,15),(27,19),(27,24),(21,29),(14,25),(13,20)],STEEL[0])
    c.poly([(18,16),(25,19),(24,23),(20,27),(15,24),(15,20)],STEEL[1])
    c.poly([(18,17),(21,18),(18,25),(15,23)],STEEL[2])
    c.line(22,19,20,25,STEEL[0]); c.line(17,17,20,19,INK)
    c.rect(18,18,19,18,STEEL[2])
    return c.finish()


def design(draw, palette, meaning):
    return Design(draw, 1, (INK, *palette), meaning,
                  'Original project artwork, Codex-assisted',
                  'Original pixel geometry and material shading authored in make_item_art.py; no external pixels.',
                  'docs/art/item-batch-01-4x.png')


DESIGNS = {
    'collectibles/ban_hammer.png': design(hammer_art, (*WOOD,*STEEL,*ORANGE), 'A heavy diagonal orange gavel with worn steel ends and a wrapped wooden handle; room bans.'),
    'collectibles/compact.png': design(compact_art, (*STEEL,*PAPER,*BLUE), 'An iron press compressing a bound paper stack; compacting context and bullets.'),
    'collectibles/summary_stapler.png': design(stapler_art, (*STEEL,*ORANGE,*BLUE), 'An open orange stapler over three blue projectile capsules; combining bullets into one shot.'),
    'collectibles/ultrathink.png': design(ultrathink_art, (*PINK,*GOLD,*STEEL), 'A folded pink brain on a brass bulb base with small sparks; escalating thought.'),
    'collectibles/subagent_swarm.png': design(swarm_art, (*ORANGE,*BLUE), 'One large orange tear connected to two smaller tears by blue branching trails; resolved child shots.'),
    'collectibles/constitution.png': design(constitution_art, (*WOOD,*PAPER,*GOLD,*PINK), 'A bound cream rulebook with an embossed shield and hanging wax seal; protective rules.'),
    'collectibles/lunch_break.png': design(lunch_art, (*BLUE,*PAPER,*WOOD,*PINK), 'A turquoise rice bowl, individual rice highlights, chopsticks and a small napkin; a healing food break.'),
    'collectibles/rice_cooker.png': design(cooker_art, (*PAPER,*STEEL,*BLUE,*ORANGE), 'A steaming cream cooker with a steel lid and blue window; cook first, attack afterward.'),
    'collectibles/token_recall.png': design(recall_art, (*GOLD,*PURPLE,*BLUE), 'A brass reel pulling a blue tear along a curved tether; recalling fired tokens.'),
    'collectibles/lets_delve.png': design(delve_art, (*WOOD,*STEEL), 'A diagonal spade with an open wooden handle, bevelled steel and a small soil clod; native digging.'),
}


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
