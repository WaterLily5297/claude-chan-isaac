"""Reproduce the original item batch's 1x/4x before/after review sheets.

Standard library only. Icons retain hard pixels; text stays outside them.
Reference shapes are original project examples, not extracted game art.
"""
import argparse
from pathlib import Path

import make_item_art as art

ROOT = Path(__file__).resolve().parent.parent
BATCH = (
    ('ban_hammer', 'Ban Hammer'), ('compact', 'Compact'),
    ('summary_stapler', 'Summary Stapler'), ('ultrathink', 'Ultrathink'),
    ('subagent_swarm', 'Subagent Swarm'), ('constitution', 'The Constitution'),
    ('lunch_break', 'Lunch Break'), ('rice_cooker', 'Rice Cooker'),
    ('token_recall', 'Token Recall'), ('lets_delve', "Let's Delve"),
)
LIGHT, DARK = (221,205,175,255), (37,31,32,255)
PAGE, TEXT = (238,229,209,255), (47,37,35,255)

# Small original bitmap label alphabet. These pixels never enter item icons.
FONT = {
    'A':'01110/10001/10001/11111/10001/10001/10001',
    'B':'11110/10001/10001/11110/10001/10001/11110',
    'C':'01111/10000/10000/10000/10000/10000/01111',
    'D':'11110/10001/10001/10001/10001/10001/11110',
    'E':'11111/10000/10000/11110/10000/10000/11111',
    'F':'11111/10000/10000/11110/10000/10000/10000',
    'G':'01111/10000/10000/10111/10001/10001/01111',
    'H':'10001/10001/10001/11111/10001/10001/10001',
    'I':'11111/00100/00100/00100/00100/00100/11111',
    'J':'00111/00010/00010/00010/10010/10010/01100',
    'K':'10001/10010/10100/11000/10100/10010/10001',
    'L':'10000/10000/10000/10000/10000/10000/11111',
    'M':'10001/11011/10101/10101/10001/10001/10001',
    'N':'10001/11001/10101/10011/10001/10001/10001',
    'O':'01110/10001/10001/10001/10001/10001/01110',
    'P':'11110/10001/10001/11110/10000/10000/10000',
    'Q':'01110/10001/10001/10001/10101/10010/01101',
    'R':'11110/10001/10001/11110/10100/10010/10001',
    'S':'01111/10000/10000/01110/00001/00001/11110',
    'T':'11111/00100/00100/00100/00100/00100/00100',
    'U':'10001/10001/10001/10001/10001/10001/01110',
    'V':'10001/10001/10001/10001/10001/01010/00100',
    'W':'10001/10001/10001/10101/10101/10101/01010',
    'X':'10001/10001/01010/00100/01010/10001/10001',
    'Y':'10001/10001/01010/00100/00100/00100/00100',
    'Z':'11111/00001/00010/00100/01000/10000/11111',
    '0':'01110/10001/10011/10101/11001/10001/01110',
    '1':'00100/01100/00100/00100/00100/00100/01110',
    '2':'01110/10001/00001/00010/00100/01000/11111',
    '3':'11110/00001/00001/01110/00001/00001/11110',
    '4':'00010/00110/01010/10010/11111/00010/00010',
    '5':'11111/10000/10000/11110/00001/00001/11110',
    '6':'01110/10000/10000/11110/10001/10001/01110',
    '7':'11111/00001/00010/00100/01000/01000/01000',
    '8':'01110/10001/10001/01110/10001/10001/01110',
    '9':'01110/10001/10001/01111/00001/00001/01110',
    "'":'00100/00100/01000/00000/00000/00000/00000',
    '-':'00000/00000/00000/11111/00000/00000/00000',
    '/':'00001/00001/00010/00100/01000/10000/10000',
    ':':'00000/00100/00100/00000/00100/00100/00000',
    ' ':'00000/00000/00000/00000/00000/00000/00000',
}


def fill(canvas, x, y, w, h, colour):
    for yy in range(y, y+h):
        canvas[yy][x:x+w] = [colour] * w


