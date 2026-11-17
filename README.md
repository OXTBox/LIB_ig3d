# LIB_ig3d

Where the worlds converge: iGame3D (2007-2008, Lua 5.1) as reference and template for
Vibecode3D, xt3d and xtalk_py. The 2008 `Data` folder structure is the plan of engine
categories and the job list (`about_LIB_ig3d.txt`). Procedural generation and scripting come
first; mouse-driven mesh editing is not a priority.

| File | What |
|---|---|
| `about_LIB_ig3d.txt` | the owner's brief |
| `DATA_FOLDER.md` | draft: one default Data folder on disk where every engine, tool and library loads and saves |
| `Data/` | that folder's structure |
| `GLOSSARY.md` | 2008 engine calls and terms; **generated** by `LIB_GAMES/igame3D_2008_Texts/_manifest/tools/build_glossary.py` |
| `PROCEDURES.md` | what to rebuild as code instead of carrying files; **generated** by the same tool, Status column for the owner |
| `ENGINE_CONTRACT.md` | every call a game may make and every message an engine sends, for the four editions (iGame3D XT, xRay, Box2DXT, xRayBox); the debts (games reaching into engine internals). Checked by `tools/contract_check.py` (`python3 -I tools/contract_check.py`, test: `tools/test_contract_check.py`) |
| `IGAME3D_EXTERNAL.md`, `IGAME3D_EXTERNAL_API.md` | the iGame3D LiveCode external and its API |
| `MAIN_UI_REUSE.md` | what to reuse from the iGame3D main UI (TODO A-83) |
