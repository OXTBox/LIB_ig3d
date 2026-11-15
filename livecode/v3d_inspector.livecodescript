-- v3d_inspector.livecodescript: the Vibecode3D editor's Inspector (TODO A-84, Opus 15 Nov 2026).
-- The owner (MAIN_UI_REUSE, 15 Nov 4:17): "Window > Inspector as one card per object kind ... set up the
-- cards and their UIs, with placeholder scripts that we'll fill in when we are challenged with a need ...
-- Obviously a BVH/bones animation previewer, key frame clipper (ie, stop the animation before the
-- ubiquitous weird glitch part), and apply them to game's Animation List to be inherited by models,
-- instead of embedded directly in them." Only what games and procedural assets need ("Blender stays king").
--
-- SOURCE OF TRUTH: this file. The window is built by code on a brand-new stack each time it opens
-- (the editor's Window > Inspector, Ig.OpenInspector in the Ig3dEditor card, does this):
--   create invisible stack "V3D_Inspector"; set its script to this file; send "Insp.Build <projects>" to it
-- It is never "start using"d: as a library its closeStackRequest would catch every stack's.
-- PAGES (drawn tab buttons along the top; one page = one group, like the 2008 Inspector's cards)
--   Object     the selected object (global gV3DSelected, set by the editor): key, mesh, position, colour. Real.
--   Animation  REAL: LIB_MOCAP clips (every LIB_BVH file has a _stick.txt twin) as a moving skeleton,
--              a frame slider, Play, In / Out, Loop; Add to the game's Animation List
--              (LIB_GAMES/Vibecode3D_Games/Animations/<Game>.anims.txt, read by LIB_MOCAP anim_list).
--   Material, Colours, Bones, Mesh   placeholders: the 2008 fields, wired when a game needs them.
-- Never names its own stack in code except to open it: uses me (in a stack script, this stack is the DEFAULT stack, which a timer or the editor may change).

constant kStack = "V3D_Inspector"
constant kPages = "Object,Animation,Material,Colours,Bones,Mesh"
local sRoot          -- the projects folder
local sClip          -- [names|parents|edges|fps|frames|joints|f,<n>] the clip on the Animation page
local sClipName, sFrame, sMarkIn, sMarkOut, sPlaying, sView, sClipList

-------------------------------------------------------------------- open, build

on closeStackRequest
   put false into sPlaying
   set the destroyStack of me to true
   pass closeStackRequest
end closeStackRequest

command Insp.Build pRoot
   local tPage, x, i
   put pRoot into sRoot
   set the defaultStack to the short name of me
   lock screen
   lock messages
   set the title of me to "Inspector (Vibecode3D)"
   set the width of me to 760
   set the height of me to 540
   set the resizable of me to false
   set the backgroundColor of me to "30,30,34"
   set the foregroundColor of me to "220,220,224"
   -- the tab row
   put 8 into x
   repeat for each item tPage in kPages
      create button ("Tab_" & tPage)
      set the label of button ("Tab_" & tPage) to tPage
      set the rect of button ("Tab_" & tPage) to x, 8, x + 100, 32
      set the script of button ("Tab_" & tPage) to "on mouseUp" & return & "   Insp.Page the label of me" & return & "end mouseUp"
      Insp.Colour the long id of button ("Tab_" & tPage)
      add 104 to x
   end repeat
   Insp.BuildObject
   Insp.BuildAnimation
   repeat for each item tPage in "Material,Colours,Bones,Mesh"
      Insp.BuildPlaceholder tPage
   end repeat
   Insp.Make "label", "Status", "8,512,752,534", empty, empty
   unlock messages
   set the loc of me to the screenLoc
   set the visible of me to true
   unlock screen
   Insp.Page "Object"
end Insp.Build

-- one control: label / note / field / list / button / check, optionally in a group (a page)
command Insp.Make pKind, pName, pRect, pText, pGroup
   local tObj
   if pKind is among the items of "button,check" then
      if pGroup is empty then
         create button pName
      else
         create button pName in group pGroup
      end if
      put it into tObj
      set the label of tObj to pText
      if pKind is "check" then
         set the style of tObj to "checkbox"
      end if
   else
      if pGroup is empty then
         create field pName
      else
         create field pName in group pGroup
      end if
      put it into tObj
      if pKind is among the items of "label,note" then
         set the lockText of tObj to true
         set the traversalOn of tObj to false
         set the showBorder of tObj to false
         set the opaque of tObj to false
         set the dontWrap of tObj to (pKind is "label")
      else if pKind is "list" then
         set the listBehavior of tObj to true
         set the lockText of tObj to true
         set the dontWrap of tObj to true
         set the vScrollbar of tObj to true
      end if
      set the text of tObj to pText
   end if
   set the rect of tObj to pRect
   Insp.Colour tObj
end Insp.Make

-- the dark look without needing LIB_THEME loaded (the same colours as its dark.txt)
command Insp.Colour pObj
   if word 1 of the name of pObj is "field" and the opaque of pObj then
      set the backgroundColor of pObj to "42,42,48"
      set the borderColor of pObj to "70,70,80"
   else if word 1 of the name of pObj is "button" then
      set the backgroundColor of pObj to "42,42,48"
      set the borderColor of pObj to "70,70,80"
   end if
   set the foregroundColor of pObj to "220,220,224"
   set the hiliteColor of pObj to "60,100,160"
end Insp.Colour

command Insp.Page pPage
   local tP
   repeat for each item tP in kPages
      if there is a group ("Page_" & tP) of me then set the visible of group ("Page_" & tP) of me to (tP is pPage)
      if tP is pPage then
         set the backgroundColor of button ("Tab_" & tP) of me to "60,100,160"
      else
         set the backgroundColor of button ("Tab_" & tP) of me to "42,42,48"
      end if
   end repeat
   if pPage is "Object" then Insp.ShowObject
   if pPage is "Animation" and sClipList is empty then Insp.ListClips empty
end Insp.Page

command Insp.NewPage pPage
   set the defaultStack to the short name of me
   create group ("Page_" & pPage)
   set the visible of group ("Page_" & pPage) to false
end Insp.NewPage

command Insp.Status pText
   put pText into field "Status" of me
end Insp.Status

-------------------------------------------------------------------- Object (real)

command Insp.BuildObject
   Insp.NewPage "Object"
   Insp.Make "label", "ObjTitle", "8,44,750,66", "The selected object", "Page_Object"
   Insp.Make "note", "ObjInfo", "8,70,750,300", empty, "Page_Object"
   Insp.Make "button", "ObjRefresh", "8,306,120,330", "Refresh", "Page_Object"
   set the script of button "ObjRefresh" to "on mouseUp" & return & "   Insp.ShowObject" & return & "end mouseUp"
end Insp.BuildObject

-- the engine keeps each object in gObjectTransforms[key]; the editor names the selected one in gV3DSelected
command Insp.ShowObject
   global gObjectTransforms, gV3DSelected
   local tKey, tOut, tProp
   if there is not a field "ObjInfo" of me then exit Insp.ShowObject
   put gV3DSelected into tKey
   if tKey is empty or gObjectTransforms[tKey] is not an array then
      put "Nothing selected. Make or load something in the editor (a primitive, or Library > Models), then Refresh." into field "ObjInfo" of me
      exit Insp.ShowObject
   end if
   put "key: " & tKey & return into tOut
   repeat for each line tProp in Insp.SortedKeys(gObjectTransforms[tKey])
      if gObjectTransforms[tKey][tProp] is an array then next repeat
      put tProp & ": " & gObjectTransforms[tKey][tProp] & return after tOut
   end repeat
   put tOut into field "ObjInfo" of me
end Insp.ShowObject

function Insp.SortedKeys pA
   local tK
   put the keys of pA into tK
   sort lines of tK
   return tK
end Insp.SortedKeys

-------------------------------------------------------------------- placeholders (the 2008 Inspector's fields)

command Insp.BuildPlaceholder pPage
   local tFields, tF, y
   switch pPage
      case "Material"
         put "ambient,diffuse,specular,emission,colour (RGBA),UV offset,UV size,UV rotation,smooth,blend,depth test" into tFields
         break
      case "Colours"
         put "background,fog colour,fog near,fog far,grid colour,tint" into tFields
         break
      case "Bones"
         put "bone tree,attach to bone,parent,export bones" into tFields
         break
      case "Mesh"
         put "vertices,edges,export mesh (glTF),combine overlaps,subdivide" into tFields
         break
   end switch
   Insp.NewPage pPage
   Insp.Make "label", pPage & "Title", "8,44,750,66", pPage & ": placeholder (the 2008 Inspector's fields; wired when a game needs them)", "Page_" & pPage
   put 74 into y
   repeat for each item tF in tFields
      Insp.Make "label", pPage & "_L_" & tF, "8," & y & ",200," & y + 22, tF, "Page_" & pPage
      Insp.Make "field", pPage & "_F_" & tF, "210," & y & ",420," & y + 22, empty, "Page_" & pPage
      add 28 to y
   end repeat
end Insp.BuildPlaceholder

-------------------------------------------------------------------- Animation (real): preview, clip, list

command Insp.BuildAnimation
   local tG
   Insp.NewPage "Animation"
   put "Page_Animation" into tG
   Insp.Make "field", "ClipFilter", "8,44,200,66", empty, tG
   set the script of field "ClipFilter" to "on returnInField" & return & "   Insp.ListClips me" & return & "end returnInField" & return & \
         "on enterInField" & return & "   Insp.ListClips me" & return & "end enterInField"
   set the tooltip of field "ClipFilter" to "Type part of a name (jump, catch, throw...) and press Return"
   Insp.Make "list", "Clips", "8,70,200,400", empty, tG
   set the script of field "Clips" to "on mouseUp" & return & "   Insp.LoadClip the value of the clickLine" & return & "end mouseUp"
   -- the preview: one line graphic; an empty line in its points breaks it into the skeleton's bones
   create graphic "Stage" in group tG
   set the style of graphic "Stage" to "rectangle"
   set the filled of graphic "Stage" to true
   set the backgroundColor of graphic "Stage" to "16,16,20"
   set the foregroundColor of graphic "Stage" to "70,70,80"
   set the rect of graphic "Stage" to 210, 44, 530, 364
   create graphic "Skeleton" in group tG
   set the style of graphic "Skeleton" to "line"
   set the lineSize of graphic "Skeleton" to 3
   set the foregroundColor of graphic "Skeleton" to "64,224,255"
   create graphic "Ground" in group tG
   set the style of graphic "Ground" to "line"
   set the foregroundColor of graphic "Ground" to "70,70,80"
   set the points of graphic "Ground" to "214,340" & return & "526,340"
   Insp.Make "button", "ViewFront", "210,370,268,392", "Front", tG
   Insp.Make "button", "ViewSide", "272,370,330,392", "Side", tG
   set the script of button "ViewFront" to "on mouseUp" & return & "   Insp.SetView " & quote & "front" & quote & return & "end mouseUp"
   set the script of button "ViewSide" to "on mouseUp" & return & "   Insp.SetView " & quote & "side" & quote & return & "end mouseUp"
   Insp.Make "label", "ClipInfo", "336,370,750,392", empty, tG
   -- the timeline
   create scrollbar "Frame" in group tG
   set the rect of scrollbar "Frame" to 210, 400, 750, 418
   set the startValue of scrollbar "Frame" to 1
   set the endValue of scrollbar "Frame" to 2
   set the script of scrollbar "Frame" to "on scrollbarDrag pV" & return & "   Insp.ShowFrame round(pV)" & return & "end scrollbarDrag"
   create graphic "InOutBar" in group tG
   set the style of graphic "InOutBar" to "rectangle"
   set the filled of graphic "InOutBar" to true
   set the backgroundColor of graphic "InOutBar" to "64,224,255"
   set the lineSize of graphic "InOutBar" to 0
   set the rect of graphic "InOutBar" to 210, 420, 750, 424
   Insp.Make "button", "Play", "210,430,290,454", "Play", tG
   set the script of button "Play" to "on mouseUp" & return & "   Insp.PlayToggle" & return & "end mouseUp"
   Insp.Make "button", "SetIn", "296,430,376,454", "In here", tG
   set the script of button "SetIn" to "on mouseUp" & return & "   Insp.SetIn" & return & "end mouseUp"
   Insp.Make "button", "SetOut", "382,430,462,454", "Out here", tG
   set the script of button "SetOut" to "on mouseUp" & return & "   Insp.SetOut" & return & "end mouseUp"
   Insp.Make "check", "Loop", "470,430,560,454", "Loop", tG
   set the hilite of button "Loop" to true
   Insp.Make "label", "InOut", "566,430,750,454", empty, tG
   -- the game's Animation List
   Insp.Make "label", "ListTitle", "540,44,750,66", "Game's Animation List", tG
   Insp.Make "field", "Game", "540,70,750,92", "Amazing_Couple", tG
   set the tooltip of field "Game" to "The game (Vibecode3D_Play_<Game>): its list is LIB_GAMES/Vibecode3D_Games/Animations/<Game>.anims.txt"
   set the script of field "Game" to "on returnInField" & return & "   Insp.ShowList" & return & "end returnInField" & return & \
         "on closeField" & return & "   Insp.ShowList" & return & "end closeField"
   Insp.Make "list", "Anims", "540,96,750,300", empty, tG
   set the script of field "Anims" to "on mouseUp" & return & "   Insp.PickAnim the hilitedLine of me" & return & "end mouseUp"
   Insp.Make "field", "AnimName", "540,306,660,328", "jump", tG
   set the tooltip of field "AnimName" to "The name the game asks for (walk, idle, jump, catch...)"
   Insp.Make "button", "AddAnim", "664,306,750,328", "Add", tG
   set the script of button "AddAnim" to "on mouseUp" & return & "   Insp.AddAnim" & return & "end mouseUp"
   Insp.Make "button", "RemoveAnim", "540,334,750,356", "Remove the selected one", tG
   set the script of button "RemoveAnim" to "on mouseUp" & return & "   Insp.RemoveAnim" & return & "end mouseUp"
   Insp.Make "note", "AnimHelp", "8,462,750,508", "Pick a clip, scrub or Play, set In and Out before the glitchy part, name it and Add: the game's list keeps clip + In + Out (the clip itself is not copied into any model).", tG
   put "front" into sView
   put false into sPlaying
end Insp.BuildAnimation

-- the library folder of clips
function Insp.MocapLib
   return sRoot & "/LIB_MOCAP/library"
end Insp.MocapLib

command Insp.ListClips pField
   local tAll, tWant, tF
   put folders(Insp.MocapLib()) into tAll
   filter tAll without ".*"
   if pField is not empty then put word 1 to -1 of the text of pField into tWant
   if tWant is not empty then filter tAll with "*" & tWant & "*"
   sort lines of tAll
   put tAll into sClipList
   put tAll into field "Clips" of me
   Insp.Status the number of lines of tAll && "clips" & (" in " & Insp.MocapLib())
end Insp.ListClips

-- a _stick.txt clip: header lines key,value; '#' comments; then one line a frame: x,y,z per joint
command Insp.LoadClip pName
   local tText, tLine, n, tFile
   if pName is empty then exit Insp.LoadClip
   put Insp.MocapLib() & "/" & pName & "/" & pName & "_stick.txt" into tFile
   if there is not a file tFile then
      Insp.Status "No stick clip:" && tFile
      exit Insp.LoadClip
   end if
   put Insp.ReadStick(tFile) into sClip
   put pName into sClipName
   put 1 into sMarkIn
   put sClip["frames"] into sMarkOut
   set the endValue of scrollbar "Frame" of me to max(2, sClip["frames"])
   put pName & ":" && sClip["frames"] && "frames at" && sClip["fps"] && "fps," && sClip["joints"] && "joints" into field "ClipInfo" of me
   Insp.ShowFrame 1
   Insp.ShowInOut
   Insp.Status "Loaded" && tFile
end Insp.LoadClip

function Insp.ReadStick pFile
   local tA, tLine, n, tKey
   put 0 into n
   repeat for each line tLine in textDecode(url ("binfile:" & pFile), "UTF-8")
      if tLine is empty or char 1 of tLine is "#" then next repeat
      put item 1 of tLine into tKey
      if tKey is a number then
         add 1 to n
         put tLine into tA["f," & n]
      else
         put item 2 to -1 of tLine into tA[tKey]
      end if
   end repeat
   if tA["frames"] is not a number or tA["frames"] > n then put n into tA["frames"]
   return tA
end Insp.ReadStick

command Insp.SetView pView
   put pView into sView
   if sFrame is not empty then Insp.ShowFrame sFrame
end Insp.SetView

-- draw frame pN on the stage: front view = x across, side = z across; y up; fitted to 1.9 m tall
command Insp.ShowFrame pN
   local tLine, tEdge, a, b, tPts, tScale, cx, gy, tAX, tAY, tBX, tBY, tCol
   if sClip["frames"] is not a number then exit Insp.ShowFrame
   put max(1, min(sClip["frames"], pN)) into sFrame
   put sClip["f," & sFrame] into tLine
   put 1 into tCol                 -- x across (front)
   if sView is "side" then put 3 into tCol   -- z across (side)
   put 150 into tScale          -- pixels a metre
   put 370 into cx
   put 340 into gy
   repeat for each word tEdge in sClip["edges"]
      set the itemDelimiter to "-"
      put item 1 of tEdge into a
      put item 2 of tEdge into b
      set the itemDelimiter to comma
      put cx + tScale * item (a * 3 + tCol) of tLine into tAX
      put gy - tScale * item (a * 3 + 2) of tLine into tAY
      put cx + tScale * item (b * 3 + tCol) of tLine into tBX
      put gy - tScale * item (b * 3 + 2) of tLine into tBY
      put round(tAX) & comma & round(tAY) & return & round(tBX) & comma & round(tBY) & return & return after tPts
   end repeat
   lock screen
   set the points of graphic "Skeleton" of me to tPts
   lock messages
   set the thumbPosition of scrollbar "Frame" of me to sFrame
   unlock messages
   unlock screen
end Insp.ShowFrame

command Insp.SetIn
   if sFrame is empty then exit Insp.SetIn
   put sFrame into sMarkIn
   if sMarkOut < sMarkIn then put sClip["frames"] into sMarkOut
   Insp.ShowInOut
end Insp.SetIn

command Insp.SetOut
   if sFrame is empty then exit Insp.SetOut
   put sFrame into sMarkOut
   if sMarkIn > sMarkOut then put 1 into sMarkIn
   Insp.ShowInOut
end Insp.SetOut

-- the In-Out span as a bar under the slider
command Insp.ShowInOut
   local tW, x1, x2
   put "In" && sMarkIn && " Out" && sMarkOut && "(" & sMarkOut - sMarkIn + 1 && "frames)" into field "InOut" of me
   put 540 into tW
   put 210 + round(tW * (sMarkIn - 1) / max(1, sClip["frames"] - 1)) into x1
   put 210 + round(tW * (sMarkOut - 1) / max(1, sClip["frames"] - 1)) into x2
   set the rect of graphic "InOutBar" of me to x1, 420, max(x1 + 2, x2), 424
end Insp.ShowInOut

command Insp.PlayToggle
   put not sPlaying into sPlaying
   if sPlaying then
      set the label of button "Play" of me to "Stop"
      if sFrame < sMarkIn or sFrame >= sMarkOut then put sMarkIn into sFrame
      send "Insp.Tick" to me in 0 milliseconds
   else
      set the label of button "Play" of me to "Play"
   end if
end Insp.PlayToggle

-- playback between In and Out at the clip's fps; loops or stops at Out
command Insp.Tick
   if not sPlaying or there is not a stack kStack then exit Insp.Tick
   if sFrame >= sMarkOut then
      if the hilite of button "Loop" of me then
         Insp.ShowFrame sMarkIn
      else
         Insp.PlayToggle
         exit Insp.Tick
      end if
   else
      Insp.ShowFrame sFrame + 1
   end if
   send "Insp.Tick" to me in round(1000 / max(1, sClip["fps"])) milliseconds
end Insp.Tick

-- the game's Animation List file: name TAB clip TAB in TAB out TAB loop
function Insp.ListFile
   local tGame
   put word 1 to -1 of field "Game" of me into tGame
   if tGame is empty then return empty
   return sRoot & "/LIB_GAMES/Vibecode3D_Games/Animations/" & tGame & ".anims.txt"
end Insp.ListFile

command Insp.ShowList
   local tText, tFile
   put Insp.ListFile() into tFile
   if tFile is not empty and there is a file tFile then put textDecode(url ("binfile:" & tFile), "UTF-8") into tText
   filter tText without "#*"
   filter tText without empty
   put tText into field "Anims" of me
end Insp.ShowList

command Insp.AddAnim
   local tName, tFile, tText, tLine, tOut, tFolder
   put word 1 to -1 of field "AnimName" of me into tName
   replace tab with space in tName
   if tName is empty or sClipName is empty then
      Insp.Status "Pick a clip and give the animation a name first"
      exit Insp.AddAnim
   end if
   put Insp.ListFile() into tFile
   if tFile is empty then
      Insp.Status "Type the game's name first"
      exit Insp.AddAnim
   end if
   put sRoot & "/LIB_GAMES/Vibecode3D_Games/Animations" into tFolder
   if there is not a folder tFolder then create folder tFolder
   if there is a file tFile then put textDecode(url ("binfile:" & tFile), "UTF-8") into tText
   if tText is empty then put "# Animation List (Inspector, LIB_ig3d A-84): name TAB LIB_MOCAP clip TAB in TAB out TAB loop" & return into tText
   -- one line a name: a new clip for a name replaces the old one
   set the itemDelimiter to tab
   repeat for each line tLine in tText
      if tLine is empty then next repeat
      if item 1 of tLine is tName then next repeat
      put tLine & return after tOut
   end repeat
   put tName & tab & sClipName & tab & sMarkIn & tab & sMarkOut & tab & the hilite of button "Loop" of me & return after tOut
   put textEncode(tOut, "UTF-8") into url ("binfile:" & tFile)
   Insp.ShowList
   Insp.Status "Added" && tName && "to" && tFile
end Insp.AddAnim

command Insp.RemoveAnim
   local tN, tName, tFile, tText, tLine, tOut
   put the hilitedLine of field "Anims" of me into tN
   if tN is empty then exit Insp.RemoveAnim
   set the itemDelimiter to tab
   put item 1 of line tN of field "Anims" of me into tName
   put Insp.ListFile() into tFile
   put textDecode(url ("binfile:" & tFile), "UTF-8") into tText
   repeat for each line tLine in tText
      if tLine is empty then next repeat
      if char 1 of tLine is not "#" and item 1 of tLine is tName then next repeat
      put tLine & return after tOut
   end repeat
   put textEncode(tOut, "UTF-8") into url ("binfile:" & tFile)
   Insp.ShowList
   Insp.Status "Removed" && tName
end Insp.RemoveAnim

-- a line of the list: load its clip at its In
command Insp.PickAnim pN
   local tLine
   if pN is empty then exit Insp.PickAnim
   put line pN of field "Anims" of me into tLine
   set the itemDelimiter to tab
   put item 1 of tLine into field "AnimName" of me
   Insp.LoadClip item 2 of tLine
   put item 3 of tLine into sMarkIn
   put item 4 of tLine into sMarkOut
   set the hilite of button "Loop" of me to (item 5 of tLine is true)
   Insp.ShowInOut
   Insp.ShowFrame sMarkIn
end Insp.PickAnim

-- tests: one line
function Insp.State
   local tPts
   put the points of graphic "Skeleton" of me into tPts
   return sClipName & "|" & sClip["frames"] & "|" & sFrame & "|" & sMarkIn & "|" & sMarkOut & "|" & sView & "|" & the number of lines of tPts
end Insp.State
