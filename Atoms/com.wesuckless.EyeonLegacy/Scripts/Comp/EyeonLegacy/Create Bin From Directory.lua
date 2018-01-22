------------------------------------------------------------------------------
-- Create Bin From Directory
--
--
-- This script can take a root directory, and add all items in the directory to a Bin
-- By default it will scan the named directory and all subdirectories
--
-- written by : Isaac Guenard
--            : Peter Loveday
--            : Sean Konrad
--              March 08, 2006

------------------------------------------------------------------------------
-- Updated for Fusion 9.x by: Andrew Hazelden (2017-08-28)

-- Note: Fusion 8 support was skipped in this script update to avoid having to manually add a Lua based replacement for the missing readdir() Lua filesystem library functions in Fu 8.x.

------------------------------------------------------------------------------

-- For an overview of how to use a Fusion Bin Server check out the classic YouTube video:
-- Fusion 6 - Configuring a Bin Server 
-- https://www.youtube.com/watch?v=Pp62Nw0bI98

------------------------------------------------------------------------------
-- Script Installation:

-- Copy the Create Bin From Directory.lua" script to your Fusion 9 user prefs "Scripts/Comp" folder.

------------------------------------------------------------------------------
-- Fusion Bin Server Usage:

-- Step 1. Start a Fusion 9 bin server

-- You can start a Fusion 9 bin server on Windows using:
-- "C:\Program Files\Blackmagic Design\Fusion 9\FusionServer.exe" --install

-- You can start a Fusion 9 bin server on MacOS using:
-- sudo "/Applications/Blackmagic Fusion 9/Fusion.app/Contents/MacOS/FusionServer" --install

-- You can start a Fusion 9 bin server on Linux using:
-- sudo "/opt/BlackmagicDesign/Fusion9/FusionServer" --install

-- Step 2. Open the Fusion Preferences window. Select the Globals and Default Settings > Bins > Servers window. Then click the "Add" button to create a new Server entry in the list.

-- Step 3. Setup the connection settings to your Fusion Bin server. 

-- Start by entering the Server name (IP address or hostname) for the remote system acting as the FusionServer.

-- Then add a username. "Administrator" or "Guest" are good choices if you don't want to create a custom user account for each person accessing the bin server. You will have to remember to use this same login setting in the "Create Bin From Directory" AskUser Dialog later on.

-- Click the Save button to close Bin Servers preference window.

-- Step 4. Run the Script > Create Bin From Directory menu item to launch the script. 

-- In the Username field type in the same Username you defined in Step 3.
-- In the "Name for new bin" field type in the name you want to use for the new bin folder.
-- In the "Root path for search" field use the folder browser button to open a new dialog that will help you select a folder that holds the items you want to add to the shared bin folder. This window selects only folders on disk so clear out any image/movie name that might be visible in the text field area at the bottom of the folder browser dialog.

-- Then finally click the "OK" button.

-- If the process completes successfully you will see an output in the Fusion Console tab like:

-- Scanning Directories
--  --------------------
--  <Your Bin Name>: adding x clips.
--  <Your Bin Name>: adding x comps.
--  <Your Bin Name>: adding x settings.
-- --------------------
-- Scan Complete

-- Step 5.
-- Open up the Fusion Bin window using the "bin" icon in the Fusion toolbar. When you click on the "Library on x" folder you can see the contents of the remote bin server. (With x being actual the Server name you defined in step 3.)

------------------------------------------------------------------------------

------------------------------------------------------------------------------
--                            DECLARE FUNCTIONS                             --
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- FUNCTION is_known_format
--
-- use this function to determine if an extension matches a valid clip format for Fusion
-- expects a table of fusion registry values, and a string containing an extension, including the "."
-- returns an index of -1 if its contained within the 'known_extensions' table,
-- or the index to the entry in fmt_list that matches the extension, or nil
------------------------------------------------------------------------------
local known_extensions = { ".fbx", ".dae", ".obj", ".3ds", ".dxf" , ".abc" }

function is_known_format(ext)
   ext = string.lower(ext)
   for j, ext2 in ipairs(known_extensions) do
      if ext2 == ext then
         return -1
      end
   end

   for i, v in ipairs(fmt_attrs) do
      if v.REGST_MediaFormat_Extension ~= nil then
          for j, ext2 in ipairs(v.REGST_MediaFormat_Extension) do
            if ext2 ~= nil and j ~= nil then
               if string.lower(ext2) == ext then
                  return i
               end
            end
        end
      end
   end

   return nil
end
------------------------------------------------------------------------------
-- FUNCTION doInsert
--
-- used to determine if the table seq describes a clip we already know
-- if not, then we check to see if it is a loadable clip
-- if it is, then we return true
-- if the clip is not multi frame (like avi) and it has a sequence number then we
-- also indicate that this should be added to the known table so that we can
-- avoid adding every frame in a sequence to the bin
------------------------------------------------------------------------------
local function doInsert(seq, known)
   index = is_known_format(seq.Extension)

   if index then
      if index < 0 then
         return true, nil
      else
         attrs = fmt_attrs[index]
         if attrs.REGB_MediaFormat_CanLoadMulti == true then
            return true, nil
          else
            if seq.Number == nil then
               return true, nil
            else
               -- term is the clean name for comparison
               term = seq.Path..seq.CleanName..seq.Extension

               if known[term] == nil then
                  return true, term
               end
            end
         end
      end
   end
   return false, nil
end

