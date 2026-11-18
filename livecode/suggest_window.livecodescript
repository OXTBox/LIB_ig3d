script "SuggestWindow"
-- LIB_ig3d / the suggestion list's first face: one small window (TODO A-99, RENAME_DAY.md).
-- Type "Entity." in the top line and everything under Entity is listed; click a line to read
-- its whole meaning and copy the call. All the thinking is in lib_suggest.livecodescript;
-- the words come from the contract (Data/contract_words.txt, written by tools/make_names.py).
--
-- This is a script-only stack: it has no saved controls, so it makes its three (the same names
-- a .gui layout would use: "typed", "words", "meaning") each time it opens.
-- Open it in OXT-Beyond (File > Open Stack), or:  go stack ".../suggest_window.livecodescript"

on preOpenStack
   SuggestWindow.Build
end preOpenStack

on openStack
   if there is a field "typed" of card 1 of stack "SuggestWindow" then
      focus on field "typed" of card 1 of stack "SuggestWindow"
      SuggestWindow.Typed empty
   end if
end openStack

-- LIB_ALPHA 12b: a closed stack lets go of its memory
on closeStackRequest
   set the destroyStack of me to true
   close stack (the mainStack of me)
end closeStackRequest

-- Makes the window's controls and loads the words. pFolder: where lib_suggest lives
-- (empty: beside this script's own file). The result: empty, or what went wrong.
on SuggestWindow.Build pFolder
   local tOld, tWhy, tW, tH, tAbout
   if pFolder is empty then
      put the effective filename of me into pFolder
      set the itemDelimiter to "/"
      put item 1 to -2 of pFolder into pFolder
   end if
   if "LibSuggest" is not among the lines of the stacksInUse then
      start using stack (pFolder & "/lib_suggest.livecodescript")
   end if
   Suggest.Load
   put the result into tWhy
   put the defaultStack into tOld
   set the defaultStack to the short name of me
   lock screen
   put 820 into tW
   put 500 into tH
   set the destroyStack of me to true
   set the title of me to "FOR OWNER | Type Entity. and a space. Click a line to copy it. About: the button"
   set the width of me to tW
   set the height of me to tH
   set the backgroundColor of me to "24,28,32"
   if there is no field "typed" of card 1 of stack "SuggestWindow" then
      create field "typed"
      create field "words"
      create field "meaning"
      create button "About"
      -- first time only: the middle of the screen (a new stack sized here can land half off it)
      set the loc of me to the screenLoc
   end if
   set the rect of field "typed" to 12,12,tW - 96,40
   set the lockText of field "typed" to false
   set the dontWrap of field "typed" to true
   set the textSize of field "typed" to 16
   set the backgroundColor of field "typed" to "255,255,255"
   set the foregroundColor of field "typed" to "0,0,0"
   set the rect of button "About" to tW - 88,12,tW - 12,40
   set the rect of field "words" to 12,48,tW - 12,tH - 132
   set the lockText of field "words" to true
   set the listBehavior of field "words" to true
   set the dontWrap of field "words" to true
   set the vScrollbar of field "words" to true
   set the textSize of field "words" to 13
   set the tabStops of field "words" to "330,470"
   set the backgroundColor of field "words" to "238,242,246"
   set the foregroundColor of field "words" to "0,0,0"
   set the rect of field "meaning" to 12,tH - 124,tW - 12,tH - 12
   set the lockText of field "meaning" to true
   set the textSize of field "meaning" to 13
   set the backgroundColor of field "meaning" to "24,28,32"
   set the foregroundColor of field "meaning" to "200,230,255"
   set the borderWidth of field "meaning" to 0
   -- rule 17: an About card
   if the number of cards of this stack < 2 then
      create card "About"
      create field "about"
      create button "Back"
      go card 1 of stack "SuggestWindow"
   end if
   put "Wednesday, November 18, 2026" & return & "SuggestWindow: the Entity. suggestion list" & return & \
         the title of me & return & return & \
         "Built to: show every call a game may make, by group, so nobody has to guess the next word." & return & \
         "The words come from the engine contract (LIB_ig3d/ENGINE_CONTRACT.md) and cannot go stale." & return & return & \
         "How:" & return & \
         "- Keyboard: type Entity. (or Mesh. Camera. HUD. ...) in the top line. A dot alone lists the groups." & return & \
         "- Keyboard: type a word with no dot (position, colour) to search every name and meaning." & return & \
         "- Keyboard: type an old name (SetObjectPosition, MeshBox) to see its new one." & return & \
         "- Keyboard: Return takes the first line. Mouse: click a line. Either copies the call to the clipboard." & return & return & \
         "Report: write what you see in LIB_TEST/OBSERVATIONS.txt. No other process is watching this window." \
         into tAbout
   set the rect of field "about" of card "About" of stack "SuggestWindow" to 12,12,tW - 12,tH - 52
   set the lockText of field "about" of card "About" of stack "SuggestWindow" to true
   set the textSize of field "about" of card "About" of stack "SuggestWindow" to 13
   set the backgroundColor of field "about" of card "About" of stack "SuggestWindow" to "238,242,246"
   set the foregroundColor of field "about" of card "About" of stack "SuggestWindow" to "0,0,0"
   put tAbout into field "about" of card "About" of stack "SuggestWindow"
   set the rect of button "Back" of card "About" of stack "SuggestWindow" to 12,tH - 44,100,tH - 12
   unlock screen
   set the defaultStack to tOld
   if tWhy is not empty then put tWhy into field "meaning" of card 1 of stack "SuggestWindow"
   return tWhy
end SuggestWindow.Build

-- What was typed: fill the list. Called on every key; a test calls it directly.
on SuggestWindow.Typed pText
   local tLines, tLine, tShow
   put Suggest.For(pText) into tLines
   set the cLines of me to tLines
   set the itemDelimiter to tab
   repeat for each line tLine in tLines
      put item 1 of tLine & tab & item 2 of tLine & tab & item 3 of tLine & return after tShow
   end repeat
   delete last char of tShow
   put tShow into field "words" of card 1 of stack "SuggestWindow"
   if tLines is empty then
      if word -1 of pText is empty then
         put "Type a group and a dot: Entity.  Mesh.  Camera.  HUD." into field "meaning" of card 1 of stack "SuggestWindow"
      else
         put "Nothing in the contract begins with or mentions" && quote & word -1 of pText & quote & "." into field "meaning" of card 1 of stack "SuggestWindow"
      end if
   else
      put the number of lines of tLines && "found. Click one, or press Return for the first." into field "meaning" of card 1 of stack "SuggestWindow"
   end if
end SuggestWindow.Typed

-- Line pN of the list is chosen: show its whole meaning and copy the call.
-- A group line ("Entity.") goes into the top line instead, and opens that group.
on SuggestWindow.Choose pN
   local tLine, tCall, tName
   put line pN of the cLines of me into tLine
   if tLine is empty then exit SuggestWindow.Choose
   set the itemDelimiter to tab
   put Suggest.Pick(tLine) into tCall
   put item 4 of tLine into tName
   if item 2 of tLine is "group" then
      put tCall into field "typed" of card 1 of stack "SuggestWindow"
      SuggestWindow.Typed tCall
      exit SuggestWindow.Choose
   end if
   set the cPicked of me to tCall
   set the clipboardData["text"] to tCall
   put "Copied:  " & tCall & return & return & Suggest.Meaning(tName) into field "meaning" of card 1 of stack "SuggestWindow"
end SuggestWindow.Choose

on textChanged
   if the short name of the target is "typed" then
      SuggestWindow.Typed the text of field "typed" of card 1 of stack "SuggestWindow"
   else
      pass textChanged
   end if
end textChanged

on returnInField
   if the short name of the target is "typed" then
      SuggestWindow.Choose 1
   else
      pass returnInField
   end if
end returnInField

on mouseUp
   local tName
   put the short name of the target into tName
   if tName is "words" and word 1 of the target is "field" then
      if the hilitedLine of field "words" of card 1 of stack "SuggestWindow" is not empty then
         SuggestWindow.Choose (item 1 of the hilitedLine of field "words" of card 1 of stack "SuggestWindow")
      end if
   else if tName is "About" and word 1 of the target is "button" then
      go card "About" of stack "SuggestWindow"
   else if tName is "Back" and word 1 of the target is "button" then
      go card 1 of stack "SuggestWindow"
   else
      pass mouseUp
   end if
end mouseUp
