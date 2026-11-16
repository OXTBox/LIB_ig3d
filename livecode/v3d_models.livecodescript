script "v3d_models"
-- v3d_models: model files for the Vibecode3D editor's windows (Opus 15 Nov 2026, A-86 / A-87).
-- Functions only (no message handlers), so it is safe to "start using".
--   Model.List(pRoot)                     every .wtf under pRoot, relative paths, sorted
--   Model.PreviewPoints(pPath, l, t, size)  the model as points for one line graphic (an empty
--                                          line between bones breaks the line), fitted in a square,
--                                          seen from the front-left and a little above
--   Model.Info(pPath)                     "vertices edges"
-- .wtf (iGame3D 2007): #Vertices: count, then x,y,z,bone lines; #Edges: count, then a,b (from 0).

constant kMaxEdges = 4000     -- previews stay quick on big models

function Model.List pRoot
   local tOut
   put Model.Walk(pRoot, empty) into tOut
   sort lines of tOut
   return tOut
end Model.List

function Model.Walk pFolder, pRel
   local tOut, tF, tSub
   repeat for each line tF in files(pFolder)
      if tF ends with ".wtf" then put pRel & tF & return after tOut
   end repeat
   repeat for each line tSub in folders(pFolder)
      if tSub is "." or tSub is ".." or tSub begins with "_" then next repeat
      put Model.Walk(pFolder & "/" & tSub, pRel & tSub & "/") after tOut
   end repeat
   return tOut
end Model.Walk

function Model.Info pPath
   local tText, n, tV, tE
   put Model.Text(pPath) into tText
   put lineOffset("#Vertices:", tText) into n
   if n > 0 then put line n + 1 of tText into tV
   put lineOffset("#Edges:", tText) into n
   if n > 0 then put line n + 1 of tText into tE
   return (tV + 0) && (tE + 0)
end Model.Info

function Model.Text pPath
   local tText
   if there is not a file pPath then return empty
   put textDecode(url ("binfile:" & pPath), "UTF-8") into tText
   replace numToCodepoint(13) with empty in tText
   return tText
end Model.Text

function Model.PreviewPoints pPath, pLeft, pTop, pSize
   local tText, n, tCount, i, tLine, tSX, tSY, minX, maxX, minY, maxY, k, tPts, tEdges, a, b, tCosA, tSinA, tCosB, tSinB, x, y, z, x2
   put Model.Text(pPath) into tText
   put lineOffset("#Vertices:", tText) into n
   if n is 0 then return empty
   put line n + 1 of tText into tCount
   if tCount is not an integer or tCount < 1 then return empty
   -- turn 35 degrees about the vertical, tip 20 degrees towards the viewer (y up in .wtf)
   put cos(0.61) into tCosA
   put sin(0.61) into tSinA
   put cos(0.35) into tCosB
   put sin(0.35) into tSinB
   put 1e9 into minX
   put -1e9 into maxX
   put 1e9 into minY
   put -1e9 into maxY
   set the itemDelimiter to comma
   repeat with i = 1 to tCount
      put line n + 1 + i of tText into tLine
      put item 1 of tLine + 0 into x
      put item 2 of tLine + 0 into y
      put item 3 of tLine + 0 into z
      put x * tCosA + z * tSinA into x2
      put z * tCosA - x * tSinA into z
      put x2 into tSX[i]
      put -(y * tCosB - z * tSinB) into tSY[i]
      put min(minX, tSX[i]) into minX
      put max(maxX, tSX[i]) into maxX
      put min(minY, tSY[i]) into minY
      put max(maxY, tSY[i]) into maxY
   end repeat
   put (pSize - 8) / max(0.000001, max(maxX - minX, maxY - minY)) into k
   put lineOffset("#Edges:", tText) into n
   if n is 0 then return empty
   put min(kMaxEdges, line n + 1 of tText) into tEdges
   if tEdges is not a number then return empty
   repeat with i = 1 to tEdges
      put line n + 1 + i of tText into tLine
      put item 1 of tLine + 1 into a
      put item 2 of tLine + 1 into b
      if tSX[a] is empty or tSX[b] is empty then next repeat
      put round(pLeft + 4 + (tSX[a] - minX) * k + (pSize - 8 - (maxX - minX) * k) / 2) & comma & \
            round(pTop + 4 + (tSY[a] - minY) * k + (pSize - 8 - (maxY - minY) * k) / 2) & return & \
            round(pLeft + 4 + (tSX[b] - minX) * k + (pSize - 8 - (maxX - minX) * k) / 2) & comma & \
            round(pTop + 4 + (tSY[b] - minY) * k + (pSize - 8 - (maxY - minY) * k) / 2) & return & return after tPts
   end repeat
   return tPts
end Model.PreviewPoints
