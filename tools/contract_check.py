#!/usr/bin/env python3
"""contract_check.py - does every game stay inside the engine contract?

    python3 -I LIB_ig3d/tools/contract_check.py              the debts, grouped by kind
    python3 -I LIB_ig3d/tools/contract_check.py --by-game    the same, one block per game
    python3 -I LIB_ig3d/tools/contract_check.py --short      one line per debt (name, games)
    python3 -I LIB_ig3d/tools/contract_check.py --stubs      are the headless stand-ins exactly the contract?
    python3 -I LIB_ig3d/tools/contract_check.py FILE ...     check these scripts only
    options: --contract PATH  --engine PATH (repeatable)  --stubs-file PATH  --strict (exit 1 on any debt)
             --projects PATH (the folder that holds LIB_GAMES, LIB_EDITOR ...; default: beside LIB_ig3d)

It reads LIB_ig3d/ENGINE_CONTRACT.md (the tables under the `<!-- contract:KIND -->` marks) and
every game script, and lists what a game uses that is outside the contract:

  internal   an engine handler that is not a contract call (the game reaches into the engine)
  missing    a contract call the XT engine does not have yet (the game would stop there today)
  unknown    a Name.Call( ) that is no game handler, contract call, engine handler or library
  global     an engine global that is not one of the contract's shared values
  host       a host word the contract lists as a debt (own windows, the cursor, fixed paths...)
  message    a Game.On... handler the engine never sends

The engine scripts are read only to know which names are the engine's. Names inside quoted
strings are not seen, except after dispatch / send / call. Its test: test_contract_check.py.
"""
import collections
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
LIB = os.path.dirname(HERE)                      # LIB_ig3d
PROJECTS = os.path.dirname(LIB)                  # ~/projects
CONTRACT = os.path.join(LIB, 'ENGINE_CONTRACT.md')
ENGINES = ['xt3D_Raylib_Livecode_Bridge/testbench/vibe_engine_xt3d.livecodescript',
           'LIB_DEV/livecode/game_player.livecodescript']
GAMES = ['LIB_GAMES/Vibecode3D_Games/Vibecode3D_Play_*.livecodescript',
         'LIB_GAMES/Vibecode3D_Games/*/*.livecodescript',
         'LIB_GAMES/Vibecode3D_Games/*/*/*.livecodescript',
         'LIB_GAMES/Vibecode3D_Games/*/*/*/*.livecodescript',
         'LIB_EDITOR/iGame3D_XT/Vibecode3D_Play_Ig3dEditor.livecodescript',
         'LIB_EDITOR/iGame3D_XT/Tools/*.livecodescript',
         'LIB_GAD/GeneticAnomaly/*.livecodescript']
STUBS = 'LIB_GAMES/tools/engine_stubs.livecodescript'

HANDLER = re.compile(r'^\s*(?:private\s+)?(on|function|command|getProp|setProp)\s+([A-Za-z_][\w.]*)', re.I)
NAME = re.compile(r'[A-Za-z_][\w.]*')
QUOTED_CALL = re.compile(r'\b(dispatch|send|call)\s+(?:command\s+|function\s+)?"([A-Za-z_][\w.]*)', re.I)
# messages the host sends by itself: an engine handler of this name is not a call a game makes
SYSTEM = set('''preopenstack openstack opencard closecard closestack closestackrequest rawkeydown rawkeyup
keydown keyup arrowkey escapekey escapekeydown mouseup mousedown mousemove mouseenter mouseleave idle
resizestack suspend resume menupick returnkey enterkey tabkey view distance'''.split())
KINDS = ('internal', 'missing', 'unknown', 'global', 'host', 'message')
TITLES = {'internal': 'Engine internals a game calls (not contract calls)',
          'missing': 'Contract calls the XT engine does not have yet',
          'unknown': 'Calls nobody defines',
          'global': 'Engine globals a game reads or writes (not shared values)',
          'host': 'Host words the contract lists as debts',
          'message': 'Game.On... handlers the engine never sends'}


