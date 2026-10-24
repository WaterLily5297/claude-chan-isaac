"""Generate all placeholder item sprites (32x32, Isaac-style).

Style target, measured from the 722 vanilla collectible sprites:
  * 32x32 RGBA, hard edges, no anti-aliasing;
  * one shared ink colour for outline and interior line work (#080000);
  * 3 tones per material: flat base, 1px shadow on the bottom/right, one light pass;
  * 4-8 colours per sprite, silhouette about 26x26 of the 32x32 frame.

Usage:
    python3 tools/make_placeholders.py                  # rewrite resources/gfx/items
    python3 tools/make_placeholders.py --preview p.png  # also write a contact sheet
    python3 tools/make_placeholders.py --out DIR        # write somewhere else
    python3 tools/make_placeholders.py --check-symmetry # verify mirror-symmetric icons

Replace with real pixel art whenever it is ready (see docs/ART_SPEC.md).
"""

import math
import struct
import sys
import zlib
from pathlib import Path

SIZE = 32
INK = "#080000"
ROOT = Path(__file__).resolve().parent.parent

# material -> (base, light, dark)
PAL = {
    "M": ("#a7a7a7", "#d6d6d6", "#777777"),   # steel
    "m": ("#8a8a8a", "#b5b5b5", "#5e5e5e"),   # dark steel
    "O": ("#e0713f", "#f2a077", "#a34d27"),   # claude orange
    "o": ("#c9704a", "#e08a5a", "#8f4a30"),   # orange shadow
    "W": ("#a9743f", "#c69355", "#7d5028"),   # wood
    "R": ("#e70000", "#ff5a4a", "#a30000"),   # red
    "r": ("#c43333", "#e06a6a", "#8a1e1e"),   # dull red
    "G": ("#f0c849", "#ffe48a", "#b08a24"),   # gold
    "g": ("#b08a24", "#d4ad45", "#7d5f16"),   # gold shadow
    "B": ("#5b734b", "#7e9a68", "#3b4a30"),   # money green
    "P": ("#f3e7d6", "#fffaf0", "#c9bba4"),   # cream paper
    "p": ("#e1c399", "#f3dcb8", "#b39568"),   # parchment
    "C": ("#f3d9b5", "#ffeecd", "#c9a87f"),   # skin
    "c": ("#4fb8c9", "#8fe3ee", "#2e8391"),   # cyan
    "V": ("#8a5bb5", "#b48ad6", "#5b3a7c"),   # purple
    "K": ("#cbcbcb", "#f2f2f2", "#969696"),   # bone grey
    "T": ("#636363", "#8a8a8a", "#404040"),   # grey
    "D": ("#3a3a3a", "#575757", "#222222"),   # dark grey
    "N": ("#2b2b2b", "#454545", "#161616"),   # near black
    "E": ("#e8a33d", "#ffc86b", "#a86c1c"),   # amber
    "H": ("#79c07a", "#a7dd9f", "#4c8548"),   # green
    "h": ("#4c8548", "#6faf66", "#345c31"),
    "L": ("#e79ab5", "#ffc2d4", "#a9617a"),   # pink
    "F": ("#d8d2c4", "#f2eee4", "#a8a191"),   # white paper
    "S": ("#b69150", "#d4b273", "#8f713c"),   # tan
    "X": ("#fffdf5", "#ffffff", "#e6ddc9"),   # glint
    "U": ("#4a5fc1", "#7d90e6", "#2e3b85"),   # berry blue
}

FONT = {
    "3": ("111", "001", "111", "001", "111"),
    "5": ("111", "100", "111", "001", "111"),
    ".": ("000", "000", "000", "000", "110"),
}


def clear():
    return [["." for _ in range(SIZE)] for _ in range(SIZE)]


def rect(c, x0, y0, x1, y1, m):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if 0 <= x < SIZE and 0 <= y < SIZE:
                c[y][x] = m


def rrect(c, x0, y0, x1, y1, rad, m):
    """Rounded rect over pixel centres, so odd/even widths stay symmetric."""
    cxp, cyp = (x0 + x1 + 1) / 2, (y0 + y1 + 1) / 2
    hx, hy = (x1 - x0 + 1) / 2, (y1 - y0 + 1) / 2
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            qx = abs(x + 0.5 - cxp) - (hx - rad)
            qy = abs(y + 0.5 - cyp) - (hy - rad)
            d = math.hypot(max(qx, 0), max(qy, 0)) + min(max(qx, qy), 0) - rad
            if d <= 0.5:
                c[y][x] = m


def ellipse(c, cx, cy, rx, ry, m):
    for y in range(max(0, int(cy - ry)), min(SIZE, int(cy + ry) + 1)):
        for x in range(max(0, int(cx - rx)), min(SIZE, int(cx + rx) + 1)):
            if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0:
                c[y][x] = m


def ring(c, cx, cy, r_out, r_in, m):
    for y in range(max(0, int(cy - r_out)), min(SIZE, int(cy + r_out) + 1)):
        for x in range(max(0, int(cx - r_out)), min(SIZE, int(cx + r_out) + 1)):
            d = math.hypot(x + 0.5 - cx, y + 0.5 - cy)
            if r_in <= d <= r_out:
                c[y][x] = m


def poly(c, pts, m):
    ys = [p[1] for p in pts]
    for y in range(int(min(ys)), int(max(ys)) + 1):
        xs = []
        for i in range(len(pts)):
            (x1, y1), (x2, y2) = pts[i], pts[(i + 1) % len(pts)]
            if (y1 <= y + 0.5 < y2) or (y2 <= y + 0.5 < y1):
                xs.append(x1 + (y + 0.5 - y1) * (x2 - x1) / (y2 - y1))
        xs.sort()
        for i in range(0, len(xs) - 1, 2):
            for x in range(int(math.ceil(xs[i] - 0.5)), int(math.floor(xs[i + 1] - 0.5)) + 1):
                if 0 <= x < SIZE and 0 <= y < SIZE:
                    c[y][x] = m


