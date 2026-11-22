script "LibConsole"
-- LIB_ig3d / lib_console: the console line (owner, 22 Nov 2026: "only took 21 years to get that").
-- One place for the console's thinking, used by the iGame3D XT editor (Window > Console) and the
-- xt3d Games bench (always there, under the view). The host makes the two fields in its own colours
-- (house rule: colour the template before create) and hands them over:
--
--   start using stack ".../LIB_ig3d/livecode/lib_console.livecodescript"
--   Con.Load                          -- lib_suggest beside it, and the words; the result: why not
--   Con.Attach tIn, tOut, tHost       -- tIn: the one-line field typed in; tOut: the answers;
--                                     -- tHost: where lines run (its Con.DoHere), empty = here
--
-- In the line:
--   typing      "Entity.Se" fills in the first name that begins so ("Entity.SetBob"), the added part
--               selected: typing on replaces it, Backspace takes it away. "Ent" fills "Entity."
--   Tab         a menu of what fits ("Entity." every Entity call; "Entity.Po" the Position calls);
--               a pick puts the call in with its parameters selected, its meaning in the answers.
--               One fit: in at once. Never cycling.
--   Return      runs the line; a call that gives a value (even typed as a command) or "put x" alone
--               shows the value
--   Up / Down   the lines run before.   "clear" empties the answers.   "help" lists the groups.
--
-- Where a line runs: the host's handler, so the host's own handlers can be called too:
--   on Con.DoHere pGlobals, pCode, pIsValue
--      local tAnswer
--      if pIsValue then
--         do pGlobals & cr & "put (" & pCode & ") into tAnswer"
--         return tAnswer
--      end if
--      do pGlobals & cr & pCode
--      return the result
--   end Con.DoHere
-- Without one (or no host) the line runs here, where only libraries (the engine) are reachable.
--
-- Con.Typing() is true while a console line has the keyboard: a host's camera or game keys wait.

local sS        -- sS[long id of the line][...]: "fill" chars autofilled, "hist" lines run, "at" Up/Down,
                -- "menu" the Tab list, "word" the word it is for, "typed" the text before the cursor
local sLoaded, sWhy, sGlobals

-------------------------------------------------------------------- setting up

function Con.Folder
   local tPath
   put the effective filename of me into tPath
   set the itemDelimiter to "/"
   return item 1 to -2 of tPath
end Con.Folder

on Con.Load
   local tLib, tErr
   if sLoaded is true then return empty
   if not ("LibSuggest" is among the lines of the stacksInUse) then
      put Con.Folder() & "/lib_suggest.livecodescript" into tLib
      if there is not a file tLib then
         put "no word list: lib_suggest.livecodescript is not beside lib_console" into sWhy
         return sWhy
      end if
      start using stack tLib
   end if
   try
      Suggest.Load
      put the result into tErr
   catch tErr
   end try
   if tErr is not empty then
      put "no word list:" && line 1 of tErr into sWhy
      return sWhy
   end if
   put true into sLoaded
   put empty into sWhy
   return empty
end Con.Load

-- why there are no words (empty when there are)
function Con.Why
   return sWhy
end Con.Why

-- the line's script (keys to here), its answers field and where lines run
on Con.Attach pIn, pOut, pHost
   local tS
   put "on keyDown pKey" & cr & "   if not Con.Key(the long id of me, pKey) then pass keyDown" & cr & "end keyDown" & cr into tS
   put "on tabKey" & cr & "   Con.Tab the long id of me" & cr & "end tabKey" & cr after tS
   put "on returnInField" & cr & "   Con.Run the long id of me" & cr & "end returnInField" & cr after tS
   put "on enterInField" & cr & "   Con.Run the long id of me" & cr & "end enterInField" & cr after tS
   put "on backspaceKey" & cr & "   Con.NoFill the long id of me" & cr & "   pass backspaceKey" & cr & "end backspaceKey" & cr after tS
   put "on arrowKey pKey" & cr & "   if pKey is " & quote & "up" & quote & " or pKey is " & quote & "down" & quote & " then" & cr & \
         "      Con.History the long id of me, pKey" & cr & "   else" & cr & "      pass arrowKey" & cr & "   end if" & cr & "end arrowKey" after tS
   set the script of pIn to tS
   set the dontWrap of pIn to true
   set the lockText of pIn to false
   set the traversalOn of pIn to true
   set the autoTab of pIn to false
   set the cConOut of pIn to pOut
   set the cConHost of pIn to pHost
   put 0 into sS[pIn]["fill"]