def read(path):
    with open(path, encoding='utf-8', errors='replace') as f:
        return f.read().replace('\r\n', '\n').replace('\r', '\n')


def strip_code(text):
    """The script's lines with comments and the insides of quoted strings removed (line numbers kept).
    A name after dispatch / send / call is kept as a bare word."""
    text = re.sub(r'/\*.*?\*/', lambda m: '\n' * m.group(0).count('\n'), text, flags=re.S)
    out = []
    for line in text.split('\n'):
        line = QUOTED_CALL.sub(lambda m: m.group(1) + ' ' + m.group(2) + ' ""', line)
        line = re.sub(r'"[^"]*"', '""', line)
        line = re.sub(r'(--|#|//).*$', '', line)
        out.append(line)
    return out


def handlers_of(lines):
    found = {}
    for line in lines:
        m = HANDLER.match(line)
        if m:
            found.setdefault(m.group(2).lower(), m.group(2))
    return found


def globals_of(lines):
    found = {}
    for line in lines:
        m = re.match(r'^\s*global\s+(.*)', line, re.I)
        if m:
            for name in m.group(1).split(','):
                name = name.strip()
                if NAME.fullmatch(name):
                    found.setdefault(name.lower(), name)
    return found


class Contract:
    """The contract's tables. A table belongs to the last `<!-- contract:KIND -->` mark above it;
    the name of a row is the first word in the first `code` of its first cell."""

    def __init__(self, text):
        self.calls = {}        # lower name -> (Name, XT cell)
        self.messages = {}
        self.values = {}
        self.properties = {}
        self.libraries = {}    # lower prefix 'bit.' -> where it lives
        self.host = []         # (regex, pattern text, label)
        kind = None
        for line in text.split('\n'):
            m = re.match(r'\s*<!--\s*contract:([a-z-]+)\s*-->', line)
            if m:
                kind = m.group(1)
                continue
            if kind in (None, 'end') or not line.lstrip().startswith('|'):
                continue
            cells = [c.strip() for c in re.split(r'(?<!\\)\|', line.strip().strip('|'))]
            code = re.search(r'`([^`]+)`', cells[0]) if cells else None
            if not code:
                continue
            form = code.group(1).replace('\\|', '|')
            if kind == 'host-debt':
                self.host.append((re.compile(form, re.I), form, cells[1] if len(cells) > 1 else ''))
                continue
            if kind == 'libraries':
                self.libraries[form.lower()] = cells[1] if len(cells) > 1 else ''
                continue
            name = NAME.search(re.sub(r'^(put|get)\s+', '', form))
            if not name:
                continue
            entry = (name.group(0), cells[2].lower() if len(cells) > 2 else '')
            # a name listed twice (Engine.Info and its planned "edition" key): the first row counts
            {'calls': self.calls, 'messages': self.messages, 'values': self.values,
             'properties': self.properties}.get(kind, {}).setdefault(name.group(0).lower(), entry)

    def xt_has(self, key):
        return self.calls[key][1].startswith('yes')

    def is_library(self, key):
        return any(key.startswith(p) for p in self.libraries)


def scan(path, lines, contract, eng_handlers, eng_globals, others):
    """[(kind, name, line number)] for one script."""
    own = handlers_of(lines)
    found = []
    my_globals = {}
    for n, line in enumerate(lines, 1):
        m = HANDLER.match(line)
        if m:
            name = m.group(2)
            if name.lower().startswith('game.on') and name.lower() not in contract.messages:
                found.append(('message', name, n))
            continue
        m = re.match(r'^\s*global\s+(.*)', line, re.I)
        if m:
            for name in m.group(1).split(','):
                name = name.strip()
                key = name.lower()
                if key in eng_globals and key not in contract.values:
                    my_globals.setdefault(key, [eng_globals[key], n, 0])
            continue
        for rx, form, label in contract.host:
            if rx.search(line):
                found.append(('host', label or form, n))
        for t in NAME.finditer(line):
            word = t.group(0).rstrip('.')
            key = word.lower()
            if key in my_globals:
                my_globals[key][2] += 1
                found.append(('global', my_globals[key][0], n))
                continue
            if key in own:
                continue
            if key in contract.calls:
                if not contract.xt_has(key):
                    found.append(('missing', contract.calls[key][0], n))
                continue
            if key in contract.messages or key in contract.values:
                continue
            if key in eng_handlers:
                if key not in SYSTEM:
                    found.append(('internal', eng_handlers[key], n))
                continue
            if '.' in word and re.match(r'[A-Za-z]\w*\.[A-Za-z]', word) and not contract.is_library(key) \
                    and key not in others:
                before = line[:t.start()].rstrip().lower()
                after = line[t.end():].lstrip()
                at_start = before == '' or before.endswith(('then', 'else', 'dispatch', 'send', 'call'))
                if after.startswith('(') or at_start:
                    found.append(('unknown', word, n))
    # a global that is declared and never used is a leftover line, not a reach into the engine
    for key, (name, n, uses) in my_globals.items():
        if uses == 0:
            found.append(('global', name + ' (declared, never used)', n))
    return found


