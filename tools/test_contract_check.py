#!/usr/bin/env python3
"""The checker's own test: a small contract, engine, game and stand-in file made here.

    python3 -I LIB_ig3d/tools/test_contract_check.py
"""
import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import contract_check as cc                   # noqa: E402

CONTRACT = """# test contract
<!-- contract:calls -->
| Call | What | XT | xRay | Box2D |
|---|---|---|---|---|
| `Entity.Spawn(pMesh, pX, pY, pZ, pColor)` | makes one | yes | yes | same |
| `Mesh.AddVertex tMesh, pX, pY, pZ` | a point | yes | yes | same |
| `HUD.Set pId, pText` | text | yes | host | same |
| `Engine.Info(pKey)` | facts | yes | yes | same |
| `Engine.Info("edition")` | planned key: the first row counts | add | add | add |
| `Game.FindFile(pPath)` | planned | add | add | add |
<!-- contract:values -->
| Value | What | XT |
|---|---|---|
| `gCameraYaw` | turn | yes |
<!-- contract:messages -->
| Message | When | XT |
|---|---|---|
| `Game.OnStart` | once | yes |
| `Collision.Hit pA, pB` | touch | yes |
<!-- contract:libraries -->
| Prefix | Where |
|---|---|
| `Map.` | lib_map |
<!-- contract:host-debt -->
| Pattern | What |
|---|---|
| `\\bthe\\s+mouse(Loc\\|H\\|V)\\b` | reads the mouse |
| `^\\s*(answer\\|ask)\\s` | dialog |
<!-- contract:end -->
| `Not.ACall` | a table after the end mark is not read | yes |
"""

ENGINE = """global gCameraYaw, gObjectTransforms, gSceneObjects
function Entity.Spawn pMesh
end Entity.Spawn
on HUD.Set
end HUD.Set
function Engine.Info
end Engine.Info
function Xform.Object pKey
end Xform.Object
on Scene.Register
end Scene.Register
on mouseMove
end mouseMove
on Collision.Hit
end Collision.Hit
"""

GAME = """global gCameraYaw, gObjectTransforms, gSceneObjects
local sId
on Game.OnStart
   put Entity.Spawn("Box", 0, 0, 0, "red") into sId   -- Scene.Register in a comment is not a call
   HUD.Set "a", "Xform.Object in a string is not a call"
   put Xform.Object(sId) into tX
   put 1 into gObjectTransforms[sId]["hp"]
   put Game.FindFile("x.txt") into tF
   if tX is empty then Bogus.Call 1
   put Map.FindPath(1, 2) into tPath
   put Mine.Helper() into tH
   dispatch "Scene.Register" to me
   put the mouseLoc into tM
   answer "hello"
   put Engine.Info("stepMS") into tS
end Game.OnStart
function Mine.Helper
   return gCameraYaw
end Mine.Helper
on Game.OnTeatime
end Game.OnTeatime
on mouseMove
end mouseMove
on Collision.Hit pA, pB
end Collision.Hit
"""

CLEAN = """global gCameraYaw
on Game.OnStart
   get Entity.Spawn("Box", 0, 0, 0, "red")
   HUD.Set "a", "b"
end Game.OnStart
"""

STUBS_GOOD = """script "x"
-- == CONTRACT ==
function Entity.Spawn
end Entity.Spawn
on Mesh.AddVertex
end Mesh.AddVertex
on HUD.Set
end HUD.Set
function Engine.Info
end Engine.Info
-- == DEBTS ==
function Xform.Object
end Xform.Object
-- == TEST HOOKS ==
function Stub.HUD
end Stub.HUD
"""

STUBS_BAD = """script "x"
function Entity.Spawn
end Entity.Spawn
function Game.FindFile
end Game.FindFile
on Scene.Register
end Scene.Register
-- == DEBTS ==
on HUD.Set
end HUD.Set
"""

CHECKS, FAILS = [0], []


def check(name, got, want=True):
    CHECKS[0] += 1
    if got == want:
        print('ok    ' + name)
    else:
        FAILS.append(name)
        print('FAIL  %s  (got %r, want %r)' % (name, got, want))