------------------------------------------------------------------------------
-- doDirectories
--
-- function gets a path (ending in "\") and a mask (i.e. *.*)
-- recurses through the path building tables of clips, comps and settings
--
-------------------------------------------------------------------------------
function doDirectories(dir, mask)
   local path = dir..mask


   local files = readdir(path)

   if files == nil then print("   FAILED TO READ : "..string.lower(dir)) return end
   --print("   "..string.lower(dir))   

   for i, f in ipairs(files) do

      if type(f) == "table" and f.IsDir == true then
      
         if ret.Recurse == 1 then
            doDirectories(dir..f.Name.."\\", mask)
         end

      else
         if type(f) == "table" then
            seq = eyeon.parseFilename(dir..f.Name)

            -- if we have no extension, we don't want to bother
            if seq.Extension then
               isclip, isknown = doInsert(seq, known)

               if isclip == true then
                  table.insert(bin_insert, seq.FullPath)
               elseif string.lower(seq.Extension) == ".comp" then
                  table.insert(comp_insert, seq.FullPath)
               elseif string.lower(seq.Extension) == ".setting" then
                  table.insert(setting_insert, seq.FullPath)
               end

               if isknown then known[isknown] = true end
            end
         end
      end
   end
end

------------------------------------------------------------------------------
--                                MAIN BODY                                 --
------------------------------------------------------------------------------

--------------------------------------------
-- Setup Initial Variables

bin_insert = {}
comp_insert = {}
setting_insert = {}


--------------------------------------------
-- get a list of known file formats from the Fusion registry
-- cache the list to a table to avoid slow repeated
-- calls to GetAttrs()

fmt_list = fusion:GetRegList(CT_ImageFormat)
fmt_attrs = {}

for i,v in ipairs(fmt_list) do
   fmt_attrs[i] = fmt_list[i]:GetAttrs()
end

known = {}
--------------------------------------------
-- Display the Ask User Dialog

ret = comp:AskUser("Path To Search For Clips", {
   {"HostName", Name="Host ID", "Text", Default="localhost", Lines=1},
   {"LibraryName", Name="Library Name", "Text", Default="Library", Lines=1},
   {"UserName", Name="Username", "Text", Default="Administrator", Lines=1},
   {"PassWord", Name="Password", "Text", Default="", Lines=1},
   {"BinName", Name="name for the new bin", "Text", Default="New Bin", Lines=1},
   {"SearchRoot", Name="root path for search", "PathBrowse"},
   {"Footage", Name="footage", "Checkbox", Default=1, NumAcross=3},
   {"Comps", Name="Comps", "Checkbox", Default=1, NumAcross=3},
   {"Settings", Name="settings", "Checkbox", Default=1, NumAcross=3},
   {"Recurse", Name="do subdirectories", "Checkbox", Default=1, NumAcross=2}
   })

   
if ret == nil then print("cancelled") return end
--------------------------------------------
-- Connect to library...

hostName = ret.HostName
es = FusionServer(hostName, 10)
if not es then print("ERROR: Could not connect to eyeonServer on ".. hostName) do return end end
es:SetTimeout(0)
LibName = ret.LibraryName
userName = ret.UserName
passWord = ret.PassWord
lib = es:OpenLibrary(LibName, userName, passWord)
if not lib then print("ERROR: Could not open bin.") do return end end
libRoot = lib:GetID()
--------------------------------------------
-- if user deselected all binitem types then exit
if ret.Settings == 0 and ret.Comps == 0 and ret.Footage == 0 then return end


--------------------------------------------
-- did they forget to provide a directory? exit.

if ret.SearchRoot == "" then print("You must provide a root directory for the script to scan.") return end

--------------------------------------------
-- set up initial directory

local dir  = ret.SearchRoot
local mask = "*.*"

--------------------------------------------
-- manually entered paths may not have a slash at the end. provide one

if string.sub(dir, -1, -1) ~= "\\" then   dir = dir .. "\\" end

--------------------------------------------
-- run the recursion function.
print()
print("Scanning Directories")
print("--------------------")

dir = composition:MapPath(dir)
doDirectories(dir, mask)

print()

--------------------------------------------
-- set up the IDs of various bin item types we'll be adding

local binclip_id    = "BinClip"
local bincomp_id    = "BinComp"
local binsetting_id = "BinSetting"

local folderRoot = lib:AddItem({Parent = libRoot, Type = "BinFolder", Name = ret.BinName, Folder = true})

--------------------------------------------
-- Add footage to bin

if ret.Footage == 1 then   
   print("   "..ret.BinName.." : adding "..table.getn(bin_insert).." clips.")
   for i, v in ipairs(bin_insert) do
      lib:AddItem({ Parent = folderRoot, Type = "BinClip", FileName = v, Name = eyeon.parseFilename(v).CleanName})
   end
end

--------------------------------------------
-- Add comps to bin

if ret.Comps == 1 then
   print("   "..ret.BinName.." : adding "..table.getn(comp_insert).." comps.")
   for i, v in ipairs(comp_insert) do
      lib:AddItem({ Parent = folderRoot, Type = "BinComp", FileName = v, Name = eyeon.parseFilename(v).CleanName})
   end
end

--------------------------------------------
-- Add settings and groups to bin

if ret.Settings == 1 then
   print("   "..ret.BinName.." : adding "..table.getn(setting_insert).." settings.")
   for i, v in ipairs(setting_insert) do
      lib:AddItem({ Parent = folderRoot, Type = "BinSetting", FileName = v, Name = eyeon.parseFilename(v).CleanName})
   end
end
print("--------------------")
print("Scan Complete")
print()
