# LIB_ig3d: the knowledge base

Where the worlds converge: iGame3D (2007-2008, Lua) as reference and template for what we build
now (iGame3D XT on the Vibecode3D core, xRay on xt3d, xtalk_py). This folder holds what we
**know**: the old engine's words, what to rebuild, how the Data folder is laid out, how a game is
planned. What we **build** from that knowledge now lives elsewhere (section 3).

Rewritten Monday, November 16, 2026 (Claude, Fable 5.2) as a map. Nothing was deleted or moved
in this rewrite: section 4 lists what is stale and what is duplicated, for the owner to decide.
The owner's brief is `about_LIB_ig3d.txt`: procedural generation and scripting first; mouse-driven
mesh editing is not a priority; "all the tools you need in one place for free".

## 1. Start here

| You want | Read |
|---|---|
| what an old iGame3D call or word meant | `GLOSSARY.md` |
| what a game may ask an engine to do, on any of the four editions | `ENGINE_CONTRACT.md` |
| where files go on a player's disk | `DATA_FOLDER.md`, then `../LIB_DATA/README.md` (the library) and `../LIB_PUBLIC/install/LAYOUT.md` (an installed PC) |
| how to plan a new game before coding it | `GDD_OUTLINE_A88.md` |
| what the old main window had, and where each part went | `MAIN_UI_REUSE.md` |
| to run the 2007 engine itself | `IGAME3D_EXTERNAL.md`, `IGAME3D_EXTERNAL_API.md` |
| the editor that came out of all this | `../LIB_EDITOR/iGame3D_XT/` (its release: `RELEASE_CHECKLIST.md` there) |

## 2. Every file, what it is for, and how fresh it is

| File | What it is for | Made | State on 16 Nov |
|---|---|---|---|
| `about_LIB_ig3d.txt` | the owner's brief: use the 2008 Data folder's structure as the list of what an engine needs | owner, 12 Nov | **current** (the brief stands) |
| `README.md` | this map | 16 Nov | current |
| `ENGINE_CONTRACT.md` + `tools/contract_check.py`, `tools/test_contract_check.py` | every call a game may make and every message an engine sends, for the four editions (iGame3D XT, xRay, Box2DXT, xRayBox); the debts (games reaching into an engine's insides); the checker and its test | Fable, 16 Nov | **current** (merged; check with `python3 -I tools/contract_check.py`) |
| `GLOSSARY.md` | part 1: the 218 engine calls of the 2008 help, each with its help text and an empty column for its xt3d / Vibecode3D name. Part 2: 574 terms from Spark's drafts (Spark's reading, not checked word by word) | generated, 14 Nov | **frozen**. Its generator moved (section 3) and the 2008 texts it reads are no longer on disk, so it cannot be made again as things are. The "new name" column was never filled; `ENGINE_CONTRACT.md` is where new names are decided now |
| `PROCEDURES.md` | per 2008 folder, what Spark thought should be code instead of files; a Status column for the owner | generated, 14 Nov | **overtaken**. The Status column was never filled; the owner decided the same question group by group on 16 Nov in `../LIB_EDITOR/iGame3D_XT/ASSET_CHECKLIST.tsv` and `STANDALONE_PLAN.md` (generate / replace / convert / keep / hold / remove). Still useful as a list of the old Lua routines by folder |
| `DATA_FOLDER.md` | the design of the one Data folder: where it lives, its layout, six rules learned from 2008, the LIB_DATA handlers | draft, 12 Nov | **mostly current, three stale spots**: it points at `LIB_GAMES/igame3D_2008_Texts/_manifest` (moved, section 3); its "open decisions" predate the forwarding note (`Moved to:` in ROOT.md, LIB_DATA) and the installed layout (`LIB_PUBLIC/install/LAYOUT.md`); the player's notes folder (`Games/<Game>/LIB_LLM/`) is not in its table |
| `Data/Core/Vibecode3D_core.livecodescript` | the owner's stand-in of 12 Nov for "one file that registers every engine command", as the old `core.lua` did | owner, 12 Nov | **stale snapshot**: it is the Vibecode3D engine script of 11 Nov with a two-line note on top (it differs from `../Vibecode3D/livecode/VIBECODE3D_LIB_MCP_11_11_2026_647PM.livecodescript` in a few dozen lines). The engine has moved on since; the idea it stands for is now `ENGINE_CONTRACT.md` |
| `IGAME3D_EXTERNAL.md` | how the 2007 engine external fits together and what it took to start it once (13 Nov) | 13 Nov | **current as history**. The owner: it stays "what was tried 20 years ago" and a template; we do not develop it. It names `LIB_GAMES/igame3D_2008_Texts` (no longer on disk) |
| `IGAME3D_EXTERNAL_API.md` | the external's 123 commands and 53 functions, names only | 13 Nov | **current**; overlaps `GLOSSARY.md` part 1, which has the same `ig3d_` names with their help text (section 4) |
| `MAIN_UI_REUSE.md` | the 2007/2026 main window, stack by stack: keep / adapt / junk, and where each part goes; the owner's answers of 15 Nov | 13-15 Nov | **verdicts current, "where it is" stale**: the editor it describes was in LIB_GAMES (branch `ig3d-ui-remake`); it is now `../LIB_EDITOR/iGame3D_XT/`. Its five TODOs became A-84 to A-88 and are done. Its "Next" lists are finished or dropped |
| `GDD_OUTLINE_A88.md` | the game design document outline from the old GameOverViewData tabs, with Vector Toss as the worked example | 15 Nov | **current**. Used by Vector Toss (its script points here). A possible later home: LIB_HOWTO, when tutorials open with one |
| `livecode/v3d_inspector.livecodescript`, `v3d_models.livecodescript`, `v3d_skins.livecodescript` | the editor's tool windows as first written here (15 Nov) | 15 Nov | **superseded** by `../LIB_EDITOR/iGame3D_XT/Tools/` (section 4) |

