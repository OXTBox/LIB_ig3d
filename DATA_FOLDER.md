# The Data folder (DRAFT, 2026-11-12)

One default place on disk where every engine, tool and library loads and saves.
No more "wherever the file got saved at 4 AM".

Based on iGame3D's `Data/` folder (2008), which worked: see
`~/projects/LIB_GAMES/igame3D_2008_Texts/_manifest/MANIFEST.md` §2.

## 1. Where it lives (decided 2026-11-12)

```
VibeCode3D/                      <- wherever the program is unzipped; nothing of yours is saved here
    VibeCode3D.exe

Documents/Data/                  <- the Data folder (default)
    ROOT.md                      <- "this is the Data folder", plus the layout in short
    Games/ Models/ Grids/ ...    <- things you make and keep (rebuildable, shareable)
    Work/                        <- things the machine makes (safe to empty)
```

Finding the Data folder (LIB_DATA's `Data.Root()`):
1. `Data.UseRoot` for this session only (tests, a USB stick).
2. The user's choice from "Change Data folder..." (`Data.SetRoot`), remembered in
   `<AppData>/Vibecode3D/data_root.txt`: outside the Data folder, so moving it keeps the setting.
   (iGame3D's `alternateRoot.txt`, moved to where Windows keeps settings.)
3. Otherwise `specialFolderPath("Documents") & "/Data"`.
4. If it does not exist, it is created with the whole layout and `ROOT.md`.

Every path in code and data is **relative to the Data folder**: `Models/Vehicles_air/heli.glb`,
never `C:/Users/...` (`Data.Relative`). Saved levels, harvests and docs then work on any machine.

## 2. Layout

| Folder | Holds | iGame3D had |
|---|---|---|
| `Games/<Game>/` | One folder per game: the game script (`Play.<Game>.livecodescript`), its data, its own assets. Self-contained. | `Levels/<name>/load script.lua` |
| `Scripts/` | Shared libraries (`LIB_*` scripts) that games load | `Scripts/`, `Scripts/Functions/` |
| `Tools/<Tool>/` | Editors and utility stacks | `Fluid/<tool>/` |
| `Models/<Category>/` | 3D models: `.glb`, `.obj`, `.wtf` | `WTF/<Category>/`, `OBJ/` |
| `Grids/<Category>/` | LIB_BIT 0/1 grids: sprites, fonts, maps, tiles | (new) |
| `Images/`, `Sounds/`, `Fonts/` | Bitmaps, audio, fonts | `Images/`, `Sounds/`, `FontPngs/` |
| `Emitters/` | Particle presets | `Emitters/` |
| `Shaders/` | Shaders | `Shaders/` |
| `Procedures/` | Parameter sets that generate assets (procedure first) | (new) |
| `Help/` | Readmes and docs, as text | `Help/` |
| `Users/<name>/` | Saves, settings, high scores | `Users/` |
| `Work/Snapshots/` | Screenshots (now `C:\LIB_MCP\*.png`) | |
| `Work/Logs/` | Error logs, raylib log, bench checks (now `C:\LIB_MCP`, `C:\xt3d`) | |
| `Work/Reports/` | Engine reports (now `Documents\Vibecode3D\REPORT_*.txt`) | |
| `Work/Harvests/` | XTJSON harvests of stacks | |
| `Work/Exports/` | Anything written for another program | `OBJ/` timestamp files |
| `Work/Inbox/` | The default for "Save as..." when nothing else fits: one place to sort later | |

Model categories start from iGame3D's 33 WTF categories (Characters, Vehicles_air,
Buildings, Weapons, Furniture, ...): see `_manifest/WTF_INDEX.md`.

## 3. Rules (from what went wrong in 2008)

1. **One spelling, exact case.** iGame3D had `Data/WTF/` and `Data/Wtf/` (breaks on
   case-sensitive disks).
2. **No copies side by side** (`Mapper2..5`, `...worksok.fl`, `kopie`). Use git or a
   `versions/` folder.
3. **Names say what it is.** No timestamp-only names (`OBJ/1205112340.obj`). When a date is
   needed, put it first and readable: `2026-11-12_1430_canyon_run.png`.
4. **Generated output goes in `Work/`**, never next to sources.
5. **Every folder has a `MANIFEST.md`**: what belongs here, who writes it. XTJSON harvests and
   the release checklist check against these.
6. **Every load and save goes through one handler set** (below), so the default is
   automatic: a tool that does not know where to save uses `Work/Inbox/`, not the
   current `defaultFolder`.

## 4. The handlers: LIB_DATA

```
start using stack ".../lib_data.livecodescript"
put Data.Root() into tRoot                      -- finds or creates the root
put Data.Path("Models", "Vehicles_air/heli.glb") into tFile   -- full path, folder made
put Data.Folder("Snapshots") into tFolder       -- ensures it exists, returns it
put Data.SaveText("Reports", "canyon_fps.txt", tText, true) into tFile   -- dated name
answer file "Open a model" with Data.Folder("Models")   -- dialogs start in the right place
```

Kinds map to folders by the table in §2, so `"Snapshots"` means `Work/Snapshots`.
Built: `~/projects/LIB_DATA` (29 tests pass). Python tools (xtalk_py, Spark runners) will get
the same layout from a `data_layout.json`.

## 5. Open decisions

- Development output now in `C:\LIB_MCP` (snapshots, error logs): move into `Work/Snapshots`
  and `Work/Logs` (the dev server's tokens stay). `C:\xt3d\extension` stays: LiveCode loads
  the xt3d extension from that fixed path.
- Mapping the old iGame3D folders in: `Levels` -> `Games`, `Fluid` -> `Tools`, `WTF`/`OBJ` ->
  `Models`, once the Spark manifest run is reviewed.
