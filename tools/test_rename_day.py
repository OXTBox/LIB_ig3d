#!/usr/bin/env python3
"""test_rename_day.py - checks rename_day.py on small made-up scripts. python3 -I test_rename_day.py"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import contract_check as cc  # noqa: E402
import rename_day as rd  # noqa: E402

CONTRACT = cc.Contract(cc.read(cc.CONTRACT))
passed = failed = 0


def ck(name, got, want):
    global passed, failed
    if got == want:
        passed += 1
    else:
        failed += 1
        print('FAIL %s\n   got:  %r\n   want: %r' % (name, got, want))


def new(text, setcam=False):
    return rd.plan(text, CONTRACT, setcam)[0]


def notes(text, setcam=False):
    return [h[1] for h in rd.plan(text, CONTRACT, setcam)[2]]


ck('plain call', new('   SetObjectPosition tId, 1, 2, 3\n'), '   Entity.SetPosition tId, 1, 2, 3\n')
ck('function call', new('put MeshBox(1,2,3) into t\n'), 'put Mesh.Box(1,2,3) into t\n')
ck('case as xTalk reads it', new('meshbox(1,2,3)\n'), 'Mesh.Box(1,2,3)\n')
ck('dotted old name', new('Engine.ResetCamera\n'), 'Camera.Reset\n')
ck('Scene. moves to Entity.', new('Scene.SetBob tId, 3\nif Scene.Has(t) then\n'),
   'Entity.SetBob tId, 3\nif Entity.Exists(t) then\n')
ck('a longer word is not touched', new('MeshBoxes(1)\nmyMeshBox\nX.MeshBox\n'), 'MeshBoxes(1)\nmyMeshBox\nX.MeshBox\n')
ck('comment not touched', new('-- SetObjectPosition here\n# MeshBox\n// MeshBox\n'),
   '-- SetObjectPosition here\n# MeshBox\n// MeshBox\n')
ck('after code, the comment is kept', new('MeshBox(1) -- MeshBox\n'), 'Mesh.Box(1) -- MeshBox\n')
ck('block comment', new('/* MeshBox\nMeshBox */ MeshBox(1)\n'), '/* MeshBox\nMeshBox */ Mesh.Box(1)\n')
ck('quoted text not touched', new('put "MeshBox" into t\n'), 'put "MeshBox" into t\n')
ck('...but listed', notes('put value("MeshBox(1,2,3)") into t\n'), ['old name in quoted text: MeshBox'])
ck('dispatch name is a call', new('dispatch "SetObjectPosition" to me with a\n'),
   'dispatch "Entity.SetPosition" to me with a\n')
ck('send name is a call', new('send "Engine.ResetCamera" to me in 1 tick\n'), 'send "Camera.Reset" to me in 1 tick\n')
ck('CRLF kept', new('MeshBox(1)\r\nMeshGrid(2)\r\n'), 'Mesh.Box(1)\r\nMesh.Grid(2)\r\n')
ck('CR kept', new('MeshBox(1)\rMeshGrid(2)\r'), 'Mesh.Box(1)\rMesh.Grid(2)\r')
ck('own handler not touched', new('function MeshBox p\nend MeshBox\nput MeshBox(1) into t\n'),
   'function MeshBox p\nend MeshBox\nput MeshBox(1) into t\n')
ck('a new name stays', new('Entity.SetPosition t, 1, 2, 3\n'), 'Entity.SetPosition t, 1, 2, 3\n')
# Engine.SetCam: listed, written only with --setcam, the signs turned round
ck('SetCam untouched without --setcam', new('   Engine.SetCam 0, 470, 380\n'), '   Engine.SetCam 0, 470, 380\n')
ck('SetCam listed', notes('   Engine.SetCam 0, 470, 380\n'), ['Engine.SetCam -> would be'])
ck('SetCam numbers', new('   Engine.SetCam 0, 470, 380\n', True), '   Camera.SetPosition 0, -470, -380\n')
ck('SetCam minus vars', new('Engine.SetCam -sCX, -sCY, -sCZ\n', True), 'Camera.SetPosition sCX, sCY, sCZ\n')
ck('SetCam mixed', new('Engine.SetCam 0, -sCamY, 0 -- look\n', True), 'Camera.SetPosition 0, sCamY, 0 -- look\n')
ck('SetCam expression', new('Engine.SetCam -sX, tH + 40, -(sZ - 9)\n', True), 'Camera.SetPosition sX, -(tH + 40), sZ - 9\n')
ck('SetCam empty axis stays', new('Engine.SetCam , 200, \n', True), 'Camera.SetPosition , -200, \n')
ck('SetCam call in an expression', new('Engine.SetCam -item 1 of t, 2, 3\n', True),
   'Camera.SetPosition -(-item 1 of t), -2, -3\n')
ck('SetCam after then: by hand', new('if a then Engine.SetCam 1, 2, 3 else Engine.SetCam 4, 5, 6\n', True),
   'if a then Engine.SetCam 1, 2, 3 else Engine.SetCam 4, 5, 6\n')
ck('debt: mouseLoc', notes('put the mouseLoc into t\n'), ['debt: the mouseLoc -> Engine.Mouse()'])
ck('debt: camera yaw', notes('put 0 into gCameraYaw\n'), ['debt: writes gCameraYaw/gCameraPitch -> Camera.SetLook'])
ck('count', rd.count_old('MeshBox(1) -- MeshBox\nput "MeshBox" into t\nEngine.SetCam 1,2,3\n', CONTRACT), 2)
print('%d passed, %d failed' % (passed, failed))
sys.exit(1 if failed else 0)
