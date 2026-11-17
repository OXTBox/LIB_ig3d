# The engine contract

Monday, November 16, 2026. Draft 1, by Fable 5.2, for the owner to correct.
Branch `engine-contract` (LIB_ig3d and LIB_GAMES). Checker: `tools/contract_check.py`.

One game script should run on all four editions:

| Edition | What it is |
|---|---|
| **iGame3D XT** | the xTalk engine draws the picture itself (vector lines) |
| **iGame3D xRay** | the same game rules, raylib (xt3d) draws |
| **iGame3D Box2DXT** | XT with Box2D physics |
| **iGame3D xRayBox** | xRay with Box2D physics |

The contract is the list of things a game may say to an engine, and the things an engine may
say to a game. A game that uses only what is listed here runs on every edition; an edition is
finished when it answers everything listed here the same way. Anything else a game touches is a
**debt** (section 12): it works today on XT by luck of how XT is built inside.

"XT today" means the engine the Game Player loads
(`xt3D_Raylib_Livecode_Bridge/testbench/vibe_engine_xt3d.livecodescript`: the Vibecode3D engine
plus `vibe_xt3d_overrides.livecodescript`) together with the player
(`LIB_DEV/livecode/game_player.livecodescript`). The xRay column was filled in by reading the
code, not by running xRay; the Box2D editions do not exist yet.

## 0. How to read the tables

- `yes` the edition has it. `add` it must be added. `same` as the edition it is built on
  (Box2DXT on XT, xRayBox on xRay). `host` the shared xTalk rules already do it, and the part
  that draws or plays must do its half.
- The checker reads these tables: the first `code` in a row is the name. Rows whose XT cell is
  `add` are planned calls; a game must not use them until XT has them (the checker says so).
- A name listed twice (`Engine.Info` and its planned `"edition"` key): the first row counts.
- Do not remove the `<!-- contract:... -->` marks: they tell the checker what each table is.

## 1. The world

| Thing | Rule |
|---|---|
| Lengths | engine units. **10 units = 1 metre** (`constant kM = 10` in a game). |
| Axes | +X right, **+Y down** (up is negative y: a thing 2 m above the floor is at y = -20), +Z away from the camera at yaw 0. |
| Angles | radians. An object's rotation is applied Z, then Y, then X. |
| Time | the engine steps the game every **33 ms** (about 30 steps a second), in fixed steps. Speeds are units per step, rotation speeds radians per step. Count steps, not milliseconds. |
| Colours | a name (`white black red green blue yellow orange cyan magenta purple`), `#RRGGBB`, or `r,g,b`. |
| Screen | pixels in the game's view, x right, y down; the view's edges are the shared values `gViewLeft` ... (section 9). |
| Ids | `Entity.Spawn` returns the object's id (text). A game keeps the id; it never builds one. |
| A mesh | a wire shape: points, faces (polygons of any size) and loose lines. Built once, named with `Mesh.Define`, then used by any number of objects. |

## 2. Scene

<!-- contract:calls -->
| Call | What it does, units, what it gives back | XT | xRay | Box2D editions |
|---|---|---|---|---|
| `Scene.ClearAll` | removes every object. Call it first in `Game.OnStart`. | yes | yes | same |
| `Scene.Has(pId)` | true while the object exists (from `Entity.Spawn` until `Entity.Kill`, an explosion or a kill). | yes | yes | same |
| `Scene.Objects(pMesh)` | the ids of the living objects, one a line; with a mesh name, only the objects drawn with it. | add | add | add |
| `Scene.SetBob pId, pAmp, pRoll, pSpeed` | the object floats: up and down pAmp units around where it is now, rocking pRoll radians, pSpeed radians a step. | yes | yes | same |
| `Scene.SetBounds pId, pBounds` | keeps a drifting object inside `xmin,xmax,zmin,zmax` (units): it bounces off the edges. | yes | yes | same |

## 3. Meshes

Makers give back a raw mesh; `Mesh.Transform` and `Mesh.Merge` work on raw meshes;
`Mesh.Define` names one so objects can use it. A game treats a mesh as a closed box: it only
passes it to these calls.