def short_name(path):
    base = os.path.basename(path)
    return base.replace('Vibecode3D_Play_', '').replace('.livecodescript', '')


def check(paths, contract, engine_paths):
    eng_handlers, eng_globals = {}, {}
    for p in engine_paths:
        if os.path.exists(p):
            lines = strip_code(read(p))
            for k, v in handlers_of(lines).items():
                eng_handlers.setdefault(k, v)
            if p == engine_paths[0]:
                eng_globals.update(globals_of(lines))
    stripped = {p: strip_code(read(p)) for p in paths}
    everyone = {}
    for p in paths:
        for k in handlers_of(stripped[p]):
            everyone.setdefault(k, set()).add(p)
    result = {}
    for p in paths:
        others = {k for k, who in everyone.items() if who - {p}}
        result[p] = scan(p, stripped[p], contract, eng_handlers, eng_globals, others)
    return result, bool(eng_handlers)


def grouped(result):
    """kind -> name -> game -> [lines]"""
    g = {k: collections.defaultdict(lambda: collections.OrderedDict()) for k in KINDS}
    for path in result:
        for kind, name, n in result[path]:
            g[kind][name].setdefault(short_name(path), []).append(n)
    return g


def lines_text(nums, most=6):
    text = ','.join(str(n) for n in nums[:most])
    return text + (',+%d more' % (len(nums) - most) if len(nums) > most else '')


def report(result, mode='kind'):
    out = []
    g = grouped(result)
    total = sum(len(names) for names in g.values())
    dirty = sum(1 for p in result if result[p])
    out.append('%d scripts read, %d with debts; %d different debts' % (len(result), dirty, total))
    if mode == 'game':
        for path in result:
            if not result[path]:
                continue
            out.append('')
            out.append(short_name(path))
            per = collections.OrderedDict()
            for kind, name, n in result[path]:
                per.setdefault((kind, name), []).append(n)
            for (kind, name), nums in sorted(per.items(), key=lambda kv: (KINDS.index(kv[0][0]), kv[0][1].lower())):
                out.append('  %-8s %-40s line %s' % (kind, name, lines_text(nums)))
        return '\n'.join(out)
    for kind in KINDS:
        names = g[kind]
        if not names:
            continue
        out.append('')
        out.append('%s (%d)' % (TITLES[kind], len(names)))
        for name in sorted(names, key=lambda k: (-len(names[k]), k.lower())):
            games = names[name]
            if mode == 'short':
                few = ', '.join(list(games)[:4]) + (' +%d more' % (len(games) - 4) if len(games) > 4 else '')
                out.append('  %-40s %2d scripts: %s' % (name, len(games), few))
            else:
                out.append('  %s   (%d scripts)' % (name, len(games)))
                row = '     '
                for game, nums in games.items():
                    item = ' %s:%s;' % (game, lines_text(nums))
                    if len(row) + len(item) > 110:
                        out.append(row)
                        row = '     '
                    row += item
                out.append(row.rstrip(';'))
    return '\n'.join(out)


