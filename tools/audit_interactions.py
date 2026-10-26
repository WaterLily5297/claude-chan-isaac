"""Conservative lexical interaction inventory; never imports or executes Lua.

Run --write to refresh the marked section of docs/INTERACTIONS.md, --check to
detect stale inventory, or --json for structured findings. Candidate overlap is
not proof of a bug, entity identity, simultaneous activation or callback order.
"""
import argparse
from collections import defaultdict
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re

BEGIN = '<!-- BEGIN GENERATED INTERACTION INVENTORY -->'
END = '<!-- END GENERATED INTERACTION INVENTORY -->'
FIELDS = set('''Damage FireDelay MaxFireDelay MoveSpeed TearRange ShotSpeed Luck
CanFly CollisionDamage SpriteScale TearFlags TearColor Color Scale Size Height
FallingSpeed FallingAcceleration Velocity Position Timeout EntityCollisionClass
GridCollisionClass Variant'''.split())
MUTATORS = set('''SetColor AddTearFlags ClearTearFlags ResetSpriteScale
ChangeVariant SetSize AddEntityFlags ClearEntityFlags'''.split())
OPERATORS = {
    '+', '-', '*', '/', '//', '%', '^', '&', '|', '~', '<<', '>>', '<', '>',
    '<=', '>=', '==', '~=', '..', 'and', 'or', 'not', '.', ':'}
STOPS = {'end', 'else', 'elseif', 'then', 'until', 'local', 'return', 'break', ';'}


@dataclass(frozen=True)
class Token:
    text: str
    kind: str
    line: int


def tokenize(source):
    tokens, i, line = [], 0, 1
    while i < len(source):
        start, start_line = i, line
        char = source[i]
        if char.isspace():
            line += char == '\n'
            i += 1
            continue
        comment = source.startswith('--', i)
        offset = i + 2 if comment else i
        long_open = re.match(r'\[(=*)\[', source[offset:])
        if long_open:
            close = ']' + long_open.group(1) + ']'
            finish = source.find(close, offset + len(long_open.group(0)))
            if finish < 0:
                raise ValueError(f'Unterminated long string/comment at line {line}')
            i = finish + len(close)
            if not comment:
                tokens.append(Token(source[start:i], 'string', start_line))
        elif comment:
            finish = source.find('\n', i)
            i = len(source) if finish < 0 else finish
        elif char in '\"\'':
            i += 1
            while i < len(source):
                if source[i] == '\\':
                    i += 2
                elif source[i] == char:
                    i += 1
                    break
                else:
                    i += 1
            else:
                raise ValueError(f'Unterminated quoted string at line {line}')
            tokens.append(Token(source[start:i], 'string', start_line))
        else:
            match = re.match(r'[A-Za-z_][A-Za-z_0-9]*|(?:\d+(?:\.\d+)?)(?:[eE][+-]?\d+)?|\.\.\.|\.\.|==|~=|<=|>=|//|<<|>>', source[i:])
            value = match.group(0) if match else char
            kind = 'identifier' if re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', value) else 'symbol'
            tokens.append(Token(value, kind, start_line))
            i += len(value)
        line += source[start:i].count('\n')
    return tokens


def compact(tokens):
    result = ''
    for token in tokens:
        text = token.text
        if result and (result[-1].isalnum() or result[-1] == '_') and (text[0].isalnum() or text[0] == '_'):
            result += ' '
        result += text
    return result


def argument(tokens, start):
    depth, end = 0, start
    while end < len(tokens):
        text = tokens[end].text
        if depth == 0 and text in {',', ')'}:
            break
        if text in {'(', '[', '{'}:
            depth += 1
        elif text in {')', ']', '}'}:
            depth -= 1
        end += 1
    return tokens[start:end], end


def expression(tokens, start):
    depth, end = 0, start
    while end < len(tokens):
        text = tokens[end].text
        if depth == 0:
            if text in STOPS or text in {')', '}', ']'}:
                break
            if end > start and tokens[end].line > tokens[end - 1].line:
                if text not in OPERATORS and tokens[end - 1].text not in OPERATORS:
                    break
            if end > start and text == '=':
                break
        if text in {'(', '[', '{'}:
            depth += 1
        elif text in {')', ']', '}'}:
            depth -= 1
        end += 1
    return tokens[start:end]


def member_start(tokens, end):
    """Return the start of a plain identifier/member chain ending at end."""
    if end < 0 or tokens[end].kind != 'identifier':
        return None
    start = end
    while start >= 2 and tokens[start - 1].text == '.' and tokens[start - 2].kind == 'identifier':
        start -= 2
    return start


def literal_key(token):
    if token.kind == 'string' and token.text[0] in '\"\'' and '\\' not in token.text:
        return token.text[1:-1]
    return None


def reads_target(lhs, rhs):
    target = [token.text for token in lhs]
    values = [token.text for token in rhs]
    for i in range(len(values) - len(target) + 1):
        if values[i:i + len(target)] != target:
            continue
        if i and values[i - 1] in {'.', ':'}:
            continue
        end = i + len(target)
        if end < len(values) and values[end] in {'.', '[', ':'}:
            continue
        return True
    return False