end Con.Attach

-- true while a console line has the keyboard
function Con.Typing
   local tF, tErr
   try
      put the focusedObject into tF
      if tF is empty or word 1 of the name of tF is not "field" then return false
      return the cConOut of tF is not empty
   catch tErr
      return false
   end try
end Con.Typing

-------------------------------------------------------------------- the words

-- the word being typed at the end of pText: back to a space, bracket, comma, quote or sign
function Con.Word pText
   local n
   put the number of chars of pText into n
   repeat while n > 0
      if offset(char n of pText, " (),[]=+-*/&<>" & quote & tab) > 0 then exit repeat
      subtract 1 from n
   end repeat
   return char n + 1 to -1 of pText
end Con.Word

-- autofill: pTyped with the rest of the first name that begins with its last word (that word in the
-- name's own capitals). "Ent" -> "Entity." (a group); "Entity.Se" -> "Entity.SetBob"; "gCam" ->
-- "gCameraPitch". Nothing fits, a dot last, or one letter: pTyped as it was.
function Con.Fill pTyped
   local tWord, tLine, tName, tBefore, tErr
   put Con.Word(pTyped) into tWord
   if the number of chars of tWord < 2 or char -1 of tWord is "." then return pTyped
   put char 1 to -(the number of chars of tWord + 1) of pTyped into tBefore
   if tWord is pTyped then put empty into tBefore
   try
      if not (tWord contains ".") then
         repeat for each line tName in Suggest.Groups()
            if tName begins with tWord then return tBefore & tName & "."
         end repeat
      end if
      set the itemDelimiter to tab
      repeat for each line tLine in Suggest.For(tWord)
         put item 4 of tLine into tName
         if tName begins with tWord and the number of chars of tName > the number of chars of tWord then return tBefore & tName
      end repeat
   catch tErr
   end try
   return pTyped
end Con.Fill

-- the Tab list for a word: lib_suggest's lines (form, tag, short meaning, name), then the names of
-- the word's group that have the rest anywhere in them ("Entity.Po": GetPosition, SetPosition)
function Con.List pWord
   local tList, tLine, tGroup, tRest, tSeen, tErr
   try
      put Suggest.For(pWord) into tList
      if pWord contains "." and char -1 of pWord is not "." then
         set the itemDelimiter to tab
         repeat for each line tLine in tList
            put true into tSeen[item 4 of tLine]
         end repeat
         put char 1 to offset(".", pWord) of pWord into tGroup
         put char offset(".", pWord) + 1 to -1 of pWord into tRest
         repeat for each line tLine in Suggest.For(tGroup)
            if tSeen[item 4 of tLine] is true then next repeat
            if char (the number of chars of tGroup + 1) to -1 of item 4 of tLine contains tRest then
               if tList is not empty then put cr after tList
               put tLine after tList
            end if
         end repeat
      end if
   catch tErr
      return empty
   end try
   return tList
end Con.List

-------------------------------------------------------------------- the keys

-- a key typed in the line (keyDown): typed at the end, the rest is filled in; true = done here
function Con.Key pIn, pKey
   local tText, tChunk, tFrom, tTo, tLen, tTyped, tFull, tErr
   put the text of pIn into tText
   put the number of chars of tText into tLen
   put the selectedChunk into tChunk
   if word 1 of tChunk is "char" and Con.Typing() then
      put word 2 of tChunk into tFrom
      put word 4 of tChunk into tTo
   else
      put tLen - sS[pIn]["fill"] + 1 into tFrom   -- no selection to read (a test): after what was typed
      put tLen into tTo
   end if
   if tTo < tLen then
      put 0 into sS[pIn]["fill"]
      return false                              -- typing in the middle: as any field does
   end if
   put char 1 to tFrom - 1 of tText & pKey into tTyped
   put tTyped into tFull
   if offset(pKey, "abcdefghijklmnopqrstuvwxyz0123456789._") > 0 then put Con.Fill(tTyped) into tFull
   set the text of pIn to tFull
   put the number of chars of tFull - the number of chars of tTyped into sS[pIn]["fill"]
   try
      if sS[pIn]["fill"] > 0 then
         select char (the number of chars of tTyped + 1) to (the number of chars of tFull) of pIn
      else
         select after char (the number of chars of tFull) of pIn
      end if
   catch tErr
   end try
   return true
end Con.Key

on Con.NoFill pIn
   put 0 into sS[pIn]["fill"]
end Con.NoFill

-- the line's text before the cursor (an autofilled tail left out)
function Con.Typed pIn
   local tText, tChunk
   put the text of pIn into tText
   put the selectedChunk into tChunk
   if word 1 of tChunk is "char" and Con.Typing() then return char 1 to word 2 of tChunk - 1 of tText
   return char 1 to -(sS[pIn]["fill"] + 1) of tText
end Con.Typed

-- Tab: a menu of what fits the word before the cursor (one fit: put in at once)
on Con.Tab pIn
   local tTyped, tWord, tList, tMenu, tLine, tB, tX, tErr
   put Con.Typed(pIn) into tTyped
   put Con.Word(tTyped) into tWord
   put Con.List(tWord) into tList
   if tList is empty then
      Con.Say pIn, "(nothing fits" && quote & tWord & quote & ")"
      exit Con.Tab
   end if
   put line 1 to 60 of tList into tList
   put tTyped into sS[pIn]["typed"]
   put tWord into sS[pIn]["word"]
   put tList into sS[pIn]["menu"]
   if the number of lines of tList is 1 then
      Con.Pick pIn, 1
      exit Con.Tab
   end if
   set the itemDelimiter to tab
   repeat for each line tLine in tList
      if item 2 of tLine is "group" then
         put item 1 of tLine & "   (" & item 3 of tLine & ")" & cr after tMenu
      else if item 2 of tLine is empty then
         put item 1 of tLine & cr after tMenu
      else
         put item 1 of tLine & "   (" & item 2 of tLine & ")" & cr after tMenu
      end if
   end repeat
   delete last char of tMenu
   replace "/" with "\/" in tMenu
   put Con.Pop(pIn, tMenu) into tB
   put min(the right of pIn - 40, the left of pIn + 6 + 7 * the number of chars of tTyped) into tX
   try
      popup tB at tX, the top of pIn
   catch tErr
      -- no screen (a headless test): the menu is filled, nothing to show it on
   end try
end Con.Tab

-- the one popup on the line's card, plain black on white (colours set on the template before create)
function Con.Pop pIn, pText
   local tCard, tB
   put the long id of the owner of pIn into tCard
   repeat while word 1 of tCard is not "card"
      put the long id of the owner of tCard into tCard
   end repeat
   if there is not a button "ConsolePop" of tCard then
      lock messages
      reset the templateButton
      set the textColor of the templateButton to "0,0,0"
      set the backgroundColor of the templateButton to "255,255,255"
      set the hiliteColor of the templateButton to "51,153,255"
      set the borderColor of the templateButton to "128,128,128"
      set the style of the templateButton to "menu"
      set the menuMode of the templateButton to "popup"
      set the visible of the templateButton to false
      create button "ConsolePop" in tCard
      reset the templateButton
      unlock messages
      set the traversalOn of button "ConsolePop" of tCard to false
      set the script of button "ConsolePop" of tCard to "on menuPick pItem" & cr & "   Con.Pick the cConIn of me, the menuHistory of me" & cr & "end menuPick"
   end if
   put the long id of button "ConsolePop" of tCard into tB
   set the cConIn of tB to pIn
   set the text of tB to pText
   return tB
end Con.Pop

-- a pick from the Tab list (its line number): the call goes in the line, its parameters selected
on Con.Pick pIn, pN
   local tLine, tForm, tName, tText, tAt, tLen, tErr
   set the itemDelimiter to tab
   put line pN of sS[pIn]["menu"] into tLine
   if tLine is empty then exit Con.Pick
   put item 1 of tLine into tForm
   put item 4 of tLine into tName
   if item 2 of tLine is "group" then put tName into tForm
   put char 1 to -(the number of chars of sS[pIn]["word"] + 1) of sS[pIn]["typed"] into tText
   if sS[pIn]["word"] is sS[pIn]["typed"] then put empty into tText
   put tText & tForm into tText
   set the text of pIn to tText
   put 0 into sS[pIn]["fill"]
   put the number of chars of tText into tLen
   put tLen - the number of chars of tForm + the number of chars of tName into tAt   -- the name's end
   try
      focus on pIn
      if char tAt + 1 of tText is "(" and char -1 of tText is ")" and tLen - tAt > 2 then
         select char tAt + 2 to tLen - 1 of pIn
      else if char tAt + 1 of tText is space and tLen - tAt > 1 then
         select char tAt + 2 to tLen of pIn
      else
         select after char tLen of pIn
      end if
   catch tErr
   end try
   if item 2 of tLine is not "group" then Con.Say pIn, tName & ":" && Suggest.Meaning(tName)
end Con.Pick

-- Up / Down: the lines run before (past the last: an empty line)
on Con.History pIn, pDir
   local tN, tErr
   put the number of lines of sS[pIn]["hist"] into tN
   if tN is 0 then exit Con.History
   if sS[pIn]["at"] is not a number then put tN + 1 into sS[pIn]["at"]
   if pDir is "up" then
      put max(1, sS[pIn]["at"] - 1) into sS[pIn]["at"]
   else
      put min(tN + 1, sS[pIn]["at"] + 1) into sS[pIn]["at"]
   end if
   set the text of pIn to line sS[pIn]["at"] of sS[pIn]["hist"]
   put 0 into sS[pIn]["fill"]
   try
      select after char (the number of chars of the text of pIn) of pIn
   catch tErr
   end try
end Con.History

-------------------------------------------------------------------- running a line

-- Return: run the line, show it and its answer
on Con.Run pIn
   local tLine, tAnswer
   put the text of pIn into tLine
   set the text of pIn to empty
   put 0 into sS[pIn]["fill"]
   if word 1 to -1 of tLine is empty then exit Con.Run
   if sS[pIn]["hist"] is empty then
      put tLine into sS[pIn]["hist"]
   else
      put cr & tLine after sS[pIn]["hist"]
   end if
   put the number of lines of sS[pIn]["hist"] + 1 into sS[pIn]["at"]
   Con.Say pIn, "> " & tLine
   put Con.Do(pIn, tLine) into tAnswer
   if tAnswer is not empty then Con.Say pIn, tAnswer
   Con.Refocus pIn
end Con.Run

-- the keyboard back to the line, the cursor at its end
on Con.Refocus pIn
   local tErr
   try
      if exists(pIn) and the visible of pIn then
         focus on pIn
         select after char (the number of chars of the text of pIn) of pIn
      end if
   catch tErr
   end try
end Con.Refocus

-- run one line at the host: a call, a command, or a value to show
function Con.Do pIn, pLine
   local tAnswer, tGlobals, tExpr, tFirst, tErr, tErr2
   put word 1 to -1 of pLine into pLine
   if pLine is "clear" then
      set the text of the cConOut of pIn to empty
      return empty
   end if
   if pLine is "help" then
      try
         put Suggest.Groups() into tAnswer
      catch tErr
      end try
      replace cr with ", " in tAnswer
      return "groups:" && tAnswer & ". Type one, a dot, then Tab. Up/Down: lines before. clear: empty this."
   end if
   put Con.Globals() into tGlobals
   -- "put x" alone shows x; a call written with brackets, a value's name or a call that gives
   -- something back is a value too
   if word 1 of pLine is "put" and not (" into " is in pLine or " after " is in pLine or " before " is in pLine) then
      put word 2 to -1 of pLine into tExpr
   else
      put char 1 to offset("(", pLine & "(") - 1 of word 1 of pLine into tFirst
      if char (the number of chars of tFirst + 1) of pLine is "(" and tFirst is not empty then
         put pLine into tExpr
      else if the number of words of pLine is 1 and Con.IsValue(pLine) then
         put pLine into tExpr
      else if Con.IsValue(tFirst) then
         -- a call that gives a value, typed as a command ("Entity.Spawn "Box", 0, 0, 0"): its value
         put tFirst & "(" & word 2 to -1 of pLine & ")" into tExpr
      end if
   end if
   if tExpr is not empty then
      try
         put Con.Exec(pIn, tGlobals, tExpr, true) into tAnswer
      catch tErr
         return "could not work that out:" && Con.Error(tErr)
      end try
      if tAnswer is empty then return "(empty)"
      return tAnswer
   end if
   try
      put Con.Exec(pIn, tGlobals, pLine, false) into tAnswer
   catch tErr
      -- not a command: maybe a sum or a value ("2 + 2", "the width of this card")
      try
         put Con.Exec(pIn, tGlobals, pLine, true) into tAnswer
      catch tErr2
         return Con.NotRun(pIn, pLine, tErr)
      end try
      -- an unknown word comes back as itself ("Scene.ClearAll" with no engine): not an answer
      if tAnswer is pLine then return Con.NotRun(pIn, pLine, tErr)
      if tAnswer is empty then return "(empty)"
      return tAnswer
   end try
   if word 1 to -1 of tAnswer is empty then return "ok"    -- nothing, or only blank lines
   return tAnswer
end Con.Do

-- why a line did not run, in words; a contract call that is not found gets the host's hint
-- (the line's cConHint, e.g. the xt3d bench: "engine calls work while a game plays")
function Con.NotRun pIn, pLine, pErr
   local tFirst, tText
   put Con.Error(pErr) into tText
   put word 1 of pLine into tFirst
   if offset("(", tFirst) > 0 then put char 1 to offset("(", tFirst) - 1 of tFirst into tFirst
   -- 573: can't find handler (OXT-Beyond gives the number alone)
   if tText contains "handler" or item 1 of line 1 of pErr is 573 then
      put tFirst && "is not found here" into tText
      try
         if Suggest.Meaning(tFirst) is not empty and the cConHint of pIn is not empty then put tText & ":" && the cConHint of pIn into tText
      catch pErr
      end try
   end if
   return "could not run that:" && tText
end Con.NotRun

-- at the host (its Con.DoHere), else here
function Con.Exec pIn, pGlobals, pCode, pIsValue
   local tHost, tAnswer
   put the cConHost of pIn into tHost
   if tHost is not empty and exists(tHost) then
      dispatch "Con.DoHere" to tHost with pGlobals, pCode, pIsValue
      if it is "handled" then return the result
   end if
   if pIsValue then
      do pGlobals & cr & "put (" & pCode & ") into tAnswer"
      return tAnswer
   end if
   do pGlobals & cr & pCode
   return the result
end Con.Exec

-- the shared values the contract names (gCameraYaw, bPaused ...), declared for a line
function Con.Globals
   local tLine, tOut, tErr
   if sGlobals is not empty then return sGlobals
   try
      set the itemDelimiter to tab
      repeat for each line tLine in Suggest.For("Value.")
         if char 1 of item 4 of tLine is "g" or char 1 of item 4 of tLine is "b" then put item 4 of tLine & "," after tOut
      end repeat
   catch tErr
   end try
   if tOut is empty then return empty
   delete last char of tOut
   put "global" && tOut into sGlobals
   return sGlobals
end Con.Globals

-- true for a shared value's name or a call that gives a value back
function Con.IsValue pName
   local tLine, tErr
   if pName is empty then return false
   try
      set the itemDelimiter to tab
      repeat for each line tLine in Suggest.For(pName)
         if item 4 of tLine is pName and (item 2 of tLine contains "value" or item 2 of tLine contains "gives") then return true
      end repeat
   catch tErr
   end try
   return false
end Con.IsValue

-- an error in words: the engine's own text for its number, else its first line
function Con.Error pErr
   local tCode, tText, tErr
   put item 1 of line 1 of pErr into tCode
   try
      if tCode is an integer and tCode > 0 then put line tCode of the scriptExecutionErrors into tText
   catch tErr
   end try
   if tText is empty then put line 1 of pErr into tText
   return tText
end Con.Error

-- one line (or more) at the end of the answers, scrolled into view; the last 400 lines kept
on Con.Say pIn, pText
   local tF, tErr
   put the cConOut of pIn into tF
   if tF is empty or not exists(tF) then exit Con.Say
   if the text of tF is empty then
      set the text of tF to pText
   else
      set the text of tF to the text of tF & cr & pText
   end if
   if the number of lines of the text of tF > 400 then set the text of tF to line -400 to -1 of the text of tF
   try
      set the vScroll of tF to the formattedHeight of tF
   catch tErr
   end try
end Con.Say
