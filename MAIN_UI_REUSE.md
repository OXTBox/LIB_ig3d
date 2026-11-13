# The iGame3D main UI: what to reuse (A-83, first pass)

Friday, November 13, 2026. Claude, from the XTJSON harvest of `ig3d_UI_MAIN_11_13_2026.livecode`
(19 stacks, 46 cards, 1,226 controls, 328 scripts; the 2007 `.rev` has 17 stacks, 971 controls).
The owner: the old engine stays a reference and a template; reuse every element that isn't junk.
**First pass from structure only** (names, counts, labels); verdicts marked *(look)* need the
scripts read before they're final. Images (108 icons on the main card) not opened.

## The main window (card 1, 183 controls)

| Part | What it had | Verdict | Goes to |
|---|---|---|---|
| Menus | File, Edit, Mesh, Window, Dev, Help, Library | **adapt** | the menu set of every LIB app (LIB_GUI, LIB_TOOLBAR) |
| Play | "Play: (esc to exit)" | **keep** the idea | LIB_ALPHA rule 18 (Escape pauses / exits play) already says it |
| Editing modes | path editing, path selection, bones, vertex, line, split, mesh editing, light, colors, camera, particles, sounds, snapshot, access view settings | **adapt** | Vibecode3D / xt3d editor mode bar; LIB_EDIT (A-22) |
| Primitives | Sphere, Cone, Cylinder, Cube, Terrain, quad, dropMesh | **keep** | Vibecode3D has generators for all of them (`MeshSphere`, `MeshPrism`, `MeshGrid`...): one toolbar row |
| Level filter, levels picker, window picker | `LevelsFilter`, `WindowPickPop` | adapt | LIB_TOOLBAR, file browser |
| Slider group, GL control, title/shadow toggle | `slider_group`, `GLControlButton`, `shadowtitletoggle` | *(look)* | view settings panel |

## The substacks

| Stack | Size | What it is | Verdict | Goes to |
|---|---|---|---|---|
| **filesLibrary** | 8 cards, 213-line script | asset/level browser ("Levels") | **keep** | the file input / asset browser the owner asked Spark to design (S-3) |
| **Inspector** | 15 cards, 264 controls | object property inspector | **keep** *(look)* | a LIB_ inspector for Vibecode3D / xt3d objects; GAD's Inspector stacks belong to the same line |
| **sceneGraph** | 15 controls | the scene as a tree | **keep** | editor panel |
| **console** | 1,210-line script | Lua console (title: `Data/Scripts/GUI/scenegraph.lua`) | **adapt** | the in-window MCP command line (LIB_ALPHA rule 19) |
| **NewAnimEd** | 176 controls | Animation Editor | **keep** *(look)* | the Sequencer's visual timeline (A-23); LIB_MOCAP clip viewer |
| **color** | 4 cards, 285-line script | colour picker | **keep** | shared widget |
| **scriptHarvesterig3d** | 21 controls | an early script harvester | reference | LIB_XTJSON's ancestor: compare, then archive |
| **exportscripts** | "rev script exporter" | script export | reference | LIB_SCRIPTBLOCKS export (done better now) |
| **murgaRevOut** | 4 cards, "rev to murga output" | converts LiveCode UI to murgaLua/FLTK | **keep as a lesson** | the plan to port approved UIs to raygui / ImGui / tkinter (S-4): it's the first try at exactly that |
| **ExternalReference** | "iGame3D Pro External Reference" | the external's API docs | reference | `IGAME3D_EXTERNAL_API.md` |
| **GLfontMaker07** | 105 controls | bitmap font maker for GL | adapt | LIB_BIT (1-bit fonts) |
| **Find T3D** | "Found ig3d_Show: 26 hits" | search across scripts | adapt | ScriptBlocks' Find |
| **Dev** | "Dev OpenStacks", 181-line script | developer launcher | adapt | LIB_TOOLBAR |
| previewImage, previewStack | small | preview windows | *(look)* | file browser preview |
| GameOverViewData | 256 controls, 3-line script | data sheet | *(look)* | maybe LIB_GENERICA data |
| replacemodelssubstack | 6 controls | replace models | *(look)* | |
| BackgroundColorEffectTEST | 2 controls | a test | junk | |

## Next

1. Read the scripts of the *(look)* rows and the **keep** rows (LIB_SCRIPTBLOCKS can cut them into blocks).
2. Compare with the 2007 `.rev` (17 stacks): what changed between 2007 and 2026.
3. Turn each **keep** into a TODO in the LIB it goes to.