def check_stubs(path, contract):
    """The stand-ins against the contract. Sections of the stub file are named by lines
    `-- == CONTRACT ==`, `-- == DEBTS ==`, `-- == TEST HOOKS ==`; handlers above any mark count
    as CONTRACT."""
    section = 'contract'
    where = {}
    for raw in read(path).split('\n'):
        m = re.match(r'\s*--\s*==\s*([A-Z ]+?)\s*==', raw)
        if m:
            section = m.group(1).strip().lower()
            continue
        h = HANDLER.match(raw)
        if h:
            where.setdefault(h.group(2).lower(), (h.group(2), section))
    out, bad = [], 0
    have = [c for c in contract.calls if contract.xt_has(c)]
    lacking = sorted(contract.calls[c][0] for c in have if c not in where)
    early = sorted(contract.calls[c][0] for c in contract.calls if not contract.xt_has(c) and c in where)
    extra = sorted(n for k, (n, s) in where.items() if s == 'contract' and k not in contract.calls)
    wrong = sorted(n for k, (n, s) in where.items() if s != 'contract' and k in contract.calls and contract.xt_has(k))
    debts = sorted(n for k, (n, s) in where.items() if s == 'debts')
    hooks = sorted(n for k, (n, s) in where.items() if s not in ('contract', 'debts'))
    out.append('stand-ins: %s' % path)
    out.append('contract calls the XT engine has: %d; stand-ins for them: %d' % (len(have), len(have) - len(lacking)))
    for title, names in (('contract calls with no stand-in', lacking),
                         ('stand-ins for calls the XT engine does not have yet (a test would pass, the game would stop)', early),
                         ('stand-ins in the contract part that are not contract calls', extra),
                         ('contract calls filed under debts or test hooks', wrong)):
        if names:
            bad += len(names)
            out.append('WRONG %s: %s' % (title, ', '.join(names)))
    out.append('debts kept alive for the games that still use them (%d): %s' % (len(debts), ', '.join(debts) or 'none'))
    out.append('test hooks (%d): %s' % (len(hooks), ', '.join(hooks) or 'none'))
    out.append('RESULT: ' + ('the stand-ins are exactly the contract' if bad == 0 else '%d things to fix' % bad))
    return '\n'.join(out), bad


def game_paths(patterns=GAMES, root=PROJECTS):
    paths = []
    for pat in patterns:
        paths += sorted(glob.glob(os.path.join(root, pat)))
    return paths


def main(argv):
    mode, strict, stubs = 'kind', False, False
    contract_path, engines, stubs_file, files, root = CONTRACT, [], None, [], PROJECTS
    it = iter(argv)
    for a in it:
        if a == '--by-game':
            mode = 'game'
        elif a == '--short':
            mode = 'short'
        elif a == '--strict':
            strict = True
        elif a == '--stubs':
            stubs = True
        elif a == '--stubs-file':
            stubs, stubs_file = True, next(it)
        elif a == '--projects':
            root = os.path.abspath(next(it))
        elif a == '--contract':
            contract_path = next(it)
        elif a == '--engine':
            engines.append(next(it))
        elif a in ('-h', '--help'):
            print(__doc__)
            return 0
        else:
            files.append(a)
    contract = Contract(read(contract_path))
    if not contract.calls:
        print('no contract tables found in ' + contract_path)
        return 2
    if stubs:
        text, bad = check_stubs(stubs_file or os.path.join(root, STUBS), contract)
        print(text)
        return 1 if bad else 0
    engines = engines or [os.path.join(root, e) for e in ENGINES]
    paths = files or game_paths(GAMES, root)
    result, has_engine = check(paths, contract, engines)
    print('contract: %d calls (%d the XT engine has), %d messages, %d shared values, %d library prefixes'
          % (len(contract.calls), sum(1 for c in contract.calls if contract.xt_has(c)), len(contract.messages),
             len(contract.values), len(contract.libraries)))
    if not has_engine:
        print('WARNING: no engine script found, so engine internals and engine globals cannot be told apart')
    print(report(result, mode))
    return 1 if strict and any(result.values()) else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
