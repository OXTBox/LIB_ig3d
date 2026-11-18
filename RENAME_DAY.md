# Rename Day, and the `Entity.` suggestion list

Wednesday, November 18, 2026. One page by Fable 5.2, for the owner to correct. TODO A-98, A-99.
Step 1 was this plan; the owner said yes on 18 Nov and **step 2 is built** (section 5 says what exists
and what was tested). No game has been moved.
Branch `rename-day`. Counts are from the contract tables and the 76 scripts the checker reads.

## 1. The names

38 of the 62 contract calls are already `Group.Verb` in the right group and keep their names. 24 change:
16 that have no group, 3 that sit in the wrong one (they act on one object, so they belong
where typing `Entity.` finds them), and the 5 camera calls, which get their own group, `Camera.`
(owner, 18 Nov: "Camera. needs its own group").

| Old name | New name | Uses | | Old name | New name | Uses |
|---|---|---|---|---|---|---|
| `SetObjectPosition` | `Entity.SetPosition` | 210 | | `MeshBox` | `Mesh.Box` | 99 |
| `GetObjectPosition` | `Entity.GetPosition` | 31 | | `MeshPrism` | `Mesh.Prism` | 21 |
| `SetObjectRotation` | `Entity.SetRotation` | 111 | | `MeshPyramid` | `Mesh.Pyramid` | 46 |
| `GetObjectRotation` | `Entity.GetRotation` | 0 | | `MeshLathe` | `Mesh.Lathe` | 6 |
| `SetObjectRotationSpeed` | `Entity.SetRotationSpeed` | 18 | | `MeshSphere` | `Mesh.Sphere` | 18 |
| `GetObjectRotationSpeed` | `Entity.GetRotationSpeed` | 0 | | `MeshLoft` | `Mesh.Loft` | 2 |
| `SetObjectVelocity` | `Entity.SetVelocity` | 7 | | `MeshExtrude` | `Mesh.Extrude` | 0 |
| `GetObjectVelocity` | `Entity.GetVelocity` | 0 | | `MeshGrid` | `Mesh.Grid` | 10 |
| `Scene.SetBob` | `Entity.SetBob` | 5 | | `Scene.Has` | `Entity.Exists` | 0 |
| `Scene.SetBounds` | `Entity.SetBounds` | 3 | | `Engine.ResetCamera` | `Camera.Reset` | 54 |
| `Engine.SetCam` | `Camera.SetPosition` (see below) | 22 | | `Engine.ScreenToFloor` | `Camera.ScreenToFloor` | 3 |
| `Engine.SetLook` (planned) | `Camera.SetLook` | 0 | | `Engine.WorldToScreen` (planned) | `Camera.WorldToScreen` | 0 |

That is 666 places in 54 scripts (377 object calls, 202 mesh makers, 8 Scene moves, 79 camera calls).
Parameters, units and meaning do not change, only the word, **with one exception:**

**`Camera.SetPosition pX, pY, pZ` puts the camera at x,y,z.** `Engine.SetCam` moves the world, so a
camera at cx,cy,cz is written `Engine.SetCam -cx, -cy, -cz` today. The new call says what it means:
`Camera.SetPosition cx, cy, cz` (an empty number still leaves that axis alone). So its alias turns
the three signs round, and its 22 places are moved by hand and checked one by one, not by the
word-swapping tool. `Engine.SetCam` keeps working, unchanged, as the old name.
The two planned calls are simply written under their new names (job 3 adds them as `Camera.SetLook`
and `Camera.WorldToScreen`); nothing uses the old ones, so they get no alias.
Later, as planned calls of the new group: `Camera.GetPosition()` and `Camera.GetLook()`, so no game
has to read `gCameraYaw` / `gCameraPitch`.

**Unchanged** (all 38 others): `Scene.ClearAll` `Scene.Objects`; `Mesh.New` `.AddVertex` `.AddFace`
`.AddLine` `.Define` `.Get` `.Has` `.Transform` `.Merge`; `Entity.Spawn` `.Kill` `.Count` `.SetMesh`
`.Set` `.Get`; `Engine.Info` `.Has` `.Mouse`; every `View.` `Game.` `HUD.` `Particles.` `FX.` `Collision.` `Weapon.`
`Sound.` call. Messages (`Game.OnStart` ...), shared values (`gViewLeft` ...) and library prefixes
(`Bit.` `Map.` ...) are not renamed.

## 2. How the old names keep working

| Stage | What is true |
|---|---|
| **A. Step 2** | The 22 new names that have an old one in use are thin aliases: three lines each, passing straight through to the old handler. The engine's own code is not touched, and a game that has not moved loses nothing. |
| **B. Games move** | Both names work. The checker counts old names as a new kind of debt, `old name`, with the new name beside it; it does not fail on them. |
| **C. The checker says 0 old names** | The switch: the engine source takes the new names, and the old names become the aliases. From here `--strict` fails on an old name in our own games. |
| **D. Before the first public release** | The old aliases are deleted (owner, 18 Nov: "we won't break anything for anyone but ourselves. I'd rather the language be clear and certain when it's released"). The released language has one name for each thing; an old name is then an ordinary error, and the checker calls it `unknown`. Public material teaches only the new names from stage A. |

