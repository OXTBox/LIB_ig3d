-- v3d_skins.livecodescript: "Replace with model..." for the Vibecode3D editor (TODO A-86, Opus 15 Nov 2026).
-- The owner: "a little UI to replace the placeholder geometry in TemplateGames and save the choices to an
-- alternate 'Skin' would be awesome."
-- SOURCE OF TRUTH: this file. Built by code on a new stack each time (the editor's Edit > Replace With
-- Model..., Ig.OpenTool in the Ig3dEditor card):
--   create invisible stack "V3D_Skins"; set its script to this file; send "Skins.Build <projects>" to it
-- HOW IT WORKS
--   Game: a Vibecode3D game (LIB_GAMES/Vibecode3D_Games/Vibecode3D_Play_<Game>.livecodescript). Its placeholder
--   meshes are the names it gives Mesh.Define ("Fuel.Car", "GA.Town" ...), listed on the left.
--   Models: the iGame3D .wtf models (LIB_GAMES/igame3D_2008_Texts/WTF), with a wire preview.
--   Assign puts a model on a mesh; Save writes Skins/<Game>/<skin>.skin.txt (mesh TAB model, relative to
--   projects); "Play with this skin" writes Skins/<Game>/ACTIVE.txt; "Placeholders" empties it.
--   The Game Player reads ACTIVE.txt (GL.LoadSkin) and the engine's Mesh.Define swaps the meshes,
--   scaling each model to its placeholder's size. The game's own script is never changed.
-- Uses me, never this stack (a stack script's "this stack" is the default stack, which may be another).

local sRoot, sMeshes, sAssign, sModels, sCurMesh, sCurModel

on closeStackRequest
   set the destroyStack of me to true
   pass closeStackRequest
end closeStackRequest

command Skins.Build pRoot
   local tG
   put pRoot into sRoot
   if "v3d_models" is not among the lines of the stacksInUse then start using stack (sRoot & "/LIB_ig3d/livecode/v3d_models.livecodescript")
   set the defaultStack to the short name of me
   lock screen
   lock messages
   set the title of me to "Replace With Model (Vibecode3D skins)"
   set the width of me to 820
   set the height of me to 520
   set the resizable of me to false
   set the backgroundColor of me to "30,30,34"
   set the foregroundColor of me to "220,220,224"
   Skins.Make "label", "GameLabel", "8,8,60,30", "Game"
   Skins.Make "field", "Game", "64,8,260,30", "FuelLine"
   set the script of field "Game" to "on returnInField" & return & "   Skins.LoadGame" & return & "end returnInField" & return & \
         "on enterInField" & return & "   Skins.LoadGame" & return & "end enterInField"
   Skins.Make "button", "LoadGame", "264,8,330,30", "Load"
   set the script of button "LoadGame" to "on mouseUp" & return & "   Skins.LoadGame" & return & "end mouseUp"
   Skins.Make "label", "MeshTitle", "8,38,330,58", "Placeholder meshes (what the game defines)"
   Skins.Make "list", "Meshes", "8,60,330,400", empty
   set the tabStops of field "Meshes" to 130
   set the script of field "Meshes" to "on mouseUp" & return & "   Skins.PickMesh the hilitedLine of me" & return & "end mouseUp"
   Skins.Make "button", "Assign", "8,406,166,430", "Assign the model"
   set the script of button "Assign" to "on mouseUp" & return & "   Skins.Assign" & return & "end mouseUp"
   Skins.Make "button", "Unassign", "172,406,330,430", "Back to placeholder"
   set the script of button "Unassign" to "on mouseUp" & return & "   Skins.Unassign" & return & "end mouseUp"
   Skins.Make "label", "ModelTitle", "340,38,560,58", "Models (iGame3D .wtf)"
   Skins.Make "field", "ModelFilter", "340,60,560,82", empty
   set the tooltip of field "ModelFilter" to "Part of a name, then Return"
   set the script of field "ModelFilter" to "on returnInField" & return & "   Skins.ListModels" & return & "end returnInField" & return & \
         "on enterInField" & return & "   Skins.ListModels" & return & "end enterInField"
   Skins.Make "list", "Models", "340,86,560,430", empty
   set the script of field "Models" to "on mouseUp" & return & "   Skins.PickModel the hilitedLine of me" & return & "end mouseUp"
   create graphic "PreviewBack"
   set the style of graphic "PreviewBack" to "rectangle"
   set the filled of graphic "PreviewBack" to true
   set the backgroundColor of graphic "PreviewBack" to "16,16,20"
   set the foregroundColor of graphic "PreviewBack" to "70,70,80"
   set the rect of graphic "PreviewBack" to 570, 38, 812, 280
   create graphic "Preview"
   set the style of graphic "Preview" to "line"
   set the foregroundColor of graphic "Preview" to "64,224,255"
   Skins.Make "label", "ModelInfo", "570,284,812,304", empty
   Skins.Make "label", "SkinLabel", "570,316,640,338", "Skin name"
   Skins.Make "field", "SkinName", "644,316,812,338", "alt1"
   Skins.Make "button", "SaveSkin", "570,344,690,368", "Save skin"
   set the script of button "SaveSkin" to "on mouseUp" & return & "   Skins.Save" & return & "end mouseUp"
   Skins.Make "button", "OpenSkin", "694,344,812,368", "Open skin"
   set the script of button "OpenSkin" to "on mouseUp" & return & "   Skins.Open" & return & "end mouseUp"
   Skins.Make "button", "UseSkin", "570,374,812,398", "Play with this skin"
   set the script of button "UseSkin" to "on mouseUp" & return & "   Skins.SetActive true" & return & "end mouseUp"
   Skins.Make "button", "UsePlace", "570,404,812,428", "Play with placeholders"
   set the script of button "UsePlace" to "on mouseUp" & return & "   Skins.SetActive false" & return & "end mouseUp"
   Skins.Make "note", "Help", "8,438,812,486", "Pick a mesh on the left and a model in the middle, then Assign. Save the skin, then 'Play with this skin': the Game Player uses the models in place of those meshes, each scaled to the placeholder's size. The game's script is not changed."
   Skins.Make "label", "Status", "8,494,812,516", empty
   unlock messages
   set the loc of me to the screenLoc
   set the visible of me to true
   unlock screen
   Skins.ListModels
   Skins.LoadGame
end Skins.Build

command Skins.Make pKind, pName, pRect, pText
   local tObj
   if pKind is "button" then
      create button pName
      put it into tObj
      set the label of tObj to pText
      set the backgroundColor of tObj to "42,42,48"
   else
      create field pName
      put it into tObj
      if pKind is among the items of "label,note" then
         set the lockText of tObj to true
         set the traversalOn of tObj to false
         set the showBorder of tObj to false
         set the opaque of tObj to false
         set the dontWrap of tObj to (pKind is "label")
      else
         set the backgroundColor of tObj to "42,42,48"
         if pKind is "list" then
            set the listBehavior of tObj to true
            set the lockText of tObj to true
            set the dontWrap of tObj to true
            set the vScrollbar of tObj to true
         end if
      end if
      set the text of tObj to pText
   end if
   set the rect of tObj to pRect
   set the foregroundColor of tObj to "220,220,224"
   set the borderColor of tObj to "70,70,80"
   set the hiliteColor of tObj to "60,100,160"
end Skins.Make

command Skins.Status pText
   put pText into field "Status" of me
end Skins.Status

-------------------------------------------------------------------- the game and its meshes

function Skins.Game
   return word 1 to -1 of field "Game" of me
end Skins.Game

function Skins.GameFile pGame
   return sRoot & "/LIB_GAMES/Vibecode3D_Games/Vibecode3D_Play_" & pGame & ".livecodescript"
end Skins.GameFile

function Skins.Dir pGame
   return sRoot & "/LIB_GAMES/Vibecode3D_Games/Skins/" & pGame
end Skins.Dir

-- the names the game gives Mesh.Define as plain quoted text (names built at run time are not found)
function Skins.MeshNames pScript
   local tLine, tOut, tStart, tName
   repeat for each line tLine in pScript
      put offset("Mesh.Define " & quote, tLine) into tStart
      if tStart is 0 then next repeat
      if char 1 to 2 of word 1 to -1 of tLine is "--" then next repeat
      put char tStart + 13 to -1 of tLine into tName
      put char 1 to offset(quote, tName) - 1 of tName into tName
      if tName is not empty and not (tName is among the lines of tOut) then put tName & return after tOut
   end repeat
   return tOut
end Skins.MeshNames

command Skins.LoadGame
   local tFile, tActive
   put Skins.GameFile(Skins.Game()) into tFile
   if there is not a file tFile then
      Skins.Status "No game script:" && tFile
      exit Skins.LoadGame
   end if
   put Skins.MeshNames(textDecode(url ("binfile:" & tFile), "UTF-8")) into sMeshes
   put empty into sAssign
   put empty into sCurMesh
   put url ("file:" & Skins.Dir(Skins.Game()) & "/ACTIVE.txt") into tActive
   put word 1 to -1 of line 1 of tActive into tActive
   if tActive is not empty then
      put tActive into field "SkinName" of me
      Skins.Open
   end if
   Skins.ShowMeshes
   if tActive is empty then
      Skins.Status Skins.Game() & ":" && the number of lines of sMeshes && "placeholder meshes; playing with placeholders"
   else
      Skins.Status Skins.Game() & ":" && the number of lines of sMeshes && "placeholder meshes; playing with skin" && tActive
   end if
end Skins.LoadGame

command Skins.ShowMeshes
   local tName, tOut
   repeat for each line tName in sMeshes
      put tName & tab & Skins.Short(sAssign[tName]) & return after tOut
   end repeat
   delete the last char of tOut
   put tOut into field "Meshes" of me
end Skins.ShowMeshes

function Skins.Short pRel
   if pRel is empty then return "(placeholder)"
   set the itemDelimiter to "/"
   return item -1 of pRel
end Skins.Short

command Skins.PickMesh pN
   if pN is empty then exit Skins.PickMesh
   put line pN of sMeshes into sCurMesh
   if sAssign[sCurMesh] is not empty then Skins.Preview sRoot & "/" & sAssign[sCurMesh]
   Skins.Status sCurMesh & ":" && Skins.Short(sAssign[sCurMesh])
end Skins.PickMesh

-------------------------------------------------------------------- models

function Skins.ModelRoot
   return sRoot & "/LIB_GAMES/igame3D_2008_Texts/WTF"
end Skins.ModelRoot

command Skins.ListModels
   local tAll, tWant
   put Model.List(Skins.ModelRoot()) into tAll
   put word 1 to -1 of field "ModelFilter" of me into tWant
   if tWant is not empty then filter tAll with "*" & tWant & "*"
   put tAll into sModels
   put tAll into field "Models" of me
end Skins.ListModels

command Skins.PickModel pN
   if pN is empty then exit Skins.PickModel
   put line pN of sModels into sCurModel
   Skins.Preview Skins.ModelRoot() & "/" & sCurModel
end Skins.PickModel

command Skins.Preview pPath
   local tInfo
   set the points of graphic "Preview" of me to Model.PreviewPoints(pPath, 572, 40, 238)
   put Model.Info(pPath) into tInfo
   set the itemDelimiter to "/"
   put item -1 of pPath & ":" && word 1 of tInfo && "vertices," && word 2 of tInfo && "edges" into field "ModelInfo" of me
end Skins.Preview

-------------------------------------------------------------------- assign, save, open, play

command Skins.Assign
   if sCurMesh is empty or sCurModel is empty then
      Skins.Status "Pick a mesh on the left and a model in the middle first"
      exit Skins.Assign
   end if
   put "LIB_GAMES/igame3D_2008_Texts/WTF/" & sCurModel into sAssign[sCurMesh]
   Skins.ShowMeshes
   Skins.Status sCurMesh && "->" && sCurModel && "(not saved yet)"
end Skins.Assign

command Skins.Unassign
   if sCurMesh is empty then exit Skins.Unassign
   delete variable sAssign[sCurMesh]
   Skins.ShowMeshes
   Skins.Status sCurMesh && "back to its placeholder (not saved yet)"
end Skins.Unassign

function Skins.SkinFile
   local tName
   put word 1 to -1 of field "SkinName" of me into tName
   replace "/" with "_" in tName
   replace space with "_" in tName
   if tName is empty then return empty
   return Skins.Dir(Skins.Game()) & "/" & tName & ".skin.txt"
end Skins.SkinFile

command Skins.Save
   local tFile, tOut, tName, tParent
   put Skins.SkinFile() into tFile
   if tFile is empty then
      Skins.Status "Give the skin a name first"
      exit Skins.Save
   end if
   put sRoot & "/LIB_GAMES/Vibecode3D_Games/Skins" into tParent
   if there is not a folder tParent then create folder tParent
   if there is not a folder Skins.Dir(Skins.Game()) then create folder Skins.Dir(Skins.Game())
   put "# Skin for" && Skins.Game() & ": mesh name TAB model file (relative to projects). Made by Replace With Model (A-86)." & return into tOut
   repeat for each line tName in sMeshes
      if sAssign[tName] is not empty then put tName & tab & sAssign[tName] & return after tOut
   end repeat
   put textEncode(tOut, "UTF-8") into url ("binfile:" & tFile)
   Skins.Status "Saved" && tFile
end Skins.Save

command Skins.Open
   local tFile, tLine
   put Skins.SkinFile() into tFile
   if tFile is empty or there is not a file tFile then
      Skins.Status "No skin file:" && tFile
      exit Skins.Open
   end if
   put empty into sAssign
   set the itemDelimiter to tab
   repeat for each line tLine in textDecode(url ("binfile:" & tFile), "UTF-8")
      if tLine is empty or char 1 of tLine is "#" then next repeat
      put item 2 of tLine into sAssign[item 1 of tLine]
   end repeat
   Skins.ShowMeshes
   Skins.Status "Opened" && tFile
end Skins.Open

-- which skin the Game Player uses for this game: this one (saved first) or none
command Skins.SetActive pUse
   local tDir
   put Skins.Dir(Skins.Game()) into tDir
   if pUse then
      Skins.Save
      if Skins.SkinFile() is empty then exit Skins.SetActive
      set the itemDelimiter to "/"
      put char 1 to -10 of item -1 of Skins.SkinFile() into url ("file:" & tDir & "/ACTIVE.txt")
      Skins.Status Skins.Game() && "now plays with the skin" && char 1 to -10 of item -1 of Skins.SkinFile()
   else
      if there is a folder tDir then put empty into url ("file:" & tDir & "/ACTIVE.txt")
      Skins.Status Skins.Game() && "now plays with its placeholders"
   end if
end Skins.SetActive

-- tests: one line
function Skins.State
   local tN, tK
   put 0 into tN
   repeat for each key tK in sAssign
      add 1 to tN
   end repeat
   return Skins.Game() & "|" & the number of lines of sMeshes & "|" & tN & "|" & the number of lines of sModels & "|" & sCurMesh & "|" & sCurModel
end Skins.State
