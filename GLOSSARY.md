# iGame3D glossary (2008 engine)

Built by `LIB_GAMES/igame3D_2008_Texts/_manifest/tools/build_glossary.py`; do not edit by hand,
run it again. Part 1 is the engine's own help text. Part 2 is from Spark's drafts that passed
`check_drafts.py` (every name they use exists in the source); meanings there are Spark's
reading, not checked word by word. xt3d / Vibecode3D names: to be filled as each call gets
its new home (LIB_SYSTEM TODO A-16).

Coverage: 218 engine calls; 574 terms from 206 kept drafts (of about 2,450 planned Spark requests).

## 1. Engine calls (Help/reference.txt, Help/scripting.txt)

| Call | What it does (the 2008 help) | xt3d / Vibecode3D |
|---|---|---|
| `ascii(code):(char)` | Returns the character of the given decimal ASCII [code]. For example ascii(65) returns "A". You can use the result of ascii() in a call to key() (although key() can also handle the codes directly). There may be other uses for this function though, so we didn't declare it as obsolete just yet. Lazy people can also look <a href=http://www.asciitable.com/>here</a>. | |
| `beep()` | Plays the standard alert sound. This is useful for testing purposes. | |
| `click(when):(result)` | Returns the state of the left mouse button. [result]=true means pressed and [result]=false means not pressed. The [when] parameter is used to get more information about the click. The default [when]="-" simply returns the state of the mouse button as described above. [when]="n" detects only "new" clicks. That means that click("n") returns true only when you just pressed the mouse button in contrast to click("-") which will return true all the time until the button is released. similar [when]="o" detects only mouse button releases. Often you will switch on particle emitters for guns on click("n") and switch it off again on click("o"). | |
| `dirToAngles(dx,dy,dz):(xa,ya,za)` | Takes a direction vector [dx, dy, dz] and returns the corresponding euler angles that an object would need to be rotated to to look in that direction (the returned [za] angle is always 0.0, so that objects don't lean to the sides by default). Typical use is to make an object look at a certain position. In that case you would simply subtract the object's position from the "look point" and use the result as the input vector [dx,dy,dz] for dirToAngles(). Then use the returned [xa,ya,za] in a call to setObjectInfo() with IG3D_ROTATION. | |
| `drawLine(x,y,z)` | Creates lines from all selected vertices to a new vertex created at world coordinates [x,y,z]. In contrast to drawVertex() no new vertex is created if one already exists at the given coordinates. In that case the existing one will be connected to the selecte vertices. The (new) vertex will be selected and everything else will be unselected. You can use combination of drawVertex and drawLine calls to create 3D models. (Three vertices, each connected to the other with a line forms a triangle!). | |
| `drawToTexture(dstTexture, srcTexture, u, v, drawingMode, edgeBehaviour)` | Draws texture image [srcTexture] into texture image [dstTexture] centered at UV coordinates [u,v]. The top-left corner of the texture image has UV coords 0,0 and the bottom-right corner of the texture image has UV coordinates [1.0, 1.0]. Both textures need to be in memory for this to work. (Either loaded using loadTexture() or created using make(ig3d_texture, ...) ). UV coords out of range [0,1] are not allowed. The way the two images are combined depends on the [drawingMode]. The following values are allowed: | |
| `drawVertex(x,y,z)` | Creates a new loose mesh vertex at world coordinates [x,y,z]. This vertex will be selected and everything else is unselected. | |
| `ig3d_AddToMesh_tag_i(tagNumber)` | This adds the selected mesh vertices to mesh tag [tagNumber] (line number in mesh tag list). | |
| `ig3d_AddToPath_i(pathNumber)` | This takes the positions of all selected mesh vertices and adds these as path points to path [pathNumber] (line # of path in path list). Very useful when you have a path that has a lot in common with the level, like for driving games. | |
| `ig3d_AlignMesh()` | Aligns the selected mesh depending on the value set using ig3d_SetMeshAlignmentSize_f | |
| `ig3d_AttachVertexToBone_s(boneName)` | This attaches the selected mesh to bone [boneName]. The part of the model attached to a bone will move and rotate with the bone and its parent bones, just like your fingers move when you move your arm! There's now visual feedback for this in mesh editing, but if you load an object with the bones and mesh attached to the bones, you can check out this behaviour in sceletal animation mode. | |
| `ig3d_BuildQuickTimeMovie_si(filename, framerate)` | This starts recording a QuickTime Movie (without sound) to a file specified by [fileName] (full path). The framerate is set in the [framerate] parameter (in frames per second). This is a Mac OS X-only feature!! | |
| `ig3d_ClearScene_b(all)` | This will delete the mesh and any visible entities in the scene. If [all]=true, then the model cache, all textures, sounds and fonts will also be cleared. | |
| `ig3d_ClusterMeshBones()` | Attaches vertices to "nearest" mesh bones. Each mesh bone has a direction arrow for orienting its bounding box and also for clustering vertices. Vertices inside an imaginary cone with its tip at the mesh bone position and oriented in arrow direction are possibly attached to this bone. The distance from both the actual bone position and the cone center line (in arrow direction) are considered when looking for the "nearest" bone. A lot of vertices will be in multiple imaginary bone cones, so this distance criterium is important for finding the nearest bone. Also the bone hierarchy is important. Vertices are always attached to the bones deepest in the hierarchy when they fit in multiple bones. This feature is useful if you want to add a bone skeleton to an unboned humanoid mesh. You could load the skeleton first (for example Data/WTF/human_bones.wtf), then load the unboned mesh, modify the bones position and direction arrows to better fit this mesh and then run the clustering process. Often you will need to fix a few vertices by hand, but this is a useful first step. | |
| `ig3d_CombineEqualMeshMaterials()` | This looks for duplicate mesh materials and combines them. Keeping the material count small is good for performance! | |
| `ig3d_CombineSelectedMeshOverlaps_f(range)` | Combines vertices within a distance <= [range] to each other, thus reducing the polycount | |
| `ig3d_CopyGLToRevWindow_4i(left, top, right, bottom)` | This copies the OpenGL scene to the rev window specified by ig3d_SetDrawingWindow_s. You have to specify the rectangle [left, top, right, bottom] (in local coordinates of the window) where it should be drawn. Use this command with care, rev is often updating its internal window data structures when controls are added, pointer tool is chosen etc., which requires you to call ig3d_SetDrawingWindow_s again before drawing or rev will crash! | |
| `ig3d_CreateDirectory_s(fullPath)` | This creates a folder at the given full path on your hard drive. It creates only this one folder and fails if its parent folder does not exist. For example /Users/greatman/igame3d/test/ can only be created if the folder /Users/greatman/igame3d exists! | |
| `ig3d_CreateMaterial_s(matName)` | Creates a new mesh material named [matName]. | |
| `ig3d_CreateMesh_tag_s(tagName)` | Creates an empty mesh tag named [tagName]. | |
| `ig3d_CreateMeshFromImage_s2f2i(texture, xz_sizes, height, divisions, mask)` | Create a squared mesh from a given heightmap image [texture]. Maximum height and side sizes can be given as well as the number of side [divisions] to set the level of detail. The component [mask] is used to tell which color channels of the image will be considered and is a sum of red:1, green:2, blue:4, alpha:8. For example 9 being red and alpha (1+8). | |
| `ig3d_CreatePath_s(pathName)` | Creates a path of name [pathName]. When you save the mesh, this path will save with it. | |
| `ig3d_DeleteMaterial_i(matNumber)` | Deletes material [matNumber] (line number in materials list). The triangles attached to this material will be attached to the default material instead. | |
| `ig3d_DeleteMesh_b(complete)` | Deletes the selected mesh. If [complete] = true, the whole mesh (including unselected parts) will be cleared | |
| `ig3d_DeleteMesh_tag_i(tagNumber)` | Detaches any vertices from and deletes mesh tag [tagNumber] (line number in mesh tag list). | |
| `ig3d_DeleteObject_i(objNumber)` | Deletes object of number [objNumber]. This number is equivalent to the line number an object appears at in ig3d_GetObjectList__s. | |
| `ig3d_DeletePath_i(pathNumber)` | Deletes path [pathNumber]. This number is equivalent to the line number of a path in the path list. | |
| `ig3d_DrawGL()` | This forces iGame3D to redraw the GL scene. Normally you need this because the scene is drawn automatically every game loop. | |
| `ig3d_DuplicateMesh()` | Duplicates the selected mesh. After the duplicating the source mesh will be unselected and the new mesh will be selected | |
| `ig3d_EndVideoCapturing()` | Stops recording the movie previously started using "ig3d_BuildQuickTimeMovie_si" and closes the movie file written to. Mac OS X only. | |
| `ig3d_ExecuteLua_s_i(text):(result)` | This executes a LUA script directly parsed as a string in [text]. The return value is the same as in ig3d_ExecuteLuaScript_s_i | |
| `ig3d_ExecuteLuaScript_s_i(fileName):(result)` | This executes a LUA script stored in file [fileName] (full path). If the file was not found, this will return 0, otherwise 1. Result type is integer because other result codes may be implemented later. | |
| `ig3d_Exit()` | Call this when you attemp to quit the iGame3D application. It will perform a basic cleanup of the resources iGame3D is using and thus is a good idea to call for a clean shutdown. | |
| `ig3d_ExtrudeSelectedMesh_fb(distance, faceOut) Extrudes the selected mesh by [distance] units` | If [faceOut] is true, the resulting geometry will be facing out, otherwise in | |
| `ig3d_FoolMousePosition_2i(x,y)` | This makes iGame3D think the mouse is positioned at screen coordinates [x,y]. You can use this to simulate a click at a desired position by calling ig3d_HandleClick right after fooling the mouse position. In the next event loop, the mouse position will be corrected again. | |
| `ig3d_GenerateAndApplyMeshCylindricUVMapping()` | This is used to apply a cylindric UV coordinate mapping to the selected mesh triangles. The middle axis of the cylinder is pointing up in direction 0,1,0. The mapping is created so that it wraps around the mesh exactly once. | |
| `ig3d_GenerateAndApplyMeshUVMapping_5fb3f(usize, vsize, umod, vmod, ya, fixed, fx,fy,fz)` | This is used to apply a UV coordinate mapping to the selected mesh triangles. [usize] and [vsize] specify width and height of ONE texture tile. So if you got a ground plate of size 4x5, [usize] of 4 and [vsize] of 5 will make the texture appear exactly once on that plate. [umod] and [vmod] allow you to offset the texture. With [ya] you can apply rotation to the mapping. [fixed] and [fx,fy,fz] can be used for a fixed projection vector just like in ig3d_GetMatchingUVSizesForMesh_fb3f_2f. Note that this command is only applying the mapping, you'll still need to apply a texture to the material used by the mesh to see the mapped texture in action. | |
| `ig3d_Get2DViewScales__3f():(xzScale, xyScale, yzScale)` | This returns the scaling factors of the three 2D views. They control how far the "camera" is away from the scene in each view. Remember: These views can be enabled using ig3d_SetFourViews_b(true). The scale values are all 30.0 by default. Increasing them means zooming out, decreasing means zooming in. The xz-view is in top-right of the window, the xy-view is bottom-left and the yz-view is bottom-right. | |
| `ig3d_Get3DControllerManual__b():(manual)` | Returns true if the 3D controller is in "manual" mode. That means that it won't perform any action and justs sends an event of type "3dcontroldrag" with the button number (1 to 9) and the new position of the mouse and the old position of the mouse. (button, h, v, old_h, old_v). The stack can then decide what to do. | |
| `ig3d_Get3DControllerVisibility__b():(show)` | Returns the visibility of the 3D controller in the top-left of the OpenGL where [true] means visible. | |
| `ig3d_Get3DPositionFrom2DCoordinates_2ib_3f(screen_x, screen_y, collideWithScene):(x,y,z)` | This function translates global 2-dimensional screen coordinates [screen_x, screen_y] into the corresponding point in 3D space of the OpenGL scene. The point will lie on the current mesh placement where the ray collides with it. If [collideWithScene] is set to true, then also objects and the mesh will be checked with the ray. If nothing is hit, the function will return nothing (empty string). | |
| `ig3d_GetCameraInfo__s():(camData)` | Returns the position and orientation of the camera in a string. This string contains two lines. Line 1: Position (x,y,z), Line 2: Orientation (xa, ya, za) | |
| `ig3d_GetColorInTexture_s6i_4f(texFile, left, top, right, bottom, x, y):(r, g, b, a)` | This lets you determine the color at a specified pixel position [x,y] in a texture [texFile] (local to iGame3D directory). The texture will (virtually) be scaled to [left, top, right, bottom] first, then the color at a position inside that rect will be looked up. (Can be used for color picking, which appears to be buggy in rev). | |
| `ig3d_GetCurrentMaterialNumber__i():(matNumber)` | Returns the number of the default material (line number in material list). The default material is the material that new created triangles get attached to. When a new material is created it becomes the default material. But you can set it yourself using ig3d_SetCurrentMaterialNumber_i as well. | |
| `ig3d_GetElapsedSeconds__f():(frameTime)` | Gets the elapsed time since the last frame. That is equivalent to the time between two consecutive draws of the OpenGL scene. It is returned in seconds. | |
| `ig3d_GetFogInfo__b5f():(on, red, green, blue, start, end)` | The parameters are the same as in "ig3d_SetFogInfo_b5f". Here you get the values instead of setting them. | |
| `ig3d_GetGroupInfo_s_s(groupName):(groupData)` | This will return a 3-line information string about group [groupName]. Line 1: Group name, Line 2: position (x,y,z), Line 3: orientation (xa,ya,za). Position and Orientation values are averaged from the group members. You can find group members of a group by calling ig3d_GetGroupsList__s which returns the complete group hierarchy. | |
| `ig3d_GetGroupsList__s():(groupList)` | Returns a line-delimited list of all groups and their members in the scene. Members are preceded by a minus sign. Since groups can be members of another group and in turn have members, multiple minus signs indicate the depth of a member inside the group hierarchy. A group without a preceding minus sign is a top-level group. | |
| `ig3d_GetLevelName__s():(levelName)` | Returns the name of the currently loaded level. The returned string will be empty, if no level has been loaded before. | |
| `ig3d_GetLightInfo_i_s(lightNumber):(lightInfo)` | Returns the light information for light number [lightNumber] which ranges from 1 to 8. This information is 7-line string. Line 1: on/off (true/false), Line 2: light position in homogenous coordinates (x,y,z,w). Line 3: Ambient (r,g,b,a), Line 4: Diffuse (r,g,b,a), Line 5: Specular (r,g,b,a), Line 6: Spotlight data (direction x,y,z, cutoff angle, exponent). Line 7: Attenuation factors (constant, linear, quadratic). See any OpenGL documentation for help and default values of these light settings. | |
| `ig3d_GetLineWidth__f():(width)` | Returns the width of mesh line edges visible in editing mode. | |
| `ig3d_GetLuaOutput__s():(output)` | OBSOLETE REV EXTERNAL FEATURE!!! Call this to receive the latest text output of the external. A typical use is to catch a "console" event in the ig3d_ext_event handler of the rev stack and then call this function and put the result into a console or a dialog window. | |
| `ig3d_GetMatchingUVSizesForMesh_fb3f_2f(ya, fixed, fx,fy,fz):(u,v)` | This is a utility function used to calculate the u and v sizes for ig3d_GenerateAndApplyMeshUVMapping_5fb3f in case you want to map a texture exactly once onto the selected mesh geometry. You specify a [ya] angle in degrees which is used to rotate a texture on the selected mesh, start with a value of 0 and play with this value until it matches you needs. If [fixed] is true, then the texture is projected in a fixed direction defined by the [fx,fy,fz] vector. If [fixed] is false, iGame3D will compute a projection vector perpendicular to the mesh and [fx,fy,fz] will be ignored. Returned is the a string consisting of two floats: u-size and v-size. This is what you send to ig3d_GenerateAndApplyMeshUVMapping_5fb3f in the first two parameters. | |
| `ig3d_GetMesh_tagsList__s():(list)` | Returns a line-delimited list of all mesh tags in the scene. | |
| `ig3d_GetMeshBonesList__s():(boneList)` | Returns a line-delimited list of all mesh bones in the scene. Each line contains two words, the bone name and the line number of its parent bone in this list. The "None" bone is the default bone that cannot be deleted, modified etc. It has no parent bone, so the parent number is set to 0. The list is not formatted in a hierarchial way because you can see the "sceleton" pretty good in sceletal animation mode already. Of course you could easily construct a hierarchial list from this output if you need to. | |
| `ig3d_GetMeshBounds__6f():(sx, bx, sy, by, sz, bz)` | Returns the smallest and biggest x,y,z coordinates of the selected mesh. Can be used to measure the mesh. [bx]-[sx] would be the x-size. | |
| `ig3d_GetMeshCentroid__3f():(x,y,z)` | Returns the center position of the selected mesh. | |
| `ig3d_GetMeshMaterialInfo_i_s(matNumber):(materialInfo)` | Returns the material information of material [matNumber] (line number in material list). For a detailed discription of the format of the multi-line material information, search for "Material instruction reference". | |
| `ig3d_GetMeshMaterialsList__s():(list)` | Returns a line-delimited list of all mesh materials. | |
| `ig3d_GetMode__i():(mode)` | This returns the editing mode the engine is currently in. See ig3d_SetMode_i() for details. | |
| `ig3d_GetNumberOfPolys__i():(polyCount)` | Returns the number of polygons (only triangles in the case of iGame3D) in the scene. It's the sum of the mesh poly count and the poly counts of all objects and particles currently visible in the scene. Think of a ray cast from the front of your monitor into the depth. | |
| `ig3d_GetObjectBoneInfo_2s_6f(objName, boneName):(x,y,z, xa,ya,za)` | This returns the current transformation of bone [boneName] of object [objName]. The return value is a string containing 6 floats: change of position (x,y,z) and orientation (xa,ya,za). | |
| `ig3d_GetObjectBonesList_s_s(objName):(boneList)` | Returns a line-delimited list of the bones of object [objName]. | |
| `ig3d_GetObjectInfo_s_s(objName):(info)` | Returns the name, position, orientation and size of object [objName]. The return value is formatted in the same way as the [info] parameter of ig3d_SetObjectInfo_2s | |
| `ig3d_GetObjectMaterialInfo_si_s(objName, materialNumber):(materialInfo)` | Returns a line-delimited list of material settings of material [materialNumber] of object [objName]. This is documented in detail elsewhere in this document. Search for "Material instruction reference". | |
| `ig3d_GetObjectMaterialsList_s_s(objName):(materialList)` | Returns a line-delimited list of the bones of object [objName]. | |
| `ig3d_GetObjectModelAnimOffset_s_i(objName):(offset)` | Returns the offset of the #Animations: chunk inside the model file of object [objName]. The first char in the file is number 0. Typical use of this is an animation editor that saves custom animations to model files. This makes it more comfortable to find the place to store the animations. | |
| `ig3d_GetObjectModelPath_s_s(objName):(modelPath)` | Returns the path of the model file that object [objName] is using. | |
| `ig3d_GetObjectsList__s():(objectList)` | Returns a line-delimited list of the names of all objects in the scene. | |
| `ig3d_GetParticle_emitterInfo_s_s(emitterName):(emtInfo)` | Returns the particle emitter info of emitter [emitterInfo]. The format of the return value is discribed in detail elsewhere in this document. Search for "Particle emitter instruction reference". | |
| `ig3d_GetParticle_emittersList__s():(emtList)` | Returns a line-delimited list of all particle emitters in the scene. | |
| `ig3d_GetPathInfo_i_s(pathNumber):(pointsList)` | Returns a line-delimited list of the positions (x,y,z coords) of all path points of path [pathNumber] (line number of path in path list). | |
| `ig3d_GetPathsList__s():(pathsList)` | Returns a line-delimited list of the paths in the scene. (only the paths of the mesh, not the ones in object models). | |
| `ig3d_GetPlaneInfo__if():(whichPlane, offset)` | Returns a string containing the number of the current visible grid plane [whichPlane] and its distance to origin (0,0,0) [offset]. If [whichPlane] is 0, it is the xz-plane, 1 is xy-plane and 2 is yz-plane. | |
| `ig3d_GetPointSize__f():(size)` | Returns the point size of mesh vertices and path points visible in editing mode (in pixels). | |
| `ig3d_GetProjection__b5f():(perspective, fov, left, right, top, bottom)` | This returns a string of information about the projection in the OpenGL viewport. When perspective projection is used, [perspective] will be true and [fov] will be the field of view in degrees (90 is default). If [perspective] is false, it is an orthographic view, and [left, right, top, bottom] specify the viewport. (for example -10.0,10.0,-10.0,-10.0). | |
| `ig3d_GetSamplesList__s():(samplesList)` | Returns a line-delimited list of all loaded sound files. | |
| `ig3d_GetScreenBounds__2i():(width, height)` | Returns [width] and [height] of the screen (monitor). | |
| `ig3d_GetSelection__s():(entityList)` | Returns a line-delimited list of all selected entities in the scene each line representing an entity. If there is just one word other than the following keywords, then it is the name of an object. Other entities are preceded by one of these keywords: "light", "sound", "particle" or "player". "light" is always followed by the light number, "sound" and "particle" are followed by the emitter name, "player" stands for the camera and nothing else follows in the line. | |
| `ig3d_GetSound_emitterInfo_s_s(emtName):(emitterInfo)` | This will return the information of sound emitter [emtName]. That is a 5-line string. Line 1: Name, Line 2: relative path to assigned sound sample file, Line 3: Position (x,y,z), Line 4: Volume (in ), Line 5: looped or unlooped (true/false) | |
| `ig3d_GetSound_emittersList__s():(sndEmtList)` | Returns a line-delimited list of all sound emitters in the scene. | |
| `ig3d_GetStateScript__s():(scriptText)` | This takes a scripted "snapshot" of the current scene. It will save positions, orientations etc. of all entities in the scene and returns that as script commands in a string. You can later execute this state script to restore the current scene! | |
| `ig3d_GetTexturesList__s():(list)` | Returns a line-delimited list of the loaded textures. | |
| `ig3d_GetUptime__f():(uptime)` | Returns the time since startup of iGame3D (in seconds). | |
| `ig3d_GetWindowBounds__4i():(left, top, right, bottom)` | Returns the bounding rectangle of the OpenGL window. | |
| `ig3d_HandleClick()` | This forces iGame3D to simulate a click into the OpenGL window at the position the mouse is at. | |
| `ig3d_HandleMouseDown()` | This forces iGame3D to simulate a mouse down in the OpenGL window at the position the mouse is at (mouse button pressed but not released yet). | |
| `ig3d_HideFaces_b(hide)` | If [hide] is true, then this hides the faces of the selected mesh, that is the triangles. This allows you to still view edges and vertices and "see through" the faces. Triangles hidden this way can only be shown again using "ig3d_HideFaces_b false" | |
| `ig3d_Idle()` | OBSOLETE REV EXTERNAL FEATURE!!! This tells the external to update the OpenGL window, handle game scripts when in "game-mode", respond to key presses etc. You should call this in Rev's idle handler either in card or stack script. | |
| `ig3d_Init_s4i(fullPath, left, top, right, bottom)` | OBSOLETE REV EXTERNAL FEATURE!!! Call this at application startup. You tell it the full pathname where of the directoy it should look for files. The engine doesn't load files from anywhere, it can only load files from within the directory you provide here and its subdirectories. The rectangle of the OpenGL window is set using [left, top, right, bottom]. | |
| `ig3d_InvertMeshFaces()` | Inverts the facing of the selected mesh polys | |
| `ig3d_InvertMeshSelection()` | Inverts the mesh selection. Originally selected parts become unselected, originally unselected parts become selected | |
| `ig3d_IsFileWritable_s_b(fileName):(writable)` | Checks if the file [fileName] is writable. If it is it will return true, otherwise false. [fileName] should be the full path of the file. | |
| `ig3d_IsMouseButtonDown__b():(mouseDown)` | Returns a boolean [mouseDown] that is true, if the left mouse button is pressed, otherwise false | |
| `ig3d_LoadMesh_sf_b(fileName, size):(result)` | This loads a mesh from a model file [fileName] (full path). Supported types are .wtf, .3ds, .obj and .mesh files. The mesh will be uniformly scaled to [size] (in  of original size). On success "true" is returned, otherwise "false". | |
| `ig3d_LoadTexture_s_b(fileName):(success)` | Loads the texture from file [fileName]. This path is relative to the iGame3D directory. (only files within the iGame3D folder hierarchy are allowed). If loading succeeded, true will be returned, otherwise false if something went wrong. | |
| `ig3d_MagicCatch_fb(distance, cylindric)` | This function is used to wrap one mesh around another mesh (typically used to make clothes). To use it position a high-poly primitive mesh around the mesh you want to wrap it around. Select only the "cloth" mesh. Then use this function with a [distance] value between 0.0 and 1.0 and [cylindric] = true or false. All "cloth" mesh vertices will move to mesh's geometric center until they hit the mesh to wrap around. If [distance] is set to 1, they will be placed at the exact collision point, if set to 0 they won't move at all. Most of the time a value of 0.8 works best. If you set [cylindric] to true, the vertices will only move in x and z direction like wrapping a cylinder around the inner shape. | |
| `ig3d_MakeBoneFromVertex_2s(boneName, parent)` | This turns a mesh vertex into a mesh bone of name [boneName]. The parent bone is set using [parent] and is just the name of another bone you want your new bone to be a child of. [parent]="None" means no parent bones except for the root bone at 0,0,0. Mesh bones don't do a thing except being green, but if you save the mesh and load it as an object you can begin animating that model. | |
| `ig3d_MakeInvisible()` | This will hide the selected mesh (vertices, lines and triangles) | |
| `ig3d_MakeMeshSmoothShaded_b(smooth)` | If [smooth] = true, then the vertex normals for the selected mesh will be calculated to make it look right when smooth shaded. Smooth shading is a per-material feature and thus can only be activated in the material! | |
| `ig3d_MeshFaceAwayFromCamera()` | The selected mesh will be outfacing from the viewer/camera | |
| `ig3d_MeshSetFacing_b3f(faceOut, x,y,z)` | This forces the selected mesh triangles to adjust their facings to be either back-facing ([faceOut]=true) or front-facing ([faceOut]=false) to the point [x,y,z]. | |
| `ig3d_MeshUndo()` | Swap current mesh with undo buffer | |
| `ig3d_MirrorSelectedMesh_3i(mirrorx, mirrory, mirrorz)` | This will mirror the selected mesh at its centroid around each axis with non-zero value. For example 0,0,1 will mirror on z-axis. | |
| `ig3d_MoveCameraInDirection_3f(dx, dy, dz)` | Moves the camera by [dx] units on the x-axis, [dy] on the y and [dz] on the z. | |
| `ig3d_OffsetUVMapping_2f(offU, offV)` | This offsets the UV coordinates of all selected mesh triangles by [offU, offV]. | |
| `ig3d_PolyReductionDownToVertexCount_i(numVertices)` | This will reduce the number of polygons of the selected mesh until there are [numVertices] vertices left. It uses edge collapses minimizing the error with a simple but effective cost function and it preserves UV mapping. | |
| `ig3d_PushMeshToUndoCache()` | Copy the current mesh to the undo buffer. When you undo later, the mesh from the undo buffer swaps with current mesh | |
| `ig3d_ReadAnimationsFromFileIntoCache_si(fileName, offset)` | This loads the sceletal animations from a file [fileName] (full path) into the animation cache. Each object can use the animations from the cache when an animation of the same name is not specified in the model itself. Using animations from the cache on a model with a different bone set will most likely cause a crash, so be careful. You specify a byte offset into the file at which the animation data begins with the [offset] parameter. (0 means at the beginning of the file). | |
| `ig3d_ReadModelAnimationsFromFile_2si(objName, fileName, offset)` | This loads the sceletal animations from a file [fileName] (full path) and attaches them to object [objName]. You specify a byte offset into the file at which the animation data begins with the [offset] parameter. (0 means at the beginning of the file). | |
| `ig3d_RebuildMacMenubar()` | On Mac OS X murgaLua tends to replace the menu bar created by the iGame3D Player with an empty menu bar at startup. Calling ig3d_RebuildMacMenubar() will reload the menu bar of the iGame3D Player. ig3d_RebuildMacMenubar() is automatically added to .lua scripts when converted from from Fluid .cxx exports. Naturely it has no effect on Windows systems. | |
| `ig3d_RemoveDoubleSidedFacesAndFixFacings()` | This removes one side of each double-sided mesh triangle. This may result in mixed frontfacing and backfacing polygons which looks ugly. If you have some mesh triangles selected when calling this function, these will be considered as examples of correctly facing triangles. The facing of all other triangles are fixed depending on the facings that are assumed to be correct (as set by selecting). The facing of the selected triangles are never changed. When nothing is selected or the whole mesh is selected, only the double-side removal is happening. | |
| `ig3d_RemoveFromMesh_tag_i(tagNumber)` | This removes the selected mesh vertices from mesh tag [tagNumber] (line number in mesh tag list), if they were at all part of it. | |
| `ig3d_ResizeGL()` | This forces the GL window to resize its viewport, normally you shouldn't need to do this yourself because it is done automatically wherever it is needed. | |
| `ig3d_RotateCameraAroundMesh_3f(xa, ya, za)` | Rotates the camera around the center of the selected mesh by [xa, ya, za] degrees and then makes the camera look at that selection. This can be used to create a spectator view. | |
| `ig3d_RotatePointAroundPoint_9f_3f(px,py,pz, cx,cy,cz, xa,ya,za):(tx,ty,tz)` | This lets you rotate a point around another point in 3D space. [px,py,pz] makes up the point to rotate. [cx,cy,cz] is the position to rotate the point around. [xa,ya,za] are the rotation angles. The new position (after the rotation) will be returned. This is an auxiliary function you might need often in calculations. It does not change anything in the scene. | |
| `ig3d_RotateSelectedMesh_6f(xang, yang, zang, cx, cy, cz)` | Rotates the selected mesh around position [cx, cy, cz] by the given angles around x,y,z axis | |
| `ig3d_SaveLevel_s(levelName)` | Saves the current scene to a folder [levelName] relative to the iGame3D directory. The mesh will also be saved (it will save to the last loaded mesh model file or create one if none exists). | |
| `ig3d_SaveMesh_sf_b(fileName, size):(result)` | This saves the current level mesh to file [fileName] (full path). It will save as a WTF model so you should use .wtf suffix in the file name. The mesh will save uniformly scaled to [size] (in  of original size). On success "true" is returned, otherwise "false". | |
| `ig3d_SaveMeshAs3DS_sf(fileName, size)` | This saves the current level mesh to file [fileName] (full path) as an 3D Studio model (.3ds). The mesh will save uniformly scaled to [size] (in  of original size). | |
| `ig3d_SaveMeshAsMeshwork_sf(fileName, size)` | This saves the current level mesh to file [fileName] (full path) as an Meshwork model (.mesh). The mesh will save uniformly scaled to [size] (in  of original size). | |
| `ig3d_SaveMeshAsOBJ_sf(fileName, size)` | This saves the current level mesh to file [fileName] (full path) as an Alias Wavefront model (.obj) The mesh will save uniformly scaled to [size] (in  of original size). | |
| `ig3d_SaveMeshAsWTF_sf(fileName, size)` | Also saves the current level mesh to file [fileName] (full path) as an .wtf model. The mesh will save uniformly scaled to [size] (in  of original size). | |
| `ig3d_SaveScreenshot_s2bi(fileName, alpha, supersampling, numFSAA)` | This saves a screenshot of the OpenGL scene to file [fileName] which takes a full path. If [alpha] is true, then an alpha channel is saved with the image with anything except the background being opaque. If supersampling is on, the image will be rendered at a bigger size and scaled down after that. This improves quality. [numFSAA] controls how many fullscreen antialiasing passes will be made. Only 0,2,4,8,15,16 are supported. | |
| `ig3d_ScaleSelectedMesh_3f(percentx, percenty, percentz)` | This will scale the selected mesh to the given percentage of the original size. | |
| `ig3d_ScaleSelectedMeshTo_3f(sizex, sizey, sizez)` | This will scale the selected mesh to fixed sizes. You can perform a uniform scale by setting two of the sizes to 0. | |
| `ig3d_ScaleUVMapping_2f(scaleU, scaleV)` | This scales the UV coordinates of all selected mesh triangles by [scaleU, scaleV]. | |
| `ig3d_SelectConnectedMesh()` | Selects the mesh that is connected to any of the currently selected mesh vertices. Two vertices A and B are connected if there is a combination of edges between them. | |
| `ig3d_SelectMesh_tagVertices_ib(tagNumber, deselectOthers)` | This will select all vertices of mesh tag [tagNumber] (line number in mesh tag list). If [deselectOthers] is true, then everything else will be deselected, otherwise the old selection will stay untouched. | |
| `ig3d_SelectMeshAttachedToBone_s(boneName)` | This selects the mesh that is attached to bone [boneName]. Everything else will be unselected unless you have the shift key pressed. | |
| `ig3d_SelectMeshBone_s(boneName)` | Selects mesh bone [boneName]. It will unselect any other vertices unless you have the shift key pressed. | |
| `ig3d_SelectMeshOfMaterial_i(matNumber)` | Selects the mesh that is attached to material [matNumber] (line number in materials list). | |
| `ig3d_SelectUnclosedEdges()` | This selects the mesh vertices on border edges. Here a border edge is an edge that is not separating exactly 2 triangles. So it is either not part of any triangle or it is border edge in a triangle mesh or for some reason its is connected to 3 or more triangles. You might want to eliminate such edges because they tend to break shadow casting where closed shapes are preferred. | |
| `ig3d_SelectWholeMesh()` | Selects the entire mesh in the scene | |
| `ig3d_Set2DViewScales_3f(xzScale, xyScale, yzScale)` | This sets the scaling factors of the three 2D views. See "ig3d_Get2DViewScales__3f" for details. | |
| `ig3d_Set3DControllerManual_b(manual)` | If [manual] is true, the 3D controller goes into "manual" mode (described in ig3d_Get3DControllerManual__b). If it is false, it goes into automatic mode and acts as usual. | |
| `ig3d_Set3DControllerVisibility_b(show)` | If [show] is true, the 3D controller in the top-left of the OpenGL window will be shown, otherwise hidden | |
| `ig3d_SetAutoBoneUpdating_b(autoUpdate)` | If [autoUpdate] is true, then sceletal animations of objects will also run in editing and animation mode, so you can preview them outside of play-testing. | |
| `ig3d_SetAuxiliaryBodyPosition_3f(x,y,z)` | Sets the position of the auxiliary body. | |
| `ig3d_SetAuxiliaryBodySize_3f(xsize, ysize, zsize)` | Sets the dimensions of the auxiliary body. | |
| `ig3d_SetAuxiliaryBodyVisibility_b(show)` | If [show]=true, the auxiliary body will be visible, otherwise hidden. | |
| `ig3d_SetBackfaceCulling_b(cullingOn)` | This will enable or disable mesh backface culling depending on the value of [cullingOn]. Note: In game-mode backface culling is always on and objects are also always backface culled. So this effects mesh culling in editing mode only. | |
| `ig3d_SetBackgroundColor_3f(red, green, blue)` | This sets the background color of the OpenGL window to the given RGB color. | |
| `ig3d_SetBonesEulersOnly_s(objName)` | Translates the current bone rotation matrix of each bone in object [objName] into euler angles, so you get correct values when calling ig3d_GetObjectBoneInfo_2s_6f. | |
| `ig3d_SetCameraInfo_s(camData)` | Sets the camera position and orientation to [camData]. The formatting is the same as the one of the return value of ig3d_GetCameraInfo__s | |
| `ig3d_SetCurrentMaterialNumber_i(matNumber)` | This sets the default material to [matNumber] (line number in material list). See ig3d_GetCurrentMaterialNumber__i for more details. | |
| `ig3d_SetDefaultMesh_tag_i(tagNumber)` | This sets the default mesh tag to [tagNumber] (line number in mesh tag list). Any new vertices you create will be added to the default mesh tag you specify here. If [tagNumber] is -1 (default), new vertices won't be added to a default mesh tag. | |
| `ig3d_SetDrawingWindow_s(windowName)` | OBSOLETE REV EXTERNAL FEATURE!!! In case you want to draw the OpenGL scene to a rev window as well, you can tell the external the name of a rev window you would like to draw to. The actual drawing is then performed by ig3d_CopyGLToRevWindow_4i | |
| `ig3d_SetFacePos_b3f(faceOut, x,y,z)` | This allows you to specify an orientation point in [x,y,z] that will be taken into consideration when creating new triangles by LUA scripting. Depending on the value of [faceOut], fresh triangles will be either back-facing or front-facing to the specified point. If you are creating a convex shape using LUA scripting, simply position the face position to the center of the shape to create and set [faceOut] to true. Any triangles created in editor won't be effected by the face position. | |
| `ig3d_SetFogInfo_b5f(on, red, green, blue, start, end)` | If [on] is true, OpenGL fog will be enabled, otherwise disabled. The fog color can be specified with [red, green, blue]. The distance to the viewer at which the fog begins (starts making things foggy) and where it ends (where you can see nothing but the fog) can be specified by [start] and [end]. | |
| `ig3d_SetFourViews_b(fourViews)` | If you set [fourViews] to true, the 3D scene window will be devided into 4 parts: One 3D view and three 2D views. This makes sense in mesh editing and is rather useless in game mode. If you set it to false there is only the one 3D view. This is the default setting. | |
| `ig3d_SetGLSmoothing_b(smooth)` | If supported by GPU and renderer, this will turn on antialiasing of lines with [smooth]=true, otherwise it can be used to turn it off. | |
| `ig3d_SetGridColor_3f(red, green, blue)` | This sets the color of the placement grid to the given RGB color. | |
| `ig3d_SetGroupInfo_2s(groupName):(groupData)` | This sets the group information of group [groupName] to [groupData]. For the format check out ig3d_GetGroupInfo_s_s. | |
| `ig3d_SetLevelName_s(levelName)` | This sets the current level name. This will replace the name returned by ig3d_GetLevelName__s. It could be used to specify a default level name or in a "Save as..." functionality, where you would first set the level name and then save the level. | |
| `ig3d_SetLightConeLength_if(lightNumber, length)` | This is used to set the length of the auxiliary cones that can be displayed for active spotlights in editing mode. [lightNumber] is a number from 1 to 8 telling which light you are talking about and [length] is that length of the cone. It's really just for more convenient editing and won't effect the light appearance. | |
| `ig3d_SetLightInfo_is(lightNumber, lightInfo)` | Sets the light information of light number [lightNumber] to [lightInfo]. The format of lightInfo is discribed in ig3d_GetLightInfo_i_s | |
| `ig3d_SetLineWidth_f(width)` | Sets the width of mesh line edges visible in editing mode to the given width. | |
| `ig3d_SetMaterialForSelectedMesh_i(matNumber)` | Attaches the selected mesh to material [matNumber] (line number in material list). | |
| `ig3d_SetMesh_tagName_is(tagNumber, newName)` | This sets the name of mesh tag [tagNumber] (line number in mesh tag list) to [newName]. | |
| `ig3d_SetMesh_tagVisibility_ib(tagNumber, show)` | This shows ([show]=true) or hides ([show]=false) all vertices of mesh tag [tagNumber] (line number in mesh tag list). | |
| `ig3d_SetMeshAlignmentSize_f(gridSize)` | This sets the grid size for automatic grid aligning to [gridSize]. | |
| `ig3d_SetMeshAutoAligning_b(alignOn)` | This will enable automatic aligning of the mesh to the grid size specified by ig3d_SetMeshAlignmentSize_f | |
| `ig3d_SetMeshBoneRotation_s3f(boneName, xa, ya, za)` | This sets the orientation of the bounding box of bone [boneName] to [xa, ya, za]. Adjusting the orientation of the bounding boxes can be useful to better approximate the actual shape of an object for collision detection. The mesh bone bounding boxes are drawn green in editing mode, play around with the rotation to best match your mesh. | |
| `ig3d_SetMeshBoneRotationAndScale_s6f(boneName, xrot, yrot, zrot, xscale, yscale, zscale)` | This is used to modify the collision boxes of bones. When you are editing the bones in the mesh editor, you will see the green bounding boxes of the bones which will be big enough to surround all vertices connected to a bone. However this box is axis-aligned by default and might not match the actual geometry well. With this function you can change the bounding box orientation of bone [boneName] by rotating it around the x,y,z-axis where [xrot, yrot, zrot] are specified in degrees (values of 0 mean no rotation). You can also scale the bounding box using the [xscal, yscal, zscal] parameters (values of 1 mean no scaling). | |
| `ig3d_SetMeshMaterialInfo_is(matNumber, materialInfo)` | Sets the material information of material [matNumber] (line number in material list) to [materialInfo]. For a detailed discription of the format of the multi-line [materialInfo], search for "Material instruction reference". | |
| `ig3d_SetMeshMaterialName_is(matNumber, newName)` | Sets the name of mesh material [matNumber] (line number in material list) to [newName]. | |
| `ig3d_SetMeshPosition_3f(x,y,z)` | Sets the centroid of the selected mesh to the given [x,y,z] position. | |
| `ig3d_SetMeshPositionNoUndo_3f(x,y,z)` | Sets the centroid of the selected mesh to the given [x,y,z] position without telling the undo manager that you did so. | |
| `ig3d_SetMeshTool_i(toolNumber)` | Selects the given mesh tool. Values: Line tool: 1, Mesh select: 2, vertex tool: 3, split tool: 4, disconnect: 5, path select: 6 | |
| `ig3d_SetMeshZBuffering_b(zbufferOn)` | Usually, triangle auxiliary edges and vertices can be seen through the mesh in editing mode. If you enable z-buffering, those edges and vertices will be z-buffered just like the rest of the mesh, so you can see only non-occluded ones. | |
| `ig3d_SetMode_i(mode)` | This sets the editing mode to one of the following: 1: editing mode (default), 2: sceletal animation mode (lets you create animations with boned objects together with animation editor), 4: game mode (This will let you preview your game, disable any editing stuff you'd see in the editing modes and it runs the game_script()-function of the current level script) | |
| `ig3d_SetMouseView_b(mouseView)` | This is used to tell iGame3D if it should use the mouse for controlling the camera. If [mouseView] is set to true, then iGame3D will hide the cursor and go into this camera "look" mode. You can then read the mouse delta using getSceneInfo(IG3D_MOUSE_DELTA). Otherwise the cursor will be shown and the camera look mode will be disabled making the mouse act normally. | |
| `ig3d_SetObjectBoneInfo_2s6f(objName, boneName, x,y,z, xa,ya,za)` | Sets the bone transformation of bone [boneName] of object [objName]. [x,y,z] makes up the position offset and [xa,ya,za] the change of orientation. | |
| `ig3d_SetObjectInfo_2s(objName, info)` | Sets the name, position, orientation and size of object [objName] to [info]. [info] is a 4-line string. Line 1: Name, Line 2: Position (x,y,z), Line 3: Orientation (xa, ya, za), Line 4: Size (x-percent, y-percent, z-percent) | |
| `ig3d_SetObjectMaterialInfo_sis(objName, matNumber, materialInfo)` | Sets the material settings of material [matNumber] of object [objName] to [materialInfo]. The specs for [materialInfo] are documented elsewhere in this document. Search for "Material instruction reference". | |
| `ig3d_SetObjectMaterialName_sis(objName, matNumber, newMatName)` | Sets the name of material [matNumber] of object [objName] to [newMatName] | |
| `ig3d_SetParticle_emitterInfo_2s(emitterName, emtInfo)` | Sets the emitter info of particle emitter [emitterName] to [emtInfo]. The format of [emtInfo] is discribed in detail elsewhere in this document. Search for "Particle emitter instruction reference". | |
| `ig3d_SetPathInfo_is(pathNumber, pointsList)` | Sets the path points of path [pathNumber] (line # in path list) to [pointsList]. [pointsList] is a line-delimited string where each line represents a point und thus has three coords (x,y,z). Setting the path points replaces the old points. | |
| `ig3d_SetPathName_is(pathNumber, newName)` | Renames path [pathNumber] to [newName]. [pathNumber] is the line number in the path list. | |
| `ig3d_SetPathsVisible_b(showPaths)` | If [showPaths] is true, then paths will be visible in the editor. Path points and their edges are purple-colored. You can use the path selection tool to select and drag path points ( ig3d_SetMeshTool_i 6 ) | |
| `ig3d_SetPlaneInfo_if(whichPlane, offset)` | Sets the current grid plane to [whichPlane] and sets its distance to origin to [offset]. See ig3d_GetPlaneInfo_if for info on [whichPlane] parameter. | |
| `ig3d_SetPointSize_f(size)` | Sets the point size of mesh vertices and path points visible in editing mode to the given pixel size. | |
| `ig3d_SetProjection_b5f(perspective, fov, left, right, top, bottom)` | This sets the projection of the OpenGL viewport to [perspective] where true means perspective projection and false means orthographic projection. The parameters have the same meaning as in ig3d_GetProjection__b5f. The value of [fov] won't be used in orthographic perspective and [left, right, top, bottom] won't be used in perspective projection. | |
| `ig3d_SetSelection_s(entityList)` | This allows you to manually select entities in the scene (reflected by the white bounding boxes). The format of [entityList] is described in ig3d_GetSelection__s. The new selection will replace the old one, thus any objects you don't include in your list will become unselected. | |
| `ig3d_SetSound_emitterInfo_2s(emtName, emitterInfo)` | This sets the information of sound emitter [emtName] to [emitterInfo]. See ig3d_GetSound_emitterInfo_s_s for a detailed description of the format of [emitterInfo]. | |
| `ig3d_SetupCollisionWorldFromMesh()` | This tells iGame3D to update its collision data structures according to the current mesh. This is done automatically every time the game mode is launched, but you might need it for special purposes. | |
| `ig3d_SetupWindowVisibility_b(show)` | If [show] is true, the OpenGL window is shown, otherwise it will be hidden. | |
| `ig3d_SetWindowBounds_4i(left, top, right, bottom)` | Sets the bounding rectangle of the OpenGL window using global screen coordinates [left, top, right, bottom]. | |
| `ig3d_ShowAll()` | Shows the whole mesh again, unhiding hidden vertices, lines and triangles, triangles hidden using "ig3d_HideFaces_b true" will remain hidden and can only be shown using "ig3d_HideFaces_b false" | |
| `ig3d_ShowGrid_b(visibility)` | If [visibility] is true, the placement grid will be shown, otherwise hidden. | |
| `ig3d_ShowLights_b(show)` | If [show] is set to true, some auxiliary graphics are displayed at the positions of active lights while editing. If set to false, these will be hidden | |
| `ig3d_ShowWindowTitleBarAndShadow_2b(visibility)` | If [visibility] is true, the OpenGL window gets a title bar and a shadow, otherwise, title bar will be hidden and shadowing disabled. (Useful to make an "in-stack" window). This feature works on Mac OS X only. | |
| `ig3d_SubdivideMesh()` | Subdivides the selected mesh (doubling the poly count). | |
| `ig3d_TellFocus_b(fieldFocus)` | This is used to tell iGame3D if it should have the keyboard focus. If [fieldFocus] is true (default), then the it won't react to keyboard input, otherwise it will. Typically you will set [fieldFocus] to true whenever you type something in a MurgaLua input text field and set it to false again when finished typing. That's why the parameter is called [fieldFocus]. (You will probably not want to move the camera when typing in a text field!) | |
| `ig3d_UpdateBones()` | OBSOLETE REV EXTERNAL FEATURE!!! Tells the external that one or more bones have been modified. In turn the external sends a "selectBone boneName" message back to the rev stack just like it would when you clicked an object bone in sceletal animation mode. | |
| `ig3d_UpdateObjectBonesAtTime_si(objName, msecs)` | Positions and rotates the bones of object [objName] according to a given moment in its current animation. The moment is [msecs] milliseconds after start of animation. | |
| `ig3d_UpdateScript_s(scriptFile)` | Use this function to tell iGame3D that the script [scriptFile] (path local to iGame3D directory) has changed, so force it to reload it. In level load scripts only the non-automatic part will be reloaded. This comes in handy when you edit the game logic in a script and don't want to reload the whole level all the time! | |
| `input(alphaNumericOnly):(char,code,name)` | This function takes a different approach to keyboard input. While key() allows you to request the state of every single key, you are often interested in the most recently typed key no matter which one it is (input text fields etc.). To do that with key() you would need a call to key() for every character that is accepted. That's where input() comes into play. When a new key is pressed it returns the character itself, its code and a descriptive name which is especially useful for the non printable characters. It also comes in use when buiding a key configuration level. When no new key is pressed, all return values are nil. If you are only interested in alphanumeric characters you can set [alphaNumericOnly] to true. In that case input() will return nil on any non-alphanumeric keys. Caps-lock and shift are handled automatically for alphanumeric keys, so input(true) will return a capital "A" when shift is pressed together with an "a". The [char] or [code] return values are exactly the ones to be used to poll key states with the key() function. So you could also use input() to find out the key code of a special key and later use it in a call to key(). | |
| `key(char,when):(result)` | Returns the state of key [char] where true means down and false means up. You use the [when] parameter to get more information about the key press. [when]="-" is the default mode where you get the key state as described above. [when]="n" can be used to detect only "new" key presses ie keys that were just pressed and have not been down in the last game loop. similarly [when]="o" detects key releases. [char] can either be the character itself or its ASCII code. For example key("a","-") and key(97,"-") are equivalent. For special keys it is a good idea to use the input() function to find out the code. | |
| `lineCollision(ax,ay,az, bx,by,bz):(collType, cx,cy,cz, collObj)` | This checks for intersections between a line segment with the mesh world or objects. The line segment is given by its two endpoint vertices [ax,ay,az] and [bx,by,bz]. It returns [collType], the type of collision that occured, the collision point in [cx,cy,cz] and in the case of an object collision also a reference to that colliding object. [collType] is always one of the following: 0 (no collision, collision point undefined, collObj=nil), 1 (collision with the mesh, collObj=nil), 2 (collision with an object, collObj=gObjects[x]). See the tutorials for more information about the gObjects table. lineCollision() gives information about the closest collision to the start point [ax,ay,az] only. In case you are interested in all object or mesh intersections on the line, you can call lineCollision repeatedly and turn off collision of each object you collide with using setObjectInfo(gObjects[x].cObj, IG3D_COLL, false) until no new collision happens. That won't help for mesh collisions though. To handle that you will need to change the line starting point [ax,ay,az] to something behind [cx,cy,cz] to detect collisions behind the first mesh collision. In most cases you will be interested in the first collision only though. | |
| `loadFont(filePath1, filePath2)` | A font is stored in 2 textures. With this function the textures are loaded from [filePath1] and [filePath2]. The paths are relative to the iGame3D root directory. Take a look at Data/FontPngs/default32_1.png and Data/FontPngs/default32_2.png to see how the textures are made. You can use the glfontmaker to create the textures which is available at the iGame3D website | |
| `loadLevel(folderPath)` | Loads the level located at [folderPath]. This folder is relative to the iGame3D root directory. To be exact: The scene is cleared and the file load script.lua inside the folder is loaded and executed. For example loadLevel("Data/Levels/FPS") will load and run "Data/Levels/FPS/load script.lua". | |
| `loadMesh(filePath)` | Loads a mesh in one of the supported formats (WTF, Coalesce, OBJ, 3DS, LWO) from file [filePath]. This file is relative the iGame3D root directory. | |
| `loadScript(filePath)` | Loads and runs the Lua script file at [filePath]. This path is relative to the iGame3D root directory | |
| `loadSound(filePath)` | Loads a sound from an OGG Vorbis file located at [filePath]. This path is relative to the iGame3D root directory. After the loading you can apply it to sound emitters. See setSound_emitterInfo() for further details. | |
| `loadTexture(filePath)` | Loads a texture from a PNG image file located at [filePath]. This path is relative to the iGame3D root directory. After the loading you can apply this texture to particle emitters, mesh materials or object materials. See setParticle_emitterInfo(), setMaterialInfo() for further details. | |
| `make(entityType, ...):(entity)` | There are entities which can explicitly created such as object, emitters etc. Other entities are always there like the camera and the 8 different lights. And some entities are implicitly created by loading a mesh or object model. Any mesh materials are created when loading a level mesh and an object's bones are created when loading the object model. make() creates an entity of type [entityType]. Depending on the type other additional parameters are needed. They are listed in detail here: | |
| `newtonPass(timeStep)` | Forces the Newton Game Dynamics library which iGame3D internally uses for physics simulation to perform a simulation step of [timeStep] seconds. Typically you won't need to use this because in every game loop the physics simulation is performed with the correct time step. | |
| `parseFluid(file1, file2)` | Converts a fluid (.fl) file at full path [file1] to a lua script file (.lua) at full path [file2]. This will overwrite an existing lu script at path [file2]. Fluid is the FLTK User Interface Designer program used to design user interfaces for FLTK. iGame3D is using FLTK for its GUIs as well. | |
| `passed():(seconds)` | This paremeterless function returns the amount of time elapsed since the last game frame in seconds. Since the game loop should run at least 50 times a second, values of < 0.02 are typical. | |
| `pause(trueOrFalse)` | If [trueOrFalse] is set to true, this will pause iGame3D. All sounds are stopped and the time is halted. No game loop will be run. With [trueOrFalse] set to false, the game is unpaused (resumed). | |
| `quit()` | Immediately quits the iGame3D Player. Any unsaved changes will be lost. | |
| `render()` | Forces redrawing of the GL scene. Typically you won't need to do this because the GL scene is drawn in every game loop. | |
| `saveLevel(folderPath)` | Saves the current scene as a load script.lua file inside folder [folderPath]. This folder is relative to the iGame3D root directory. In case there is a mesh in the scene, a loadMesh() function is added to this load script that loads the most recently saved or loaded mesh WTF file. saveLevel() fails if the desired folder does not exist. You can use ig3d_CreateDirectory_s() to create missing folders if you ever need to. A level saved this way can be loaded using loadLevel(). | |
| `saveMesh(filePath)` | Saves the level mesh to file [filePath]. This path is relative to the iGame3D root directory | |
| `saveTexture(filePath, saveAsFilePath)` | Saves the texture [filePath] at path [saveAsFilePath]. This path is relative to the iGame3D root directory. The texture [filePath] needs to be in memory for this to work. It must have been loaded using loadTexture() or created using make(ig3d_texture, ...). You can use this function to create copies of textures (different [filePath] and [saveAsFilePath]) or to simply save textures created on the fly with make(ig3d_texture, ....). The following example illustrates this: | |
| `time():(seconds)` | This paremeterless function returns the amount of time elapsed since startup of the iGame3D Player. | |

## 2. Terms from the drafts

| Term | Meaning (Spark, checked names) | Seen in |
|---|---|---|
| `.emt` | particle emitter settings file containing key-value pairs for particle behavior | Emitters/oldEmitters/More Emitters, Emitters/oldEmitters/Star |
| `.emt file` | particle emitter settings file in the iGame3D project, containing `key=value` pairs for particle behavior. | Scripts/Convert |
| `.fl file` | FLUID (FLTK UI designer) text file containing FLTK UI widgets and Lua code blocks for the iGame3D user interface. | Scripts/Convert |
| `3D vector` | a set of x, y, z coordinates used for spatial calculations | Scripts/iFly_Functions |
| `8-row binary pattern` | A glyph stored as eight rows of binary `0`/`1` characters representing a character's pixel pattern. | Scripts/Convert |
| `A* grid setup` | setup of the pathfinding grid used by the A* system for path generation. | Scripts/RTS_Functions |
| `A* pathfinding` | algorithm that finds the shortest path between two nodes by expanding nodes and tracking open/closed node lists | Scripts/RTS_Functions |
| `AI behaviour` | logic that drives game object behaviour, including sense handling, task execution, combat, and animation. | Scripts/RTS_Functions |
| `alive flag` | a flag marking a window as currently active. | Scripts/UDG_Functions/UDG_Entities |
| `allPoints` | Global shared between files that holds the list of points for path objects. | Scripts/Functions |
| `amount` | the number of particles an emitter produces. | Emitters/oldEmitters/Star |
| `angle` | a degree value used for rotation and angle difference calculations | Scripts/iFly_Functions |
| `anim` | flag setting for emitter particle animation behavior | Emitters/oldEmitters/More Emitters, Emitters/oldEmitters/Star |
| `anim settings` | animation parameters applied to the emitter | Emitters/oldEmitters/Glo |
| `Animation offset` | the starting frame offset for a model animation source file. | Scripts/Functions |
| `animation reference` | a reference to a video or GIF asset used for animated particle behavior | Emitters/oldEmitters |
| `animTable` | Table holding the animation entries for a zombie style.` | Scripts/RTS_Functions/RTS_Entities |
| `AntackGUI0` | game or demo level folder | Levels/AntackGUI0/Textures |
| `AntackTrainer` | the level folder this textures folder belongs to, containing its associated game or demo assets | Levels/AntackTrainer/Textures |
| `AquariusCharactersPMB conversion` | The font conversion process this script supports, building character glyph data for the PMB character set. | Scripts/Convert |
| `arcadeFont` | a local table mapping font names to glyph name/glyph pairs used for text rendering. | Scripts/Functions |
| `area` | the spatial region particles are emitted from | Emitters/oldEmitters/Glo, Emitters/oldEmitters/Star |
| `askLevel` | Global flag indicating whether the level selection UI has been requested.` | Scripts/Functions/Menus |
| `asksaveLevel` | Global flag indicating whether a save-as level dialog is already open.` | Scripts/Functions/Menus |
| `assign_free_sound_emitter` | engine function that assigns a free sound emitter to an object. | Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions/UDG_Entities |
| `assign_free_sound_emitter / setSound_emitterInfo` | engine calls used to attach and configure sound emitters for objects. | Scripts/UDG_Functions/UDG_Entities |
| `Auto bone updating` | engine setting that automatically updates bones during animation playback. | Scripts/Functions |
| `Auto Boning` | the workflow for preparing meshes and clustering mesh bones in the AutoBones tool. | Fluid/AutoBones |
| `auto-script generation` | code that produces the level's script output from collected entity info. | Fluid/CarAndDriver |
| `blood` | A property set to false to disable blood effects on objects.` | Scripts/RTS_Functions |
| `bodyPaintUnit` | A widget providing a unit value used for texture and material settings.` | Fluid/BodyPaint |
| `bone_name` | A name identifying a specific bone on a character object. | Scripts/Examples |
| `boneMeshCluster` | helper routine that clusters the bones of a mesh. | Fluid/AutoBones |
| `BoningWindow` | the FLTK user interface widget defined by AutoBones.fl for the Auto Boning workflow. | Fluid/AutoBones |
| `BSDDungeonSpawnsOut` | function that writes formatted spawn data to a generated Lua file under the Dungeons WTF folder. | Scripts/Convert |
| `buildingTeam` | global value identifying the building team for the objects being configured. | Scripts/UDG_Functions/UDG_Entities |
| `bulletTimeKey` | A function that toggles freeze-time slow mode and resets game speed when a specified key is pressed. | Scripts/RTS_Functions |
| `BVH` | a 3D motion capture file format used for animation data. | Fluid/BVHbrowser, Scripts/Convert, Scripts/Examples +2 |
| `BVH frame` | a unit of motion data in a BVH file containing channel offsets, neutral coordinates, and child frames. | Scripts/Examples |
| `BVHBrowser` | the FLTK UI window for browsing and manipulating BVH files. | Fluid/BVHbrowser |
| `bvhmarker` | a marker object used to store generated BVH frame and mesh data. | Scripts/Examples |
| `BVHPathTables` | Generated Lua table file holding scanned BVH folder paths and animation names. | Scripts/Convert |
| `BVHTables` | a Lua table mapping BVH animation names to their saved file paths, generated by the file. | Scripts/oldConvert |
| `C function` | a native compiled function in the host environment, distinct from Lua functions in the engine. | Scripts/Functions |
| `callback` | FLTK widget binding that associates a button with a code block or named function. | Fluid/AutoBones, Fluid/Collector, Fluid/Colors +1 |
| `camera` | the view object holding position and angle properties used for direction and distance math | Scripts/iFly_Functions |
| `CameraBrowser` | FLTK user interface for browsing and editing cameras; FLUID - FLTK UI designer text format; WTF - 3D model and text source format; FLTK - user interface library; FL - FLTK UI file format. | Fluid/CameraBrowser |
| `cars` | table built by UDG_Car.lua to register RTS vehicle objects for the game. | Scripts/UDG_Functions/UDG_Entities |
| `chr` | Global table storing character glyph bitmaps and character data for the conversion script. | Scripts/Convert |
| `ClassesBrowser` | the FLTK UI window that provides the class browsing and management interface | Fluid/ClassesBrowser |
| `clearsceneClicked` | Function called when the Clear Scene menu item is selected. | Scripts/Functions/Menus |
| `cluster mesh bones` | The engine operation `ig3d_ClusterMeshBones` that groups selected mesh bones for display. | Scripts/Functions |
| `coll_o_m / coll_o_o / coll_o_p / coll_p_p / coll_p_m` | Global collision dispatch functions for object and particle interactions` | Scripts |
| `collect destination` | the directory path where collected levels are stored | Fluid/Collector |
| `Color attribute` | A property such as background color, grid color, light color, fog, or tint color that can be edited via the color editor. | Fluid/Colors |
| `Color edit mode` | A state (`gColorEditMode`) that selects which color attributes are being edited, such as background, grid, light, or fog | Fluid/Colors |
| `Color editing interface` | The FLTK-based window with color input widgets, color chooser, and fog toggle controls used to adjust scene, light, fog, and tint color attributes. | Fluid/Colors |
| `Color source texture` | The texture (`Data/Images/Colors/colorsource.png`) used to extract colors from a mouse position | Fluid/Colors |
| `color_cycle` | global function that cycles colors using the `counter` global and applies the resulting color. | Fluid/Mappers |
| `colormap` | The FLTK color chooser widget used for selecting colors in the editor. | Fluid/Colors |
| `computeLODModelName` | engine function used to compute the model name for level of detail rendering. | Scripts/UDG_Functions/UDG_Entities |
| `computeShadowModelName` | engine helper that computes the shadow model name for an object. | Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions/UDG_Entities |
| `connections` | a global tracking variable for connected chat clients. | Scripts/Functions |
| `conversionTable` | Table matching BVH and WIF animation paths for conversion. | Scripts/Convert |
| `convertFluidToIg3d` | a conversion function that turns a FLUID `.fl` file into a corresponding Lua file. | Scripts/Convert |
| `createLocalMatricesForBVHFrame` | function used to generate frame matrix data for BVH conversion. | Fluid/BVHbrowser, Scripts/Examples |
| `createMeshBones` | recursively creates mesh bones for a BVH hierarchy, drawing vertex positions and setting mesh positions. | Scripts/Examples |
| `CXX` | C++ source files that are converted into iGame3D Lua code. | Scripts/oldConvert |
| `Data` | folder containing all engine and game data files | Levels/AntackGUI0/Textures |
| `Data/` | Folder holding game assets, scripts, and level folders, referenced by relative path concatenation in code. | Scripts/Functions, Scripts/Functions/Menus |
| `Data/ folder` | the central folder in the iGame3D project where all project code, assets, and folders are organized. | Scripts/Convert |
| `Data/ path` | folder-based path used to locate engine assets and scripts. | Scripts/Functions |
| `Data/Sounds` | Folder containing sound asset files used by the sound functions.` | Scripts/UDG_Functions |
| `debug info` | host debug library data that describes the current execution context, including function and line details. | Scripts/Functions |
| `default_escapekey` | a function used to handle escape key interactions for chat clients. | Scripts/Functions |
| `documentation` | A global table storing structured help content for functions, variables, and reference data. | Scripts/Functions |
| `dofile` | engine call used to load Lua scripts from file paths. | Scripts/Convert, Scripts/FPS_Functions, Scripts/Functions +5 |
| `dofile(...)` | the iGame3D engine call used to load Lua code from a file path. | Scripts/Convert |
| `dontPlaceRandomly` | A flag disabling random object placement.` | Scripts/UDG_Functions |
| `doorsTeam` | global used to configure door-specific state flags. | Scripts/RTS_Functions/RTS_Entities |
| `doorTeam` | Shared reference to the door object set used by door management functions. | Scripts/UDG_Functions/UDG_Entities |
| `dragGrid` | function that handles grid dragging events and fills a temporary grid with rectangles. | Fluid/Mappers |
| `drawBox` | callback function that captures event coordinates, draws a square rectangle, and triggers color cycling. | Fluid/Mappers |
| `drawrectF` | function that draws a filled rectangle using a color cycle and a square of a given size. | Fluid/Mappers |
| `drive_to_obj` | Function that drives an object to a target object by computing a direction and calling `drive_to_spot`. | Scripts/RTS_Functions |
| `DSB` | text map data format read by the tool. FLTK - user interface framework used by the tool. DSB_Dungeons - Lua script loaded for map conversion. FLUID - FLTK UI designer text format for the .fl files. | Fluid/DungeonMapper |
| `DSB conversion` | The iGame3D text-to-map conversion flow that translates text map data into 3D dungeon maps. | Scripts/Functions |
| `DSB conversion script` | the 2008 3D game engine scripted in Lua 5.1 used for the DSB project, with its own global configuration and startup routine. | Scripts/Convert |
| `dsb_text2map` | Engine call that wraps a text-to-map conversion script for use in the DSB flow. | Scripts/Functions |
| `dsbaddchampion` | DSB champion data table collecting champion arguments for the DSB dungeon system. | Scripts/Convert |
| `dsbspawn` | DSB spawn data table collecting spawn arguments for the DSB dungeon system. | Scripts/Convert |
| `dsbtext2map` | DSB text-to-map data table holding map text, coordinates, and button actions. | Scripts/Convert |
| `DWindow` | global FLTK window object used to manage the mapper UI window. | Fluid/Mappers |
| `eat_dead_human / object_action_eat / object_action_melee` | Functions handling eating and melee collision actions for objects. | Scripts/RTS_Functions |
| `edit_func` | Global shared between files holding the edit function. | Levels/iFly/iFly_Title, Scripts, Scripts/Examples |
| `editingModeSwitch` | Engine call that switches the active editing mode of the engine, such as "lookaround". | Scripts/Functions |
| `editMenuText` | Table holding the fixed labels for the Edit menu. | Scripts/Functions/Menus |
| `Editor key input` | key handling in UDG_Editor.lua that routes pressed keys to matching object creation functions. | Scripts/UDG_Functions |
| `emission rate` | how often particles are emitted from the emitter | Emitters/oldEmitters/Glo, Emitters/oldEmitters/More Emitters, Emitters/oldEmitters/Star |
| `EmissionInputGroup` | A particle emitter group used to control emitter input settings in the particle menu. | Scripts/Functions/Menus |
| `emitter` | table of emitter style data used to configure particle emitters. | Scripts/Functions |
| `emitter attribute` | A named setting (model, amount, life, etc.) inside an emitter file. | Scripts/Functions |
| `emitter name` | The identifier used to reference a specific particle emitter in the code. | Scripts/RTS_Functions/RTS_Entities |
| `emitter source` | The `.emt` file path that defines an emitter's settings. | Scripts/Functions |
| `emitter value` | A value paired with an emitter attribute in an emitter file. | Scripts/Functions |
| `emitter-settings` | configuration file defining particle emission parameters for 3D effects; `.emt` - file format for particle emitter settings containing key-value particle definitions; particle definitions - reusable configuration data for particle emission parameters used in 3D effects; particle emission parameters - configuration values defining how particles are emitted, including model, amount, emission rate, life, fade, size, speed, and explode settings; images/ textures - texture assets referenced by the emitter settings files | Emitters/oldEmitters, Emitters/oldEmitters/Blast, Emitters/oldEmitters/FireBalls +2 |
| `Emitters` | .emt particle settings referenced by the engine's particle system. | Scripts/Convert |
| `EmitterSourceGroup` | A particle emitter group used to load the particle source list in the particle menu. | Scripts/Functions/Menus |
| `Engine-core initialization` | the UDG_Init.lua entry point that sets global game state, preloads scripts, loads entity scripts, and runs initialization steps. | Scripts/UDG_Functions |
| `entity class` | a predefined set of entity types (humans, cars, zombies, etc.) managed by `gDefaultEntityClasses` | Fluid/ClassesBrowser |
| `entityBtnClick` | callback function for entity button interactions in the mapper UI. | Fluid/Mappers |
| `entityMenuPick` | function that routes a selected Entity menu row to the matching Entity browser or editor. | Scripts/Functions/Menus |
| `entityMenuText` | table holding the labels for the Entity menu items. | Scripts/Functions/Menus |
| `EntityPicker` | the application component this UI file supports, managing entity selection and value input. | Fluid/EntityPicker |
| `escape_to` | a function used to route escape key interactions to a target. | Scripts/Functions |
| `esize` | grid cell size used to determine marker placement and drawing. | Fluid/Mappers |
| `event task` | a task set on an object to run when a game event occurs, such as looking at, stabbing, or sidestepping a target. | Scripts/RTS_Functions |
| `event_constants` | A global table holding FLTK event type constants used by event handling functions. | Scripts/Functions |
| `explode` | whether particles move outward from the emission point | Emitters/oldEmitters/Glo, Emitters/oldEmitters/More Emitters, Emitters/oldEmitters/Star |
| `exvar` | Event variable configuration attached to spawn entries, setting activation, interaction, and behavior rules for objects like triggers, buttons, teleporters, and generators. | Scripts/Convert |
| `facetitles` | A function that populates text box titles/labels for the UI. | Scripts/Functions |
| `fade` | whether particle visibility decreases over time | Emitters/oldEmitters/Glo, Emitters/oldEmitters/Star |
| `fastFilePaths` | Engine call that builds file paths for the specified asset type. | Fluid/ExportObj |
| `fight_enemy_order` | Function that assigns a fight order to an object. | Scripts/RTS_Functions |
| `fill_*Menu` | Functions that populate individual menu sections of the application menu bar from label tables and folder contents. | Scripts/Functions/Menus |
| `fill_EntityMenu` | function that populates the Entity section of the main menu. | Scripts/Functions/Menus |
| `fill_FluidsMenu` | function that builds and adds the fluid menu lines to the menu bar. | Scripts/Functions/Menus |
| `fill_LevelMenu` | Function that populates the level menu bar with the stored labels. | Scripts/Functions/Menus |
| `Fl:run` | FLTK application entry point that launches the built UI` | Fluid/Mappers |
| `Fl_Browser` | FLTK UI widget used to display and select levels in the UI. | Fluid/Collector |
| `Fl_Button` | FLTK UI widget used for buttons in the Collector window. | Fluid/Collector |
| `Fl_Check_Browser` | FLTK check browser widget used for UI interaction in the EntityPicker` | Fluid/EntityPicker |
| `fl_dir_chooser / fl_file_chooser` | FLTK dialog functions that open folder or file selection windows. | Scripts/Functions |
| `Fl_Double_Window` | FLTK double-height window widget used to build the EntityPicker UI` | Fluid/EntityPicker |
| `FL_Double_Window` | A FLTK window type created by `fltk:Fl_Double_Window()` for displaying UI elements. | Scripts/Functions |
| `Fl_Group` | FLTK group widget used to organize UI elements within the EntityPicker` | Fluid/EntityPicker |
| `Fl_Input` | FLTK UI widget used for input fields in the Collector window. | Fluid/Collector |
| `Fl_Menu_Button` | FLTK menu button widget used for UI interaction in the EntityPicker` | Fluid/EntityPicker |
| `Fl_Output` | FLTK output widget used for UI interaction in the EntityPicker` | Fluid/EntityPicker |
| `Fl_Value_Input` | FLTK value input widget used for UI interaction in the EntityPicker` | Fluid/EntityPicker |
| `Fl_Window` | FLTK UI designer widget used to define the BoningWindow window. | Fluid/AutoBones, Fluid/Collector |
| `flagNode` | function that updates node collision flags based on object bounds and time | Scripts/RTS_Functions |
| `fltk` | FLTK user interface library used for the color editing window` | Fluid/Colors, Scripts/Functions |
| `FLTK` | the user interface toolkit used by the FLUID UI designer to build the window widgets. | Fluid/EntityPicker, Fluid/Mappers, Scripts/Examples +1 |
| `FLTK folder chooser` | the FLTK dialog used to select a directory for the collect destination | Fluid/Collector |
| `FLTK UI` | User interface components used for input and display in the engine. | Scripts/Functions |
| `FLTK UI calls` | FLTK user interface function calls used to create, show, and manipulate widgets, e.g. `colorswindow:show()`, `Fl:flush` | Fluid/Colors |
| `FLTK UI file` | FLUID designer text file (`Fl_Window`, `Fl_Button` etc.) used to build FLTK windows. | Scripts/Functions |
| `FLTK user interface` | the FLUID (FLTK) UI designer structure used to build the level's interface. | Fluid/CarAndDriver |
| `FLTK widget` | FLTK UI widget used to define the Collector window layout, including `Fl_Window`, `Fl_Browser`, `Fl_Button`, and `Fl_Input`. | Fluid/Collector |
| `FLTK widget calls` | User interface widget methods like label, value, hide, and redraw used to configure the UI.` | Fluid/Lights |
| `FLTK window` | the base FLTK interface window used to build the Collector UI | Fluid/Collector, Fluid/HelloWorld |
| `fltk.` | FLTK user interface calls used to build and manage the UI widgets. | Fluid/Colors |
| `fltk.fl_color` | FLTK engine call that applies a color to the UI. | Fluid/Mappers |
| `fltk.fl_color_chooser` | FLTK color chooser widget used to request user color input` | Fluid/Colors |
| `fltk.fl_file_chooser` | FLTK file chooser dialog used to let users select files or folders. | Scripts/Functions/Menus |
| `fltk.fl_rectf` | FLTK engine call that draws a filled rectangle with floating-point coordinates. | Fluid/Mappers |
| `fltk:Fl_Browser` | FLTK browser widget used for the tool's sub-window content` | Fluid/Mappers |
| `fltk:Fl_Double_Window` | FLTK double-height window widget used to build the tool's main interface` | Fluid/Mappers |
| `fltk:Fl_Menu_Bar` | FLTK menu bar widget used for the tool's sub-window controls` | Fluid/Mappers |
| `fltk_event_status` | A helper that checks pending FLTK events and formats mouse/event details into text. | Scripts/Functions |
| `fltk_update` | engine call used to refresh the FLTK user interface after AI updates. | Scripts/FPS_Functions, Scripts/Functions |
| `FLUID` | the FLTK User Interface Designer that authors this `.fl` file. | Fluid/EntityPicker, Scripts/Convert, Scripts/Functions +1 |
| `FLUID (FLTK UI designer)` | The FLTK-based UI designer used to author the `.fl` file's widget layout and code blocks | Fluid/Colors |
| `FluidsMenuText` | table holding the text content used to populate the fluid menu. | Scripts/Functions/Menus |
| `forget_corpses` | function that removes dead objects from an object's mind table. | Scripts/RTS_Functions |
| `Game loop` | the main UDG game logic loop, defined in UDG_Game.lua and UDG_Gamemine.lua. | Scripts/UDG_Functions |
| `Game object` | a registered entity in the engine that can have attributes, behaviours, and properties configured via engine calls. | Scripts/RTS_Functions |
| `game type` | a selected value that triggers scanning of the Scripts folder and folder creation for a new game | Fluid/ClassesBrowser |
| `game_func` | Global variable that selects the routine used to update the game loop. | Levels/HelloWorld, Levels/iFly/iFly_EnterName, Levels/iFly/iFly_Title +2 |
| `gameroot` | A global path used to build engine file paths under the `Data/` folder. | Scripts/Functions, Scripts/UDG_Functions/UDG_Entities |
| `gBrowserFiles` | A shared list of PNG files and directories in the current browser directory.` | Fluid/PNG_Browser |
| `gBrowserPath` | The current PNG directory path used to scan and navigate files.` | Fluid/PNG_Browser |
| `gBVHBrowserFiles` | global variable holding the list of available BVH files and directories. | Fluid/BVHbrowser |
| `gBVHBrowserPath` | global variable holding the current BVH file path used for loading files. | Fluid/BVHbrowser |
| `gBVHLastBrowserControlClick` | global timestamp tracking the last click on the BVH browser control. | Fluid/BVHbrowser |
| `gBVHLastSelection` | global state tracking the last selection index in the BVH browser. | Fluid/BVHbrowser |
| `gBVHSpeedCoefficient` | global variable controlling the playback speed of loaded BVH animations. | Fluid/BVHbrowser |
| `gCatchTexturePath` | A shared record of the texture path loaded from the PNG browser.` | Fluid/PNG_Browser |
| `gChosenLight` | global tracking the selected light for color application` | Fluid/Colors, Fluid/Lights |
| `gCollectSearchTable` | global search table used by collection functions to scan Lua script text for referenced file paths. | Scripts/Functions |
| `gColorAttribute` | global tracking the active color attribute being edited` | Fluid/Colors |
| `gColorEditMode` | global tracking the current color editing mode` | Fluid/Colors |
| `gColorTargets` | global list of color targets matched by color button labels` | Fluid/Colors |
| `gConverterString` | a global string accumulator used to collect and print conversion output. | Scripts/Convert |
| `gCurFrame` | A global holding the current BVH frame index. | Scripts/Examples |
| `gCurObject` | global variable holding the currently selected object. | Scripts/Functions/Menus |
| `gDangerFlag` | a global flag set to `false` at the top of the file to control danger state. | Scripts/FPS_Functions |
| `gDistances` | precomputed table of pairwise object distances built by `buildDistancesTable`. | Scripts/RTS_Functions |
| `gDoFileRemember` | shared global table tracking files that have been loaded or processed, used to remember loaded file paths. | Scripts/Functions |
| `gDoShadows` | global flag controlling whether shadow generation is enabled for objects. | Scripts/RTS_Functions, Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions/UDG_Entities |
| `gEditingMode` | global flag tracking the current editing mode of the engine. | Scripts/Functions |
| `generateAStarPathBetweenPositions` | Engine function that generates an A* path between two object positions.` | Scripts/RTS_Functions |
| `get` | engine call that retrieves an object by name. | Scripts/Functions, Scripts/UDG_Functions/UDG_Entities, Scripts/iFly_Functions |
| `getCameraInfo` | engine call that retrieves camera information for camera updates` | Scripts/RTS_Functions, Scripts/UDG_Functions |
| `getCameraInfo / setCameraInfo` | Engine calls used to read or set camera position and rotation properties. | Scripts/Functions |
| `getData` | A parameter passed to help functions that controls which type of help output is generated. | Scripts/Functions |
| `getLightInfo` | Reads current light settings for the game. | Scripts/FPS_Functions |
| `getMapAxisFromControls` | function that reads the map axis value from controls and returns a fixed tuple based on that value. | Scripts/Functions |
| `getObjectInfo` | engine call used to read object property values. | Fluid/BVHbrowser, Scripts/FPS_Functions, Scripts/Functions +4 |
| `getObjectInfo / setObjectInfo` | Engine calls that read or set object property values such as position, rotation, and text. | Scripts/Convert, Scripts/Functions, Scripts/RTS_Functions +2 |
| `getRandomAnimationOfStyle` | function that selects a random animation name and linked flag from a style-specific animation table. | Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions/UDG_Entities |
| `getrandthree` | Generates three random values, each calculated as a random number between 1 and 3 minus 2, and returns them as a tuple` | Scripts/Functions |
| `getSceneInfo` | engine call that retrieves scene information for a specified scene data type. | Fluid/BodyPaint, Levels/iFly/iFly_Controls, Scripts/Functions +3 |
| `getText_boxInfo` | iGame3D call used to read text box configuration (text, lines, etc.).` | Scripts/Functions |
| `gFirstFrame` | global controlling the start index for bone indexing during BVH loading. | Scripts/Examples |
| `gFourView` | A global flag tracking the four-view state of the game. | Scripts/Functions |
| `gHumanNames` | Predefined list of names used to identify human objects. | Scripts/RTS_Functions/RTS_Entities |
| `gInverseGameSpeed` | Global tracking state for the inverse game speed used in camera/object updates. | Scripts/RTS_Functions |
| `gLabelTable` | Global used by the light editor to manage label/value controls for light attributes.` | Fluid/Lights, Fluid/PNG_Browser |
| `gLastBrowserControlClick` | Shared control click state used for browser interaction.` | Fluid/PNG_Browser |
| `gLastMenuPick` | Global tracking the selected library pick value. | Scripts/Functions/Menus |
| `gLastSelection` | Shared selection state for the PNG browser.` | Fluid/PNG_Browser |
| `gLevelPath` | A global path variable used to locate level folders.` | Scripts/RTS_Functions |
| `gLightEditMode` | Global that stores the current light editing mode selected by the user.` | Fluid/Lights |
| `gLookAround` | Global tracking state for camera rotation. | Scripts/RTS_Functions |
| `gNativeOS` | Global holding the host operating system name` | Scripts |
| `gNumBoxes` | Global shared between files storing the number of boxes. | Levels/iFly/iFly_Title, Scripts/Functions |
| `gNumObjects` | global variable tracking the total number of loaded objects. | Scripts, Scripts/Functions, Scripts/Functions/Menus |
| `gNumTextboxes` | a global counter tracking the number of text boxes, used to wrap cycling counters. | Scripts/Functions |
| `gObjectPositions` | Global table holding object positions used during initialization.` | Scripts/UDG_Functions |
| `gObjects` | shared global holding engine objects used by the UI. | Fluid/CarAndDriver, Fluid/PNG_Browser, Scripts +6 |
| `goDirsUp` | Engine call to navigate up one directory level.` | Fluid/PNG_Browser |
| `gParticleNamesAndEMTs` | shared global table tracking registered emitter names and emitter types. | Scripts/Functions |
| `gReachedTolerance` | Shared engine global used to check whether an object has reached its target position. | Scripts/RTS_Functions |
| `grid button` | A FLTK button representing a grid cell coordinate for dungeon map editing. | Scripts/Functions |
| `gSafePlaces` | A table storing generated safe place coordinates.` | Scripts/UDG_Functions |
| `gSelBox` | Global shared between files storing the selected box index. | Levels/iFly/iFly_Title |
| `gSensesTime / gSensesInterval` | globals used to manage timed sense handling in the AI cycle. | Scripts/FPS_Functions |
| `gServerMode` | global setting that selects whether the client runs gathering or gameplay mode` | Fluid/3Dnetclient |
| `gSoundEmittersHighwaterMark` | Global counter tracking the current free sound emitter index for the highwater mark.` | Scripts/RTS_Functions |
| `gTelnetServer` | the iGame3D global holding the telnet server object used for network communication. | Scripts/Functions |
| `gTextboxes` | global list of text boxes used by the level's input handling. | Levels/iFly/iFly_EnterName, Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions/UDG_Entities |
| `gTrackedPosition` | Global tracking state for the position of the tracked object. | Scripts/RTS_Functions |
| `gTrackingLights` | Global collection of tracking lights assigned to human objects. | Scripts/RTS_Functions, Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions/UDG_Entities |
| `gTrackLightEnabled` | A shared global flag set to `false` at file level, controlling tracked light behavior. | Scripts/RTS_Functions |
| `GUI` | graphical user interface element for the game | Levels/AntackGUI0/Textures |
| `gunned_civilian_behaviour` | global setting controlling behaviour for gunned civilian objects. | Scripts/RTS_Functions, Scripts/RTS_Functions/RTS_Entities |
| `gunned_civilian_behaviour / soldier_behaviour` | Behaviour tables assigned to human objects based on random checks during setup. | Scripts/UDG_Functions/UDG_Entities |
| `guns` | global table used to collect and manage gun-tagged objects. | Scripts/UDG_Functions/UDG_Entities |
| `gYMod` | global controlling vertical motion handling during BVH processing. | Scripts/Examples |
| `gZoomDistance` | Global tracking state for the zoom distance of the camera. | Scripts/RTS_Functions |
| `hand bone` | A bone of a carrier object used as the attachment point for weapons.` | Scripts/RTS_Functions |
| `handle_clicks` | Function that processes mouse clicks, manages double-click detection, and handles drag-based object movement and line collision. | Scripts/RTS_Functions |
| `handle_FPS` | the function that runs the FPS game input, camera/object updates, level loading, and per-frame game logic. | Scripts/FPS_Functions |
| `handle_FPSAI` | the function that runs the FPS AI update cycle for the game. | Scripts/FPS_Functions |
| `handle_gameplay` | function that handles client input-driven movement and frame history updates` | Fluid/3Dnetclient |
| `handle_RTS` | Function that drives the RTS game loop, updating console text, scene settings, health, AI, and team selection. | Scripts/RTS_Functions |
| `handle_server_message` | function that processes incoming server messages for object position and rotation updates` | Fluid/3Dnetclient |
| `handle_UDG_Windows` | function in UDG_Window.lua that updates window position and rotation when the window is alive and health is greater than zero. | Scripts/UDG_Functions/UDG_Entities |
| `hitbad event` | an event that triggers when an object hits a bad target, scheduled with a delay and accompanied by the hit sound. | Scripts/RTS_Functions |
| `house flag` | a flag marking a window as a house window. | Scripts/UDG_Functions/UDG_Entities |
| `houseGrid` | grid state variable holding placed marker positions for the mapper. | Fluid/Mappers |
| `humans` | The collection of human objects managed by this file for gameplay setup. | Scripts/UDG_Functions/UDG_Entities |
| `iFly_AI` | game logic library for enemy and friend initialization, movement, shooting, power-up pickup, camera positioning, and cloud particle emitter generation | Scripts/iFly_Functions |
| `iFly_Game` | main script for the iFly game session that starts the game, loads the title level, configures scene and sound settings, and runs the game loop | Scripts/iFly_Functions |
| `iFly_Init` | engine-core file that initializes the iFly game startup sequence including object setup, sound emitter configuration, cloud generation, and camera/plane initialization | Scripts/iFly_Functions |
| `iFly_math` | math helper library providing vector and angle utility functions and the global SMALL_NUM constant | Scripts/iFly_Functions |
| `iFly_plane` | library providing reusable plane-related functions for plane orientation, control state, rotation, throttle, and physics | Scripts/iFly_Functions |
| `IG3D_` | iGame3D engine constants that name the property being read or set in object/scene/camera/light/text box calls. | Levels/iFly/iFly_EnterName, Scripts, Scripts/Functions +4 |
| `ig3d_* calls` | Engine function calls used to manipulate meshes, tags, and related objects. | Scripts/Functions |
| `IG3D_* constants` | Engine property names used to read or set light attributes such as position, ambient, diffuse, specular, spot, and attenuation.` | Fluid/Lights, Levels/iFly/iFly_Success, Scripts/Functions +4 |
| `IG3D_...` | Engine property constants used to read/set object properties such as position, rotation, text, and info. | Scripts/Functions, Scripts/RTS_Functions, Scripts/RTS_Functions/RTS_Entities +1 |
| `ig3d_... calls` | engine functions invoked to perform UV mapping operations on meshes. | Scripts/Functions |
| `IG3D_... constant` | Engine property name used in object info calls to identify the property being read or set (e.g., position, rotation). | Scripts/Convert |
| `IG3D_... constants` | iGame3D engine constants that name the property being read or set (e.g., `IG3D_POSITION` for position), not the kind of object. | Scripts/Convert |
| `ig3d_... first argument` | the iGame3D engine call pattern where the first argument names the kind of object (e.g., `ig3d_object`). | Scripts/Convert |
| `IG3D_ADD` | A property constant used to add texture data during drawing.` | Fluid/BodyPaint, Scripts/FPS_Functions |
| `IG3D_AMBIENT` | An engine constant naming the light ambient property being read or set. | Scripts/RTS_Functions |
| `IG3D_BACKGROUND_COLOR` | iGame3D constant naming the background color property` | Fluid/Colors, Scripts/Functions |
| `ig3d_bone` | Engine object kind used to reference character bones. | Scripts/Examples, Scripts/RTS_Functions |
| `IG3D_BONE_COLL` | the property name for an object's bone collision setting. | Scripts/RTS_Functions |
| `ig3d_box` | engine call used to create or configure a box-shaped object. | Scripts/UDG_Functions/UDG_Entities |
| `IG3D_BRAKE` | wheel property value controlling brake force for wheels.` | Scripts/RTS_Functions |
| `IG3D_CAST_SHADOW` | the property name for an object's cast shadow setting. | Scripts/RTS_Functions |
| `ig3d_chatserver` | the chat server connection handler function that processes connected chat clients. | Scripts/Functions |
| `IG3D_CLAMP` | A property constant used to clamp texture drawing parameters.` | Fluid/BodyPaint, Scripts/FPS_Functions |
| `IG3D_COLL` | the property name for an object's collision setting. | Scripts/RTS_Functions, Scripts/UDG_Functions/UDG_Entities |
| `IG3D_COLOR` | constant naming the color property being read or set | Levels/iFly/iFly_Controls, Scripts/UDG_Functions |
| `IG3D_EMISSION` | material property value controlling material emission.` | Scripts/RTS_Functions |
| `IG3D_ENABLED` | An engine constant naming the light enabled property being read or set. | Scripts/RTS_Functions |
| `IG3D_EXACT_COLLISION_DATA` | A property constant naming collision data retrieved from the scene.` | Fluid/BodyPaint, Scripts/FPS_Functions |
| `IG3D_FOG` | iGame3D constant naming the fog property being read or set` | Fluid/Colors |
| `IG3D_FONT` | Constant naming the font property of an object, used to set text box fonts. | Scripts/UDG_Functions |
| `IG3D_FORCE` | Engine property constant naming the force of an object being set.` | Scripts/iFly_Functions |
| `IG3D_FRAGMENT_SHADER_SUPPORTED` | iGame3D constant indicating whether fragment shader support is enabled for the engine. | Scripts/Functions, Scripts/RTS_Functions/RTS_Entities |
| `ig3d_GetTextboxInfo_i_3i4f2s` | engine call that reads text box info (position, text, etc.). | Scripts/Functions |
| `IG3D_GRAVITY_MULTIPLIER` | the property name for an object's gravity multiplier. | Scripts/RTS_Functions, Scripts/UDG_Functions/UDG_Entities |
| `IG3D_LEVEL_MESH` | Engine constant naming the level mesh property being set.` | Scripts/Functions/Menus |
| `IG3D_LOD_MODEL` | the property name for an object's LOD model setting. | Scripts/RTS_Functions |
| `IG3D_LOOP` | Engine constant naming the loop property of a sound emitter being read or set.` | Scripts/UDG_Functions |
| `ig3d_material` | iGame3D engine call naming the kind of object being manipulated, here a material. | Scripts/Functions |
| `IG3D_MOUSE_LINE` | A property constant naming mouse line data retrieved from the scene.` | Fluid/BodyPaint, Levels/iFly/iFly_Controls, Scripts/Functions |
| `IG3D_MOUSE_VIEW` | Engine constant used to set the scene to mouse view mode. | Scripts/Functions |
| `IG3D_NAME` | engine constant naming the object name property being read or set. | Fluid/BVHbrowser, Scripts/RTS_Functions, Scripts/UDG_Functions/UDG_Entities |
| `ig3d_object` | an object kind used by engine make/get calls to create or query objects` | Fluid/3Dnetclient, Scripts, Scripts/Examples +3 |
| `ig3d_object / ig3d_bone / ig3d_material` | Engine object types used as the first argument to `make`/`get` calls. | Scripts/RTS_Functions |
| `IG3D_OMEGA` | Engine constant naming the angular velocity property of an object. | Scripts/Examples |
| `ig3d_particle_emitter` | The engine object kind used to read and set particle emitter properties. | Scripts/Functions/Menus, Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions/UDG_Entities |
| `IG3D_POSITION` | engine constant naming the position property of an object` | Fluid/3Dnetclient, Fluid/BodyPaint, Levels/HelloWorld +6 |
| `IG3D_POSITION / IG3D_ROTATION / IG3D_ROTATION_MATRIX` | engine constants naming the properties being read or set on objects. | Scripts/Examples |
| `IG3D_RAGDOLL` | Engine property constant naming the ragdoll state of an object, used to read object ragdoll info.` | Scripts/RTS_Functions |
| `IG3D_RECEIVE_SHADOW` | A constant naming the property being read or set for shadow reception.` | Scripts/RTS_Functions |
| `IG3D_ROOT` | Engine constant naming the scene property being read for the game root. | Levels/iFly/iFly_Title, Scripts/Examples, Scripts/Functions +1 |
| `IG3D_ROTATION` | Engine constant naming the rotation property of a bone. | Scripts, Scripts/Examples, Scripts/Functions +1 |
| `IG3D_ROTATION_MATRIX` | Engine constant naming the rotation matrix property of an object. | Scripts/Examples, Scripts/RTS_Functions, Scripts/iFly_Functions |
| `IG3D_SAMPLE` | Engine constant naming the sample property of a sound emitter being read or set.` | Scripts/UDG_Functions |
| `ig3d_SetTextboxInfo_4i4f2s` | engine call that sets text box info (position, text, etc.). | Scripts/Functions |
| `IG3D_SIZE` | Constant naming the object property for size. | Scripts/Functions, Scripts/UDG_Functions |
| `IG3D_SOUND_DAMPING` | Engine constant naming the sound damping property being set.` | Scripts/RTS_Functions |
| `IG3D_SPEED` | An engine constant naming the scene speed property being read or set. | Scripts/RTS_Functions |
| `IG3D_STEERING_ANGLE` | wheel property value controlling steering angle for wheels.` | Scripts/RTS_Functions |
| `IG3D_STOP, IG3D_CLEAR_PARTICLES, IG3D_START` | Engine constants naming the properties read or set on particle emitters for stop, clear, and start actions. | Scripts/Functions/Menus |
| `ig3d_telnetserver` | the function that manages the Telnet server lifecycle, connection tracking, and message relaying | Scripts/Functions |
| `IG3D_TEXT` | engine constant naming the text property of a text box` | Fluid/3Dnetclient, Levels/HelloWorld, Levels/iFly/iFly_Controls +2 |
| `IG3D_TEXTURE` | engine property constant naming the texture property being read or set on objects. | Fluid/BodyPaint, Scripts/Examples, Scripts/FPS_Functions +4 |
| `ig3d_texture` | iGame3D engine call naming the kind of object being manipulated, here a texture. | Scripts/Functions |
| `IG3D_TORQUE` | wheel property value controlling wheel torque for driving.` | Scripts/RTS_Functions, Scripts/iFly_Functions |
| `IG3D_TRANSPARENT` | engine property constant naming the transparency property being read or set on objects. | Fluid/BodyPaint |
| `IG3D_UV_TRANSFORMATION` | Engine constant naming the UV transformation property being read or set on a material.` | Scripts/Examples, Scripts/Functions |
| `IG3D_VECTOR_CONSTRAINT` | the property name for an object's vector constraint setting. | Scripts/RTS_Functions |
| `IG3D_VELOCITY` | object property holding the object's velocity used for sound and steering calculations.` | Scripts/RTS_Functions, Scripts/iFly_Functions |
| `IG3D_WHEEL_DELTA` | iGame3D constant used for wheel-based zoom input handling` | Scripts/RTS_Functions |
| `IG3D_WINDOW_COORDS` | constant naming the window coordinates property being read | Levels/iFly/iFly_Controls, Scripts/Functions |
| `iGame3D` | the 2008 3D game engine scripted in Lua 5.1 using murgaLua, FLTK, and LuaFileSystem. | Scripts/Convert, Scripts/oldConvert |
| `iGame3D calls` | Engine API functions used to create, read, and set object properties in the game. | Levels/HelloWorld, Levels/iFly/iFly_Options, Scripts/Functions/Menus |
| `iGame3D calls and constants` | Engine API calls and property constants used to read or set object attributes in the iGame3D engine, e.g. `getSceneInfo`, `setLightInfo`, `IG3D_FOG` | Fluid/Colors |
| `iGame3D session` | the current running 3D game session managed by the engine; quit - the action of ending the current iGame3D session; level-script - the entry script for a level that starts the level session when the level is loaded | Levels/iFly/iFly_Quit |
| `ignore-collision` | a property that disables object collision for an object. | Scripts/RTS_Functions |
| `init_car` | Function used to initialize a car object (referenced in the file's dependency list). | Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions/UDG_Entities |
| `insideRECT` | Returns true only when both the given x and y coordinates fall within the specified rectangle boundaries, otherwise returns nothing` | Scripts/Functions |
| `insmark` | insertion mark used to track text editing position. | Levels/iFly/iFly_EnterName |
| `isFemale` | Function used to adjust zombie voice pitch for female zombies.` | Scripts/RTS_Functions |
| `isTwoHandedWeapon` | A function that checks whether an object is a two-handed melee weapon by comparing its model path. | Scripts/UDG_Functions/UDG_Entities |
| `key-value settings` | parameter pairs (name = value) defining emitter behavior | Emitters/oldEmitters |
| `labels` | Global shared between files holding title labels. | Levels/iFly/iFly_Title |
| `lastLoadedFile` | Global holding the name of the last loaded file used to build export paths. | Fluid/ExportObj, Scripts/Functions/Menus |
| `Level` | a folder containing game or demo content, loaded via loadLevel | Levels/AntackGUI0/Textures, Scripts/Convert |
| `level browser` | a FLTK widget listing available game levels for selection | Fluid/Collector |
| `Level listing` | a generated list of UDG levels, produced by scanning folder contents and extracting names from file names in UDG_Utilities.lua. | Scripts/UDG_Functions |
| `Level script` | script that loads and initializes a multi-folder game level setup, including preloading libraries and configuring scene settings. | Scripts/RTS_Functions |
| `level-script` | A script file that configures level options, sets up the main game loop, and handles level-specific UI interactions. | Levels/iFly/iFly_Options |
| `levelexit` | A table collecting the exit entities for a level, built from game objects whose names contain `levelexit`. | Scripts/UDG_Functions/UDG_Entities |
| `levelexitTeam` | Global name associated with the UDG level's exit entity configuration. | Scripts/UDG_Functions/UDG_Entities |
| `levelislit` | global flag marking whether the current level is lit, set to `true` by `UDGWorkLighting` and `false` by `UDGLevel1Lighting`. | Scripts/UDG_Functions |
| `levelmapXY` | The level map grid used to position objects and generate safe places.` | Scripts/UDG_Functions |
| `levelMenuText` | Global table holding the labels used to build the level menu. | Scripts/Functions/Menus |
| `levels` | Global shared between files holding level names. | Levels/iFly/iFly_Title |
| `LevelsMenuText` | Table holding the text content used to populate the Levels menu UI.` | Scripts/Functions/Menus |
| `lfs.attributes` | LFS call that checks the mode (file or directory) of a given path. | Scripts/Functions |
| `lfs.dir` | murgaLua host call to list files in a directory.` | Fluid/PNG_Browser, Scripts/Functions, Scripts/Functions/Menus |
| `Library_menuBar` | FLTK UI widget used to display the Objects menu bar. | Scripts/Functions/Menus |
| `LibraryMenuText` | Local table listing library menu entries for the library menu. | Scripts/Functions/Menus |
| `life` | the duration particles remain active | Emitters/oldEmitters/Glo, Emitters/oldEmitters/More Emitters, Emitters/oldEmitters/Star |
| `lightAttributes` | List of light attribute names used by the UI to define available light properties.` | Fluid/Lights |
| `linked` | Flag indicating whether an animation entry is linked.` | Scripts/RTS_Functions/RTS_Entities |
| `listdspspawn` | function that builds a formatted text representation of the `dsbspawn` table. | Scripts/Convert |
| `listFolders / listFiles` | Functions that list subfolders or files inside a given path using the file system listing API. | Scripts/Functions |
| `loadBVHFile` | engine call used to load a selected BVH file. | Fluid/BVHbrowser, Scripts/Examples |
| `loadstring` | Engine call that compiles and runs a dynamically constructed Lua string. | Scripts/Functions |
| `loadtime` | The time value used to gate level loading in the loop. | Levels/iFly/iFly_Briefing |
| `local transformation matrix` | a matrix computed for a BVH frame to represent its local position and rotation offsets. | Scripts/Examples |
| `lookaround` | The camera editing mode that lets the user rotate and move the camera via mouse and keyboard input. | Scripts/Functions |
| `loop` | The game loop function that runs repeatedly during gameplay. | Levels/iFly/iFly_Briefing, Levels/iFly/iFly_Controls, Levels/iFly/iFly_EnterName |
| `low.wtf / shadow.wtf` | model file names appended to object model paths to get low-level and shadow-level model names. | Scripts/RTS_Functions |
| `Lua function` | a function defined inside Lua code in the engine, distinct from C functions. | Scripts/Functions |
| `lux` | a parameter controlling particle light properties. | Emitters/oldEmitters/Star |
| `lux flag` | flag controlling light-related emitter behavior | Emitters/oldEmitters/Glo |
| `main menu widget callback` | The callback handler that processes user input from the main menu interface. | Scripts/Functions/Menus |
| `mainMenuIndex` | Global table/value used as the base index for menu labels and to resolve menu actions. | Scripts/Functions/Menus |
| `make / get` | Engine calls used to create or retrieve objects by kind and file/name, e.g. `make(ig3d_object, "file.wtf")`. | Scripts/Convert, Scripts/Functions |
| `make/get` | Engine calls used to create or retrieve objects by kind and name.` | Scripts/UDG_Functions |
| `make_cloud` | Generates a cloud object for the game.` | Scripts/iFly_Functions |
| `make_window` | engine/tool routine that creates the BoningWindow window. | Fluid/AutoBones |
| `makeHelpTables` | A function that reads help text files and builds documentation tables for engine functions. | Scripts/Functions |
| `map level` | A specific dungeon or level folder/level identifier used to select game content. | Scripts/Functions |
| `map text array` | The text-based map data array used to build dungeon maps and mapper UI. | Scripts/Functions |
| `mapDrop` | function that places a drop marker at given mouse coordinates. | Fluid/Mappers |
| `mapper window` | The FLTK window used to browse and edit dungeon maps interactively. | Scripts/Functions |
| `math.random` | The host's random number generator used for procedural values.` | Scripts/RTS_Functions |
| `matrix` | A 3x3 or 4x4 numeric array used for 3D transformations in the engine. | Scripts/Functions, Scripts/iFly_Functions |
| `matsetting` | FLTK settings object used to configure material property options.` | Scripts/Functions |
| `MaxLines` | global set to 100, the maximum allowed lines for text boxes.` | Scripts/Functions |
| `meleeWeapons` | A shared table that holds classified melee weapons and their assignment targets. | Scripts/UDG_Functions/UDG_Entities |
| `menu fill functions` | Functions that populate individual sections of the application menu bar. | Scripts/Functions/Menus |
| `menu index lookup` | A table mapping menu labels to corresponding menu index values used to dispatch menu actions. | Scripts/Functions/Menus |
| `menu pick` | Functions that route selected menu rows to matching engine UI windows, browsers, or editors. | Scripts/Functions/Menus |
| `menuBar` | FLTK UI widget container used to display menu labels and add menu lines. | Scripts/Functions/Menus |
| `menuBar:add` | Engine call that adds a menu bar entry to the library menu. | Scripts/Functions/Menus |
| `menuIndexCount` | Global counter tracking the number of existing menu items used to compute menu index positions. | Scripts/Functions/Menus |
| `mesh bone` | a bone created from a vertex and parent name to represent a mesh vertex in the BVH output. | Scripts/Examples, Scripts/Functions |
| `mesh bone list` | The list of bones returned by `ig3d_GetMeshBonesList__s`, parsed into a tree structure by `listBones`. | Scripts/Functions |
| `mesh bone widget` | A FLTK UI widget (`meshBones`) used to display and select mesh bone names. | Scripts/Functions |
| `mesh centroid` | The center point of a mesh, accessed via `ig3d_GetMeshCentroid__3f()`. | Fluid/Meshtags |
| `mesh menu` | the FLTK menu structure for selecting and editing mesh data in iGame3D. | Scripts/Functions/Menus |
| `mesh menu callback` | the FLTK button callback that handles mesh menu button interactions and dispatches pick actions. | Scripts/Functions/Menus |
| `mesh mirror` | mirroring an iGame3D mesh along a defined axis using MIRRORX, MIRRORY, or MIRRORZ constants. | Scripts/Functions/Menus |
| `mesh pick` | the action routing logic that maps a selected menu option to a mesh editing engine function. | Scripts/Functions/Menus |
| `mesh tag` | tag used to identify mesh objects in iGame3D; FLTK - user interface toolkit used by the engine; FLUID - FLTK UI designer producing .fl files; ui-dialog - FLTK dialog type for this interface. | Fluid/MeshtagBrowser, Fluid/Meshtags |
| `mesh tag list` | The list of existing mesh tags returned by `ig3d_GetMesh_tagsList__s()`. | Fluid/Meshtags |
| `mesh tool` | the editing tool selection for manipulating meshes in iGame3D; mesh tag - a tagged mesh object created with `ig3d_CreateMesh_tag_s` for individual mesh objects; mesh centroid - the center point of a mesh retrieved with `ig3d_GetMeshCentroid__3f`; mesh face - a face of a mesh used for wall and quad geometry; mesh duplication - copying a mesh into a new tagged mesh with `ig3d_DuplicateMesh`; mesh conversion - converting level or mesh object tables into saved mesh files. | Scripts/Functions |
| `mesh vertex selection` | Selecting specific vertices of a mesh using mesh tag indices via `ig3d_SelectMesh_tagVertices_ib()`. | Fluid/Meshtags |
| `mesh visibility` | The visibility state of a mesh tag, set via `ig3d_SetMesh_tagVisibility_ib()`. | Fluid/Meshtags |
| `mesh_Tags` | Engine-managed tag data attached to meshes for identification and organization. | Scripts/Functions |
| `mesh_Tagslist` | Global list of mesh tag entries used for tree construction and display. | Scripts/Functions |
| `meshMaterials` | FLTK widget holding the list of current mesh materials.` | Scripts/Functions |
| `meshtoolPath` | Editing mode value that triggers path mouse down actions. | Scripts/Functions |
| `mind` | object field holding remembered perceived object entries used for AI memory tracking. | Scripts/RTS_Functions |
| `model browser` | tool for browsing and editing 3D models; WTF - folder of 3D model files; FLTK - user interface framework; loadLevel - switches game level; getObjectInfo - reads object property info. | Fluid/ModelsBrowser |
| `mouseCoords` | reads current mouse and window coordinates from scene info | Levels/iFly/iFly_Controls, Levels/iFly/iFly_Options |
| `mouseInBox` | checks if mouse coordinates fall within bounds | Levels/iFly/iFly_Controls |
| `mouseloc` | Engine helper function that computes the 3D position of the mouse cursor. | Scripts/Functions |
| `move` | particle movement behavior | Emitters/oldEmitters/Glo, Emitters/oldEmitters/More Emitters, Emitters/oldEmitters/Star |
| `murgaLua` | host environment providing FLTK and file system functions for the engine. | Fluid/Mappers, Scripts/Convert |
| `murgaLua.createFltkTimer` | host engine function used to start the map timer` | Fluid/Mappers |
| `n` | The key that triggers the force object update in the loop. | Levels/iFly/iFly_Briefing |
| `neutral pose` | the zeroed rotation and position state of a bone, used as a base for mesh bone creation. | Scripts/Examples |
| `neutralPose` | resets a bone's rotation and position to zero and records its offset as the neutral pose. | Scripts/Examples |
| `nextAStarTime` | An object field tracking when its A* scheduling time is due.` | Scripts/UDG_Functions |
| `Node grid` | 3D grid of nodes built from object bounds and collision floors used for pathfinding | Scripts/RTS_Functions |
| `normalized` | a function used to compute normalized offset coordinates for blood particle effects. | Scripts/FPS_Functions |
| `numberToMinusSigns` | builds a string of `n` minus signs | Levels/iFly/iFly_Controls |
| `numConnections` | a global tracking variable for the count of connected chat clients. | Scripts/Functions |
| `OBJ` | Asset type used by `fastFilePaths` for OBJ file paths. | Fluid/ExportObj |
| `object` | a game entity with position coordinates used for distance and direction calculations | Scripts/iFly_Functions |
| `Object sense handling` | logic that detects objects within sensor ranges and manages object sensing state for game objects. | Scripts/RTS_Functions |
| `object_action_` | constants naming AI task/action types (e.g. `object_action_goto`, `object_action_shootat`) that drive AI behaviour. | Scripts/RTS_Functions |
| `object_action_drive` | Engine task constant for a vehicle to perform driving behaviour.` | Scripts/RTS_Functions |
| `object_action_eat` | Engine task constant for an object to perform eating behaviour.` | Scripts/RTS_Functions |
| `object_action_idle` | Engine task constant for an object to perform idle behaviour.` | Scripts/RTS_Functions |
| `object_action_melee` | Engine task constant for an object to perform melee behaviour.` | Scripts/RTS_Functions |
| `object_action_shootat` | Engine task constant for an object to perform shoot-at behaviour.` | Scripts/RTS_Functions |
| `Objects menu` | the menu bar listing available WTF model objects for selection. | Scripts/Functions/Menus |
| `objExport` | The FLTK window name for the ExportObj user interface. | Fluid/ExportObj |
| `objpart` | the function that applies blood particle effects to objects. | Scripts/FPS_Functions |
| `oldGameFunc` | Global variable holding the previous game function to run after ocean animation.` | Scripts/Examples |
| `OPEN_UI_WINDOWS` | Engine call used to open UI windows for menu pick routing. | Scripts/Functions, Scripts/Functions/Menus |
| `opendoor` | Function that opens a door. | Scripts/RTS_Functions |
| `parseText2Map` | function that parses a text map into coordinate lists, wall metadata, and button actions. | Scripts/Convert |
| `particle emitter` | a component that emits particles with configured settings | Emitters/oldEmitters, Scripts/Functions, Scripts/RTS_Functions/RTS_Entities +1 |
| `ParticleBrowser` | Shared particle browser object referenced by the PNG tool.` | Fluid/PNG_Browser, Scripts/Functions, Scripts/Functions/Menus |
| `ParticlesMenu` | The FLTK menu widget that holds the particle source and control menu entries. | Scripts/Functions/Menus |
| `path info` | Per-path data (e.g. vertex coordinates) stored as a string, parsed into tuples via `getPathInfo2` and written via `setPathInfo2`. | Scripts/Functions |
| `path list` | A collection of paths managed by the engine, stored as a string and rebuilt into a table via `getPathList`. | Scripts/Functions |
| `path1` | File path referenced by the engine call to load the path file. | Scripts/Functions |
| `PBM` | a plain text bitmap format used for storing grid data and screenshots in this engine. | Scripts/Functions |
| `PBM mesh map` | a generated file built from grid values that defines mesh objects for the game. | Scripts/Functions |
| `PBM screenshot` | a PBM text file containing pixel data used for UI lookups and subgrid extraction. | Scripts/Functions |
| `PBM2 map` | a character string parsed into structured tables for floor, quad wall, button, and text map data. | Scripts/Functions |
| `PBMMapper` | FLTK-based tool for editing and converting PBM/DSB map data; DSB - map data format saved by the tool; mesh - converted geometry objects for the current level; FLTK - user interface framework used by the tool; iGame3D - 3D game engine scripted in Lua 5.1 | Fluid/PBMMapper |
| `pencilTexture` | A widget holding the pencil texture value used for texture drawing.` | Fluid/BodyPaint |
| `PNGBrowserNew` | A constructor for creating the PNG browser window and its widgets.` | Fluid/PNG_Browser |
| `PokeOut` | a text file written by `doit` to output extracted character commands. | Scripts/Functions |
| `prepMeshForBones` | helper routine that prepares meshes for bone clustering. | Fluid/AutoBones |
| `putObjectOnGround` | Helper function that repositions an object to the ground. | Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions/UDG_Entities |
| `quaternion` | A four-component rotation representation used to represent 3D rotations in the engine. | Scripts/Functions |
| `quit_callback` | A callback that asks for user confirmation before hiding a window. | Scripts/Functions |
| `ragdoll` | an object type that can be enabled to apply ragdoll physics behaviour. | Scripts/RTS_Functions |
| `redraw` | UI method that refreshes the widget display. | Fluid/Colors |
| `removeSpaces` | Global function that strips spaces from input text for matching. | Scripts/Functions |
| `replaceText` | A helper function used by the chooser functions to process the returned path or filename. | Scripts/Functions |
| `resetCollisionToDefault` | engine call to reset an object's collision settings to default. | Scripts/UDG_Functions/UDG_Entities |
| `resize` | FLTK user interface call that sets a widget's width and height. | Fluid/Mappers |
| `rnd` | Generates a random number between the given lowest and highest values` | Scripts/Functions |
| `rndlist` | Prints a comma-separated string of three random values for each iteration of a loop that steps from 1 to the given number of steps in the given step size` | Scripts/Functions |
| `RNDRTS_Maker` | FLTK UI window for the CarAndDriver level with input fields, buttons and callbacks. | Fluid/CarAndDriver |
| `rotate` | rotation behavior for the emitter | Emitters/oldEmitters/Glo, Emitters/oldEmitters/More Emitters, Emitters/oldEmitters/Star |
| `rotation matrix` | A matrix used to compute and apply yaw, pitch, and roll to an object.` | Scripts/iFly_Functions |
| `RTS entities` | the game's real-time strategy object types handled by the engine. | Scripts/RTS_Functions/RTS_Entities |
| `RTS_console` | A global variable holding the console text box for the RTS game. | Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions/UDG_Entities |
| `run_on_path` | Function that advances an object along its path based on distance tolerance and updates its task. | Scripts/RTS_Functions |
| `Safe places` | generated game state entries for safe locations, created procedurally from level grid coordinates in UDG_Utilities.lua. | Scripts/UDG_Functions |
| `save_* functions` | Engine calls that save game assets to the `Data/` folder. | Scripts/Functions/Menus |
| `save_asOBJ` | Callback that runs when the ExportObj button is clicked to save the selected mesh as OBJ and open the generated file. | Fluid/ExportObj |
| `scale` | overall size multiplier for the emitter | Emitters/oldEmitters/Glo, Emitters/oldEmitters/More Emitters, Emitters/oldEmitters/Star |
| `sceneryTeam` | shared global used to group or reference the scenery objects being configured. | Scripts/UDG_Functions/UDG_Entities |
| `selected path` | The current path index used for operations, stored in the shared `selectedPath` global. | Scripts/Functions |
| `selectionRect` | Object used to define the selection rectangle for mouse-based object selection. | Scripts/RTS_Functions |
| `sensed` | object field holding the list of perceived objects used for AI prioritization and sorting. | Scripts/RTS_Functions |
| `set_changed` | UI method marking that the widget has changed so it can be redrawn. | Fluid/Colors |
| `setBoneInfo` | engine call used to set properties on a bone, such as rotation and position. | Scripts/Examples |
| `setBoneInfo / getBoneInfo` | Engine calls to read or set properties on a bone within an object. | Scripts/RTS_Functions |
| `setBoneInfo / setParticle_emitterInfo / setSound_emitterInfo` | Engine calls to set properties on bones, particle emitters, and sound emitters. | Scripts/RTS_Functions |
| `setCameraInfo` | engine call used to set camera configuration for the level. | Levels/iFly/iFly_EnterName, Scripts/RTS_Functions, Scripts/UDG_Functions |
| `SETemitterStyle` | engine call that applies a named emitter style to an emitter. | Scripts/Functions |
| `setLightInfo` | Engine call that sets properties on a light. | Levels/iFly/iFly_Briefing, Levels/iFly/iFly_EnterName, Levels/iFly/iFly_Success +3 |
| `setMaterialInfo` | engine call that sets properties on a material object. | Fluid/BodyPaint, Scripts/Examples, Scripts/Functions +2 |
| `setObjectInfo` | engine call to set object property values. | Fluid/CarAndDriver, Levels/iFly/iFly_Briefing, Levels/iFly/iFly_Success +8 |
| `setObjectInfo / getObjectInfo` | engine calls that read or set named properties (e.g. position, rotation) of an object. | Scripts/Examples, Scripts/FPS_Functions, Scripts/RTS_Functions |
| `setParticle_emitterInfo` | engine call used to configure particle emitter settings. | Scripts/FPS_Functions, Scripts/Functions, Scripts/iFly_Functions |
| `setSceneInfo` | Engine call that sets properties on the scene. | Levels/iFly/iFly_Briefing, Levels/iFly/iFly_Controls, Levels/iFly/iFly_EnterName +6 |
| `setSelectionRect` | Engine call used to update the selection rectangle state. | Scripts/RTS_Functions |
| `setSound_emitterInfo` | engine call that sets sound emitter properties on an object. | Scripts/RTS_Functions, Scripts/RTS_Functions/RTS_Entities, Scripts/UDG_Functions +2 |
| `setText_boxInfo` | Engine call that sets properties (text, position) on a text box object. | Levels/HelloWorld, Levels/iFly/iFly_Briefing, Levels/iFly/iFly_Controls +3 |
| `setupAStarGrid` | A call that prepares the A* grid for pathfinding.` | Scripts/RTS_Functions |
| `shared globals` | Names starting with `g` that are shared across files, such as `gPathList`, `selectedPath`, `selectedPathInfo`. | Scripts/Functions |
| `SimpleList` | lightweight Lua list type with add, isEmpty, contains, cleanup methods for managing node collections | Scripts/RTS_Functions |
| `SimpleMinHeap` | lightweight Lua min-heap type with insert, extractMin, heapify, contains, changeKey, isEmpty, cleanup methods for priority-based node management | Scripts/RTS_Functions |
| `size` | the visual size of emitted particles | Emitters/oldEmitters/Glo, Emitters/oldEmitters/Star |
| `size variance` | variation in particle size | Emitters/oldEmitters/Glo, Emitters/oldEmitters/Star |
| `sm_gameplay` | server mode constant for gameplay mode` | Fluid/3Dnetclient |
| `sm_gathering` | server mode constant for gathering mode` | Fluid/3Dnetclient |
| `sniper_behaviour` | Behaviour table assigned to sniper human objects during setup. | Scripts/UDG_Functions/UDG_Entities |
| `socket` | the TCP socket library used for the telnet server's bind, accept, and client communication methods. | Scripts/Functions, Scripts/LuaSocket/socket |
| `socket-based Telnet connection server` | a server that uses socket calls to accept and relay Telnet connections between users | Scripts/Functions |
| `Sound emitter count` | the number of sound emitters configured for UDG sound playback, managed in UDG_Sounds.lua. | Scripts/UDG_Functions |
| `soundEmittersHack` | Global function that ensures enough sound emitters exist for the game objects.` | Scripts/UDG_Functions |
| `Spawn` | object placement entries used to build level layouts from numeric coordinates and object types. | Scripts/Convert |
| `spawninpack` | DSB spawn-in-pack data table collecting spawn-in-pack arguments for the DSB dungeon system. | Scripts/Convert |
| `stack trace` | the sequence of Lua function calls that led to the current execution point, used to inspect execution flow. | Scripts/Functions |
| `style` | The zombie style used to select animations.` | Scripts/RTS_Functions/RTS_Entities |
| `target / source` | Parameters naming the target object and source object used for gun attachment. | Scripts/Examples |
| `task` | object field referencing the task object that drives the AI object's current behaviour. | Scripts/RTS_Functions |
| `team identifier` | a global name used to identify a specific team in the game's entity system. | Scripts/UDG_Functions/UDG_Entities |
| `team identifiers` | global constants naming teams used by RTS entity code. | Scripts/RTS_Functions/RTS_Entities |
| `text box` | A UI element in the iGame3D interface that displays text and can be toggled via mouse clicks. | Levels/iFly/iFly_Options, Scripts/Functions |
| `text_box` | A UI element used to display text in the game, created and configured via `make` and `setText_boxInfo`. | Scripts/UDG_Functions |
| `textbox` | a text display object in the iGame3D engine, referenced by text-box info calls. | Scripts/Functions |
| `texture` | the image asset applied to a particle emitter | Emitters/oldEmitters, Emitters/oldEmitters/Glo, Emitters/oldEmitters/Star +1 |
| `Texture` | image asset used for rendering in the game | Levels/AntackGUI0/Textures |
| `texture image file` | an image asset stored in this folder for use by the engine's texture loading and rendering pipeline | Levels/AntackTrainer/Textures |
| `tFilter` | A parameter passed to the `help` function that filters help content by type. | Scripts/Functions |
| `tFolder / tFile` | Globals that store the selected directory path or filename returned by the chooser functions. | Scripts/Functions |
| `threerandom` | Converts the three values returned by getrandthree into a comma-separated string and returns it` | Scripts/Functions |
| `throttle` | The control input value controlling plane movement speed.` | Scripts/iFly_Functions |
| `thrust` | The input value used to drive plane physics calculations.` | Scripts/iFly_Functions |
| `tim` | timer used to manage the name entry prompt timing. | Levels/iFly/iFly_EnterName |
| `time out of 0.0` | a timeout value of 0.0 used in the server setup, described in the header comment as a poor approach that only works for testing until threads exist | Scripts/Functions |
| `toggled` | Flips a value between "YES" and "NO" based on its current value. | Levels/iFly/iFly_Options |
| `trackLightsKey` | A function that adjusts ambient light values and updates tracked light properties based on a numeric key. | Scripts/RTS_Functions |
| `TrueBones` | BVH folder structure containing motion capture animation data. | Scripts/Convert, Scripts/Functions |
| `truebonesTpose` | The mesh file containing the truebone tpose data loaded by `prepMeshForBones`. | Scripts/Functions |
| `UDG AI logic` | scene LOD and sense management, zombie near-player and sight handling, object task execution, and floor collision checks implemented in UDG_AI.lua. | Scripts/UDG_Functions |
| `UDG entities` | the set of game objects and logic organized under the UDG_Functions/UDG_Entities folder. | Scripts/UDG_Functions/UDG_Entities |
| `unique_mind_insert` | function that inserts an object into a mind table only if no matching object with the same `o` field already exists. | Scripts/RTS_Functions |
| `unique_sense_insert` | function that inserts an object into a sensing table only if no matching object already exists. | Scripts/RTS_Functions |
| `updateTexture` | Engine call to refresh a texture object after loading.` | Fluid/PNG_Browser |
| `UV mapping` | mesh texture coordinate mapping configuration handled via engine calls. | Scripts/Functions |
| `uvmapaxis` | control holding the current map axis value used to determine UV mapping parameters. | Scripts/Functions |
| `value` | FLTK property used to set the value of a widget, such as the collect destination directory. | Fluid/Collector |
| `vecLength` | a function used to compute the length of a vector for camera/object updates. | Scripts/FPS_Functions |
| `Vehicle control` | logic for updating vehicle behavior, sounds, and physics state across the game. | Scripts/RTS_Functions |
| `w:label(), w:value(), w:text()` | Engine calls that read the label, value, and text of a clicked menu item. | Scripts/Functions/Menus |
| `warning` | printed message indicating a missing required asset | Scripts/UDG_Functions/UDG_Entities |
| `weight` | emitter priority or weighting value | Emitters/oldEmitters/Glo, Emitters/oldEmitters/Star |
| `widget:labelsize` | FLTK widget helper that sets a UI widget's label size` | Fluid/EntityPicker |
| `widget:resize` | FLTK widget helper that resizes a UI widget` | Fluid/EntityPicker |
| `WIF` | Text format for organized BVH animation data used as an intermediate conversion asset. | Scripts/Convert, Scripts/Functions, Scripts/oldConvert |
| `WIF animation WTF file` | a WTF file created from WIF animation data for use in iGame3D. | Scripts/oldConvert |
| `WIFPathTables` | Generated Lua table file holding organized WIF folder paths and animation names. | Scripts/Convert |
| `WIFTables` | a Lua table mapping animation names to their saved WIF file paths, generated by the file. | Scripts/oldConvert |
| `windows` | table built from `gObjects` entries to define UDG window entities with position, rotation, health, and flags. | Scripts/UDG_Functions/UDG_Entities |
| `windowTeam` | a function that assigns a team value to a window object. | Scripts/UDG_Functions/UDG_Entities |
| `WTF` | 3D model/animation asset format used as the final conversion output. | Scripts/Convert, Scripts/Functions, Scripts/Functions/Menus +1 |
| `WTF browser` | FLTK browser widget used to list and select WTF files and folders | Fluid/ClassesBrowser |
| `WTF file` | iGame3D 3D model files in the `Data/WTF/` folder, loaded with `make(ig3d_object, "file.wtf")` | Fluid/ClassesBrowser |
| `WTF file browser` | the FLTK browser widget used to list and navigate files inside the WTF folder | Fluid/ClassesBrowser |
| `WTF model` | iGame3D 3D model assets stored in the WTF folder. | Scripts/Functions/Menus |
| `WTF preview PNG` | generated PNG assets created for selected WTF files or folders to display previews | Fluid/ClassesBrowser |
| `XPM` | XML Pixel Map format used for image files in this engine. | Scripts/Functions |
| `XPM header lines` | fixed metadata lines describing image name, width, height, and color count for an XPM file. | Scripts/Functions |
| `XPM image` | an image file in XPM format handled by the engine's image pipeline. | Scripts/Functions |
| `XPM image object` | a FLTK widget created from an XPM image file for display. | Scripts/Functions |
| `XPMPixelData` | table holding parsed pixel data for an XPM image. | Scripts/Functions |
| `xywh` | FLTK widget layout property specifying widget position and size. | Fluid/AutoBones, Fluid/Collector |
| `zombie_behaviour` | Shared configuration table for zombie entity behaviour in the UDG system.` | Scripts/UDG_Functions/UDG_Entities |
| `zombieAnims` | Table holding zombie animation names and linked flags for animation selection.` | Scripts/UDG_Functions/UDG_Entities |
| `zombies` | table holding zombie entity configuration and animation cache data. | Scripts/RTS_Functions/RTS_Entities |