## 3. What moved out since 12 Nov, and where to look now

| Was here, or was planned to land here | Now lives in | Since |
|---|---|---|
| The editor's tool windows (`livecode/v3d_*`) | `LIB_EDITOR/iGame3D_XT/Tools/` (the editor opens those first; it also has `v3d_buildings`, `v3d_props`, `v3d_figures`, `window_shape`) | 16 Nov |
| The remade editor itself (described in `MAIN_UI_REUSE.md` as a LIB_GAMES game) | `LIB_EDITOR/iGame3D_XT/Vibecode3D_Play_Ig3dEditor.livecodescript`: a tool, not a game, never in the game launcher. The edition before it: LIB_EDITOR tag `edition/known-works` | 16 Nov |
| The 2008 survey (Spark's manifest, the WTF index) and the tool that writes `GLOSSARY.md` / `PROCEDURES.md` | `LIB_EDITOR/iGame3D_XT/_manifest_2008/` (`tools/build_glossary.py`). The tool still expects to sit inside the 2008 texts folder; from its new home it would write to the wrong place | 16 Nov |
| The 2008 Data folder itself (the texts these documents quote) | removed from disk on 16 Nov; kept whole in LIB_GAMES (commit 5a62a5d, tag `archive/ig3d-editor-works`). The names of everything in it: `LIB_EDITOR/iGame3D_XT/INVENTORY.md` | 16 Nov |
| "What to rebuild as code" (the decision `PROCEDURES.md` was waiting for) | `LIB_EDITOR/iGame3D_XT/ASSET_CHECKLIST.tsv` and `STANDALONE_PLAN.md` | 16 Nov |
| The old Lua hooks, as something you can run | `LIB_EDITOR/iGame3D_XT/Data/Scripts/LEVEL_API.txt` (the level commands in xTalk) | 16 Nov |
| The Data folder as a working library | `LIB_DATA` (`Data.Root`, `Data.SetRoot`, the forwarding note) | 12-16 Nov |
| Where everything goes on a player's PC; what real people do to an install | `LIB_PUBLIC/install/` (`LAYOUT.md`, `vibeinstall.py`, `ESCAPES_RESULTS.md`), the Library program in `LIB_PUBLIC/launcher/` | 15-16 Nov |
| The "smooth use" release checklist the owner asked for | `LIB_EDITOR/iGame3D_XT/RELEASE_CHECKLIST.md` | 16 Nov |
| How we speak in public (xTalk, the HyperCard family; the product names) | `LIB_PUBLIC` (`index.html`, its README) | 12 Nov on |
| Genetic Anomaly and the Galactica reference (generic data, labels, self-writing scripts) | `LIB_GAD` (`GeneticAnomaly/`, `GAD_ESSENCE_AND_VARIABLES.md`, `GENERICA_TEMPLATE.md`); it was never in this folder, but it is the other place "shared framework" questions get answered | 16 Nov |
| Motion clips the old engine used | `LIB_MOCAP` / `LIB_BVH` (only the clips the games use were kept) | 16 Nov |

## 4. Duplicates and stale copies: listed, nothing deleted

For the owner to decide. "Suggested" is only a suggestion.

| # | What | The facts | Suggested |
|---|---|---|---|
| 1 | `livecode/v3d_inspector.livecodescript` | the same, byte for byte, as `LIB_EDITOR/iGame3D_XT/Tools/v3d_inspector.livecodescript` | retire this copy, after test t17 (which still reads it from here) is pointed at LIB_EDITOR |
| 2 | `livecode/v3d_models.livecodescript` | the same, byte for byte, as the LIB_EDITOR copy | retire with 1 |
| 3 | `livecode/v3d_skins.livecodescript` | **older**: 315 lines here, 693 in LIB_EDITOR (Replace With Model was reworked there on 16 Nov). Anything opening this one gets the old tool | retire with 1; until then it is a trap |
| 4 | the editor's last fallback | `Ig.ToolFile` in the editor still falls back to `LIB_ig3d/livecode/` when its own `Tools/` is missing | remove the fallback (release checklist step C5), then 1-3 can go |
| 5 | `Data/Core/Vibecode3D_core.livecodescript` (300 KB) | the owner's file: the Vibecode3D script of 11 Nov plus his two-line note. Nothing reads it | keep the two-line note as an idea in `ENGINE_CONTRACT.md` or here; move the file to `LIB_LLMOUT/Read/LIB_ig3d/` when the owner says |
| 6 | `IGAME3D_EXTERNAL_API.md` and `GLOSSARY.md` part 1 | both list the external's `ig3d_` calls: the API file has all 176 names with no text; the glossary has those the 2008 help describes, with the text | keep both: the API file is the full list, the glossary the meanings. One line in each pointing at the other would do |
| 7 | `PROCEDURES.md` and `LIB_EDITOR/iGame3D_XT/ASSET_CHECKLIST.tsv` | the same question (file or code?) asked twice; only the checklist was answered | mark `PROCEDURES.md` "answered in the checklist" at its top; keep it as the list of old routines |
| 8 | `README.md` rows written twice | the `engine-contract` work adds one row for `ENGINE_CONTRACT.md` to the old README; this rewrite already carries that row | done 18 Nov: this file was kept whole in the merge |
| 9 | `DATA_FOLDER.md` section 4 and `LIB_DATA/README.md` | the handler list is in both; LIB_DATA's is the one kept up to date | leave the design here, trim the handler list to a pointer |
| 10 | `MAIN_UI_REUSE.md` "Started: the toolbar, remade" and the editor's own header (`TOOLBAR_MAP`, `kTools`) | the icon-to-symbol table is in both; the script's is the one that runs | leave as history; a line at the top saying where the editor lives now |

## 5. Rules for this folder

- It is a knowledge base: documents, not programs. A script that runs belongs to the LIB that
  ships it (LIB_EDITOR for the editor's tools, LIB_DATA for the Data folder).
- A generated document says at its top what made it; do not edit it by hand.
- When something moves out, leave a line in section 3 saying where it went.
- Public wording: xTalk, from the HyperCard family; iGame3D with a capital D; the lowercase x
  inside a name (xRay), "XT" in capitals when it stands alone.
