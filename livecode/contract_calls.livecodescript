script "ContractCalls"
-- The engine contract's calls that the owner's engine script does not have itself
-- (LIB_ig3d/ENGINE_CONTRACT.md, TODO A-93, A-96). Hand-written; not generated.
--
-- Engine 1 (pure xTalk). xt3d's tools/make_vibe_xt3d.py appends this file to the Vibecode3D
-- engine after vibe_xt3d_overrides.livecodescript, the same way: a handler here that the
-- engine also has replaces it (the engine's becomes Vibe.Orig.<name>), and every handler
-- shares the engine's script locals. So XT (the Game Player) and xRay (the xt3d bench) get
-- these from one place. The engine source in Vibecode3D is not touched.
--
-- Names are the final ones (Rename Day): no old names, no aliases.
-- Hosts may set two globals before Game.OnStart:
--   gV3DEdition   "XT" (empty means XT), "xRay", "Box2DXT", "xRayBox"
--   gV3DHas       the optional parts this host has, comma separated: physics, sound, models

------------------------------------------------------------------------- the camera

## Turns the camera, radians. Yaw: 0 looks along +Z, positive turns right. Pitch: positive
## looks up. Roll: positive tips the picture clockwise. An empty number leaves that turn alone.
on Camera.SetLook pYaw, pPitch, pRoll
   global gCameraYaw, gCameraPitch, gCameraRoll
   if pYaw is a number then put pYaw into gCameraYaw
   if pPitch is a number then put pPitch into gCameraPitch
   if pRoll is a number then put pRoll into gCameraRoll
end Camera.SetLook

## Where a world point shows: "x,y" in the same pixels Game.OnClick gets and
## Camera.ScreenToFloor takes, or empty when it is behind the camera.
function Camera.WorldToScreen pX, pY, pZ
   local tP, tS
   if pX is not a number or pY is not a number or pZ is not a number then return empty
   Render.FrameMatrices
   put Mat3.Apply(sCamM, pX, pY, pZ) into tP
   put ProjectVertex((word 1 of tP) + (word 1 of sFrameT), \
         (word 2 of tP) + (word 2 of sFrameT), \
         (word 3 of tP) + (word 3 of sFrameT)) into tS
   if tS is empty then return empty
   return (word 1 of tS) & comma & (word 2 of tS)
end Camera.WorldToScreen

## REPLACES the engine's: the camera turn with roll after pitch and yaw.
## Roll 0 (every game today) gives exactly the engine's own matrix.
function Mat3.Camera
   global gCameraRoll
   local tC, tS
   if gCameraRoll is not a number or gCameraRoll = 0 then return Vibe.Orig.Mat3.Camera()
   put cos(gCameraRoll) into tC
   put sin(gCameraRoll) into tS
   return Mat3.Mul(tC & comma & -tS & comma & 0 & comma & tS & comma & tC & comma & 0 & ",0,0,1", \
         Vibe.Orig.Mat3.Camera())
end Mat3.Camera

## REPLACES the engine's: Camera.Reset (its alias) also levels the roll.
on Engine.ResetCamera
   global gCameraRoll
   Vibe.Orig.Engine.ResetCamera
   put 0 into gCameraRoll
end Engine.ResetCamera

## REPLACES the engine's: a new game starts with no roll.
on init.globals
   global gCameraRoll
   Vibe.Orig.init.globals
   put 0 into gCameraRoll
end init.globals

------------------------------------------------------------------------- objects

## The ids of the living objects, one a line; with a mesh name, only those drawn with it.
function Scene.Objects pMesh
   global gSceneObjects
   local tOut, tEntry
   repeat for each line tEntry in gSceneObjects
      if pMesh is empty or word 1 of tEntry is pMesh then put word 2 of tEntry & cr after tOut
   end repeat
   delete the last char of tOut
   return tOut
end Scene.Objects

## Draws the object with another mesh from now on. Its radius becomes the new mesh's
## (Entity.Set pId, "radius" afterwards to keep another). the result: empty, or why not.
on Entity.SetMesh pId, pMesh
   global gSceneObjects, gObjectTransforms
   local tOut, tEntry, tFound, tMesh
   if not Mesh.Has(pMesh) then return "Entity.SetMesh: no mesh" && pMesh
   put false into tFound
   repeat for each line tEntry in gSceneObjects
      if word 2 of tEntry is pId and pId is not empty then
         put pMesh into word 1 of tEntry
         put true into tFound
      end if
      put tEntry & cr after tOut
   end repeat
   if not tFound then return "Entity.SetMesh: no object" && pId
   delete the last char of tOut
   put tOut into gSceneObjects
   put pMesh into gObjectTransforms[pId]["mesh"]
   put Mesh.Get(pMesh) into tMesh
   if tMesh["radius"] is a number then put tMesh["radius"] into gObjectTransforms[pId]["radius"]
   return empty
end Entity.SetMesh

## Sets a value the engine understands: hp (hits it takes before it explodes), ttl (steps
## until the engine removes it), radius (units, for collisions). Empty clears hp or ttl.
## the result: empty, or why not.
on Entity.Set pId, pProp, pValue
   global gObjectTransforms
   if not Scene.Has(pId) then return "Entity.Set: no object" && pId
   if pProp is not among the items of "hp,ttl,radius" then return "Entity.Set: not a property:" && pProp & " (hp, ttl, radius)"
   if pValue is empty and pProp is not "radius" then
      delete variable gObjectTransforms[pId][pProp]
      return empty
   end if
   if pValue is not a number then return "Entity.Set:" && pProp && "takes a number"
   put pValue into gObjectTransforms[pId][pProp]
   return empty
end Entity.Set

## Reads one back: hp, ttl, radius, mesh, group. Empty when the object is gone.
function Entity.Get pId, pProp
   global gObjectTransforms
   if not Scene.Has(pId) then return empty
   if pProp is not among the items of "hp,ttl,radius,mesh,group" then return empty
   return gObjectTransforms[pId][pProp]
end Entity.Get

------------------------------------------------------------------------- meshes

## True when a mesh of that name is defined (Mesh.Define, or one of the stack's own meshes).
function Mesh.Has pName
   global gMeshCache
   local tKeys, tErr
   if pName is empty then return false
   if gMeshCache[pName]["count"] is a number then return true
   try
      put the customKeys of stack (the mainStack of this stack) into tKeys
   catch tErr
      return false
   end try
   return ("xyz" & pName & "Array") is among the lines of tKeys
end Mesh.Has

------------------------------------------------------------------------- the engine

## REPLACES the engine's: adds "edition" (XT, xRay, Box2DXT, xRayBox).
function Engine.Info pKey
   global gV3DEdition
   if pKey is "edition" then
      if gV3DEdition is empty then return "XT"
      return gV3DEdition
   end if
   return Vibe.Orig.Engine.Info(pKey)
end Engine.Info

## True when this edition has an optional part: physics, sound, models. The host says
## which (gV3DHas); none does yet, so every game plays on without them.
function Engine.Has pFeature
   global gV3DHas
   if pFeature is empty then return false
   return pFeature is among the items of gV3DHas
end Engine.Has

## "x,y,down": the mouse in the same pixels Game.OnClick gets, and true while its button
## is held. Empty while an AI tests (gNoMouse).
function Engine.Mouse
   global gNoMouse
   local tLoc
   if gNoMouse is true then return empty
   put the mouseLoc into tLoc
   if tLoc is empty then return empty
   return tLoc & comma & (the mouse is down)
end Engine.Mouse

## The full path of one of the game's files, or empty. pPath is written from the projects
## folder ("LIB_GAMES/Vibecode3D_Games/Antack/antack_data.txt"). Looks in the game's own
## folder (the player's uScriptFile), then "Vibecode3D Common" beside it, then upward from
## the game's stack and from this engine, then the projects folder on WSL unless bNoWSL
## (LIB_PUBLIC/install/LAYOUT.md 5.1). The games' own copies (Face.FindFile ...) do the same.
function Game.FindFile pPath
   global bNoWSL
   local tShort, tDir, tTry, tErr, tStart
   if pPath is empty then return empty
   put pPath into tShort
   if tShort begins with "LIB_GAMES/Vibecode3D_Games/" then delete char 1 to 27 of tShort
   set the itemDel to "/"
   put empty into tDir
   try
      put the uScriptFile of this stack into tDir
   catch tErr
      put empty into tDir
   end try
   replace "\" with "/" in tDir
   if tDir contains "/" then
      delete item -1 of tDir
      put tDir & "/" & tShort into tTry
      if there is a file tTry then return tTry
      put item 1 to -2 of tDir & "/Vibecode3D Common/" into tTry
      if there is a file (tTry & pPath) then return tTry & pPath
      if there is a file (tTry & tShort) then return tTry & tShort
   end if
   repeat with tStart = 1 to 2
      if tStart is 1 then
         put the effective filename of this stack into tDir
      else
         put the effective filename of me into tDir
      end if
      replace "\" with "/" in tDir
      repeat 6 times
         delete item -1 of tDir
         if tDir is empty then exit repeat
         put tDir & "/" & pPath into tTry
         if there is a file tTry then return tTry
      end repeat
   end repeat
   if bNoWSL is true then return empty
   put "//wsl$/Ubuntu/home/igame3d/projects/" & pPath into tTry
   if there is a file tTry then return tTry
   put "/home/igame3d/projects/" & pPath into tTry
   if there is a file tTry then return tTry
   return empty
end Game.FindFile