def scan_module(path, source):
    tokens = tokenize(source)
    result = dict(path=path, sha256=hashlib.sha256(source.encode('utf-8')).hexdigest(),
                  callbacks=[], cache_flags=[], writes=[], mutators=[], state=[], limitations=[])
    multiple = set()
    for i, token in enumerate(tokens):
        if token.text != '=':
            continue
        start = i - 1
        while start >= 0 and tokens[start].line == token.line and tokens[start].text != ';':
            start -= 1
        lhs = tokens[start + 1:i]
        # Only disclose simple comma-separated property targets, not call args.
        if any(t.text == ',' for t in lhs) and not any(t.text in {'(', '{', '='} for t in lhs):
            if any(t.text in FIELDS for t in lhs):
                multiple.add(i)
                result['limitations'].append(f'L{token.line}: multiple assignment requires manual mapping')
                for j in range(start + 2, i):
                    if tokens[j].text in FIELDS and tokens[j - 1].text == '.':
                        target_start = member_start(tokens, j - 2)
                        if target_start is not None:
                            result['writes'].append(dict(line=tokens[j].line, field=tokens[j].text,
                                target=compact(tokens[target_start:j + 1]),
                                rhs=compact(expression(tokens, i + 1)), mode='multiple-target; manual mapping'))
    for i, token in enumerate(tokens):
        text = token.text
        if text in {'AddCallback', 'AddPriorityCallback'} and i and tokens[i - 1].text in {':', '.'} and i + 1 < len(tokens) and tokens[i + 1].text == '(':
            callback, end = argument(tokens, i + 2)
            priority = 'default'
            if text == 'AddPriorityCallback':
                priority_tokens, _ = argument(tokens, end + 1)
                priority = compact(priority_tokens)
            result['callbacks'].append(dict(line=token.line, callback=compact(callback), priority=priority))
        if text == 'CacheFlag' and i + 2 < len(tokens) and tokens[i + 1].text == '.':
            result['cache_flags'].append(tokens[i + 2].text)
        if text in MUTATORS and i and tokens[i - 1].text == ':' and i + 1 < len(tokens) and tokens[i + 1].text == '(':
            result['mutators'].append(dict(line=token.line, method=text))
        if text in {'Risk', 'self'} and (text == 'Risk' or path == 'scripts/risk.lua'):
            if i + 2 < len(tokens) and [t.text for t in tokens[i + 1:i + 3]] == ['.', 'state']:
                end, key = i + 3, '[whole table]'
                if end + 1 < len(tokens) and tokens[end].text == '.':
                    key, end = tokens[end + 1].text, end + 2
                elif end + 2 < len(tokens) and tokens[end].text == '[':
                    if tokens[end + 2].text == ']':
                        key = literal_key(tokens[end + 1]) or '[dynamic]'
                        end += 3
                    else:
                        key = '[dynamic]'
                        while end < len(tokens) and tokens[end].text != ']':
                            end += 1
                        end += 1
                access = 'direct write' if end < len(tokens) and tokens[end].text == '=' else 'read/alias'
                result['state'].append(dict(line=token.line, key=key, access=access))
        field, eq, start = None, None, None
        if text in FIELDS and i and tokens[i - 1].text == '.' and i + 1 < len(tokens) and tokens[i + 1].text == '=':
            field, eq, start = text, i + 1, member_start(tokens, i - 2)
        elif text == '[' and i + 3 < len(tokens) and tokens[i + 2].text == ']' and tokens[i + 3].text == '=':
            key = literal_key(tokens[i + 1])
            if key in FIELDS:
                field, eq, start = key, i + 3, member_start(tokens, i - 1)
            elif key is None:
                result['limitations'].append(f'L{token.line}: dynamic field target requires manual review')
        if field is None or eq in multiple:
            continue
        if start is None:
            result['limitations'].append(f'L{token.line}: expression receiver for {field} requires manual review')
            lhs = f'<expression>.{field}'
        else:
            lhs = compact(tokens[start:eq])
        rhs_tokens = expression(tokens, eq + 1)
        rhs = compact(rhs_tokens)
        if start is not None and reads_target(tokens[start:eq], rhs_tokens):
            mode = 'self-dependent'
        elif re.fullmatch(r'-?(?:\d+(?:\.\d+)?|true|false|nil)', rhs):
            mode = 'literal'
        else:
            mode = 'indirect'
        result['writes'].append(dict(line=token.line, field=field, target=lhs, rhs=rhs, mode=mode))
    result['cache_flags'] = sorted(set(result['cache_flags']))
    result['limitations'] = sorted(set(result['limitations']))
    result['writes'].sort(key=lambda item: item['line'])
    return result


def scan_repository(root):
    paths = [root / 'main.lua'] + sorted((root / 'scripts').rglob('*.lua'))
    return [scan_module(path.relative_to(root).as_posix(), path.read_text(encoding='utf-8')) for path in paths]