def line(c, x0, y0, x1, y1, m, thick=1):
    dx, dy = abs(x1 - x0), -abs(y1 - y0)
    sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
    err = dx + dy
    lo = -((thick - 1) // 2)
    while True:
        for ox in range(lo, lo + thick):
            for oy in range(lo, lo + thick):
                x, y = x0 + ox, y0 + oy
                if 0 <= x < SIZE and 0 <= y < SIZE:
                    c[y][x] = m
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 >= dy:
            err += dy
            x0 += sx
        if e2 <= dx:
            err += dx
            y0 += sy


def text(c, x, y, s, m, scale=1):
    for ch in s:
        glyph = FONT[ch]
        for gy, row in enumerate(glyph):
            for gx, bit in enumerate(row):
                if bit == "1":
                    rect(c, x + gx * scale, y + gy * scale,
                         x + gx * scale + scale - 1, y + gy * scale + scale - 1, m)
        x += (len(glyph[0]) + 1) * scale


def sym(c):
    """Mirror the left half onto the right half (vertical axis at x = 15.5)."""
    out = [row[:] for row in c]
    for y in range(SIZE):
        for x in range(SIZE // 2):
            out[y][SIZE - 1 - x] = out[y][x]
    return out


def solid(c, x, y):
    return 0 <= x < SIZE and 0 <= y < SIZE and c[y][x] != "."


def render(c):
    """Fill, one diagonal light pass, shadow on the bottom/right, ink outline."""
    seen = [[False] * SIZE for _ in range(SIZE)]
    light = set()
    for y0 in range(SIZE):
        for x0 in range(SIZE):
            if c[y0][x0] in (".", "#") or seen[y0][x0]:
                continue
            m, stack, cells = c[y0][x0], [(x0, y0)], []
            seen[y0][x0] = True
            while stack:
                x, y = stack.pop()
                cells.append((x, y))
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < SIZE and 0 <= ny < SIZE and not seen[ny][nx] and c[ny][nx] == m:
                        seen[ny][nx] = True
                        stack.append((nx, ny))
            if len(cells) >= 60:
                bx0 = min(p[0] for p in cells)
                by0 = min(p[1] for p in cells)
                for (x, y) in cells:
                    if (x - bx0) + (y - by0) <= 4:
                        light.add((x, y))

    out = [["." for _ in range(SIZE)] for _ in range(SIZE)]
    for y in range(SIZE):
        for x in range(SIZE):
            m = c[y][x]
            if m == ".":
                continue
            if m == "#":
                out[y][x] = INK
                continue
            base, lt, dk = PAL[m]
            if (x, y) in light:
                col = lt
            elif not solid(c, x, y + 1) or (not solid(c, x + 1, y) and not solid(c, x, y - 1)):
                col = dk
            else:
                col = base
            out[y][x] = col

    ink = [row[:] for row in out]
    for y in range(SIZE):
        for x in range(SIZE):
            if out[y][x] != ".":
                continue
            if any(solid(c, x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                ink[y][x] = INK
    return ink


def write_png(pixels, path):
    raw = b"".join(b"\x00" + bytes(v for p in row for v in p) for row in pixels)

    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff)

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", len(pixels[0]), len(pixels), 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
    Path(path).write_bytes(png)


def rgba(grid):
    out = []
    for row in grid:
        line_ = []
        for col in row:
            if col == ".":
                line_.append((0, 0, 0, 0))
            else:
                line_.append((int(col[1:3], 16), int(col[3:5], 16), int(col[5:7], 16), 255))
        out.append(line_)
    return out


# --------------------------------------------------------------------------
# sprites
# --------------------------------------------------------------------------

def ban_hammer():
    c = clear()
    rrect(c, 3, 4, 28, 13, 2, "O")
    rect(c, 3, 11, 28, 13, "o")
    rect(c, 3, 4, 5, 13, "M")
    rect(c, 26, 4, 28, 13, "M")
    line(c, 6, 5, 6, 12, "#")
    line(c, 25, 5, 25, 12, "#")
    rrect(c, 12, 13, 19, 16, 1, "M")
    rect(c, 14, 16, 18, 28, "W")
    rect(c, 14, 16, 18, 17, "R")
    line(c, 14, 21, 18, 21, "#")
    line(c, 14, 26, 18, 26, "#")
    rrect(c, 13, 28, 19, 29, 1, "M")
    c = sym(c)
    return c


def residential_ip():
    c = clear()
    poly(c, [(16, 2), (2, 15), (30, 15)], "H")
    rect(c, 2, 14, 30, 15, "h")
    rect(c, 6, 15, 25, 28, "C")
    rect(c, 6, 15, 25, 16, "p")
    rect(c, 12, 21, 18, 28, "W")
    rect(c, 8, 18, 12, 22, "#")
    rect(c, 9, 19, 11, 21, "c")
    rect(c, 20, 18, 24, 22, "#")
    rect(c, 21, 19, 23, 21, "c")
    c = sym(c)
    rect(c, 23, 5, 26, 13, "r")
    line(c, 23, 5, 26, 5, "#")
    line(c, 2, 15, 30, 15, "#")
    line(c, 6, 28, 25, 28, "#")
    return c


def compact():
    c = clear()
    rrect(c, 9, 3, 22, 28, 1, "P")
    for y in (8, 12, 16, 20, 24):
        line(c, 12, y, 19, y, "#")
    line(c, 6, 9, 2, 16, "c", 2)
    line(c, 2, 16, 6, 23, "c", 2)
    c = sym(c)
    return c

def absolutely_right():
    c = clear()
    rrect(c, 2, 3, 28, 20, 5, "P")
    c = sym(c)
    # tail centred under the bubble
    poly(c, [(13, 19), (19, 19), (16, 27)], "P")
    line(c, 9, 12, 13, 16, "H", 2)
    line(c, 13, 16, 23, 6, "H", 2)
    return c

def cheap_relay():
    c = clear()
    line(c, 16, 3, 11, 28, "M", 2)
    line(c, 16, 3, 24, 28, "M", 2)
    for y, half in ((22, 6), (16, 5), (11, 4)):
        line(c, 16 - half, y, 16 + half, y, "m")
    ellipse(c, 16, 2, 2, 2, "R")
    line(c, 12, 2, 8, 0, "c")
    line(c, 22, 2, 26, 0, "c")
    c = sym(c)
    # price tag, tied to the left leg
    line(c, 10, 20, 13, 16, "#")
    rrect(c, 1, 19, 10, 27, 1, "G")
    ellipse(c, 3, 21, 1, 1, "#")
    line(c, 2, 25, 8, 25, "g")
    return c

def ultrathink():
    """Orange brain with folds, and the yellow idea bulb under it (as the early placeholder)."""
    c = clear()
    ellipse(c, 16, 11, 10, 8, "O")
    ellipse(c, 10, 8, 5, 4, "O")
    ellipse(c, 22, 8, 5, 4, "O")
    for x in (10, 16, 22):
        line(c, x, 6, x + 1, 10, "o")
        line(c, x + 1, 10, x, 15, "o")
    line(c, 7, 12, 25, 12, "o")
    rect(c, 14, 18, 17, 20, "M")
    # bulb
    ellipse(c, 16, 24, 6, 6, "G")
    for x in (14, 18):
        line(c, x, 22, x, 25, "g")
    line(c, 15, 23, 17, 23, "g")
    rrect(c, 13, 29, 19, 30, 1, "M")
    line(c, 14, 29, 14, 30, "m")
    return c

def million_context():
    c = clear()
    # a centred stack of pages: the context just keeps going
    rect(c, 4, 4, 27, 19, "p")
    rect(c, 7, 9, 24, 26, "P")
    for i, y in enumerate((13, 16, 19, 22)):
        line(c, 10, y, 21, y, "#")
    for x in (14, 16, 18):
        ellipse(c, x, 24, 1, 1, "c")
    return c

def silent_update():
    c = clear()
    rect(c, 14, 3, 17, 6, "G")
    poly(c, [(9, 18), (9, 12), (12, 8), (19, 8), (22, 12), (22, 18), (26, 21), (5, 21)], "G")
    ellipse(c, 16, 24, 2, 2, "g")
    line(c, 5, 21, 25, 21, "g")
    c = sym(c)
    line(c, 6, 5, 27, 26, "R", 2)
    return c


def skip_permissions():
    c = clear()
    rrect(c, 6, 14, 25, 28, 2, "G")
    rect(c, 6, 14, 25, 15, "g")
    line(c, 6, 27, 25, 27, "g")
    ellipse(c, 16, 19, 2, 2, "#")
    rect(c, 15, 19, 16, 24, "#")
    c = sym(c)
    # open shackle: a rounded U whose right end is lifted out of the body
    line(c, 9, 14, 9, 9, "M", 3)
    line(c, 9, 9, 12, 6, "M", 3)
    line(c, 12, 6, 19, 6, "M", 3)
    line(c, 19, 6, 22, 9, "M", 3)
    line(c, 22, 9, 22, 11, "M", 3)
    # speed lines
    line(c, 1, 17, 4, 17, "c", 2)
    line(c, 1, 21, 4, 21, "c", 2)
    line(c, 1, 25, 4, 25, "c", 2)
    return c

def tests_passing():
    c = clear()
    rrect(c, 6, 4, 26, 29, 2, "P")
    rect(c, 6, 4, 26, 5, "p")
    rrect(c, 11, 1, 21, 6, 1, "M")
    rect(c, 12, 2, 20, 3, "K")
    c = sym(c)
    for y0 in (11, 18, 25):
        line(c, 9, y0 + 2, 11, y0 + 4, "H")
        line(c, 11, y0 + 4, 16, y0 - 2, "H")
        line(c, 18, y0 + 1, 24, y0 + 1, "#")
    return c


def vibe_coding():
    c = clear()
    ellipse(c, 16, 16, 10, 10, "V")
    c = sym(c)
    rect(c, 7, 11, 25, 12, "c")
    rect(c, 5, 19, 23, 20, "G")
    rect(c, 9, 15, 27, 15, "c")
    rect(c, 12, 22, 24, 22, "V")
    c = sym(c)
    rect(c, 12, 10, 14, 10, "F")
    return c

def banked_reset():
    c = clear()
    ring(c, 16, 16, 12, 9, "H")
    rect(c, 0, 0, 31, 5, ".")
    ellipse(c, 16, 16, 6, 6, "G")
    ring(c, 16, 16, 6, 5, "g")
    c = sym(c)
    poly(c, [(22, 2), (29, 6), (22, 10)], "H")
    return c


def subagent_swarm():
    c = clear()
    # one tear splitting into a symmetric pair of subagents
    ellipse(c, 16, 23, 6, 5, "O")
    poly(c, [(16, 12), (11, 20), (21, 20)], "O")
    for x in (7, 25):
        ellipse(c, x, 11, 2, 2, "O")
        poly(c, [(x, 6), (x - 2, 10), (x + 2, 10)], "O")
    for x in (12, 20):
        rect(c, x, 17, x, 17, "c")
    return c

def constitution():
    c = clear()
    rect(c, 6, 5, 26, 27, "p")
    rect(c, 5, 3, 27, 6, "S")
    rect(c, 5, 26, 27, 29, "S")
    for y in (10, 13, 16, 19):
        line(c, 10, y, 23, y, "#")
    c = sym(c)
    # wax seal: ring + raised centre
    ellipse(c, 16, 19, 4, 4, "R")
    ring(c, 16, 19, 4, 3, "r")
    rect(c, 15, 17, 16, 17, "X")
    return c

def opus_mode():
    c = clear()
    poly(c, [(7, 11), (7, 4), (11, 8), (16, 3), (21, 8), (25, 4), (25, 11)], "G")
    rect(c, 7, 9, 25, 11, "g")
    ellipse(c, 16, 21, 10, 9, "g")
    ellipse(c, 16, 20, 9, 8, "G")
    poly(c, [(15, 16), (16, 16), (20, 21), (16, 26), (15, 26), (11, 21)], "g")
    poly(c, [(15, 18), (16, 18), (19, 21), (16, 24), (15, 24), (12, 21)], "R")
    poly(c, [(15, 18), (16, 18), (16, 21), (15, 21)], "r")
    rect(c, 14, 18, 14, 18, "F")
    c = sym(c)
    return c


def overloaded():
    c = clear()
    rrect(c, 6, 4, 25, 28, 2, "D")
    rect(c, 8, 7, 23, 12, "N")
    rect(c, 8, 14, 23, 19, "r")
    rect(c, 8, 21, 23, 26, "N")
    c = sym(c)
    rect(c, 10, 9, 11, 9, "H")
    rect(c, 10, 16, 11, 16, "F")
    rect(c, 10, 23, 11, 23, "H")
    line(c, 13, 16, 20, 16, "R")
    line(c, 13, 18, 19, 18, "R")
    return c


def hardcoded_output():
    """A printed label with a barcode and the fixed value, instead of a terminal window."""
    c = clear()
    rrect(c, 3, 6, 28, 25, 2, "P")
    rect(c, 3, 6, 28, 7, "p")
    text(c, 5, 10, "3.5", "#", 2)
    x = 6
    for w in (2, 1, 3, 1, 2, 1, 3, 2, 1, 1):
        if x + w - 1 > 25:
            break
        rect(c, x, 21, x + w - 1, 23, "#")
        x += w + 1
    return c
def thinking_cleared():
    """Blank head with X eyes and shoulders (as the early placeholder)."""
    c = clear()
    ellipse(c, 16, 12, 9, 8, "K")
    rect(c, 15, 19, 16, 25, "C")
    poly(c, [(8, 25), (24, 25), (26, 29), (6, 29)], "p")
    # X eyes
    for x in (10, 20):
        line(c, x, 10, x + 2, 12, "#")
        line(c, x + 2, 10, x, 12, "#")
    line(c, 14, 16, 18, 16, "#")
    return c

def welcome_notice():
    c = clear()
    rrect(c, 3, 8, 28, 26, 2, "P")
    line(c, 3, 9, 16, 19, "#")
    line(c, 28, 9, 16, 19, "#")
    c = sym(c)
    ellipse(c, 16, 19, 4, 4, "H")
    line(c, 14, 19, 16, 21, "F")
    line(c, 16, 21, 20, 16, "F")
    return c


def status_page():
    c = clear()
    rrect(c, 4, 5, 27, 27, 2, "D")
    c = sym(c)
    for y in (10, 16, 22):
        ellipse(c, 8, y, 2, 2, "H")
        line(c, 12, y, 22, y, "N")
    line(c, 23, 5, 19, 12, "R")
    line(c, 19, 12, 24, 18, "R")
    return c


def appeal_form():
    c = clear()
    rect(c, 6, 4, 25, 28, "P")
    c = sym(c)
    for y in (9, 12, 15):
        line(c, 9, y, 22, y, "#")
    line(c, 9, 20, 12, 23, "R")
    line(c, 12, 23, 15, 19, "R")
    line(c, 15, 19, 18, 23, "R")
    ring(c, 20, 24, 4, 3, "H")
    line(c, 18, 24, 20, 26, "H")
    line(c, 20, 26, 23, 22, "H")
    return c


def support_ticket():
    c = clear()
    rrect(c, 4, 5, 27, 27, 2, "P")
    line(c, 5, 11, 26, 11, "c", 2)
    for y in (16, 20, 24):
        line(c, 8, y, 15, y, "#")
    ellipse(c, 22, 21, 5, 5, "H")
    line(c, 19, 21, 21, 23, "F")
    line(c, 21, 23, 25, 18, "F")
    return c


def lunch_break():
    """A blue rice bowl with chopsticks: DeepSeek's "brb, getting food"."""
    c = clear()
    ellipse(c, 16, 15, 9, 5, "F")          # rice
    rrect(c, 6, 15, 25, 24, 4, "c")        # bowl
    line(c, 8, 18, 23, 18, "X")            # rim glint
    rect(c, 12, 24, 19, 26, "c")           # foot
    line(c, 19, 3, 27, 12, "W")            # chopsticks
    line(c, 22, 3, 28, 10, "W")
    return c


def summary_stapler():
    """Original orange stapler over paper, using the existing geometric icon system."""
    c = clear()
    rect(c, 7, 16, 25, 25, "P")
    rect(c, 10, 18, 22, 18, "T")
    rect(c, 10, 21, 20, 21, "T")
    rrect(c, 5, 22, 24, 26, 1, "m")
    rrect(c, 5, 6, 12, 23, 2, "M")
    rrect(c, 6, 5, 26, 12, 2, "O")
    rect(c, 22, 12, 25, 15, "M")
    return c


def ignore_instructions():
    """A prompt sheet whose old lines are struck through, with a fresh orange line."""
    c = clear()
    rrect(c, 6, 4, 25, 27, 1, "P")
    for y in (8, 11, 14):
        line(c, 9, y, 22, y, "T")
    line(c, 8, 16, 23, 6, "R", 2)          # strike-through
    line(c, 9, 20, 20, 20, "O", 2)         # the injected instruction
    line(c, 9, 24, 16, 24, "O")
    rect(c, 21, 19, 23, 21, "N")           # text cursor
    return c


def tungsten_cube():
    """A dense grey metal cube drawn in three faces."""
    c = clear()
    poly(c, [(5, 11), (16, 6), (27, 11), (16, 16)], "K")    # top
    poly(c, [(5, 11), (16, 16), (16, 28), (5, 23)], "M")    # left
    poly(c, [(16, 16), (27, 11), (27, 23), (16, 28)], "m")  # right
    line(c, 16, 16, 16, 27, "#")
    line(c, 5, 11, 15, 16, "#")
    line(c, 17, 16, 27, 11, "#")
    return c


def pizza_glue():
    """A glue bottle dripping onto a pizza slice."""
    c = clear()
    poly(c, [(4, 13), (26, 13), (15, 29)], "E")             # slice
    rect(c, 4, 12, 26, 14, "W")                              # crust
    ellipse(c, 11, 18, 2, 2, "R")
    ellipse(c, 18, 17, 2, 2, "R")
    ellipse(c, 15, 23, 2, 2, "R")
    rrect(c, 18, 2, 27, 10, 2, "F")                          # bottle
    rect(c, 21, 0, 24, 2, "O")                               # cap
    line(c, 18, 9, 14, 14, "X", 2)                           # glue drip
    return c


def claudius_discount():
    """A price tag with an orange discount slash."""
    c = clear()
    poly(c, [(4, 12), (11, 5), (27, 5), (27, 19), (11, 19)], "p")
    ring(c, 10, 12, 2.5, 1.2, "#")
    for y in (9, 13):
        line(c, 15, y, 24, y, "T")
    line(c, 14, 17, 24, 17, "B")
    line(c, 12, 26, 26, 20, "O", 2)       # discount slash
    line(c, 8, 22, 12, 26, "O", 2)
    return c


def small_rock():
    """One small grey rock on a plate."""
    c = clear()
    ellipse(c, 16, 22, 12, 5, "F")         # plate
    ellipse(c, 16, 21, 8, 3, "K")          # plate well
    ellipse(c, 16, 16, 6, 5, "T")          # the rock
    rect(c, 13, 13, 15, 14, "K")           # highlight
    rect(c, 17, 18, 19, 18, "D")           # crack
    return c


def mt_moon():
    """A cave mouth under a crescent moon."""
    c = clear()
    poly(c, [(3, 28), (10, 12), (16, 9), (23, 13), (29, 28)], "T")
    ellipse(c, 16, 25, 6, 7, "N")          # cave mouth
    rect(c, 10, 26, 22, 28, "N")
    ellipse(c, 24, 6, 4, 4, "G")           # moon
    ellipse(c, 26, 5, 3, 3, ".")
    return c


def strawberry():
    """A strawberry with an R on it."""
    c = clear()
    poly(c, [(6, 11), (26, 11), (24, 20), (16, 29), (8, 20)], "R")
    rect(c, 10, 7, 21, 10, "H")            # leaves
    rect(c, 15, 3, 16, 7, "h")             # stem
    line(c, 13, 14, 13, 23, "F", 2)        # letter R
    line(c, 13, 14, 18, 14, "F", 2)
    line(c, 18, 14, 18, 18, "F", 2)
    line(c, 13, 18, 18, 18, "F", 2)
    line(c, 15, 19, 19, 23, "F", 2)
    return c


def golden_gate():
    """A red-orange suspension bridge tower over water."""
    c = clear()
    rect(c, 2, 25, 29, 29, "c")            # water
    rect(c, 2, 18, 29, 20, "r")            # deck
    rect(c, 8, 5, 10, 24, "r")             # towers
    rect(c, 21, 5, 23, 24, "r")
    rect(c, 8, 9, 23, 10, "r")             # crossbeam
    line(c, 2, 6, 9, 17, "G")              # cables
    line(c, 9, 5, 16, 15, "G")
    line(c, 16, 15, 22, 5, "G")
    line(c, 22, 5, 29, 15, "G")
    return c


def seahorse_emoji():
    """A seahorse outline made of dashes inside a speech bubble: it does not exist."""
    c = clear()
    rrect(c, 3, 3, 28, 23, 4, "F")         # speech bubble
    poly(c, [(8, 23), (14, 23), (8, 28)], "F")
    ellipse(c, 17, 8, 3, 3, "E")           # head
    rect(c, 18, 6, 22, 8, "E")             # snout
    poly(c, [(14, 10), (19, 10), (18, 17), (14, 15)], "E")
    line(c, 15, 16, 13, 20, "E", 2)        # curled tail
    line(c, 13, 20, 16, 21, "E", 2)
    rect(c, 9, 9, 11, 11, "R")             # question mark dot block
    rect(c, 9, 14, 11, 15, "R")
    return c


def temperature_dial():
    """A round dial from blue 0 to red 1."""
    c = clear()
    ellipse(c, 16, 17, 12, 12, "D")
    ellipse(c, 16, 17, 10, 10, "F")
    line(c, 8, 22, 11, 13, "c", 2)         # cold arc
    line(c, 21, 13, 24, 22, "R", 2)        # hot arc
    line(c, 16, 18, 21, 11, "N", 2)        # needle
    rect(c, 15, 17, 17, 19, "N")
    return c


def deep_research():
    """A magnifying glass over a tall stack of papers."""
    c = clear()
    rect(c, 4, 6, 18, 27, "P")
    for y in (9, 12, 15, 18, 21, 24):
        line(c, 6, y, 16, y, "T")
    ring(c, 21, 15, 7, 4.5, "M")
    ellipse(c, 21, 15, 4.5, 4.5, "c")
    line(c, 25, 20, 29, 27, "W", 3)
    return c


def ai_language_model():
    """A refusal card: a raised palm in a red circle."""
    c = clear()
    rrect(c, 5, 4, 26, 27, 2, "P")
    ring(c, 16, 15, 8, 6.2, "R")
    rect(c, 13, 12, 19, 19, "C")           # palm
    for x in (13, 15, 17, 19):
        rect(c, x, 9, x, 12, "C")          # fingers
    line(c, 9, 23, 22, 23, "T")
    return c


def prompt_leak():
    """A cracked scroll with a dripping leak."""
    c = clear()
    rect(c, 6, 5, 25, 22, "p")
    rect(c, 4, 4, 27, 6, "W")
    rect(c, 4, 21, 27, 23, "W")
    for y in (9, 12, 15, 18):
        line(c, 9, y, 22, y, "#")
    line(c, 17, 6, 14, 14, "N")            # crack
    ellipse(c, 14, 27, 2, 3, "c")          # leaking drop
    return c


def disgrace_loop():
    """A circular arrow around a sad face."""
    c = clear()
    ring(c, 16, 16, 12, 9.5, "V")
    poly(c, [(24, 3), (29, 9), (22, 10)], "V")   # arrow head
    ellipse(c, 16, 16, 7, 7, "C")
    rect(c, 13, 13, 14, 14, "#")
    rect(c, 18, 13, 19, 14, "#")
    line(c, 13, 20, 19, 20, "#")
    line(c, 12, 21, 12, 21, "#")
    line(c, 20, 21, 20, 21, "#")
    return c


# ---- Fifty-row backlog icons (rows 02-50); original geometric pixel art ----

def rejection_letter():
    c = clear()
    rect(c, 4, 9, 27, 25, "P")
    line(c, 4, 9, 15, 18, "T"); line(c, 27, 9, 16, 18, "T")
    rect(c, 18, 18, 25, 23, "R")
    line(c, 19, 19, 24, 22, "F"); line(c, 24, 19, 19, 22, "F")
    return c


def red_stamp():
    c = clear()
    rect(c, 13, 3, 18, 12, "W")
    ellipse(c, 15.5, 4, 5, 3, "W")
    rect(c, 8, 13, 23, 17, "N")
    rect(c, 6, 18, 25, 21, "R")
    ring(c, 15.5, 26, 6, 4.5, "R")
    return c


def anniversary_cake():
    c = clear()
    rect(c, 6, 17, 25, 27, "L")
    rect(c, 6, 17, 25, 19, "F")
    rect(c, 9, 12, 22, 16, "P")
    rect(c, 15, 6, 16, 11, "F")
    rect(c, 15, 3, 16, 5, "E")
    for x in (8, 13, 18, 23):
        rect(c, x, 22, x + 1, 23, "R")
    return c


def rice_cooker():
    c = clear()
    rrect(c, 5, 10, 26, 27, 4, "F")
    ellipse(c, 15.5, 10, 11, 4, "K")
    rect(c, 13, 4, 18, 7, "N")
    rect(c, 11, 18, 20, 21, "c")
    rect(c, 22, 19, 24, 20, "R")
    return c


def one_bowl():
    c = clear()
    ellipse(c, 16, 14, 9, 4, "F")
    rrect(c, 6, 14, 25, 23, 4, "c")
    rect(c, 12, 23, 19, 25, "c")
    rect(c, 15, 4, 16, 10, "#")             # "one"
    return c


def wengu_clock():
    c = clear()
    ellipse(c, 16, 16, 12, 12, "c")
    ellipse(c, 16, 16, 9.5, 9.5, "F")
    line(c, 16, 16, 16, 9, "N", 2)
    line(c, 16, 16, 21, 19, "N", 2)
    rect(c, 15, 2, 16, 4, "c")
    return c


def seven_second_memory():
    c = clear()
    ellipse(c, 16, 14, 11, 9, "c")
    rect(c, 9, 22, 22, 25, "c")
    line(c, 11, 10, 21, 10, "F", 2)
    line(c, 21, 10, 14, 20, "F", 2)
    return c


def sanity_test():
    c = clear()
    rrect(c, 9, 3, 22, 27, 2, "F")
    rect(c, 11, 3, 20, 6, "D")
    line(c, 12, 15, 15, 19, "H", 2)
    line(c, 15, 19, 20, 11, "H", 2)
    return c


def routing_receipt():
    c = clear()
    poly(c, [(8, 3), (24, 3), (24, 28), (21, 26), (18, 28), (15, 26), (12, 28), (8, 26)], "F")
    for y in (7, 11, 15):
        line(c, 11, y, 21, y, "T")
    line(c, 11, 20, 15, 20, "#"); line(c, 15, 20, 18, 23, "#"); line(c, 18, 23, 21, 23, "#")
    return c


def tibo_reset():
    c = clear()
    ring(c, 16, 16, 11, 8.5, "H")
    poly(c, [(22, 2), (28, 8), (21, 10)], "H")
    rect(c, 13, 12, 18, 20, "F")
    rect(c, 15, 10, 16, 12, "F")
    return c


def same_model_badge():
    c = clear()
    ellipse(c, 16, 13, 10, 10, "G")
    ellipse(c, 16, 13, 7, 7, "g")
    poly(c, [(9, 20), (13, 22), (11, 30), (8, 27)], "R")
    poly(c, [(23, 20), (19, 22), (21, 30), (24, 27)], "R")
    rect(c, 14, 10, 17, 16, "F")
    return c


def nano_banana():
    c = clear()
    poly(c, [(6, 8), (10, 8), (14, 20), (24, 24), (26, 27), (16, 28), (8, 22)], "G")
    rect(c, 6, 5, 8, 8, "W")
    line(c, 9, 10, 13, 21, "E")
    return c


def one_more_finger():
    c = clear()
    rect(c, 8, 16, 24, 27, "C")
    for i, x in enumerate((8, 11, 14, 17, 20, 23)):
        rect(c, x, 7 + (i % 2) * 2, x + 1, 16, "C")
    rect(c, 23, 6, 24, 9, "R")
    return c


def undo_brush():
    c = clear()
    line(c, 6, 26, 18, 14, "W", 3)
    poly(c, [(17, 10), (23, 6), (26, 9), (22, 15)], "V")
    ring(c, 21, 22, 6, 4, "c")
    poly(c, [(13, 20), (17, 18), (16, 23)], "c")
    return c


def unchanged_preview():
    c = clear()
    rect(c, 3, 8, 14, 22, "F"); rect(c, 5, 10, 12, 20, "c")
    rect(c, 17, 8, 28, 22, "F"); rect(c, 19, 10, 26, 20, "c")
    ellipse(c, 8.5, 15, 2, 2, "G"); ellipse(c, 22.5, 15, 2, 2, "G")
    line(c, 14, 26, 17, 26, "#")
    return c


def is_this_true():
    c = clear()
    rrect(c, 4, 4, 27, 22, 4, "N")
    poly(c, [(9, 22), (14, 22), (8, 28)], "N")
    line(c, 12, 9, 19, 9, "F", 2); line(c, 19, 9, 19, 13, "F", 2)
    line(c, 19, 13, 15, 15, "F", 2); rect(c, 15, 18, 16, 19, "F")
    return c


def live_wire():
    c = clear()
    poly(c, [(18, 2), (8, 17), (15, 17), (12, 29), (24, 12), (17, 12)], "E")
    return c


def quote_retort():
    c = clear()
    rrect(c, 4, 6, 27, 25, 3, "F")
    rect(c, 8, 10, 12, 14, "N"); rect(c, 14, 10, 18, 14, "N")
    line(c, 11, 14, 9, 17, "N", 2); line(c, 17, 14, 15, 17, "N", 2)
    line(c, 20, 20, 24, 16, "R", 2)
    return c


def community_note():
    c = clear()
    rect(c, 5, 5, 26, 26, "P")
    rect(c, 5, 5, 26, 9, "c")
    for y in (13, 17, 21):
        line(c, 8, y, 23, y, "T")
    rect(c, 21, 2, 24, 7, "R")
    return c


def base_model():
    c = clear()
    rect(c, 6, 20, 25, 26, "S")
    rect(c, 9, 14, 22, 19, "S")
    rect(c, 12, 8, 19, 13, "S")
    rect(c, 14, 4, 17, 7, "V")
    return c


def another_adapter():
    c = clear()
    rect(c, 9, 4, 22, 18, "K")
    rect(c, 11, 18, 13, 26, "M"); rect(c, 18, 18, 20, 26, "M")
    rect(c, 12, 8, 19, 12, "V")
    return c


def final_weights():
    c = clear()
    rect(c, 4, 13, 27, 17, "M")
    rect(c, 2, 8, 6, 22, "N"); rect(c, 25, 8, 29, 22, "N")
    rect(c, 7, 10, 9, 20, "D"); rect(c, 22, 10, 24, 20, "D")
    return c


def tiny_variant():
    c = clear()
    ellipse(c, 16, 22, 5, 5, "V")
    rect(c, 14, 17, 17, 20, "V")
    line(c, 6, 4, 10, 12, "T"); line(c, 25, 4, 21, 12, "T")
    rect(c, 13, 20, 14, 21, "#"); rect(c, 18, 20, 19, 21, "#")
    return c


def open_weights():
    c = clear()
    rrect(c, 6, 10, 25, 27, 3, "W")
    poly(c, [(4, 10), (16, 4), (27, 10)], "S")
    ellipse(c, 12, 18, 2.5, 2.5, "c"); ellipse(c, 20, 21, 2.5, 2.5, "c")
    rect(c, 15, 13, 16, 16, "F")
    return c


def herd_bell():
    c = clear()
    poly(c, [(10, 8), (22, 8), (26, 24), (6, 24)], "G")
    rect(c, 5, 24, 26, 26, "g")
    rect(c, 14, 4, 17, 8, "W")
    ellipse(c, 16, 28, 2, 2, "g")
    return c


def please_come_back():
    c = clear()
    ellipse(c, 11, 13, 6, 6, "L"); ellipse(c, 21, 13, 6, 6, "L")
    poly(c, [(5, 15), (27, 15), (16, 28)], "L")
    line(c, 16, 9, 14, 16, "#"); line(c, 14, 16, 18, 20, "#"); line(c, 18, 20, 16, 27, "#")
    return c


def release_soon():
    c = clear()
    rect(c, 4, 6, 27, 27, "F")
    rect(c, 4, 6, 27, 10, "R")
    for r, y in enumerate((14, 19, 24)):
        for x in (7, 12, 17, 22):
            rect(c, x, y, x + 2, y + 2, "T")
    line(c, 21, 18, 26, 26, "N", 2); line(c, 26, 18, 21, 26, "N", 2)
    return c


def emergency_baguette():
    c = clear()
    line(c, 5, 27, 26, 5, "E", 5)
    for i in range(3):
        line(c, 10 + i * 5, 19 - i * 5, 13 + i * 5, 23 - i * 5, "W")
    return c


def slipstream_boots():
    c = clear()
    rect(c, 10, 4, 18, 18, "E")
    rect(c, 10, 18, 26, 25, "E")
    rect(c, 10, 25, 26, 27, "W")
    line(c, 2, 10, 7, 10, "c"); line(c, 3, 15, 8, 15, "c"); line(c, 2, 20, 7, 20, "c")
    return c


def large_kitten():
    c = clear()
    ellipse(c, 16, 18, 12, 10, "E")
    poly(c, [(5, 12), (8, 3), (13, 10)], "E"); poly(c, [(27, 12), (24, 3), (19, 10)], "E")
    rect(c, 11, 16, 12, 18, "#"); rect(c, 20, 16, 21, 18, "#")
    rect(c, 15, 20, 17, 21, "L")
    return c


def edge_compass():
    c = clear()
    ellipse(c, 16, 16, 12, 12, "G")
    ellipse(c, 16, 16, 9.5, 9.5, "F")
    poly(c, [(16, 7), (19, 16), (13, 16)], "R")
    poly(c, [(16, 25), (19, 16), (13, 16)], "T")
    rect(c, 2, 2, 4, 29, "D")
    return c


def instant_apology():
    c = clear()
    ellipse(c, 16, 16, 11, 11, "c")
    rect(c, 11, 12, 13, 13, "#"); rect(c, 19, 12, 21, 13, "#")
    line(c, 12, 20, 20, 20, "#")
    rect(c, 24, 6, 27, 9, "L")
    return c


def next_time_again():
    c = clear()
    ring(c, 16, 16, 11, 8.5, "c")
    poly(c, [(4, 9), (10, 3), (12, 11)], "c")
    rect(c, 14, 11, 17, 20, "F"); rect(c, 12, 18, 19, 20, "F")
    return c


def confident_answer():
    c = clear()
    rrect(c, 4, 5, 27, 22, 4, "c")
    poly(c, [(9, 22), (14, 22), (8, 28)], "c")
    line(c, 10, 14, 14, 18, "F", 2); line(c, 14, 18, 22, 9, "F", 2)
    return c


def smiling_correction():
    c = clear()
    ellipse(c, 16, 16, 11, 11, "E")
    rect(c, 11, 12, 12, 14, "#"); rect(c, 19, 12, 20, 14, "#")
    line(c, 11, 19, 14, 22, "#"); line(c, 14, 22, 18, 22, "#"); line(c, 18, 22, 21, 19, "#")
    line(c, 22, 4, 28, 10, "W", 2)
    return c


def slide_deadline():
    c = clear()
    rect(c, 4, 4, 27, 20, "F")
    rect(c, 4, 4, 27, 7, "V")
    rect(c, 8, 11, 12, 17, "c"); rect(c, 14, 13, 18, 17, "c"); rect(c, 20, 9, 24, 17, "c")
    rect(c, 15, 20, 16, 27, "D"); line(c, 10, 28, 21, 28, "D")
    return c


def citation_thread():
    c = clear()
    rect(c, 3, 8, 12, 14, "F"); rect(c, 19, 17, 28, 23, "F")
    line(c, 12, 11, 19, 20, "R")
    rect(c, 5, 10, 6, 12, "#"); rect(c, 21, 19, 22, 21, "#")
    return c


def overtime_slides():
    c = clear()
    rect(c, 3, 6, 22, 21, "F"); rect(c, 3, 6, 22, 8, "V")
    ellipse(c, 23, 21, 6, 6, "D")
    ellipse(c, 25, 19, 5, 5, ".")
    return c


def standup_meeting():
    c = clear()
    for x in (8, 16, 24):
        ellipse(c, x, 10, 3, 3, "C")
        rect(c, x - 3, 14, x + 3, 24, "V")
    rect(c, 3, 25, 28, 27, "W")
    return c


def queue_ticket():
    c = clear()
    rect(c, 5, 8, 26, 23, "P")
    ellipse(c, 5, 15.5, 2, 3, "."); ellipse(c, 26, 15.5, 2, 3, ".")
    rect(c, 10, 11, 21, 13, "H")
    rect(c, 10, 17, 21, 19, "T")
    return c


def sold_out():
    c = clear()
    rect(c, 4, 9, 27, 22, "F")
    line(c, 4, 22, 27, 9, "R", 2)
    rect(c, 7, 13, 12, 17, "T"); rect(c, 19, 13, 24, 17, "T")
    return c


def please_retry():
    c = clear()
    rrect(c, 3, 6, 28, 25, 3, "F")
    ring(c, 16, 16, 7, 4.8, "H")
    poly(c, [(19, 7), (24, 10), (19, 13)], "H")
    rect(c, 3, 6, 28, 8, "T")
    return c


def access_pass():
    c = clear()
    rrect(c, 4, 6, 27, 25, 2, "H")
    rect(c, 7, 9, 13, 16, "C")
    for y in (10, 14, 18):
        line(c, 16, y, 24, y, "F")
    rect(c, 7, 20, 24, 22, "G")
    return c


def cache_cartridge():
    c = clear()
    rect(c, 6, 4, 25, 25, "D")
    rect(c, 9, 7, 22, 15, "c")
    for x in range(8, 24, 3):
        rect(c, x, 25, x + 1, 28, "G")
    return c


def token_recall():
    c = clear()
    ellipse(c, 16, 16, 10, 10, "G")
    ellipse(c, 16, 16, 7, 7, "g")
    poly(c, [(2, 16), (8, 10), (8, 22)], "c")
    rect(c, 15, 12, 16, 20, "F")
    return c


def checkpoint_pin():
    c = clear()
    ellipse(c, 16, 11, 8, 8, "R")
    poly(c, [(9, 14), (23, 14), (16, 29)], "R")
    ellipse(c, 16, 11, 3, 3, "F")
    return c


def rate_limit_valve():
    c = clear()
    rect(c, 2, 18, 29, 24, "M")
    rect(c, 13, 10, 18, 18, "M")
    rect(c, 6, 6, 25, 9, "R")
    rect(c, 14, 19, 17, 23, "D")
    return c


def consensus_coin():
    c = clear()
    ellipse(c, 16, 16, 12, 12, "G")
    ellipse(c, 16, 16, 9, 9, "g")
    line(c, 11, 16, 14, 19, "F", 2); line(c, 14, 19, 21, 12, "F", 2)
    return c


def error_budget():
    c = clear()
    rect(c, 5, 20, 26, 26, "D")
    rect(c, 7, 22, 24, 24, "H")
    rect(c, 18, 22, 24, 24, "R")
    poly(c, [(16, 3), (26, 17), (6, 17)], "E")
    rect(c, 15, 8, 16, 12, "#"); rect(c, 15, 14, 16, 15, "#")
    return c


def em_dash():
    """A paragraph whose sentence runs into one long bold dash."""
    c = clear()
    rrect(c, 5, 4, 26, 27, 2, "P")
    for y in (8, 11):
        line(c, 8, y, 23, y, "T")
    line(c, 8, 22, 15, 22, "T")
    rect(c, 2, 15, 29, 18, "N")            # the em dash, past both margins
    return c


def blueberry():
    """A blueberry with a star-shaped crown and a B on it."""
    c = clear()
    ellipse(c, 16, 18, 11, 11, "U")
    poly(c, [(12, 7), (16, 4), (20, 7), (19, 10), (13, 10)], "V")   # crown
    line(c, 12, 14, 12, 24, "F", 2)        # letter B
    line(c, 12, 14, 18, 14, "F", 2)
    line(c, 12, 19, 18, 19, "F", 2)
    line(c, 12, 24, 18, 24, "F", 2)
    line(c, 19, 15, 19, 18, "F", 2)
    line(c, 19, 20, 19, 23, "F", 2)
    return c


def benchmaxxed():
    """A bar chart: two short grey bars and one gold bar off the top."""
    c = clear()
    rect(c, 3, 27, 28, 28, "D")            # axis
    rect(c, 5, 19, 10, 26, "T")
    rect(c, 12, 16, 17, 26, "T")
    rect(c, 20, 3, 26, 26, "G")            # the benchmark score
    poly(c, [(19, 4), (23, 0), (27, 4)], "G")
    return c


def i_panicked():
    """A database cylinder struck through with a red X."""
    c = clear()
    rect(c, 6, 8, 25, 23, "M")
    ellipse(c, 16, 24, 10, 4, "M")         # rounded bottom
    ellipse(c, 16, 8, 10, 4, "K")          # lid
    line(c, 6, 13, 25, 13, "m")
    line(c, 6, 18, 25, 18, "m")
    line(c, 5, 5, 26, 28, "R", 3)
    line(c, 26, 5, 5, 28, "R", 3)
    return c


SPRITES = {
    "summary_stapler": summary_stapler,
    "lunch_break": lunch_break,
    "support_ticket": support_ticket,
    "ban_hammer": ban_hammer,
    "residential_ip": residential_ip,
    "compact": compact,
    "absolutely_right": absolutely_right,
    "cheap_relay": cheap_relay,
    "ultrathink": ultrathink,
    "million_context": million_context,
    "silent_update": silent_update,
    "skip_permissions": skip_permissions,
    "tests_passing": tests_passing,
    "vibe_coding": vibe_coding,
    "banked_reset": banked_reset,
    "subagent_swarm": subagent_swarm,
    "constitution": constitution,
    "opus_mode": opus_mode,
    "overloaded": overloaded,
    "hardcoded_output": hardcoded_output,
    "thinking_cleared": thinking_cleared,
    "welcome_notice": welcome_notice,
    "status_page": status_page,
    "appeal_form": appeal_form,
    "ignore_instructions": ignore_instructions,
    "tungsten_cube": tungsten_cube,
    "pizza_glue": pizza_glue,
    "strawberry": strawberry,
    "rejection_letter": rejection_letter,
    "red_stamp": red_stamp,
    "anniversary_cake": anniversary_cake,
    "rice_cooker": rice_cooker,
    "one_bowl": one_bowl,
    "wengu_clock": wengu_clock,
    "seven_second_memory": seven_second_memory,
    "sanity_test": sanity_test,
    "routing_receipt": routing_receipt,
    "tibo_reset": tibo_reset,
    "same_model_badge": same_model_badge,
    "nano_banana": nano_banana,
    "one_more_finger": one_more_finger,
    "undo_brush": undo_brush,
    "unchanged_preview": unchanged_preview,
    "is_this_true": is_this_true,
    "live_wire": live_wire,
    "quote_retort": quote_retort,
    "community_note": community_note,
    "base_model": base_model,
    "another_adapter": another_adapter,
    "final_weights": final_weights,
    "tiny_variant": tiny_variant,
    "open_weights": open_weights,
    "herd_bell": herd_bell,
    "please_come_back": please_come_back,
    "release_soon": release_soon,
    "emergency_baguette": emergency_baguette,
    "slipstream_boots": slipstream_boots,
    "large_kitten": large_kitten,
    "edge_compass": edge_compass,
    "instant_apology": instant_apology,
    "next_time_again": next_time_again,
    "confident_answer": confident_answer,
    "smiling_correction": smiling_correction,
    "slide_deadline": slide_deadline,
    "citation_thread": citation_thread,
    "overtime_slides": overtime_slides,
    "standup_meeting": standup_meeting,
    "queue_ticket": queue_ticket,
    "sold_out": sold_out,
    "please_retry": please_retry,
    "access_pass": access_pass,
    "cache_cartridge": cache_cartridge,
    "token_recall": token_recall,
    "checkpoint_pin": checkpoint_pin,
    "rate_limit_valve": rate_limit_valve,
    "consensus_coin": consensus_coin,
    "error_budget": error_budget,
    "golden_gate": golden_gate,
    "seahorse_emoji": seahorse_emoji,
    "temperature_dial": temperature_dial,
    "deep_research": deep_research,
    "claudius_discount": claudius_discount,
    "small_rock": small_rock,
    "mt_moon": mt_moon,
    "ai_language_model": ai_language_model,
    "prompt_leak": prompt_leak,
    "disgrace_loop": disgrace_loop,
    "em_dash": em_dash,
    "blueberry": blueberry,
    "benchmaxxed": benchmaxxed,
    "i_panicked": i_panicked,
}

# icons whose content is symmetric: mirror the finished pixels, shading included
PIXEL_SYMMETRIC = {"ban_hammer", "compact", "opus_mode", "overloaded",
                   "welcome_notice", "constitution", "ultrathink", "thinking_cleared",
                   "million_context", "vibe_coding", "subagent_swarm"}

# silhouettes that must be mirror-symmetric about x = 15.5
SYMMETRIC = {"ban_hammer", "compact", "tests_passing", "constitution",
             "opus_mode", "overloaded", "hardcoded_output", "welcome_notice",
             "status_page", "appeal_form"}

TRINKETS = {"overloaded", "hardcoded_output", "thinking_cleared",
            "welcome_notice", "status_page", "appeal_form",
            "claudius_discount", "small_rock", "mt_moon",
            "ai_language_model", "prompt_leak", "disgrace_loop"}
ORDER = list(SPRITES)


def preview(grids, path, scale=6, cols=7, bg=(24, 20, 18, 255)):
    pad = 6
    cell = SIZE * scale + pad
    rows = math.ceil(len(grids) / cols)
    w, h = cols * cell + pad, rows * cell + pad
    canvas = [[bg for _ in range(w)] for _ in range(h)]
    for i, grid in enumerate(grids):
        ox = pad + (i % cols) * cell
        oy = pad + (i // cols) * cell
        for y in range(SIZE):
            for x in range(SIZE):
                col = grid[y][x]
                if col == ".":
                    continue
                px = (int(col[1:3], 16), int(col[3:5], 16), int(col[5:7], 16), 255)
                for sy in range(scale):
                    for sx in range(scale):
                        canvas[oy + y * scale + sy][ox + x * scale + sx] = px
    write_png(canvas, path)


def main():
    args = sys.argv[1:]
    out_root = ROOT / "resources" / "gfx" / "items"
    if "--out" in args:
        out_root = Path(args[args.index("--out") + 1])

    grids = []
    for name in ORDER:
        grid = render(SPRITES[name]())
        if name in PIXEL_SYMMETRIC:
            grid = [row[:] for row in grid]
            for y in range(SIZE):
                for x in range(SIZE // 2):
                    grid[y][SIZE - 1 - x] = grid[y][x]
        sub = "trinkets" if name in TRINKETS else "collectibles"
        target = out_root / sub
        target.mkdir(parents=True, exist_ok=True)
        write_png(rgba(grid), target / (name + ".png"))
        grids.append(grid)
        print(f"wrote {target / (name + '.png')}")

    if "--check-symmetry" in args:
        bad = 0
        for name in ORDER:
            g = SPRITES[name]()
            diff = sum(1 for y in range(SIZE) for x in range(SIZE // 2)
                       if (g[y][x] != ".") != (g[y][SIZE - 1 - x] != "."))
            if name in SYMMETRIC and diff:
                bad += 1
                print(f"asymmetric silhouette: {name} ({diff} px)")
        print(f"symmetry check: {len(SYMMETRIC)} silhouettes, "
              f"{len(PIXEL_SYMMETRIC)} pixel-mirrored, {bad} failures")

        if bad:
            raise SystemExit(1)

    if "--preview" in args:
        path = Path(args[args.index("--preview") + 1])
        preview(grids, path)
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