Where they live: **one table, three generated files.** The table (old, new) goes into
`ENGINE_CONTRACT.md` as one more marked table (`<!-- contract:renames -->`). A new tool,
`LIB_ig3d/tools/make_names.py`, writes from the contract:

| File | For |
|---|---|
| `LIB_ig3d/livecode/contract_aliases.livecodescript` | the alias handlers. `make_vibe_xt3d.py` (bridge repo) appends it to the generated engine, so XT and xRay both get it, and the Game Player needs no change. The headless stand-ins load the same file. |
| `LIB_ig3d/Data/contract_words.txt` | the suggestion list's words (section 4), one call a line, tabs between fields. |
| `LIB_ig3d/Data/Menus/contract_menu.txt` | the same words as `Group/Call` paths, the LIB_MENU file form. |

Both engines, said plainly: the aliases are **Engine 1** xTalk (the shared game rules), carried into
the generated `vibe_engine_xt3d.livecodescript` by the tool; the generated file is never edited by
hand. **Engine 2** (`xt3d.lcb`, the shim, the DLL) is not touched at all: its `xt3d_*` names are not
contract names.

Cost of an alias: one extra handler call (a guess: a few millionths of a second; measured in
step 2 with 200 objects a step before any game moves).

## 3. The order the games move (Opus, after step 2)

A small tool does each move (`tools/rename_day.py GAME`): it changes the words outside
comments and quoted text (all but `Engine.SetCam`, which it lists for the hand), then the game's headless test and the checker run. One commit a game.

| Wave | Who | Why this order |
|---|---|---|
| 0 | Simple_Cube, the stand-ins' own test, LIB_HOWTO steps, the contract's examples | what people learn from shows only new names from the first day |
| 1 | the 28 scripts with fewer than 10 old names (Face 2 ... TabletopRacers 9) | small, quick to check, proves the tool |
| 2 | the 9 with 10 to 16 (VineRun, LightTrailArena, PromptAndGlazeMaze, FuelLine, CoastRoad, DeadDays, FareDash, GridSprint, NeonDriftWastes) | |
| 3 | the big ones: CraterCrawler 18, InterceptorRun 22, ProbeVsCone 23, BlockCityHustle 26, SquadBuggy 32 | |
| 4 | the 9 that also reach into the engine's tables: Hunter, Canyon, Antack, AntackFresh, uDead, Amazing_Couple, Thrmnlra, VectorToss, the editor (Ig3dEditor) | wait for `Entity.Set` / `Entity.Get` / `Entity.SetMesh` (job 3), so each is opened once for names and debts together |
| never | `demo`, `Simple_Test2` | retired (owner, 17 Nov) |

Job 3's new calls are written under their final names from the start (`Camera.SetLook`,
`Camera.WorldToScreen`, `Entity.Set` ...): they need no alias. The 17 games that write
`gCameraYaw` / `gCameraPitch` move to `Camera.SetLook` in the same visit as their names (A-96).

## 4. The suggestion list

**Where its words come from.** Only from the contract tables, through `make_names.py`. Nobody
types a word list. The checker's own test runs the tool and fails if the three files differ from
what the contract says today, so the list cannot go stale without a red test. Library words
(`Bit.` `Map.` `Gen.` ...) come later the same way, read from the handler lines of the scripts
section 10b names.

**What it shows.** One line a call:

```
Entity.                                   <- what was typed
  Entity.Spawn(pMesh, pX, pY, pZ, pColor)   gives  a new object ... gives back its id
  Entity.SetPosition pId, pX, pY, pZ               puts it there (units)
  Entity.Set pId, pProp, pValue            planned sets hp, ttl, radius
  also about an object:  Collision.SetGroup   FX.Explode   FX.Destroy
```

| Typed | Shown |
|---|---|
| `Entity.` | every call in the group; `gives` marks one that gives a value back; `planned` (grey) one XT does not have yet |
| `Entity.Se` | narrows as you type |
| `position` (no dot) | every call with that word in its name or its meaning, in any group |
| `SetObjectPosition` or `MeshBox` | the old name, with "now `Entity.SetPosition`" |
| `.` alone | the groups: Scene Mesh Entity Camera Engine View Game HUD Particles FX Collision Weapon Sound |
| `Game.On` | the messages; `g` and `b` the shared values |

"Also about an object" is worked out, not written: any call in another group whose first
parameter is `pId` and whose meaning says "object" (`HUD.Set` has a `pId` too, but it names a line of text). Enter or a click puts the call with its parameter names where the cursor is.

**Where it appears.** One small library does the thinking and draws nothing:
`LIB_ig3d/livecode/lib_suggest.livecodescript` (`Suggest.Load`, `Suggest.For(pTyped)` gives the
lines, `Suggest.Pick(pLine)` gives the text to insert). It is tested headless. Every place below
is only a face on it:

| # | Place | When | Whose work |
|---|---|---|---|
| 1 | **Its own small window**, "FOR OWNER \| Type Entity. and a space": a line to type in, the list, the meaning. Opens in OXT-Beyond, from `LIB_TEST/` | step 2 | Fable |
| 2 | **The in-game console** (LIB_ALPHA rule 19: the command line, lower left of every game window): the list rises above the line as you type. This is the Blender one | next | Opus (Game Player, LIB_DEV) |
| 3 | **A Contract menu** from `contract_menu.txt`: LIB_MENU's "the menu's words are data" rule; a pick pastes the call; it ends like every menu with `Leave comment...` and `Explore here...` (the contract, at that row) | when LIB_MENU's `Menu.Fill` is in | Opus |
| 4 | **The script editor in OXT-Beyond**: the list after a dot while writing a game | after 2 | Opus |
| 5 | **LIB_HOWTO**: each word opens the lesson step that adds it | when the stack exists | Opus |

LIB_GUI fit: window 1 is laid out as a `.gui` file (`field typed`, `list words`, `label meaning`)
so the same list can later show in raygui (xRay) and in vector lines (XT, inside a game). Step 2
builds it with plain xTalk controls of the same three names if `Gui.Build` is not ready for it.
The Message Box is not used: it belongs to the IDE, and a library must not depend on the IDE.

## 5. Step 2: built 18 Nov, after the owner's yes

| Built | Where | Tested |
|---|---|---|
| The renames table; the contract's tables now show the new names; the camera has its own section | `ENGINE_CONTRACT.md` sections 4, 5, 16 | read by the checker |
| `make_names.py`: aliases, words, menu from the contract; `--check` says when one is stale | `tools/make_names.py`, `livecode/contract_aliases.livecodescript`, `Data/contract_words.txt`, `Data/Menus/Contract.txt` | the checker's test (65 of 65), which also fails if the real files are stale |
| The checker knows both names: `old name` is counted apart from the debts (666 places, 54 scripts); `--strict-names` for the day the engine switches; `--stubs` accepts the alias file | `tools/contract_check.py` | the same test; `--stubs`: exactly the contract |
| The engine is made with the 22 aliases appended | bridge repo, branch `rename-day`: `tools/make_vibe_xt3d.py`, `testbench/vibe_engine_xt3d.livecodescript` | headless `t45_rename_aliases`: 60 checks on the stand-ins and on the real engine script. Every new name gives what the old one gives; `Camera.SetPosition 100,-160,-520` shows the same floor as `Engine.SetCam -100,160,520`; 5000 calls cost the same through the alias (77 ms and 76 ms) |
| The list: `Suggest.Load`, `Suggest.For`, `Suggest.Pick`, `Suggest.Meaning` | `livecode/lib_suggest.livecodescript` | headless `t46_suggest`: 37 checks |
| The small window, "FOR OWNER \| Type Entity. and a space" | `livecode/suggest_window.livecodescript` (open it in OXT-Beyond) | the same test builds it, types and picks through its handlers. **Not tested: how it looks, and real typing and clicking** (no screen in a headless test) |

Not done, and why: the window is plain xTalk controls named `typed`, `words`, `meaning`; no `.gui`
file was written, because one that nothing has built would be an untested file. The stand-ins
(`LIB_GAMES/tools/engine_stubs.livecodescript`) were not edited: a test adds the alias file after them.
Making the engine again also brought in the engine source's variable renames of 15 Nov
(`tArray` to `tXYZArray` ...; Vibecode3D commit cd5560c), which the last generated copy did not have.

The list below is what was planned:

1. The `renames` table in the contract; `make_names.py`; the three generated files.
2. The checker learns the table: both names are contract calls; `old name` is a debt kind;
   `--stubs` accepts the alias file; its test covers all of it.
3. `make_vibe_xt3d.py` appends the aliases (bridge repo, branch `rename-day`); the engine is made
   again; one headless test (next free tNN) calls every new name against the stand-ins.
4. `lib_suggest` and window 1, with a headless test of `Suggest.For("Entity.")`.

Not in step 2: moving any game; the engine source; LIB_DEV, LIB_MENU, LIB_GUI, LIB_BIT, LIB_GAD.

## 6. Questions for the owner

| # | Question | Default taken |
|---|---|---|
| 1 | The three Scene moves (`Scene.SetBob`, `Scene.SetBounds`, `Scene.Has` to `Entity.`): yes? | **answered, 18 Nov: yes.** "We'll go with everything being an entity": what acts on one object goes under `Entity.`, for new calls too |
| 2 | Camera calls: a `Camera.` group? | **answered, 18 Nov: yes, its own group** (section 1). `Camera.SetPosition` takes the camera's real place (signs turned round from `Engine.SetCam`): **confirmed 18 Nov**, "the old method is for old computers, never go back" |
| 3 | `Get` in the names (`Entity.GetPosition`), or the short form (`Entity.Position`)? | **answered, 18 Nov: Get and Set** |
| 4 | Old names: kept through the first public release? | **answered, 18 Nov: no.** They are for us only, while the games move, and are gone before release (section 2, stage D) |
| 5 | Where should the list show up next, after the small test window: inside a running game (the command line at the lower left of the game window), or in the script editor while you write a game's code? | inside a running game |
