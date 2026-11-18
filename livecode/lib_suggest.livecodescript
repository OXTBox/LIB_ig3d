script "LibSuggest"
-- LIB_ig3d / lib_suggest: type "Entity." and get everything under Entity (TODO A-99, RENAME_DAY.md).
-- It only thinks: no window, no IDE. Any place that wants the list (the small test window, the
-- in-game console, a script editor, a menu) asks Suggest.For and shows the lines its own way.
--
-- The words are never typed here: Suggest.Load reads LIB_ig3d/Data/contract_words.txt, which
-- tools/make_names.py writes from the tables of ENGINE_CONTRACT.md.
--
--   start using stack ".../LIB_ig3d/livecode/lib_suggest.livecodescript"
--   Suggest.Load                              -- the result: empty, or what went wrong
--   put Suggest.For("Entity.") into tLines    -- one suggestion a line, tabs between:
--                                             --   form, tag, short meaning, name
--   put Suggest.Pick(line 2 of tLines)        -- the text to paste: "Entity.Kill pId"
--   put Suggest.Meaning("Entity.Kill")        -- the whole meaning from the contract
--
-- Tags: "gives" it gives a value back; "planned" the XT engine does not have it yet;
-- "was SetObjectPosition" found by its old name; "also" about an object, from another group;
-- "message" the engine sends it to the game; "value" a shared value; "group" a group of calls.

local sW          -- sW[n][field]: the rows of the words file, in file order
local sCount      -- how many rows
local sFile       -- the file they came from

function Suggest.DefaultFile
   local tPath
   put the effective filename of me into tPath
   set the itemDelimiter to "/"
   return item 1 to -3 of tPath & "/Data/contract_words.txt"
end Suggest.DefaultFile

on Suggest.Load pFile
   local tText, tLine, tN
   if pFile is empty then put Suggest.DefaultFile() into pFile
   if there is no file pFile then return "no words file:" && pFile
   put textDecode(url ("binfile:" & pFile), "UTF-8") into tText
   replace numToChar(13) with empty in tText
   put empty into sW
   put 0 into tN
   set the itemDelimiter to tab
   repeat for each line tLine in tText
      if tLine is empty or char 1 of tLine is "#" then next repeat
      if the number of items of tLine < 4 then next repeat
      add 1 to tN
      put item 1 of tLine into sW[tN]["kind"]
      put item 2 of tLine into sW[tN]["group"]
      put item 3 of tLine into sW[tN]["name"]
      put item 4 of tLine into sW[tN]["form"]
      put item 5 of tLine into sW[tN]["gives"]
      put item 6 of tLine into sW[tN]["xt"]
      put item 7 of tLine into sW[tN]["old"]
      put item 8 of tLine into sW[tN]["first"]
      put item 9 to -1 of tLine into sW[tN]["meaning"]
   end repeat
   put tN into sCount
   put pFile into sFile
   if tN is 0 then return "no words in" && pFile
   return empty
end Suggest.Load

function Suggest.Count
   return sCount + 0
end Suggest.Count

function Suggest.File
   return sFile
end Suggest.File

-- The groups of calls, one a line, in the contract's order ("Scene", "Mesh", "Entity" ...).
function Suggest.Groups
   local tN, tOut, tSeen
   repeat with tN = 1 to sCount
      if sW[tN]["kind"] is not "call" then next repeat
      if sW[tN]["group"] is empty then next repeat
      if tSeen[sW[tN]["group"]] is not empty then next repeat
      put true into tSeen[sW[tN]["group"]]
      put sW[tN]["group"] & return after tOut
   end repeat
   delete last char of tOut
   return tOut
end Suggest.Groups

-- The whole meaning of one name (new or old), as the contract words it.
function Suggest.Meaning pName
   local tN
   repeat with tN = 1 to sCount
      if sW[tN]["name"] is pName or (sW[tN]["old"] is not empty and sW[tN]["old"] is pName) then
         return sW[tN]["meaning"]
      end if
   end repeat
   return empty
end Suggest.Meaning

-- The text to paste for one line of Suggest.For: the call with its parameter names.
function Suggest.Pick pLine
   set the itemDelimiter to tab
   return item 1 of pLine
end Suggest.Pick

