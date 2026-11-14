# The iGame3D Pro external: how it fits (re-found 2026-11-13)

Tested by Claude in `~/projects/LIB_BIN` (scripts in `LIB_BIN/tests/`). Full API:
`IGAME3D_EXTERNAL_API.md` (123 commands, 53 functions).

## What it is

`iGame3D Pro external.dll` (2 MB, 2007; same as `iGame3D Pro external051707.dll`) is a LiveCode
(Revolution) **external**: the iGame3D engine (OpenGL renderer, Lua 5.1, Newton physics, OpenAL +
Ogg Vorbis sound) packaged so a LiveCode stack can drive it. The LiveCode main UI
(`ig3d_UI_MAIN`, 19 stacks) is the editor around it; Lua scripts in `Data/` are the game logic.
Later iGame3D moved off LiveCode to murgaLua + FLTK (the 2008 `Data/` folder in
`LIB_GAMES/igame3D_2008_Texts`).

## The pieces and where they must be

| Piece | Kind | Must be |
|---|---|---|
| `iGame3D Pro external.dll` | **32-bit** Windows DLL (i386) | in the folder the engine loads externals from: next to the stack that lists it (the stack's `externals` property), or in the engine's `externals/` folder |
| `lua5.1.dll`, `Newton.dll`, `OpenAL32.dll`, `ogg.dll`, `vorbis.dll`, `vorbisenc.dll`, `vorbisfile.dll` | 32-bit DLLs the external links to | where Windows finds them for the process: the same folder as the external, or beside the engine exe (copies also sit in `Data/`) |
| `Data/` | iGame3D's data (Scripts, Levels, WTF models, Shaders, emitters, Images...) | passed to `ig3d_Init_s4i` as its first argument |
| LiveCode engine | **32-bit, 7.1.4 at the latest** (your note: "Livecode_714_is_last_igame3d_external_version") | 64-bit engines (9.6.3 x86_64) can't load a 32-bit DLL |

**Why it seemed broken:** the 7.1.4-only main UI stack lists its external as
`iGame3D Pro external.bundle` (the Mac name). On Windows the engine looks for that name, finds
nothing, and loads no commands. On Windows the list must say `iGame3D Pro external.dll`
(standalones set it per platform). LiveCode's later `Externals` folder plus a list in the
standalone settings was a second way to say the same thing.

## What worked (LiveCode Community Server 7.1.4, 32-bit, run from WSL, headless)

1. A probe stack (`zz_claude_ext_probe.livecode`, next to the DLL) whose `externals` is
   `iGame3D Pro external.dll`, saved and loaded again: **123 commands, 53 functions** loaded.
2. `ig3d_Init_s4i "<...>/Data/", 40, 40, 360, 280`: the engine started (OpenGL 4.6, GLSL,
   ARB fragment programs, 8 texture units) and set its window to that rectangle.
3. `ig3d_ExecuteLua_s_i("print(6*7)")` (a **function**: `_s_i` returns an integer): Lua ran inside
   iGame3D and printed `42`; a second chunk printed `iGame3D Lua says 42 at Fri Nov 13 11:23:31 2026`.
4. On exit the server crashed (signal 11): the engine was never shut down. Next: find the
   shutdown call (likely `ig3d_SetMode_i` or a quit path in the main UI's scripts).

## The calls that matter first

| Call | What |
|---|---|
| `ig3d_Init_s4i dataPath, left, top, right, bottom` | start the engine and its window |
| `ig3d_ExecuteLua_s_i(code)`, `ig3d_ExecuteLuaScript_s_i(file)`, `ig3d_GetLuaOutput__s()` | run Lua inside iGame3D |
| `ig3d_SetMode_i`, `ig3d_UpdateScript_s`, `ig3d_GetStateScript__s` | game mode and the running script |
| `ig3d_SetWindowBounds_4i`, `ig3d_SetupWindowVisibility_b`, `ig3d_ShowWindowTitleBarAndShadow_2b`, `ig3d_SetDrawingWindow_s` | the 3D window |
| `ig3d_CopyGLToRevWindow_4i` | copy the 3D picture into a LiveCode window (how the old UI showed it) |
| `ig3d_Get/SetObjectInfo`, `...CameraInfo`, `...LightInfo`, `...FogInfo`, `...Particle_emitterInfo`, `...Sound_emitterInfo`, `...ObjectBoneInfo` | the scene, read and written by name |

## What this opens

- The 2007 engine can run again, driven from LiveCode 7.1.4 (and from WSL scripts), so the 2008
  Lua scripts and levels Spark is cataloguing can be run, not only read.
- A harness in `LIB_BIN/tests/` can run a level headless-ish and save screenshots (via
  `CopyGLToRevWindow` into an image) for comparison with xt3d and Vibecode3D versions.
