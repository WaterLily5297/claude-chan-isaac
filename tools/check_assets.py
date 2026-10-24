"""Check generated sprites without overwriting installed artwork (standard library)."""
import ast
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parent.parent
for path in root.glob('tools/*.py'):
    ast.parse(path.read_text(encoding='utf-8'), filename=str(path))
with tempfile.TemporaryDirectory() as temporary:
    out = Path(temporary)
    subprocess.run([sys.executable, str(root / 'tools/make_placeholders.py'),
                    '--out', str(out), '--check-symmetry'], check=True, stdout=subprocess.PIPE)
    definitions = ET.parse(root / 'content/items.xml').getroot()
    for item in definitions:
        relative = item.attrib['gfx'].removeprefix('gfx/items/')
        path = root / 'resources/gfx/items' / relative
        png = path.read_bytes()
        assert png[:8] == b'\x89PNG\r\n\x1a\n', path
        assert struct.unpack('>II', png[16:24]) == (32, 32), path
        assert png[24:26] == bytes([8, 6]), f'{path}: expected RGBA8'
        assert png == (out / relative).read_bytes(), f'{path}: generated sprite differs'
    names = {item.attrib['name'] for item in definitions if item.tag != 'trinket'}
    for item in ET.parse(root / 'content/itempools.xml').iter('Item'):
        assert item.attrib['Name'] in names, f'Undefined pool entry: {item.attrib}'
print('  OK: Python syntax, 32x32 RGBA sprites, deterministic generation and item pools')

players = ET.parse(root / 'content/players.xml').getroot()
for player in players:
    for attribute, prefix in [('skin', 'root'), ('portrait', 'portraitroot'),
                               ('bigportrait', 'bigportraitroot'), ('nameimage', 'nameimageroot')]:
        path = root / 'resources' / players.attrib[prefix] / player.attrib[attribute]
        assert path.is_file(), f'Missing character asset: {path}'
        data = path.read_bytes()
        assert data[:8] == b'\x89PNG\r\n\x1a\n' and data[24:26] == bytes([8, 6]), path
        if attribute == 'skin':
            assert struct.unpack('>II', data[16:24]) == (512, 512), path

for path in (root / 'content/gfx').glob('*.anm2'):
    animation = ET.parse(path).getroot()
    sheets = {}
    for sheet in animation.findall('./Content/Spritesheets/Spritesheet'):
        image = path.parent / sheet.attrib['Path']
        assert image.is_file(), f'Missing animation sheet: {image}'
        sheets[sheet.attrib['Id']] = struct.unpack('>II', image.read_bytes()[16:24])
    layers = {layer.attrib['Id']: sheet for layer in animation.findall('./Content/Layers/Layer')
              for sheet in [layer.attrib['SpritesheetId']]}
    for layer in animation.findall('.//LayerAnimation'):
        width, height = sheets[layers[layer.attrib['LayerId']]]
        for frame in layer.findall('Frame'):
            assert int(frame.attrib['XCrop']) + int(frame.attrib['Width']) <= width, path
            assert int(frame.attrib['YCrop']) + int(frame.attrib['Height']) <= height, path
print('  OK: character textures, portraits, selection animations and frame bounds')

# Every advertised family must be registered, selectable and have a dossier.
roster = json.loads((root / 'docs/portrait-prompts.json').read_text(encoding='utf-8'))['entries']
normal_names = {p.get('name') for p in players if not p.get('bSkinParent')}
menu_names = {a.get('Name') for a in ET.parse(root / 'content/gfx/characterportraits.anm2').findall('./Animations/Animation')}
assert {e['name'] for e in roster} == normal_names == menu_names
assert len({e['key'] for e in roster}) == len(roster)
for entry in roster + [{'key': e['key'] + '_b'} for e in roster]:
    key = entry['key']
    png = (root / f'resources/gfx/ui/dossiers/{key}.png').read_bytes()
    assert struct.unpack('>II', png[16:24]) == (384, 576), key
    assert png[24:26] == bytes([8, 6]), key
    actor = ET.parse(root / f'resources/gfx/ui/dossiers/{key}.anm2')
    for sheet in actor.findall('./Content/Spritesheets/Spritesheet'):
        assert (root / 'resources' / sheet.get('Path')).is_file(), key
    frame = actor.find('./Animations/Animation/LayerAnimations/LayerAnimation/Frame')
    assert (int(frame.get('Width')), int(frame.get('Height'))) == (384, 576), key
    assert frame.get('XCrop') == '0' and frame.get('YCrop') == '0', key
alt_names = {a.get('Name') for a in ET.parse(root / 'content/gfx/characterportraitsalt.anm2').findall('./Animations/Animation')}
assert alt_names == normal_names, 'every family needs a tainted menu cell'
print(f'  OK: {len(roster)} playable model families, selection names and full portrait dossiers')

# Committed skins must match the reviewed manifest, so an unrecorded edit or a
# skipped animate_roster_walk.py run is caught without Pillow.
for record in json.loads((root / 'docs/roster-art-manifest.json').read_text(encoding='utf-8')):
    key = record['key']
    gamekey = key.replace('_b', 'chan_b') if key.endswith('_b') else key + 'chan'
    data = (root / f'resources/gfx/characters/costumes/character_{gamekey}.png').read_bytes()
    assert hashlib.sha256(data).hexdigest() == record['packed_sprite_sha256'], f'{key}: atlas differs from manifest'
print('  OK: character atlases match the art manifest')

subprocess.run([sys.executable, str(root / 'tools/make_roster_tainted_art.py'), '--check'], check=True)