def main():
    with tempfile.TemporaryDirectory(prefix='contract_check_test_') as tmp:
        def put(name, text):
            path = os.path.join(tmp, name)
            with open(path, 'w', encoding='utf-8') as f:
                f.write(text)
            return path
        engine = put('engine.livecodescript', ENGINE)
        game = put('Vibecode3D_Play_Toy.livecodescript', GAME)
        clean = put('Vibecode3D_Play_Clean.livecodescript', CLEAN)
        contract = cc.Contract(CONTRACT)

        check('reads the calls', sorted(contract.calls), ['engine.info', 'entity.spawn', 'game.findfile', 'hud.set', 'mesh.addvertex'])
        check('a name listed twice: the first row counts', contract.xt_has('engine.info'))
        check('a planned call is not one XT has', contract.xt_has('game.findfile'), False)
        check('reads the values', sorted(contract.values), ['gcamerayaw'])
        check('reads the messages', sorted(contract.messages), ['collision.hit', 'game.onstart'])
        check('reads the library prefixes', sorted(contract.libraries), ['map.'])
        check('reads the host patterns, | unescaped', contract.host[0][1], r'\bthe\s+mouse(Loc|H|V)\b')
        check('nothing is read after the end mark', 'not.acall' in contract.calls, False)

        result, has_engine = cc.check([game, clean], contract, [engine])
        check('the engine script was read', has_engine)
        found = {(k, n): line for k, n, line in reversed(result[game])}
        check('an engine internal is found, with its line', found.get(('internal', 'Xform.Object')), 6)
        check('a quoted name after dispatch is found', found.get(('internal', 'Scene.Register')), 12)
        check('names in comments and strings are not calls',
              [n for k, n, line in result[game] if k == 'internal' and line in (4, 5)], [])
        check('a planned call XT lacks is found', found.get(('missing', 'Game.FindFile')), 8)
        check('a call nobody defines is found', found.get(('unknown', 'Bogus.Call')), 9)
        check('a library call passes', ('unknown', 'Map.FindPath') in found, False)
        check("the game's own handler passes", ('unknown', 'Mine.Helper') in found, False)
        check('an engine global in use is found', found.get(('global', 'gObjectTransforms')), 7)
        check('an engine global only declared is told apart',
              found.get(('global', 'gSceneObjects (declared, never used)')), 1)
        check('a shared value passes', [n for k, n, line in result[game] if n.startswith('gCameraYaw')], [])
        check('a host debt is found', found.get(('host', 'reads the mouse')), 13)
        check('a dialog is found', found.get(('host', 'dialog')), 14)
        check('a Game.On... the engine never sends is found', found.get(('message', 'Game.OnTeatime')), 20)
        check('a system message is not a call', [n for k, n, line in result[game] if n.lower() == 'mousemove'], [])
        check('answering Collision.Hit is not a debt', [n for k, n, line in result[game] if n == 'Collision.Hit'], [])
        check('a contract call with a known key passes', [n for k, n, line in result[game] if n == 'Engine.Info'], [])
        check('a clean game has no debts', result[clean], [])
        check('how many debts the toy game has', len(result[game]), 9)

        for mode in ('kind', 'short', 'game'):
            text = cc.report(result, mode)
            check('the %s report names the game and the debt' % mode, 'Toy' in text and 'Xform.Object' in text)
        check('the full report gives the line', 'Toy:6' in cc.report(result, 'kind'))

        text, bad = cc.check_stubs(put('good.livecodescript', STUBS_GOOD), contract)
        check('good stand-ins: nothing to fix', bad, 0)
        check('good stand-ins: the debt kept alive is listed', 'Xform.Object' in text)
        text, bad = cc.check_stubs(put('bad.livecodescript', STUBS_BAD), contract)
        check('bad stand-ins: five things to fix', bad, 5)
        check('bad: a contract call with no stand-in', 'no stand-in: Engine.Info, Mesh.AddVertex' in text)
        check('bad: a stand-in for a planned call', 'the game would stop): Game.FindFile' in text)
        check('bad: a stand-in that is no contract call', 'not contract calls: Scene.Register' in text)
        check('bad: a contract call filed under debts', 'under debts or test hooks: HUD.Set' in text)

        code = cc.main(['--contract', put('c.md', CONTRACT), '--engine', engine, '--strict', game])
        check('--strict exits 1 on a debt', code, 1)
        code = cc.main(['--contract', os.path.join(tmp, 'c.md'), '--engine', engine, '--strict', clean])
        check('--strict exits 0 on a clean game', code, 0)

        # Rename Day: the renames table, old names, the alias file, the generated files
        import make_names as mn
        renamed = CONTRACT.replace('<!-- contract:values -->', """| `Entity.SetPosition pId, pX, pY, pZ` | puts it there | yes | yes | same |
| `Mesh.Box(pW, pH, pD)` | a box | yes | yes | same |
| `Camera.SetPosition pX, pY, pZ` | the camera's place | yes | yes | same |
| `Camera.SetLook pYaw` | planned | add | add | add |
<!-- contract:values -->""") + """
<!-- contract:renames -->
| Old name | New name | Alias |
|---|---|---|
| `SetObjectPosition` | `Entity.SetPosition` | same |
| `MeshBox` | `Mesh.Box` | same |
| `Engine.SetCam` | `Camera.SetPosition` | signs |
| `Engine.SetLook` | `Camera.SetLook` | same |
<!-- contract:end -->
"""
        rc = cc.Contract(renamed)
        check('reads the renames', sorted(rc.renames), ['engine.setcam', 'engine.setlook', 'meshbox', 'setobjectposition'])
        check('a rename keeps old, new and how', rc.renames['engine.setcam'], ('Engine.SetCam', 'Camera.SetPosition', 'signs'))
        check('the rows keep form and meaning', [r['meaning'] for r in rc.rows if r['name'] == 'Mesh.Box'], ['a box'])
        old_game = put('Vibecode3D_Play_Old.livecodescript', """on Game.OnStart
   SetObjectPosition "a", 1, 2, 3
   put MeshBox(1, 2, 3) into tM
   Entity.SetPosition "a", 1, 2, 3
end Game.OnStart
""")
        result, has_engine = cc.check([old_game], rc, [engine])
        check('an old name is found, with the new one', [(k, n, l) for k, n, l in result[old_game]],
              [('oldname', 'SetObjectPosition (now Entity.SetPosition)', 2), ('oldname', 'MeshBox (now Mesh.Box)', 3)])
        text = cc.report(result, 'kind')
        check('old names are counted apart from the debts', '0 with debts; 0 different debts' in text
              and 'old names (Rename Day): 2 places in 1 scripts' in text)
        rpath = put('r.md', renamed)
        check('--strict passes over old names', cc.main(['--contract', rpath, '--engine', engine, '--strict', old_game]), 0)
        check('--strict-names does not', cc.main(['--contract', rpath, '--engine', engine, '--strict-names', old_game]), 1)

        files, problems = mn.build(rc)
        ali = files['livecode/contract_aliases.livecodescript']
        check('aliases: nothing wrong in the table', problems, [])
        check('aliases: a command passes straight through',
              'on Entity.SetPosition pId, pX, pY, pZ\n   SetObjectPosition pId, pX, pY, pZ\n   return the result\nend Entity.SetPosition' in ali)
        check('aliases: a function returns the old one', 'function Mesh.Box pW, pH, pD\n   return MeshBox(pW, pH, pD)\nend Mesh.Box' in ali)
        check('aliases: signs turned round, empty left alone',
              'if pX is a number then put 0 - pX into pX' in ali and '   Engine.SetCam pX, pY, pZ' in ali)
        check('aliases: none for a planned call', 'Camera.SetLook' in ali, False)
        words = files['Data/contract_words.txt']
        check('words: a call line', 'call\tEntity\tEntity.SetPosition\tEntity.SetPosition pId, pX, pY, pZ\tno\tyes\tSetObjectPosition\tpId\tputs it there' in words)
        check('words: a function, planned', 'call\tGame\tGame.FindFile\tGame.FindFile(pPath)\tyes\tplanned\t\tpPath\tplanned' in words)
        check('words: a message and a value', 'message\tGame\tGame.OnStart\t' in words and 'value\tValue\tgCameraYaw\t' in words)
        check('words: a name listed twice comes once', words.count('\tEngine.Info\t'), 1)
        check('menu: Head/Sub/Item', 'handler: ContractMenuPick\n' in files['Data/Menus/Contract.txt']
              and 'Contract/Entity/Entity.SetPosition\n' in files['Data/Menus/Contract.txt'])
        bad_table = cc.Contract(renamed.replace('| `MeshBox` | `Mesh.Box` | same |', '| `MeshBox` | `Mesh.Cube` | same |'))
        check('a rename to a name with no row is said', mn.build(bad_table)[1], ['renames: Mesh.Cube has no row in the call tables'])

        # (the old handlers go first: handlers above any mark are in the contract part)
        stubs_old = put('old.livecodescript', """on SetObjectPosition
end SetObjectPosition
function MeshBox
end MeshBox
on Engine.SetCam
end Engine.SetCam
""" + STUBS_GOOD)
        text, bad = cc.check_stubs(stubs_old, rc, put('aliases.livecodescript', ali))
        check('stand-ins with old names + the alias file: nothing to fix', bad, 0)
        check('...and the new names reached through it are listed', 'through the alias file (3)' in text)
        text, bad = cc.check_stubs(stubs_old, rc, os.path.join(tmp, 'no_such_file'))
        check('without the alias file the new names have no stand-in', bad, 3)

        out = os.path.join(tmp, 'out')
        check('make_names writes', mn.main(['--contract', rpath, '--out', out]), 0)
        check('make_names --check: fresh', mn.main(['--contract', rpath, '--out', out, '--check']), 0)
        with open(os.path.join(out, 'Data', 'contract_words.txt'), 'a') as f:
            f.write('edited by hand\n')
        check('make_names --check: a hand edit is caught', mn.main(['--contract', rpath, '--out', out, '--check']), 1)
        # the real files: what is committed is what the real contract says today
        check('THE REAL FILES are what ENGINE_CONTRACT.md says (else run tools/make_names.py)', mn.main(['--check']), 0)

    print('\n%d of %d passed' % (CHECKS[0] - len(FAILS), CHECKS[0]))
    return 1 if FAILS else 0


if __name__ == '__main__':
    sys.exit(main())