| Call | What it does, units, what it gives back | XT | xRay | Box2D editions |
|---|---|---|---|---|
| `Mesh.New()` | an empty mesh. | yes | yes | same |
| `Mesh.AddVertex tMesh, pX, pY, pZ` | adds a point (units, mesh's own centre = 0,0,0). The point's number is in `the result` (first point is 1). | yes | yes | same |
| `Mesh.AddFace tMesh, pIndices` | adds a polygon: point numbers with spaces, in order round it (`"1 2 3 4"`). Faces can be hit by the laser. | yes | yes | same |
| `Mesh.AddLine tMesh, pA, pB` | adds a loose line between two points (drawn, never hit). | yes | yes | same |
| `Mesh.Define pName, tMesh` | names the finished mesh. Defining a name again replaces it. A skin (the player's business) may swap in a model of the same size. | yes | host | same |
| `Mesh.Get(pName)` | the named mesh, finished. Its `["radius"]` (units from its centre to its farthest point) and `["count"]` may be read. | yes | yes | same |
| `Mesh.Has(pName)` | true when a mesh of that name is defined. | add | add | add |
| `Mesh.Transform(tMesh, pRX, pRY, pRZ, pTX, pTY, pTZ, pScale)` | a copy turned (radians), scaled (empty = 1), then moved (units). | yes | yes | same |
| `Mesh.Merge(tA, tB)` | mesh A with mesh B added. | yes | yes | same |
| `MeshBox(pW, pH, pD)` | a box centred on 0,0,0: width (x), height (y), depth (z) in units. | yes | yes | same |
| `MeshPrism(pSides, pRadius, pHeight)` | a prism standing on the y axis, centred (6 to 8 sides reads as a cylinder). | yes | yes | same |
| `MeshPyramid(pSides, pRadius, pHeight)` | a pyramid or cone: base at +height/2 (the bottom), tip at -height/2 (the top). | yes | yes | same |
| `MeshLathe(pProfile, pSides)` | a profile spun round the y axis. Profile: `radius,y` points from top to bottom, `\|` between points. | yes | yes | same |
| `MeshSphere(pRadius, pRings, pSides)` | a low-count ball. | yes | yes | same |
| `MeshLoft(pOutlineA, pYA, pOutlineB, pYB)` | two outlines seen from above (`x,z` points, same count) joined at two heights: hulls, wings. | yes | yes | same |
| `MeshExtrude(pOutline, pDepth)` | a flat outline (`x,y` points, front view) pushed pDepth units along z, centred: letters, panels. | yes | yes | same |
| `MeshGrid(pCols, pRows, pSpacing)` | a flat grid on the floor plane, centred; pSpacing units a square. | yes | yes | same |

## 4. Entities (the objects in the scene)

| Call | What it does, units, what it gives back | XT | xRay | Box2D editions |
|---|---|---|---|---|
| `Entity.Spawn(pMesh, pX, pY, pZ, pColor)` | a new object drawn with the named mesh at that place (units), at rest, not turned. Gives back its id. | yes | yes | same; a body too when the game asks (section 11) |
| `Entity.Kill pId` | removes it at once, no effect. Killing an id that is gone does nothing. | yes | yes | same |
| `Entity.Count(pMesh)` | how many living objects are drawn with that mesh. | yes | yes | same |
| `Entity.SetMesh pId, pMesh` | draws the object with another mesh from now on (a hill that shrinks, a door that opens). | add | add | add |
| `Entity.Set pId, pProp, pValue` | sets a value the engine understands: `hp` (hits it can take from the laser or a default collision), `ttl` (steps until the engine removes it), `radius` (units, for collisions). A game's own facts about an object belong in the game's own variables. | add | add | add |
| `Entity.Get(pId, pProp)` | reads one back (`hp`, `ttl`, `radius`, `mesh`, `group`); empty when the object is gone. | add | add | add |
| `SetObjectPosition pId, pX, pY, pZ` | puts it there (units). An empty number is 0. | yes | yes | same; moves the body |
| `GetObjectPosition(pId, pAxis)` | `x,y,z`; with pAxis `"x"`, `"y"` or `"z"`, that one number. | yes | yes | same; the body's place |
| `SetObjectRotation pId, pRX, pRY, pRZ` | turns it (radians about x, y, z). | yes | yes | same |
| `GetObjectRotation(pId)` | `rx,ry,rz` (0 for any never set). | yes | yes | same |
| `SetObjectRotationSpeed pId, pRX, pRY, pRZ` | keeps it turning: radians a step. | yes | yes | same |
| `GetObjectRotationSpeed(pId)` | `rx,ry,rz`. | yes | yes | same |
| `SetObjectVelocity pId, pVX, pVY, pVZ` | keeps it moving: units a step, in world directions. The engine moves it each step. Give three numbers only (XT's fifth parameter is broken). | yes | yes | same; the body's speed |
| `GetObjectVelocity(pId)` | `vx,vy,vz`. | yes | yes | same |

## 5. Camera, the view, and the engine itself

| Call | What it does, units, what it gives back | XT | xRay | Box2D editions |
|---|---|---|---|---|
| `Engine.ResetCamera` | a plain camera: at 0,0,0, looking along +Z, no turn, no zoom. Call it in `Game.OnStart`. | yes | yes | same |
| `Engine.SetCam pX, pY, pZ` | moves the WORLD by x,y,z (units), so a camera standing at cx,cy,cz is `Engine.SetCam -cx, -cy, -cz`. An empty number leaves that axis alone. Turning is the shared values `gCameraYaw`, `gCameraPitch` (section 9). | yes | yes | same |
| `Engine.Info(pKey)` | `"stepMS"`: 33. `"simTick"`: steps since the engine started. `"projection"`: `k,offX,offY`: a point x,y,z in front of an unturned camera shows at screen `x*k/z + offX`, `y*k/z + offY`. `"fps"`, `"playing"`, `"paused"`. Any other key: empty. | yes | yes | same |
| `Engine.Info("edition")` | `XT`, `xRay`, `Box2DXT` or `xRayBox` (the same call as above with a new key; XT answers empty today). | add | add | add |
| `Engine.Has(pFeature)` | true when this edition has an optional part: `"physics"`, `"sound"`, `"models"`. A game asks before using an optional part and plays on without it. | add | add | add |
| `Engine.ScreenToFloor(pX, pY, pFloorY)` | the place on the level floor y = pFloorY (units) under a screen point: `x z` (a space between), or empty when that point looks at the sky. | yes | yes | same |
| `Engine.WorldToScreen(pX, pY, pZ)` | where a world point shows on the screen: `x,y` in pixels, or empty when it is behind the camera. | add | add | add |
| `Engine.Mouse()` | `x,y,down`: the mouse in the view's pixels, and true while its button is held. Empty when there is no mouse (a test, `gNoMouse`). | add | add | add |
| `View.UsePreset pName` | the look: `1983`, `Arcade`, `Fast`, `Vectrex` (line colour, glow, far lines fading). | yes | host | same |
| `View.NextPreset()` | the name of the look after the current one (pass it to `View.UsePreset`). | yes | yes | same |
| `Game.Exit` | the game ends itself: the engine sends `Game.OnStop` and stops stepping. The window stays, the player offers Reset. | yes | yes | same |
| `Game.FindFile(pPath)` | the full path of one of the game's files, or empty. pPath is written from the projects folder (`LIB_GAMES/Vibecode3D_Games/Antack/antack_data.txt`); the engine looks in the game's own folder first, then the shared folder, then upward (`LIB_PUBLIC/install/LAYOUT.md` 5.1). Today every game carries its own copy of this (section 12). | add | add | add |

## 6. HUD and text

| Call | What it does, units, what it gives back | XT | xRay | Box2D editions |
|---|---|---|---|---|
| `HUD.Set pId, pText, pX, pY, pSize` | a line of vector text at screen x,y (its top left, pixels), letters pSize pixels high. Setting an id again replaces it. Letters `A-Z 0-9 : - + . ! / ^ ? , '` and space; anything else is a gap. Small letters show as capitals. | yes | host | same |
| `HUD.Remove pId` | removes that line. | yes | yes | same |
| `HUD.Clear` | removes every line. | yes | yes | same |

## 7. Particles and effects

| Call | What it does, units, what it gives back | XT | xRay | Box2D editions |
|---|---|---|---|---|
| `Particles.Clear` | removes every particle. | yes | yes | same |
| `Particles.Add pX, pY, pZ, pHX, pHY, pHZ, pVX, pVY, pVZ, pLife, pColorId, pSpin, pGravity` | one short line: centre, half-length as a vector, speed (units a step), life in steps, whether it tumbles, and gravity (added to its y speed each step: positive falls). At most 200 live at once; more are dropped. **pColorId is an engine-internal name today** (section 12): use `FX.Sparks` until this takes a colour. | yes | host | same |
| `Particles.Count()` | how many are alive. | yes | yes | same |
| `FX.Sparks pX, pY, pZ, pCount, pColor` | a burst of pCount bright streaks at a world point. | yes | host | same |
| `FX.Explode pId` | the object breaks into its own lines, which fly apart; the object is removed. | yes | host | same |
| `FX.Destroy pId` | the object is removed with the look's own effect (fade-out or `FX.Explode`). | yes | host: the fade-out is made with xTalk graphics and must be redone | same |

## 8. Collisions, the laser, sound

Collisions are balls: each object has a radius (its mesh's, unless given). Each step, for every
pair of groups a rule names, the engine sends `Collision.Hit` for each pair of touching objects.

| Call | What it does, units, what it gives back | XT | xRay | Box2D editions |
|---|---|---|---|---|
| `Collision.SetGroup pId, pGroup, pRadius` | puts the object in a named group; pRadius (units) is optional. | yes | yes | must give the same hits as XT |
| `Collision.AddRule pGroupA, pGroupB` | objects of these two groups are tested against each other (a group against itself is allowed). | yes | yes | must give the same hits as XT |
| `Collision.ClearRules` | forgets every rule. Call it in `Game.OnStart`. | yes | yes | same |
| `Weapon.FireAt pScreenX, pScreenY` | a laser through that screen point. The first object with a face under it is hit: with `hp` it loses 1 and at 0 is destroyed (`Game.OnKill` is sent); without, sparks. The hit id (or empty) is in `the result`. | yes | host: draws the beam | same |
| `Sound.Play pType` | plays the next sound of that kind (`"shot"`, `"boom"`...), silent when there is none. In the Game Player there are none today: games are silent. | yes | add (raylib sound) | same |

<!-- contract:end -->

## 9. Shared values

Globals a game may declare. "read" means the engine sets it and the game only looks.

<!-- contract:values -->
| Value | What it is | XT | xRay | Box2D editions |
|---|---|---|---|---|
| `gViewLeft` | read: the view's left edge in screen pixels. | yes | yes | same |
| `gViewTop` | read: its top edge. | yes | yes | same |
| `gViewRight` | read: its right edge. | yes | yes | same |
| `gViewBottom` | read: its bottom edge. | yes | yes | same |
| `CenterX` | read: the view's centre, x. | yes | yes | same |
| `CenterY` | read: the view's centre, y. | yes | yes | same |
| `gCameraYaw` | read and write: the camera's turn left-right (radians; 0 looks along +Z, positive turns right). | yes | yes | same |
| `gCameraPitch` | read and write: its tilt (radians; positive looks up). | yes | yes | same |
| `bPaused` | read: true while paused (Escape, the menu, the window in the background). | yes | yes | same |
| `bPlaying` | read: true while the game runs. | yes | yes | same |
| `bStill` | write: the game puts true when nothing moves (an editor at rest); the player then neither steps nor draws until a key or the mouse is pressed, and puts it back to false. | yes | add | same |
| `gV3DTickMS` | write: the game's own time between frames, 8 to 200 ms; empty = 33. Changes how often the player draws, never the 33 ms step. | yes | add | same |
| `gNoMouse` | read: true while an AI tests. The game must not read, lock or move the mouse. | yes | yes | same |
<!-- contract:end -->

## 10. What the engine says to a game

A game is one card script. It answers these; all are optional except `Game.OnStart`.

<!-- contract:messages -->
| Message | When, and what comes with it | XT | xRay | Box2D editions |
|---|---|---|---|---|
| `Game.OnStart` | once, before the first step (and again on Reset). Build everything here. | yes | yes | same |
| `Game.OnUpdate` | every 33 ms step while playing and not paused, after the engine has moved the objects and before it tests collisions. | yes | yes | same |
| `Game.OnStop` | when the game ends or the window closes. | yes | yes | same |
| `Game.OnPause` | when the game is paused. | yes | yes | same |
| `Game.OnResume` | when it goes on. | yes | yes | same |
| `Game.OnClick pX, pY, pButton` | a mouse click in the view: screen pixels; button 1 left, 3 right. Not sent while paused. | yes | host | same |
| `Game.OnKill pId, pX, pY, pZ` | the laser destroyed an object: its id (already gone) and where it was hit (units). | yes | yes | same |
| `Collision.Hit pA, pB` | two objects touch and a rule covers them. If the game does not answer, any of the two with `hp` is destroyed. | yes | yes | must send the same pairs |
<!-- contract:end -->

The player also calls `<Prefix>.StartLevel pLevel` when the owner picks a level in its menu
(the prefix and the level count come from the game list, not from the game).

### Keys and the host's own messages

These come from xTalk itself, the same on every edition, and are part of the contract:

<!-- contract:host-ok -->
| Form | Use |
|---|---|
| `the keysDown` | the keys held now, as key codes with commas (65361 left, 65362 up, 65363 right, 65364 down, 32 space). Read it in `Game.OnUpdate`. This is the normal way to steer. |
| `on arrowKey` | answer it with nothing, so an arrow key never moves the card. |
| `on rawKeyDown pCode` / `on keyDown pChar` | one-off keys (typing games). `pass` what is not yours: Escape belongs to the player. |
| `the milliseconds` | only to measure; game time is steps. |
| `URL ("binfile:" & tPath)` | reading and writing the game's own files, found with `Game.FindFile`. |
| `start using` / `insert script` | loading a library script found with `Game.FindFile` (section 10b). |
<!-- contract:end -->

### 10b. Libraries a game may load

Not engine calls: ordinary xTalk scripts a game loads itself. The checker lets these names pass.

<!-- contract:libraries -->
| Prefix | Where it lives |
|---|---|
| `Bit.` | `LIB_BIT/livecode/lib_bit.livecodescript` |
| `Map.` | `LIB_MAP/livecode/lib_map.livecodescript` |
| `CellMap.` | `LIB_BIT/editor` (cellmap v2) |
| `Anims.` | `LIB_MOCAP/livecode/anim_list.livecodescript` |
| `Seq.` | `LIB_GAMES/Vibecode3D_Games/Sequencer/sequencer.livecodescript` |
| `Term.` | the same script: the Sequencer's text console |
| `Clip.` | `LIB_GAMES/Vibecode3D_Games/Sequencer/Clips/` and a game's own `Data/Clips/` |
| `Gen.` | `LIB_GENERICA/livecode/lib_generica.livecodescript` (a game's words as label files) |
| `Bld.` | `LIB_EDITOR/iGame3D_XT/Tools/v3d_buildings.livecodescript` |
| `Fig.` | `LIB_EDITOR/iGame3D_XT/Tools/v3d_figures.livecodescript` |
| `Prop.` | `LIB_EDITOR/iGame3D_XT/Tools/v3d_props.livecodescript` |
| `Shape.` | `LIB_EDITOR/iGame3D_XT/Tools/window_shape.livecodescript` |
| `Insp.` | `LIB_EDITOR/iGame3D_XT/Tools/v3d_inspector.livecodescript` |
| `Skins.` | `LIB_EDITOR/iGame3D_XT/Tools/v3d_skins.livecodescript` |
| `Model.` | `LIB_EDITOR/iGame3D_XT/Tools/v3d_models.livecodescript` |
<!-- contract:end -->

## 11. The player's side

The player (the window a game runs in) owns: the timer, drawing, Escape (pause and resume),
the `...` menu (Pause, Reset, Levels, Quit), pausing when the window goes to the background,
the status line, the game notes box, skins, and the error log. A game does none of these.

<!-- contract:properties -->
| Property of the player window | What it is | XT | xRay | Box2D editions |
|---|---|---|---|---|
| `uGame` | the game's name. | yes | add | same |
| `uScriptFile` | where the game script was loaded from. `Game.FindFile` reads it; a game should not (section 12). | yes | add | same |
| `uPrefix` | the game's prefix, for `<Prefix>.StartLevel`. | yes | add | same |
| `uLevels` | how many levels the menu offers (0 = no level menu). | yes | add | same |
| `uQuitOnClose` | closing the window ends the program. | yes | add | same |
| `uErrorFile` | where errors are written; set by the installed launcher. Without it, the owner's inbox (`LIB_LLMIN/LIB_DEV/GAME_PLAYER_ERRORS.txt`). | yes | add | same |
| `uLastError` | the last error, kept on the window. | yes | add | same |
<!-- contract:end -->

When a game errors, the player stops it, shows the line number, logs the full error, and offers
Reset. It never closes the window by itself.

### Physics (Box2D editions): reserved, not yet written

The prefix `Physics.` is reserved. Nothing is specified, because no game needs it yet and no
Box2D edition exists to test against. The rules it must follow when written:

1. A game asks `Engine.Has("physics")` and still plays on XT and xRay without it (today every
   game fakes its own bouncing and falling; that stays as the fallback).
2. Box2D is flat (two axes). The game says which plane its bodies live in (the floor x,z for a
   top-down game; x,y for a side view), 10 units a metre, y down.
3. Objects stay `Entity.Spawn` ids. A body is added to an id; `GetObjectPosition` then gives the
   body's place and `SetObjectPosition` moves it.
4. `Collision.SetGroup`, `Collision.AddRule` and `Collision.Hit` keep their meaning: a Box2D
   edition sends the same message for the same touching pairs, so old games do not change.

## 12. What each edition must add

**All four** (planned calls, section 2 to 5): `Game.FindFile`, `Scene.Objects`, `Mesh.Has`,
`Entity.SetMesh`, `Entity.Set`, `Entity.Get`, `Engine.WorldToScreen`, `Engine.Mouse`,
`Engine.Has`, `Engine.Info("edition")`. Each one exists to retire a debt below.

| Edition | Must add |
|---|---|
| **iGame3D XT** | the ten planned calls. Fix `SetObjectVelocity`'s fifth parameter or remove it. Give `Particles.Add` a colour instead of an internal name. Sound files for the Game Player (today `Sound.Play` is silent there). |
| **iGame3D xRay** | the ten planned calls. Its own player with the same properties and the same Escape / menu / background pause / `bStill` / `gV3DTickMS` behaviour. Drawing for: HUD text, particles, the laser beam, the explode and fade-out effects, the looks (`View.UsePreset`), skins in `Mesh.Define`. `Game.OnClick` and `Engine.Mouse` in the view's pixels when raylib owns the window. `Sound.Play` through raylib. |
| **iGame3D Box2DXT** | everything XT has, unchanged for games that do not ask for physics; the `Physics.` group once written; `Engine.Has("physics")` true; the same `Collision.Hit` pairs as XT. |
| **iGame3D xRayBox** | everything xRay has, plus the same physics part as Box2DXT. |

## 13. Debts: what games use that is not in the contract

A debt is not a bug today: every game runs on XT. It is a place where a game depends on how XT
is built inside, so it would stop on another edition or after XT is tidied. The full list with
every game and line is made by the checker, never by hand:

    python3 -I LIB_ig3d/tools/contract_check.py            every debt, every game and line
    python3 -I LIB_ig3d/tools/contract_check.py --short    one line each
    python3 -I LIB_ig3d/tools/contract_check.py --by-game  what one game owes

### Host words that are debts

The checker looks for these patterns in a game's code (outside comments and quoted text).

<!-- contract:host-debt -->
| Pattern | What it is, and what to use |
|---|---|
| `\buScriptFile\b` | own copy of FindFile (reads the player's uScriptFile): use Game.FindFile |
| `\bthe\s+mouse(Loc\|H\|V)\b` | reads the mouse off the card: use Game.OnClick or Engine.Mouse |
| `\bscreenMouseLoc\b` | reads or moves the mouse on the whole screen |
| `\blockCursor\b` | locks the cursor |
| `^\s*create\s+(invisible\s+)?(field\|button\|graphic\|group\|image\|player\|stack\|scrollbar\|widget)\b` | makes its own controls or windows |
| `\bthe\s+(width\|height\|rect)\s+of\s+this\s+(stack\|card)\b` | measures the window: use gViewLeft ... gViewBottom |
| `^\s*(answer\|ask)\s` | opens a dialog box (hangs a headless test) |
| `\bshell\s*\(\|\bopen\s+process\b\|^\s*launch\s` | starts another program |
| `\bsend\s.+\sin\s.+(milliseconds\|millisecs\|seconds\|secs\|ticks)\b` | its own timer (runs on through pause): count steps in Game.OnUpdate |
| `^\s*wait\s` | waits inside a step (freezes the loop) |
<!-- contract:end -->

### The debts found on 16 Nov 2026

74 scripts read (50 games, the Sequencer and its clips, the iGame3D XT editor and its tools,
Genetic Anomaly): 56 owe something, 53 different debts. No game uses a planned call yet. In short:

| # | Debt | Who | What retires it |
|---|---|---|---|
| 1 | Its own copy of FindFile, reading the player's `uScriptFile` | Amazing_Couple, Antack, DeadDays, Face, Thrmnlra, VectorToss, uDead, the editor, Genetic Anomaly | `Game.FindFile` in the engine (planned since LAYOUT.md 5.1) |
| 2 | Reads or writes the engine's object table `gObjectTransforms` (hit points, time to live, positions, "is it alive") | Canyon (55 places), Hunter (84), Amazing_Couple, Antack, AntackFresh, Thrmnlra, VectorToss, uDead, the editor and its inspector, the two demo cards | `Entity.Set`, `Entity.Get`, `Scene.Has`, `GetObjectPosition` |
| 3 | Rewrites the engine's draw list `gSceneObjects` to change an object's mesh, or walks it to find objects | Amazing_Couple, Antack, AntackFresh, Thrmnlra, VectorToss, uDead (mesh swap); Canyon, Hunter (walk) | `Entity.SetMesh`, `Scene.Objects` |
| 4 | Works out where a world point is on screen with engine maths (`ProjectVertex`, `Xform.Object`, `Mat3.Camera`, `Mat3.Apply`) | ProbeVsCone, Thrmnlra, Genetic Anomaly, Antack, AntackFresh | `Engine.WorldToScreen` |
| 5 | Reads the mouse off the card or the whole screen, or locks the cursor | Antack, AntackFresh, Canyon, Hunter, LightTrailArena, ProbeVsCone, SquadBuggy, VectorToss, uDead, the editor | `Engine.Mouse`. Mouse-look (Hunter, uDead lock the cursor) has no contract form yet. |
| 6 | Builds objects the old way (`Scene.AddObject`, `Scene.Register`, `Scene.ColorGraphic`), stops the loop itself (`game.loop.stop`), casts its own ray (`RayCastScene`) | Hunter, Canyon | `Entity.Spawn`, `Game.Exit`, `Weapon.FireAt` |
| 7 | Looks into the mesh store `gMeshCache` | Thrmnlra | `Mesh.Has` |
| 8 | Makes its own buttons, fields or windows; measures the window; dialogs; waits; own timers; starts programs; calls the player's `Player.Quit` | the editor and its tools (most), Thrmnlra, the Sequencer, Genetic Anomaly, Hunter (one timer) | a decision first (question 3); for an editor this may simply be allowed |
| 9 | The old demo cards: 13 engine internals and 19 engine globals each | demo, Simple_Test2 (the same script twice) | retire them (question 4) |
| 10 | A leftover line: declares `gSceneObjects` / `gObjectTransforms` and never uses them | 44 and 41 scripts | delete the line (harmless today) |

The whole list, as the checker printed it (name, then game:line numbers):

```
contract: 61 calls (52 the XT engine has), 8 messages, 13 shared values, 15 library prefixes
74 scripts read, 56 with debts; 53 different debts

Engine internals a game calls (not contract calls) (18)
  ProjectVertex   (3 scripts)
      ProbeVsCone:477,478; Thrmnlra:813; GeneticAnomaly:451
  Scene.AddObject   (3 scripts)
      Hunter:64; Simple_Test2:26,27,29; demo:26,27,29
  App.ResetScene   (2 scripts)
      Simple_Test2:18; demo:18
  game.loop.stop   (2 scripts)
      Canyon:549; Hunter:836
  Game.TogglePause   (2 scripts)
      Simple_Test2:400; demo:400
  MoveCameraLocal   (2 scripts)
      Simple_Test2:403,409,415,421; demo:403,409,415,421
  Object.Angle.Keys   (2 scripts)
      Simple_Test2:314; demo:314
  RENDER_SCENE   (2 scripts)
      Simple_Test2:464; demo:464
  RENDER_VIEW   (2 scripts)
      Simple_Test2:393,397; demo:393,397
  Selection.Kill   (2 scripts)
      Simple_Test2:396; demo:396
  SetAngles   (2 scripts)
      Simple_Test2:279; demo:279
  Xform.Object   (2 scripts)
      Antack:155; AntackFresh:155
  Mat3.Apply   (1 scripts)
      Thrmnlra:812
  Mat3.Camera   (1 scripts)
      Thrmnlra:812
  Player.Quit   (1 scripts)
      Ig3dEditor:504
  RayCastScene   (1 scripts)
      Hunter:546
  Scene.ColorGraphic   (1 scripts)
      Canyon:86
  Scene.Register   (1 scripts)
      Canyon:86

Engine globals a game reads or writes (not shared values) (25)
  gSceneObjects (declared, never used)   (44 scripts)
      BatDuel:11; BigBallOfVectors:12; BlockCityHustle:19; BounceRally:13; CityShield:12; CoastRoad:14;
      CraterCrawler:21; CrossTraffic:10; DeadDays:16; DeepDive:11; DodgeTunnel:11; DotMaze:11; Face:14;
      FareDash:14; FloppyFlynn:12; FuelLine:15; GridSprint:15; InterceptorRun:16; JaiAlaiBlock:11;
      LightTrailArena:24; LongWorm:10; MatrixLock:12; NeonDriftWastes:13; ProbeVsCone:20;
      PromptAndGlazeMaze:13; RampRider:14; RockField:11; ShaftDescent:12; Simple_Test1:9; Simple_Test2:218;
      SkyRaiders:12; SoftLanding:11; SquadBuggy:24; StackDown:11; TabletopRacers:15; TrenchRun:13;
      VectorBlobApocalypse:11; VectorPong3D:11; VineRun:12; WallBreaker:10; WreckRing:15; demo:218;
      Ig3dEditor:33; GeneticAnomaly:27
  gObjectTransforms (declared, never used)   (41 scripts)
      BatDuel:11; BigBallOfVectors:12; BlockCityHustle:19; BounceRally:13; CityShield:12; CoastRoad:14;
      CraterCrawler:21; CrossTraffic:10; DeadDays:16; DeepDive:11; DodgeTunnel:11; DotMaze:11; Face:14;
      FareDash:14; FloppyFlynn:12; FuelLine:15; GridSprint:15; InterceptorRun:16; JaiAlaiBlock:11;
      LightTrailArena:24; LongWorm:10; MatrixLock:12; NeonDriftWastes:13; ProbeVsCone:20;
      PromptAndGlazeMaze:13; RampRider:14; RockField:11; ShaftDescent:12; Simple_Test1:9; SkyRaiders:12;
      SoftLanding:11; SquadBuggy:24; StackDown:11; TabletopRacers:15; TrenchRun:13; VectorBlobApocalypse:11;
      VectorPong3D:11; VineRun:12; WallBreaker:10; WreckRing:15; GeneticAnomaly:27
  gObjectTransforms   (12 scripts)
      Amazing_Couple:892,899; Antack:132; AntackFresh:132; Canyon:282,283,287,295,326,327,+49 more;
      Hunter:60,290,307,308,312,313,+78 more; Simple_Test2:84,230; Thrmnlra:706,713; VectorToss:1804,1811;
      demo:84,230,485; uDead:1293,1300; Ig3dEditor:1241,1928,2120; v3d_inspector:161,166,167,168
  gSceneObjects   (8 scripts)
      Amazing_Couple:893,898; Antack:126,131; AntackFresh:126,131; Canyon:514; Hunter:546; Thrmnlra:707,712;
      VectorToss:1805,1810; uDead:1294,1299
  bEditor   (2 scripts)
      Simple_Test2:227; demo:227
  bMissile   (2 scripts)
      Simple_Test2:228; demo:228
  bMouseLook   (2 scripts)
      Simple_Test2:252; demo:252
  gCameraVertices   (2 scripts)
      Simple_Test2:247; demo:247
  gDebug   (2 scripts)
      Simple_Test2:231; demo:231
  gFocalLength   (2 scripts)
      Simple_Test2:234; demo:234
  gLogSelection (declared, never used)   (2 scripts)
      Simple_Test2:220; demo:220
  gMeshCache (declared, never used)   (2 scripts)
      Simple_Test2:219; demo:219
  gMeshEdges   (2 scripts)
      Simple_Test2:244; demo:244
  gMeshFaces (declared, never used)   (2 scripts)
      Simple_Test2:168; demo:168
  gMeshVertices   (2 scripts)
      Simple_Test2:243; demo:243
  gMouseDeltaX   (2 scripts)
      Simple_Test2:258; demo:258
  gMouseDeltaY   (2 scripts)
      Simple_Test2:259; demo:259
  gMouseLookLastH   (2 scripts)
      Simple_Test2:255; demo:255
  gMouseLookLastV   (2 scripts)
      Simple_Test2:256; demo:256
  gMouseLookSensitivity   (2 scripts)
      Simple_Test2:257; demo:257
  gNearPlane   (2 scripts)
      Simple_Test2:233; demo:233
  gRenderPoints   (2 scripts)
      Simple_Test2:250; demo:250
  gSceneTransforms   (2 scripts)
      Simple_Test2:229; demo:229
  gSelectionHistory   (2 scripts)
      Simple_Test2:224; demo:224
  gMeshCache   (1 scripts)
      Thrmnlra:767

Host words the contract lists as debts (10)
  reads the mouse off the card: use Game.OnClick or Engine.Mouse   (10 scripts)
      Antack:362,557; AntackFresh:401,596; Canyon:320,321; Hunter:392; LightTrailArena:870; ProbeVsCone:303;
      SquadBuggy:678; VectorToss:513; uDead:2042; Ig3dEditor:400,405,407,408
  own copy of FindFile (reads the player's uScriptFile): use Game.FindFile   (9 scripts)
      Amazing_Couple:977; Antack:209; DeadDays:69; Face:136; Thrmnlra:1010; VectorToss:1876; uDead:180;
      Ig3dEditor:605,1088,1139,1761; GeneticAnomaly:61
  makes its own controls or windows   (7 scripts)
      Thrmnlra:219; sequencer:321,729; Ig3dEditor:96,101,117,151,274,294,+6 more;
      v3d_inspector:49,74,76,85,87,137,+5 more; v3d_skins:41,57,63,114,116,128,+1 more;
      window_shape:88,144,154,258; GeneticAnomaly:782
  reads or moves the mouse on the whole screen   (4 scripts)
      Hunter:409; uDead:2053; Ig3dEditor:938,942,946,951,952,1179; window_shape:238,241,242
  its own timer (runs on through pause): count steps in Game.OnUpdate   (3 scripts)
      Hunter:426; Ig3dEditor:504; v3d_inspector:398
  measures the window: use gViewLeft ... gViewBottom   (3 scripts)
      Thrmnlra:224,228; Ig3dEditor:98,267,268,270,407,408,+3 more; GeneticAnomaly:792
  locks the cursor   (2 scripts)
      Hunter:84,108,114,834; uDead:103,148,153,158
  opens a dialog box (hangs a headless test)   (2 scripts)
      Ig3dEditor:484; v3d_skins:331
  waits inside a step (freezes the loop)   (2 scripts)
      Ig3dEditor:411,947; window_shape:244
  starts another program   (1 scripts)
      Ig3dEditor:1481
```

## 14. The stand-ins and the tests

`LIB_GAMES/tools/engine_stubs.livecodescript` is the contract as code with nothing behind it:
one stand-in for every call above that XT has today, nothing for the planned ones (so a test
stops where the real engine would), plus two debts kept alive for the games that still use them
(`Xform.Object`, `ProjectVertex`) and the test hooks (`Stub.HUD`, `Stub.NoMouse`).
`contract_check.py --stubs` says whether that is still true.

A stand-in remembers what a game sets (positions, rotations, speeds, which objects exist, HUD
text) and does nothing else: nothing moves, nothing collides, nothing is drawn.

## 15. Open questions for the owner

1. **The object table.** XT keeps every object in the global `gObjectTransforms` and the draw
   list in `gSceneObjects`. This draft puts both outside the contract and adds five small calls
   (`Entity.Set`, `Entity.Get`, `Entity.SetMesh`, `Scene.Objects`, `Scene.Has`) to replace what
   games do with them. The other choice is to make the table itself the contract; then xRay and
   the Box2D editions must keep an identical table forever. Default taken: calls, not the table.
2. **Camera turn** stays two shared values (`gCameraYaw`, `gCameraPitch`) because 17 games write
   them and no call exists. Say if you would rather have `Engine.SetLook pYaw, pPitch`.
3. **Games that make their own buttons and fields** (the editor, Genetic Anomaly, Thrmnlra and
   others): a debt as written, since raylib's own window has no cards. If xRay always shows
   inside an xTalk window (it can), this can become allowed. Default taken: debt.
4. **The old demo cards** (`demo`, `Simple_Test2`) reach deepest into the engine (they were its
   test bed). Retire them from the game list rather than fix them?
5. **Names.** Object calls are `SetObjectPosition` style and the rest `Group.Verb` style. Left
   as they are (330 uses); a rename day could add `Entity.SetPosition` beside the old names.