-- The suggestions for what was typed. Only the last word counts ("put Entity.Se" -> "Entity.Se").
function Suggest.For pTyped
   local tWord, tOut, tDone, tN, tGroup, tCountA, tName, tRest
   if sCount is empty or sCount is 0 then return empty
   put word -1 of pTyped into tWord
   -- nothing yet, or a dot alone: the groups
   if tWord is empty or tWord is "." then
      repeat with tN = 1 to sCount
         if sW[tN]["kind"] is "call" and sW[tN]["group"] is not empty then add 1 to tCountA[sW[tN]["group"]]
      end repeat
      repeat for each line tGroup in Suggest.Groups()
         put tGroup & "." & tab & "group" & tab & tCountA[tGroup] && "calls" & tab & tGroup & "." & return after tOut
      end repeat
      delete last char of tOut
      return tOut
   end if
   if tWord contains "." then
      -- 1. names that begin with it (calls and messages); "Value." lists the shared values
      repeat with tN = 1 to sCount
         put sW[tN]["name"] into tName
         if tName begins with tWord then
            put sugLine(tN, empty) & return after tOut
            put true into tDone[tN]
         else if sW[tN]["kind"] is "value" and tWord begins with "Value." then
            put char 7 to -1 of tWord into tRest
            if tRest is empty or tName begins with tRest then
               put sugLine(tN, empty) & return after tOut
               put true into tDone[tN]
            end if
         end if
      end repeat
      -- 2. found by an old name that had a dot ("Scene.SetBob", "Engine.SetCam")
      repeat with tN = 1 to sCount
         if tDone[tN] is true or sW[tN]["old"] is empty then next repeat
         if sW[tN]["old"] begins with tWord and the number of chars of tWord > 3 then
            put sugLine(tN, "was" && sW[tN]["old"]) & return after tOut
            put true into tDone[tN]
         end if
      end repeat
      -- 3. "Entity." alone: the calls of other groups that are about an object too
      --    (worked out, not listed: their first parameter is pId and their meaning says "object";
      --    HUD.Set's pId is a line of text, not an object)
      if tWord is "Entity." then
         repeat with tN = 1 to sCount
            if tDone[tN] is true then next repeat
            if sW[tN]["kind"] is "call" and sW[tN]["first"] is "pId" and sW[tN]["group"] is not "Entity" \
                  and sW[tN]["meaning"] contains "object" then
               put sugLine(tN, "also") & return after tOut
            end if
         end repeat
      end if
      delete last char of tOut
      return tOut
   end if
   -- no dot: 1. names and old names that begin with it
   repeat with tN = 1 to sCount
      if sW[tN]["name"] begins with tWord then
         put sugLine(tN, empty) & return after tOut
         put true into tDone[tN]
      else if sW[tN]["old"] is not empty and sW[tN]["old"] begins with tWord then
         put sugLine(tN, "was" && sW[tN]["old"]) & return after tOut
         put true into tDone[tN]
      end if
   end repeat
   -- 2. from three letters on: the word anywhere in a name, an old name, then in a meaning
   if the number of chars of tWord >= 3 then
      repeat with tN = 1 to sCount
         if tDone[tN] is true then next repeat
         if sW[tN]["name"] contains tWord then
            put sugLine(tN, empty) & return after tOut
            put true into tDone[tN]
         else if sW[tN]["old"] contains tWord then
            put sugLine(tN, "was" && sW[tN]["old"]) & return after tOut
            put true into tDone[tN]
         end if
      end repeat
      repeat with tN = 1 to sCount
         if tDone[tN] is true then next repeat
         if sW[tN]["meaning"] contains tWord then put sugLine(tN, empty) & return after tOut
      end repeat
   end if
   delete last char of tOut
   return tOut
end Suggest.For

-- One suggestion line: form, tag, short meaning, name (tabs between).
private function sugLine pN, pExtra
   local tTag, tShort, tAt
   if pExtra is not empty then put pExtra into tTag
   if sW[pN]["kind"] is "message" then
      put sugJoin(tTag, "message") into tTag
   else if sW[pN]["kind"] is "value" then
      put sugJoin(tTag, "value") into tTag
   else if sW[pN]["gives"] is "yes" then
      put sugJoin(tTag, "gives") into tTag
   end if
   if sW[pN]["xt"] is "planned" then put sugJoin(tTag, "planned") into tTag
   put sW[pN]["meaning"] into tShort
   put offset(". ", tShort) into tAt
   if tAt > 0 then put char 1 to tAt of tShort into tShort
   if the number of chars of tShort > 90 then put char 1 to 87 of tShort & "..." into tShort
   return sW[pN]["form"] & tab & tTag & tab & tShort & tab & sW[pN]["name"]
end sugLine

private function sugJoin pA, pB
   if pA is empty then return pB
   return pA & "," && pB
end sugJoin