def code(value):
    return '`' + value.replace('`', "'").replace('|', '\\|').replace('\n', ' ') + '`'


def ref(path, line=None):
    suffix = f'#L{line}' if line else ''
    label = path.removeprefix('scripts/') + (f':{line}' if line else '')
    return f'[{label}](../{path}{suffix})'


def render_report(modules):
    modules = sorted(modules, key=lambda item: item['path'])
    digest = hashlib.sha256(''.join(m['path'] + ':' + m['sha256'] + '\n' for m in modules).encode()).hexdigest()
    callbacks = sum(len(m['callbacks']) for m in modules)
    writes = sum(len(m['writes']) for m in modules)
    lines = ['## Generated source inventory\n',
             f'{len(modules)} files; {callbacks} callback registrations; {writes} candidate direct field writes. Source fingerprint: `{digest}`.\n',
             'Counts are lexical findings, not runtime coverage. Helper modules with no matched operations remain listed. See the manual review and scanner limits above.\n',
             '### Candidate overlaps\n',
             'Shared field names require an order/activation review; different receivers may be different entities. Even self-dependent addition and multiplication can be order-sensitive. No row is automatically a confirmed bug.\n',
             '| Field | Modules with direct writes | Review scope |\n|---|---|---|\n']
    fields, states = defaultdict(set), defaultdict(set)
    for module in modules:
        for write in module['writes']:
            fields[write['field']].add(module['path'])
        for state in module['state']:
            states[state['key']].add(module['path'])
    for field, paths in sorted(fields.items()):
        if len(paths) > 1:
            lines.append(f'| {field} | ' + ', '.join(ref(p) for p in sorted(paths)) + ' | Receiver identity, active form, callback phase/priority and source registration order need review. |\n')
    lines.extend(['\n### Shared state-root access\n',
                  'Read/alias access can mutate nested state later; this table does not infer ownership or prove isolation. Whole-table restoration and dynamic keys require manual review.\n',
                  '| Root | Referencing modules |\n|---|---|\n'])
    for key, paths in sorted(states.items()):
        if len(paths) > 1 or key.startswith('['):
            lines.append(f'| {code(key)} | ' + ', '.join(ref(p) for p in sorted(paths)) + ' |\n')
    lines.append('\n### Per-module inventory\n')
    for module in modules:
        path = module['path']
        lines.append(f'\n#### {path}\n\n')
        callbacks = ', '.join(f'{code(c["callback"])} ({code(c["priority"])}, {ref(path, c["line"])})' for c in module['callbacks'])
        lines.append('Callbacks: ' + (callbacks or 'none detected') + '.\n\n')
        lines.append('Cache flag references: ' + (', '.join(code(f) for f in module['cache_flags']) or 'none detected') + '.\n\n')
        if module['writes']:
            lines.append('| Location | Target | RHS | Classification |\n|---|---|---|---|\n')
            for write in module['writes']:
                lines.append(f'| {ref(path, write["line"])} | {code(write["target"])} | {code(write["rhs"])} | {write["mode"]} |\n')
            lines.append('\n')
        else:
            lines.append('Direct tracked-field writes: none detected.\n\n')
        if module['mutators']:
            lines.append('Mutator calls: ' + ', '.join(f'{code(m["method"])} ({ref(path, m["line"])})' for m in module['mutators']) + '.\n\n')
        state_groups = defaultdict(list)
        for state in module['state']:
            state_groups[(state['key'], state['access'])].append(str(state['line']))
        state_text = '; '.join(f'{code(key)} {access} at L' + ', L'.join(locations) for (key, access), locations in sorted(state_groups.items()))
        lines.append('Risk state roots: ' + (state_text or 'none detected') + '.\n')
        if module['limitations']:
            lines.append('\nUnresolved syntax: ' + '; '.join(module['limitations']) + '.\n')
    return '\n'.join(lines).strip() + '\n'


def update_report(root, check):
    path = root / 'docs/INTERACTIONS.md'
    old = path.read_text(encoding='utf-8')
    if old.count(BEGIN) != 1 or old.count(END) != 1 or old.index(BEGIN) >= old.index(END):
        raise ValueError('Expected one ordered generated-inventory marker pair')
    before, rest = old.split(BEGIN)
    _, after = rest.split(END)
    new = before + BEGIN + '\n\n' + render_report(scan_repository(root)) + '\n' + END + after
    if check and new != old:
        raise ValueError('Interaction inventory is stale; run python tools/audit_interactions.py --write and review the diff')
    if not check:
        with path.open('w', encoding='utf-8', newline='\n') as output:
            output.write(new)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument('--write', action='store_true')
    action.add_argument('--check', action='store_true')
    action.add_argument('--json', action='store_true')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    if args.json:
        print(json.dumps(scan_repository(root), indent=2))
    else:
        update_report(root, args.check)
        print('Interaction source inventory ' + ('matches.' if args.check else 'updated; review candidates manually.'))


if __name__ == '__main__':
    main()