def label(canvas, x, y, text, scale=1):
    for char in text.upper():
        glyph = FONT[char].split('/')
        for gy, row in enumerate(glyph):
            for gx, bit in enumerate(row):
                if bit == '1': fill(canvas,x+gx*scale,y+gy*scale,scale,scale,TEXT)
        x += 6 * scale


def paste(canvas, pixels, x, y, scale):
    for yy, row in enumerate(pixels):
        for xx, p in enumerate(row):
            if p[3]: fill(canvas,x+xx*scale,y+yy*scale,scale,scale,p)


def references():
    c = art.Canvas()
    c.oval(16,17,10,9,art.GOLD[0]); c.oval(15,16,9,8,art.GOLD[1])
    c.line(9,11,15,8,art.GOLD[2]); c.line(10,22,20,23,art.GOLD[0])
    coin = c.finish()
    c = art.Canvas()
    c.poly([(4,13),(7,7),(13,8),(16,12),(20,8),(25,7),(28,12),(26,20),(16,28),(6,20)],art.PINK[0])
    c.poly([(5,13),(8,8),(12,9),(16,14),(21,9),(24,8),(26,13),(23,19),(16,25),(8,19)],art.PINK[1])
    c.line(8,10,10,10,art.PINK[2]); c.line(7,11,7,14,art.PINK[2])
    heart = c.finish()
    c = art.Canvas()
    c.poly([(4,21),(7,12),(15,7),(24,11),(28,20),(23,26),(9,26)],art.STEEL[0])
    c.poly([(5,20),(8,13),(15,8),(21,12),(17,21),(9,24)],art.STEEL[1])
    c.poly([(8,13),(15,8),(19,11),(13,14)],art.STEEL[2])
    return coin, heart, c.finish()


def sheet(scale):
    size = 32 * scale
    panel = size + 10
    card_w = max(280, panel * 4 + 16)
    card_h = size + 48
    width = card_w * 2 + 24
    top, bottom = 66, size + 58
    height = top + card_h * 5 + bottom
    canvas = [[PAGE for _ in range(width)] for _ in range(height)]
    label(canvas,16,12,f'ITEM ART - BATCH 01 - {scale}X',2)
    label(canvas,16,35,'OLD / NEW ON LIGHT AND DARK BACKGROUNDS')
    label(canvas,16,48,'ORIGINAL PROJECT PIXELS - NATIVE PRESENTATION UNVERIFIED')
    for i,(key,name) in enumerate(BATCH):
        x,y = 12 + (i%2)*card_w, top + (i//2)*card_h
        label(canvas,x+4,y,name)
        start = x + (card_w - panel*4)//2
        label(canvas,start+panel-10,y+14,'OLD')
        label(canvas,start+panel*3-10,y+14,'NEW')
        old = art.placeholder_pixels('collectibles/'+key+'.png')
        new = art.DESIGNS['collectibles/'+key+'.png'].draw()
        for j,pixels in enumerate((old,old,new,new)):
            px,py = start+j*panel,y+26
            fill(canvas,px,py,size+4,size+4,LIGHT if j%2==0 else DARK)
            paste(canvas,pixels,px+2,py+2,scale)
    y = top + card_h*5
    label(canvas,16,y+4,'ORIGINAL PROJECT REFERENCE SHAPES - NOT GAME ASSETS')
    for i,pixels in enumerate(references()):
        for j,bg in enumerate((LIGHT,DARK)):
            x = 16 + (i*2+j)*(size+12)
            fill(canvas,x,y+20,size+4,size+4,bg)
            paste(canvas,pixels,x+2,y+22,scale)
    return art.png_bytes(canvas)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--write',action='store_true')
    mode.add_argument('--check',action='store_true')
    args=parser.parse_args()
    for scale in (1,4):
        path=ROOT/f'docs/art/item-batch-01-{scale}x.png'
        data=sheet(scale)
        if args.check:
            art.require(path.is_file() and path.read_bytes()==data,f'Stale review sheet: {path.name}')
        else:
            path.parent.mkdir(parents=True,exist_ok=True); path.write_bytes(data)
    print('  OK: original item-art 1x/4x before/after sheets')


if __name__=='__main__':
    main()
