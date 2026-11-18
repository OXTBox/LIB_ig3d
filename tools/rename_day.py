#!/usr/bin/env python3
"""rename_day.py - move one game (or several) to the Rename Day names (RENAME_DAY.md section 3).

    python3 -I LIB_ig3d/tools/rename_day.py GAME ...            show what would change; touch nothing
    python3 -I LIB_ig3d/tools/rename_day.py GAME ... --write    write it
    python3 -I LIB_ig3d/tools/rename_day.py --list              every script with old names, fewest first
    options: --setcam  also turn Engine.SetCam lines into Camera.SetPosition with the signs turned round
                       (each proposed line is printed first: read them all before using it)
             --contract PATH  --projects PATH (folder holding LIB_GAMES ...; default beside LIB_ig3d)

GAME is a script path, or a short name as contract_check.py prints it (Hunter, BatDuel, Ig3dEditor).

What it changes: every old name in the contract's renames table that stands in CODE, as a whole
word, case-insensitively as xTalk reads names, becomes the new name. Code means: not inside a
comment (-- # // /* */) and not inside quoted text, except the quoted name right after
dispatch / send / call (`dispatch "MeshBox"` is a call, so it is renamed).

What it never changes, only lists for the hand:
  - Engine.SetCam (the renames table says `signs`): Camera.SetPosition takes the camera's real place,
    so the three numbers turn round. Without --setcam each line is printed with the line it would become.
  - an old name inside other quoted text (`value("MeshBox(1,2,3)")`, `do "..."`): it may be code
  - an old name the script defines as its own handler (then it is the game's, not the engine's)
It also lists the debts to retire in the same visit (RENAME_DAY.md section 3, wave 4 / A-96):
`the mouseLoc` (Engine.Mouse), writes to gCameraYaw / gCameraPitch (Camera.SetLook), and a
handler of the game's own that finds files (Game.FindFile).

Line endings and everything else in the file are kept byte for byte. Its test: test_rename_day.py.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import contract_check as cc  # noqa: E402

DEBTS = [
    (re.compile(r'\bthe\s+mouseLoc\b', re.I), 'the mouseLoc -> Engine.Mouse()'),
    (re.compile(r'\bput\b.*\binto\s+gCamera(Yaw|Pitch)\b|\b(add|subtract)\b.*\bgCamera(Yaw|Pitch)\b', re.I),
     'writes gCameraYaw/gCameraPitch -> Camera.SetLook'),
    (re.compile(r'^\s*(?:private\s+)?(?:function|command|on)\s+\w*find\w*file\w*', re.I),
     'its own file finder -> Game.FindFile'),
]
QUOTED_CALL = re.compile(r'\b(dispatch|send|call)\s+(?:command\s+|function\s+)?$', re.I)


def regions(text):
    """[(start, end, kind)] covering text: kind 'code', 'string', 'callname' (the quoted name after
    dispatch/send/call, quotes excluded) or 'comment'."""
    out, i, n, start = [], 0, len(text), 0

    def flush(upto, kind='code'):
        if upto > start:
            out.append((start, upto, kind))

    while i < n:
        c = text[i]
        if text.startswith('/*', i):
            flush(i)
            j = text.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.append((i, j, 'comment'))
            i = start = j
        elif text.startswith('--', i) or text.startswith('//', i) or c == '#':
            flush(i)
            j = i
            while j < n and text[j] not in '\r\n':
                j += 1
            out.append((i, j, 'comment'))
            i = start = j
        elif c == '"':
            flush(i)
            j = i + 1
            while j < n and text[j] not in '"\r\n':
                j += 1
            line_start = max(text.rfind('\n', 0, i), text.rfind('\r', 0, i)) + 1
            if QUOTED_CALL.search(text[line_start:i]):
                m = re.match(r'[A-Za-z_][\w.]*', text[i + 1:j])
                if m:
                    out.append((i, i + 1, 'string'))
                    out.append((i + 1, i + 1 + m.end(), 'callname'))
                    out.append((i + 1 + m.end(), min(j + 1, n), 'string'))
                    i = start = min(j + 1, n)
                    continue
            j = min(j + 1, n) if j < n and text[j] == '"' else j
            out.append((i, j, 'string'))
            i = start = j
        else:
            i += 1
    flush(n)
    return out


def word_rx(names):
    alts = sorted((re.escape(x) for x in names), key=len, reverse=True)
    return re.compile(r'(?<![\w.])(' + '|'.join(alts) + r')(?![\w])', re.I)


def split_args(s):
    """top-level comma split (parentheses and quotes respected)"""
    parts, depth, cur, q = [], 0, '', False
    for ch in s:
        if ch == '"':
            q = not q
        elif not q and ch == '(':
            depth += 1
        elif not q and ch == ')':
            depth -= 1
        if ch == ',' and depth == 0 and not q:
            parts.append(cur)
            cur = ''
        else:
            cur += ch
    parts.append(cur)
    return parts


def negate(arg):
    lead = re.match(r'\s*', arg).group(0)
    trail = re.search(r'\s*$', arg).group(0)
    a = arg.strip()
    if a == '' or a.lower() == 'empty':
        return arg
    if re.fullmatch(r'-\s*[\w.]+', a):
        return lead + a[1:].lstrip() + trail
    if re.fullmatch(r'-\s*\(.*\)', a) and _balanced(a.lstrip('-').strip()[1:-1]):
        return lead + a.lstrip('-').strip()[1:-1] + trail
    if re.fullmatch(r'[\w.]+', a):
        return lead + ('0' if a == '0' else '-' + a) + trail
    return lead + '-(' + a + ')' + trail


def _balanced(s):
    d = 0
    for ch in s:
        d += ch == '('
        d -= ch == ')'
        if d < 0:
            return False
    return d == 0


def setcam_line(line, old_span):
    """The Camera.SetPosition line for an `Engine.SetCam a, b, c` line, or None when unsure."""
    s, e = old_span
    rest = line[e:]
    m = re.match(r'(\s+)([^\r\n]*?)(\s*(?:--|#|//).*)?$', rest)
    if not m or not m.group(2).strip():
        return None
    body = m.group(2)
    tail = m.group(3) or ''
    # the call must be the whole statement on the line (no "then ... else" after it)
    if re.search(r'\b(then|else)\b', body, re.I):
        return None
    args = split_args(body)
    if len(args) > 3:
        return None
    return line[:s] + 'Camera.SetPosition' + m.group(1) + ','.join(negate(a) for a in args) + tail


def plan(text, contract, setcam=False):
    """(new text, changes [(line, before, after)], hand [(line, note, text)])"""
    renames = contract.renames
    own = cc.handlers_of(cc.strip_code(text))
    rx = word_rx([v[0] for v in renames.values()])
    regs = regions(text)
    pieces, hand, setcams = [], [], []
    line_of = _line_index(text)
    for s, e, kind in regs:
        chunk = text[s:e]
        if kind in ('comment',):
            pieces.append(chunk)
            continue
        if kind == 'string':
            for m in rx.finditer(chunk):
                hand.append((line_of(s + m.start()), 'old name in quoted text: ' + m.group(1), None))
            pieces.append(chunk)
            continue

        def swap(m, base=s):
            key = m.group(1).lower()
            old, new, how = renames[key]
            if key in own:
                hand.append((line_of(base + m.start()), 'the script has its own handler ' + m.group(1), None))
                return m.group(0)
            if how != 'same':
                setcams.append(base + m.start())
                return m.group(0)
            return new
        pieces.append(rx.sub(swap, chunk))
    new_text = ''.join(pieces)
    # Engine.SetCam: positions in the new text equal positions in the old one only before the first
    # swap, so find them again in the new text by line
    if setcams:
        new_text, hand = _do_setcam(new_text, text, setcams, line_of, hand, setcam)
    changes = _diff(text, new_text)
    hand += _debts(text)
    hand.sort(key=lambda h: h[0])
    return new_text, changes, hand


def _do_setcam(new_text, old_text, positions, line_of, hand, apply):
    nl_split = re.split(r'(\r\n|\r|\n)', new_text)
    lines, seps = nl_split[0::2], nl_split[1::2]
    done = set()
    for pos in positions:
        ln = line_of(pos)
        if ln in done:
            continue
        done.add(ln)
        line = lines[ln - 1]
        m = re.search(r'(?<![\w.])Engine\.SetCam(?![\w])', line, re.I)
        proposal = setcam_line(line, m.span()) if m else None
        if proposal is None:
            hand.append((ln, 'Engine.SetCam: by hand (could not turn the signs safely)', line.strip()))
            continue
        hand.append((ln, 'Engine.SetCam -> ' + ('written' if apply else 'would be'), proposal.strip()))
        if apply:
            lines[ln - 1] = proposal
    out = []
    for i, l in enumerate(lines):
        out.append(l)
        if i < len(seps):
            out.append(seps[i])
    return ''.join(out), hand


def _line_index(text):
    starts = [0] + [m.end() for m in re.finditer(r'\r\n|\r|\n', text)]
    import bisect

    def line_of(pos):
        return bisect.bisect_right(starts, pos)
    return line_of


def _split_lines(text):
    return re.split(r'\r\n|\r|\n', text)


def _diff(a, b):
    la, lb = _split_lines(a), _split_lines(b)
    return [(i + 1, x, y) for i, (x, y) in enumerate(zip(la, lb)) if x != y]


def _debts(text):
    out = []
    lines = cc.strip_code(text)
    for n, line in enumerate(lines, 1):
        for rx, label in DEBTS:
            if rx.search(line):
                out.append((n, 'debt: ' + label, _split_lines(text)[n - 1].strip()))
    return out


def resolve(names, root):
    paths = cc.game_paths(cc.GAMES, root)
    by_short = {}
    for p in paths:
        by_short.setdefault(cc.short_name(p).lower(), p)
    out = []
    for n in names:
        if os.path.exists(n):
            out.append(os.path.abspath(n))
        elif n.lower() in by_short:
            out.append(by_short[n.lower()])
        else:
            raise SystemExit('no script called ' + n)
    return out


def count_old(text, contract):
    rx = word_rx([v[0] for v in contract.renames.values()])
    return sum(len(rx.findall(chunk)) for s, e, k in regions(text) if k in ('code', 'callname')
               for chunk in [text[s:e]])


def main(argv):
    write = setcam = listing = False
    contract_path, root, names = cc.CONTRACT, cc.PROJECTS, []
    it = iter(argv)
    for a in it:
        if a == '--write':
            write = True
        elif a == '--setcam':
            setcam = True
        elif a == '--list':
            listing = True
        elif a == '--contract':
            contract_path = next(it)
        elif a == '--projects':
            root = os.path.abspath(next(it))
        elif a in ('-h', '--help'):
            print(__doc__)
            return 0
        else:
            names.append(a)
    contract = cc.Contract(cc.read(contract_path))
    if not contract.renames:
        print('the contract has no renames table: nothing to do')
        return 2
    if listing:
        rows = []
        for p in cc.game_paths(cc.GAMES, root):
            with open(p, encoding='utf-8', errors='replace', newline='') as f:
                k = count_old(f.read(), contract)
            if k:
                rows.append((k, cc.short_name(p), p))
        for k, s, p in sorted(rows):
            print('%4d  %-28s %s' % (k, s, os.path.relpath(p, root)))
        print('%d places in %d scripts' % (sum(r[0] for r in rows), len(rows)))
        return 0
    if not names:
        print(__doc__)
        return 2
    for path in resolve(names, root):
        with open(path, encoding='utf-8', errors='surrogateescape', newline='') as f:
            text = f.read()
        new, changes, hand = plan(text, contract, setcam)
        print('== %s: %d lines change%s' % (os.path.relpath(path, root), len(changes),
                                          '' if write else ' (dry run)'))
        for n, before, after in changes:
            print('  %5d  - %s' % (n, before.strip()))
            print('         + %s' % after.strip())
        for n, note, line in hand:
            print('  HAND %5d  %s%s' % (n, note, ('\n               ' + line) if line else ''))
        if write and new != text:
            with open(path, 'w', encoding='utf-8', errors='surrogateescape', newline='') as f:
                f.write(new)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
