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
| Slider group, GL control, title/shadow toggle | `slider1` moves the grid plane along its axis (distance from the camera); `GLController` toggles the 3D move/rotate gizmo | **adapt** (read 14 Nov) | view settings panel: a grid-plane slider and a gizmo on/off |

## The substacks

| Stack | Size | What it is | Verdict | Goes to |
|---|---|---|---|---|
| **filesLibrary** | 8 cards, 213-line script | asset/level browser ("Levels") | **keep** | the file input / asset browser the owner asked Spark to design (S-3) |
| **Inspector** | 15 cards, 281 controls | object property inspector; read 14 Nov: one card per thing to edit (material with ambient/diffuse/specular/colour/emission + RGBA fields + UV offset/size/rotation + smooth/blend/depth flags; bones tree with attach/parent/export; mesh export; background/fog/grid/tint colours; terrain). The card *is* the data model of an ig3d object | **keep** | a LIB_ inspector for Vibecode3D / xt3d objects; GAD's Inspector stacks belong to the same line |
| **sceneGraph** | 15 controls | the scene as a tree | **keep** | editor panel |
| **console** | 1,210-line script | Lua console (title: `Data/Scripts/GUI/scenegraph.lua`) | **adapt** | the in-window MCP command line (LIB_ALPHA rule 19) |
| **NewAnimEd** | 176 controls | Animation Editor; read 14 Nov: a bone list + a timeline (100 px = 1 s) of markers, each marker `bone, morph?, start, end, x, y, z, rx, ry, rz`; play = linear blend from the bone's last pose to each marker; saved into the model file's `#Animations` section as `start,end` + `morph=` or `set=bone,x,y,z,rx,ry,rz` lines (see below) | **keep** | the Sequencer's visual timeline (A-23); LIB_MOCAP clip viewer |
| **color** | 4 cards, 285-line script | colour picker | **keep** | shared widget |
| **scriptHarvesterig3d** | 21 controls | an early script harvester | reference | LIB_XTJSON's ancestor: compare, then archive |
| **exportscripts** | "rev script exporter" | script export | reference | LIB_SCRIPTBLOCKS export (done better now) |
| **murgaRevOut** | 4 cards, "rev to murga output" | converts LiveCode UI to murgaLua/FLTK | **keep as a lesson** | the plan to port approved UIs to raygui / ImGui / tkinter (S-4): it's the first try at exactly that |
| **ExternalReference** | "iGame3D Pro External Reference" | the external's API docs | reference | `IGAME3D_EXTERNAL_API.md` |
| **GLfontMaker07** | 105 controls | bitmap font maker for GL | adapt | LIB_BIT (1-bit fonts) |
| **Find T3D** | "Found ig3d_Show: 26 hits" | search across scripts | adapt | ScriptBlocks' Find |
| **Dev** | "Dev OpenStacks", 181-line script | developer launcher | adapt | LIB_TOOLBAR |
| previewImage, previewStack | small | read 14 Nov: a 72 px image preview that you drag a model from into the scene (drop point from `2Dto3D`); a colour-swatch picker that sets grid/background/fog/tint | adapt | file browser preview with drag-to-scene; the swatch goes into the shared colour widget |
| GameOverViewData | 256 controls, 3-line script | read 14 Nov: a **game design document form** (Overview, Philosophy, Goals, World Layout, Scheduled, Sounds, Music, Weapons, Camera tabs); `Save_Props` is broken (`myLis`/`wchk` typos, never writes anything) | adapt the outline, not the stack | a design-doc template for PROMPT & GLAZE / LIB_HOWTO (headings only) |
| replacemodelssubstack | 6 controls | read 14 Nov: swap every object matching a filter for another model, keeping name, info and attached scripts | adapt | one editor command ("replace with...") in the Vibecode3D editor |
| BackgroundColorEffectTEST | 2 controls | a test | junk | |

## Next

1. Read the scripts of the *(look)* rows and the **keep** rows (LIB_SCRIPTBLOCKS can cut them into blocks).
2. Compare with the 2007 `.rev` (17 stacks): what changed between 2007 and 2026.
3. Turn each **keep** into a TODO in the LIB it goes to.

## Started: the toolbar, remade (2026-11-13, LIB_GAMES branch `ig3d-ui-remake`)

`Vibecode3D_Play_Ig3dEditor.livecodescript`: the 2026 main card's 26 icon tools in their old order,
each PNG icon replaced by a Unicode symbol chosen from the icon's file name (images never opened;
the owner's LIB_UNICODE note: tool icons in Unicode). The map, `kTools` in that card:

| tool | symbol | old icon | wired? |
|---|---|---|---|
| level | ⚙ U+2699 | console.png | no |
| snapshot | ◙ U+25D9 | snapshot.png | no |
| colors | ◐ U+25D0 | colorball16x16.png | yes (recolours the last object) |
| light | ☀ U+2600 | lights.png | marker only |
| objects | ☺ U+263A | 32x32zombie3.png | no |
| particles | ✳ U+2733 | particlesicon24x24.png | no |
| camera | ◎ U+25CE | meshView.png | yes (reset) |
| GLController | ✥ U+2725 | repositiontoolnew2.png | yes (orbit) |
| pathselect, path | ⇢ ✎ | pathSelectIcon / pathToolIcon | no |
| select_mesh, vertex, line, disconnect, split | ▦ • ╱ ✂ ⋔ | tool6 / tool2 / tool3 / tool5 / tool4 | no |
| quad, cube, dropMesh, Terrain, cylinder, cone, sphere | ▭ ▣ ⤓ ▲ ⌭ △ ● | their own icons | yes |
| Play_Game | ▶ U+25B6 | playGameButton.png | yes (orbit) |
| sounds | ♪ U+266A | soundicon22x22.png | no |
| WindowPickPop | ❐ U+2750 | windows.png | no |
| bones | ⟟ U+27DF | bone.png | no |

**Done since:** the menu bar (File Edit Library Mesh Window Dev Help, items and submenus as they
were; File > Level > New/Reset/Clear, Edit > Undo / boom / boom all, Mesh > Focus Mesh wired), and
**Library = filesLibrary remade**: Models / Levels / Emitters / Scripts list the 2008 Data files;
a `.wtf` model loads as a Vibecode3D wireframe from its `#Vertices` and `#Edges` (755 models).

**Next:** open Levels / Emitters / Scripts items (a level loads its objects; an emitter shows its
settings); Window > Inspector (the Inspector substack: properties of the selected object);
Window > Console (an xTalk command line, rule 19); the vertex tools on loaded meshes.

## Second pass (2026-11-14, the *(look)* rows read)

All *(look)* verdicts above are now final. Read from the harvested scripts
(`XTJSON/batch/igame3d/ig3d_UI_MAIN_11_13_2026/scripts/`, summary via
`LIB_XTJSON/tools/harvest_summary.py`).

**2007 against 2026: almost nothing changed.** The 17 stacks of `ig3d_MainUI050107.rev` are the
same size and script length in the 2026 file (Inspector 281 controls / 173 lines both, console
1,210 lines both, NewAnimEd 271 lines both...). New in 2026: `GameOverViewData`, `murgaRevOut`;
`GLfontMaker07` grew 23 lines; the main card lost 12 controls. So the 2007 file needs no
separate reading: the 2026 harvest stands for both.

**The animation format, worth keeping as written** (NewAnimEd `Save_and_apply_animations`):

```
#Animations
<number of animations>
<name>
<number of keys>
<start>,<end>                       seconds
morph=<bone-1>,x,y,z,rx,ry,rz       morph = blend toward it; set = jump
...
```

It is a plain-text keyframe list per bone, the same idea as the Sequencer's `.seq` clips
(A-23): a reader for it lets the 755 `.wtf` models' animations play in Vibecode3D.

**Not worth keeping:** the card `idle` loop (polls the engine and murgaLua each idle; caps lock
switches mouse-look), `BackgroundColorEffectTEST`, the duplicated `markertemplatebackup`.

**TODOs this gives (step 3), for the owner to accept into LIB_SYSTEM/TODO.md:**
- Vibecode3D editor: Window > Inspector as one card per object kind (material, bones, colours). -- This sounds reasonable, MOST of the MESH Editing level features of iGame3d won't be relevant in Vibecode3D, use only what's needed to produce the games and game assets proceduraly, for now. We'll respecfully honor Blender's deserved infinitely expandable King of the 3D apps status. Go ahead and set up the cards and their UIs, with placeholder scripts that we'll fill in when we are challenged with a need for the functionality. Obviously a BVH/bones animation previewer, key frame clipper (ie, stop the animation before the ubiquitous weird glitch part), and apply them to game's Animation List to be inherited by models, instead of embeddded directly in them.
- A `#Animations` reader for `.wtf` models → Sequencer clips (with A-23). If this is passable to our glb/bvh then go forward, else put .wtf model activity on a backburner. UNLESS we want to start saving our procedurally generated meshes? Nah, stick with glb/glft and USD...I was trying to invent USD in 2005, I was completey in over my head.
- Editor command "replace with model..." (replacemodels). -- Yes!, a little UI to replace the placeholder geometry in TemplateGames and save the choices to an alternate "Skin" would be awesome. 
- Library preview: drag a model from the preview into the scene. -- You know how to do it? You put a preview of the model/whatever into a temp stack,  stack follows mouse over the viewport, works across multiple stacks, and maybe even into other apps. Let's get that in place.
- A game-design-document outline from GameOverViewData's tabs (LIB_HOWTO / PROMPT & GLAZE). -- Not sure what this is, but I sounds good.
