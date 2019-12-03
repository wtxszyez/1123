_VERSION = 'v4.3 2019-12-03'

--[[--
Directory Tree v4.3 2019-12-03
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com
----------------------------------------------------------------------------

Overview:
The "Directory Tree" script displays a ui:Tree view that allows you to browse through and quickly import the media assets stored in the same folder hierarchy as your .comp file. This script works in Fusion v9-16.1.1+ but won't do much for you in Resolve's Fusion page since there is no concept of a "Comp:/" PathMap.


Usage:
Step 1. Save your Fusion composite to disk.

Step 2. Select the "Script > KartaVR > Viewers > Directory Tree" menu item. This will open a window with a tree view list of the files that are located in your composite folder.

Step 3. After the "Directory Tree" window is open, you can click on the heading rows to sort the tree view list.

Step 4. Single-click on a row in the tree view to copy the filepath to your clipboard. 

Step 5. Double-click summary:

Double-clicking on a row will import images, image sequences, movies, and FBX/OBJ/Alembic 3D models into your comp. 
Double-clicking on a .comp file will open it in a new tab.
Double-clicking on a .setting file will add the macro node to your current composite.
Double-clicking on a .lua script will run it.
Double-clicking on an .atom file will open it in the Reactor atom package editing window.
Double-clicking on an .xyz point cloud file will import to your current composite as a PointCloud3D node.
Double-clicking on a .pts (PTGui v10) file will run the KartaVR PTGui Project Importer script.
Double-clicking on a .txt file or .html webpage will open it in the default viewing program.
Double-clicking on a folder will open the folder up in a Finder/Explorer/Nautilus folder browsing window.
Double-clicking on a LUT file will load it in Fusion.


Keyboard Maestro on macOS Note: 
If you are on macOS and have the KartaVR Bonus atom package installed + use Keyboard Maestro + have imported the KartaVR Keyboard Maestro file from inside of the "Reactor:/Deploy/Bin/KartaVR/" folder, you are capable of doing full scene re-importing of PSD, ABC, and FBX assets in the Flow view window by changing the "enableKeyboardMaestro" variable to a value of "enableKeyboardMaestro = true".

Double clicking on FBX, or Alembic meshes will reload those full scene items. Double clicking on a layered PSD will load in the full layer stack. If you double click on a macro .setting file it will be added to the current comp. If you double click on a .comp file it will be opened in a new Fusion composite tab. 


Installation:
The Linux copy to clipboard command is "xclip"
This requires a custom xclip tool install on Linux:

Debian/Ubuntu:
sudo apt-get install xclip

Redhat/Centos/Fedora:
yum install xclip


Todos:
Save window origin and width/height to prefs so it tracks and remembers where you placed it

Location ComboControl
	Probe the Fusion preferences for a way to read all of the active PathMap locations as an array

Add more Columns:
	Date Created

	Owner

	Permissions
		Line the Unix Octal Code 777 /755 / 644

Known issues:
The latest fix for extracting file extensions from filenames with multiple periods in them has made the "Ignore Unix Hidden Files" checkbox in the UI useless.

--]]--

-- Should Keyboard Maestro be used on macOS?
enableKeyboardMaestro = false

------------------------------------------------------------------------
-- Plain Lua Functions

------------------------------------------------------------------------
-- Should a debugging mode be active that prints out details in the Console tab?
debugPrint = false

dprint = (debugPrint ~= true) and function() end or 
-- function(fmt, ...)
--	 print(fmt:format(...))
function(...)
	print(...)
end

ddump = (debugPrint ~= true) and function() end or 
function(val)
	dump(val)
end

dopenfileexternal = (debugPrint ~= true) and function() end or 
function(...)
	bmd.openfileexternal(...)
end

------------------------------------------------------------------------
-- Check what platform this script is running on
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Find out if we are running in Fusion 9/16+ or Resolve 15/16+
local ver = app:GetVersion()
appVersion = ver[1] + ver[2]/10 + ver[3]/100
appName = ver.App or (ver[1] < 15 and 'Fusion' or 'Resolve')

-- Make sure to disable "enableKeyboardMaestro" if the platform is anything but macOS
if not platform == 'Mac' then
	enableKeyboardMaestro = false
end

------------------------------------------------------------------------
-- Startup message
print('[Directory Tree] ' .. tostring(_VERSION))

------------------------------------------------------------------------
-- Get the file extension from a filepath
function getExtension(mediaDirName)
	local extension = ''
	if mediaDirName then
		extension = string.match(mediaDirName, '^.+(%..+)$')
	end

	return extension or ''
end

------------------------------------------------------------------------
-- Get the base filename from a filepath
function getFilename(mediaDirName)
	local path, basename = ''
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
	end

	return basename or ''
end

------------------------------------------------------------------------
-- Get the base filename without the file extension or frame number from a filepath
function getFilenameNoExt(mediaDirName)
	local path, basename,name, extension, barename, sequence = ''
	if mediaDirName then
	path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
		if basename then
			name, extension = string.match(basename, '^(.+)(%..+)$')
			if name then
				barename, sequence = string.match(name, '^(.-)(%d+)$')
			end
		end
	end

	return barename or ''
end

------------------------------------------------------------------------
-- Get the base filename with the frame number left intact
function getBasename(mediaDirName)
	local path, basename,name, extension, barename, sequence = ''
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
		if basename then
			name, extension = string.match(basename, '^(.+)(%..+)$')
			if name then
				barename, sequence = string.match(name, '^(.-)(%d+)$')
			end
		end
	end

	return name or ''
end

------------------------------------------------------------------------
-- Get the file path
function getPath(mediaDirName)
	local path, basename
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
	end

	return path or ''
end

------------------------------------------------------------------------
-- Remove the trailing file extension off a filepath
function trimExtension(mediaDirName)
	local path, basename
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
	end
	return path or '' .. basename or ''
end

------------------------------------------------------------------------
-- Check if Resolve is running and then disable relative filepaths
host = app:MapPath('Fusion:/')
if string.lower(host):match('resolve') then
	hostOS = 'Resolve'
else
	hostOS = 'Fusion'
end

------------------------------------------------------------------------
-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end

------------------------------------------------------------------------
-- Set a fusion specific preference value
-- Example: setPreferenceData('KartaVR.SendMedia.Format', 3, true)
function setPreferenceData(pref, value, status)
	-- comp:SetData(pref, value)
	fusion:SetData(pref, value)

	-- List the preference value
	if status == 1 or status == true then
		if value == nil then
			print('[Setting ' .. pref .. ' Preference Data] ' .. 'nil')
		else
			print('[Setting ' .. pref .. ' Preference Data] ' .. value)
		end
	end
end

------------------------------------------------------------------------
-- Read a fusion specific preference value. If nothing exists set and return a default value
-- Example: getPreferenceData('KartaVR.SendMedia.Format', 3, true)
function getPreferenceData(pref, defaultValue, status)
	-- local newPreference = comp:GetData(pref)
	local newPreference = fusion:GetData(pref)
	if newPreference then
		-- List the existing preference value
		if status == 1 or status == true then
			if newPreference == nil then
				print('[Reading ' .. pref .. ' Preference Data] ' .. 'nil')
			else
				print('[Reading ' .. pref .. ' Preference Data] ' .. newPreference)
			end
		end
	else
		-- Force a default value into the preference & then list it
		newPreference = defaultValue
		-- comp:SetData(pref, defaultValue)
		fusion:SetData(pref, defaultValue)

		if status == 1 or status == true then
			if newPreference == nil then
				print('[Creating ' .. pref .. ' Preference Data] ' .. 'nil')
			else
				print('[Creating '.. pref .. ' Preference Entry] ' .. newPreference)
			end
		end
	end

	return newPreference
end


------------------------------------------------------------------------
-- Recursively scan a directory
-- Example: fileTable = {};fileCount = 1;ScanDirectory('Comp:')
function ScanDirectory(dir, expandPathMaps, ignoreUnixHiddenFiles)
	cmp = app.CurrentComp or comp
	if not comp then
		-- There is no comp document open or we are outside of the Fusion page in Resolve
		cmp = app
	end

	-- Convert relative pathmaps into absolute filepaths
	fullDir = cmp:MapPath(dir)

	-- The characters '/*' need to be added to a path to scan inside the current folder: 
	local dirList = bmd.readdir(fullDir .. '*')
	-- https://steve.fi/Software/lua/lua-fs/docs/manual.html#readdir

	-- When searching through subdirectories look for:
	for i, f in ipairs(dirList) do
		-- Generate the filename
		filename = tostring(f.Name)

		-- Should PathMaps be expanded or not?
		if expandPathMaps == true or expandPathMaps == 1 then
			-- Convert the PathMaps into an absolute filepath
			filepath = cmp:MapPath(dir) .. filename
		else
			-- Leave the relative PathMaps in the filepath
			filepath = dir .. osSeparator .. filename
		end

		if filename ~= nil then
			-- Process each item
			if f.IsDir == false then
				-- Check if this is a unix hidden file - (filename:match('^^.+(%..+)$') ~= nil) or (filepath:match('(/)^.+(%..+)$') ~= nil)
				if (ignoreUnixHiddenFiles == true or ignoreUnixHiddenFiles == 1) and (filename:match('^^.+(%..+)$') ~= nil) or (filepath:match('(\\)^.+(%..+)$') ~= nil) or (filepath:match('(/)^.+(%..+)$') ~= nil) or (filename:match('Thumbs.db') ~= nil) or (filename:match('%.DS_Store') ~= nil) then
					-- This is a hidden file so it won't be added to the fileTable
					dprint('[Hidden File] [Filename] ' .. tostring(filename) .. ' [Filepath] ' .. tostring(filepath))
				else
					-- Add this file to the fileTable
					dprint('[File] [Filename] ' .. tostring(filename) .. ' [Filepath] ' .. tostring(filepath))
					fileTable[fileCount] = {ID = fileCount, filename = filepath, kind = 'File'}

					-- We've added another file to the list
					fileCount = fileCount + 1
				end
			else
				if (ignoreUnixHiddenFiles == true or ignoreUnixHiddenFiles == 1) and (filename:match('^^.+(%..+)$') ~= nil) or (filepath:match('(\\)^.+(%..+)$') ~= nil) or (filepath:match('(/)^.+(%..+)$') ~= nil) or (filename:match('Thumbs.db') ~= nil) or (filename:match('%.DS_Store') ~= nil) then
					-- This is a hidden folder so it won't be added to the fileTable
					dprint('[Hidden File] [Filename] ' .. tostring(filename) .. ' [Filepath] ' .. tostring(filepath))
				else
					-- Add this folder to the fileTable
					dprint('[Folder] [Filename] ' .. tostring(filename) .. ' [Filepath] ' .. tostring(filepath))
					fileTable[fileCount] = {ID = fileCount, filename = filepath, kind = 'Folder'}

					-- We've added another file to the list
					fileCount = fileCount + 1

					-- Scan the next subfolder
					ScanDirectory(filepath)
				end
			end
		end
	end
end

------------------------------------------------------------------------
-- Add a loader node to the composite based upon the current frame name
-- Example: AddLoaderPreview('LoaderPreview', filename, imageNumber)
function AddLoaderPreview(nodeName, filename, imageNumber)
	cmp = app.CurrentComp or comp
	
	-- Disable the file browser dialog
	AutoClipBrowse = fusion:GetPrefs('Global.UserInterface.AutoClipBrowse')
	fusion:SetPrefs('Global.UserInterface.AutoClipBrowse', false)

	-- Add a new loader node at the default coordinates in the Flow
	local previewLoader = cmp:AddTool('Loader', -32768, -32768)

	-- Re-enable the file browser dialog
	fusion:SetPrefs('Global.UserInterface.AutoClipBrowse', AutoClipBrowse)

	-- Rename the loader node
	previewLoader:SetAttrs({TOOLS_Name = nodeName, TOOLB_NameSet = true})

	-- Update the loader's clip filename
	previewLoader.Clip[TIME_UNDEFINED] = filename
	previewLoader.GlobalStart = 1
	previewLoader.GlobalEnd = imageNumber

	-- Update the timeline render and global ranges
	cmp:SetAttrs({COMPN_RenderStart = 1})
	cmp:SetAttrs({COMPN_RenderEnd = imageNumber})

	cmp:SetAttrs({COMPN_GlobalStart = 1})
	cmp:SetAttrs({COMPN_GlobalEnd = imageNumber-1})

	-- Loop 
	previewLoader:SetAttrs({TOOLBT_Clip_Loop = true})

	-- Hold on missing frames
	previewLoader.MissingFrames = 1 

	-- Enable HiQ mode
	cmp:SetAttrs{COMPB_HiQ = true}

	-- Display the Loader node in the Viewer 1 window
	if appVersion >= 15 then
		-- Fusion 16 compatible viewer
		cmp:GetPreviewList().LeftView:ViewOn(previewLoader, 1)
	else
		-- Fusion 9 compatible viewer
		cmp:GetPreviewList().Left:ViewOn(previewLoader, 1)
	end

	-- Move the timeline playhead to the current snapshot frame number
	cmp.CurrentTime = imageNumber
	-- cmp.CurrentTime = imageNumber - 1
end


------------------------------------------------------------------------
-- Open the file up in Fusion, show it in an external tool, or display the containing folder in your desktop file browser
function OpenDirectory(mediaDirName)
	cmp = app.CurrentComp or comp or app
	-- Check if the file exists
	if eyeon.fileexists(comp:MapPath(filepath)) then
		if (mediaDirName:match('%.atom$') ~= nil) then
			-- This is a .atom Reactor package file
			print('\n[Load Atom] ' .. tostring(mediaDirName))
			cmp:RunScript(app:MapPath('Reactor:/System/UI/Atomizer.lua'), {atomFile = mediaDirName})
		elseif (mediaDirName:match('%.pts$') ~= nil) then
			-- This is a .pts PTGui Pro 10 file
			print('\n[PTGui Pro Project Import] ' .. tostring(mediaDirName))
			cmp:RunScript(app:MapPath('Scripts:/Comp/KartaVR/Stitching/PTGui Project Importer.lua'), {gPTGuiImporterFile = mediaDirName})
		elseif (mediaDirName:match('%.xyz$') ~= nil) then
			-- This is an .xyz point cloud file
			-- Load the pts file
			print('\n[PointCloud3D XYZ Import] ' .. tostring(mediaDirName))

			-- Create the positions string elements
			local ptPositionElements = ''

			-- Prefix name appended to each of the point cloud elements
			-- local ptPrefix = 'Locator'
			local ptPrefix = ''

			-- Point cloud sample type
			local pointType = ''

			local lineCounter = 0
			for oneLine in io.lines(mediaDirName) do
				-- One line of data
				-- print('[' .. lineCounter .. '] ' .. oneLine)

				-- extract the XYZ positions, using %s as a white space character
				local x, y, z = string.match(oneLine, '(%g+)%s(%g+)%s(%g+)')

				-- Point cloud sample type
				if lineCounter == 0 then
					-- The first point is of type SPN
					pointType = 'SPN'
				else
					-- All other points are of type PN
					pointType = 'PN'
				end

				-- Add the next positions string element
				-- Example: [0] = { -8, 0, 0, "locator1", "" },
				ptPositionElements = ptPositionElements .. '\t\t\t\t[' .. tostring(lineCounter) .. '] = { ' .. tostring(x) .. ', ' .. tostring(y) .. ', ' .. tostring(z) .. ', "' .. tostring(ptPrefix) .. tostring(lineCounter + 1) .. '", "' .. pointType .. '" },\n'

				-- Display the raw output to the console
				-- print('[' .. lineCounter .. '] ' ..' [XYZ] ' .. x .. ', ' .. y .. ', ' .. z)

				-- Give a status result every 250 points
				-- if lineCounter % 250 == 0 then
				--	print('[' .. lineCounter .. '] ' ..' [X] ' .. x .. ' [Y] ' .. y .. ' [Z] ' .. z)
				-- end

				-- Track the number of point cloud entries processed
				lineCounter = lineCounter + 1
			end

			-- ---------------------------------
			-- Export the settings file to disk

			-- Locator Style defines if each sample is shown as a "point" or a "cross" shape
			local LocatorStyle = 'Point'
			-- local LocatorStyle = 'Cross'

			-- Create the point cloud string
			local ptString = ''
			
			ptString = ptString .. '{\n'
			ptString = ptString .. '	Tools = ordered() {\n'
			ptString = ptString .. '		PointCloud3D1 = PointCloud3D {\n'
			ptString = ptString .. '			CtrlWZoom = false,\n'
			ptString = ptString .. '			Inputs = {\n'
			ptString = ptString .. '				LocatorStyle = Input { Value = FuID { "' .. tostring(LocatorStyle) .. '" }, },\n'
			ptString = ptString .. '			},\n'
			ptString = ptString .. '			Positions = {\n'
			ptString = ptString .. '				Version = 2,\n'
			ptString = ptString .. ptPositionElements
			ptString = ptString .. '			}\n'
			ptString = ptString .. '		}\n'
			ptString = ptString .. '	}\n'
			ptString = ptString .. '}\n'

			-- print('[Point Cloud String] ')
			-- dump(ptString)

			print('[Point Cloud Samples] ' .. lineCounter)

			-- The system temporary directory path (Example: $TEMP/KartaVR/)
			outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
			os.execute('mkdir "' .. outputDirectory ..'"')

			-- Save a .setting file in the $TEMP/KartaVR/ folder
			settingFile = outputDirectory .. 'pointcloud.setting'
			-- print('[Settings File] ' .. settingFile)

			-- Open up the file pointer for the output textfile
			outFile, err = io.open(settingFile,'w')
			if err then
				print("[Error Opening File for Writing]")
				return
			end

			-- Write out the .settings file
			outFile:write(ptString)
			outFile:write('\n')

			-- Close the file pointer on our input and output textfiles
			outFile:close()

			-- Add the macro .setting file to the foreground comp
			cmp:QueueAction('AddSetting', {filename = settingFile})
			-- cmp:DoAction('AddSetting', {filename = settingFile})
		elseif (mediaDirName:match('%.comp$') ~= nil) then
			-- This is a comp file and Fusion can open it
			filepath = cmp:MapPath(mediaDirName)
			fusion:LoadComp(filepath, true, false, false)
			print('[Opening Comp] "' .. filepath .. '"')
		-- elseif (mediaDirName:match('%.als$') ~= nil) or (mediaDirName:match('%.pix$') ~= nil) or (mediaDirName:match('%.iff$') ~= nil) or (mediaDirName:match('%.ari$') ~= nil) or (mediaDirName:match('%.cin$') ~= nil) or (mediaDirName:match('%.kdk$') ~= nil) or (mediaDirName:match('%.dng$') ~= nil) or (mediaDirName:match('%.hvd$') ~= nil) or (mediaDirName:match('%.dpx$') ~= nil) or (mediaDirName:match('%.avi$') ~= nil) or (mediaDirName:match('%.mov$') ~= nil) or (mediaDirName:match('%.mp4$') ~= nil) or (mediaDirName:match('%.mkv$') ~= nil) or (mediaDirName:match('%.flv$') ~= nil) or (mediaDirName:match('%.gif$') ~= nil) or (mediaDirName:match('%.mts$') ~= nil) or (mediaDirName:match('%.m2ts$') ~= nil) or (mediaDirName:match('%.webm$') ~= nil) or (mediaDirName:match('%.flx$') ~= nil) or (mediaDirName:match('%.fb$') ~= nil) or (mediaDirName:match('%.raw$') ~= nil) or (mediaDirName:match('%.ifl$') ~= nil) or (mediaDirName:match('%.ipl$') ~= nil) or (mediaDirName:match('%.jpg$') ~= nil) or (mediaDirName:match('%.jpeg$') ~= nil) or (mediaDirName:match('%.jp2$') ~= nil) or (mediaDirName:match('%.mf$') ~= nil) or (mediaDirName:match('%.exr$') ~= nil) or (mediaDirName:match('%.sxr$') ~= nil) or (mediaDirName:match('%.png$') ~= nil) or (mediaDirName:match('%.vpb$') ~= nil) or (mediaDirName:match('%.qtl$') ~= nil) or (mediaDirName:match('%.qt$') ~= nil) or (mediaDirName:match('%.3gp$') ~= nil) or (mediaDirName:match('%.hdr$') ~= nil) or (mediaDirName:match('%.rgbe$') ~= nil) or (mediaDirName:match('%.r3d$') ~= nil) or (mediaDirName:match('%.6rn$') ~= nil) or (mediaDirName:match('%.sgi$') ~= nil) or (mediaDirName:match('%.rgb$') ~= nil) or (mediaDirName:match('%.bw$') ~= nil) or (mediaDirName:match('%.s16$') ~= nil) or (mediaDirName:match('%.si$') ~= nil) or (mediaDirName:match('%.pic$') ~= nil) or (mediaDirName:match('%.ras$') ~= nil) or (mediaDirName:match('%.tga$') ~= nil) or (mediaDirName:match('%.tif$') ~= nil) or (mediaDirName:match('%.tiff$') ~= nil) or (mediaDirName:match('%.tif3$') ~= nil) or (mediaDirName:match('%.tif16$') ~= nil) or (mediaDirName:match('%.rla$') ~= nil) or (mediaDirName:match('%.rla16$') ~= nil) or (mediaDirName:match('%.rpf$') ~= nil) or (mediaDirName:match('%.bmp$') ~= nil) or (mediaDirName:match('%.dib$') ~= nil) or (mediaDirName:match('%.yuv$') ~= nil) or (mediaDirName:match('%.yuv8$') ~= nil) then
		elseif (mediaDirName:match('%.mov$') ~= nil) or (mediaDirName:match('%.mp4$') ~= nil) or (mediaDirName:match('%.ifl$') ~= nil) or (mediaDirName:match('%.ipl$') ~= nil) or (mediaDirName:match('%.jpg$') ~= nil) or (mediaDirName:match('%.jpeg$') ~= nil) or (mediaDirName:match('%.exr$') ~= nil) or (mediaDirName:match('%.sxr$') ~= nil) or (mediaDirName:match('%.png$') ~= nil) or (mediaDirName:match('%.hdr$') ~= nil) or (mediaDirName:match('%.rgbe$') ~= nil) or (mediaDirName:match('%.r3d$') ~= nil) or (mediaDirName:match('%.tga$') ~= nil) or (mediaDirName:match('%.tif$') ~= nil) or (mediaDirName:match('%.tiff$') ~= nil) or (mediaDirName:match('%.tif3$') ~= nil) or (mediaDirName:match('%.tif16$') ~= nil) or (mediaDirName:match('%.rla$') ~= nil) or (mediaDirName:match('%.rla16$') ~= nil) or (mediaDirName:match('%.rpf$') ~= nil) or (mediaDirName:match('%.bmp$') ~= nil) then
			-- This is a media file and Fusion can open it
			filepath = cmp:MapPath(mediaDirName)
			print('[Adding Loader Node] "' .. filepath .. '"')

			AddLoaderPreview('LoaderPreview', filepath, 1)
		elseif (mediaDirName:match('%.setting$') ~= nil) then
			-- This is a macro .setting file and Fusion can open it
			filepath = comp:MapPath(mediaDirName)
			cmp:Paste(bmd.readfile(filepath))
			print('[Opening Macro] "' .. filepath .. '"')
		elseif (mediaDirName:match('%.viewlut$') ~= nil) or (mediaDirName:match('%.cube$') ~= nil) or (mediaDirName:match('%.alut$') ~= nil) or (mediaDirName:match('%.lut$') ~= nil) or (mediaDirName:match('%.shlut$') ~= nil) or (mediaDirName:match('%.look$') ~= nil) or (mediaDirName:match('%.3dl$') ~= nil) or (mediaDirName:match('%.itx$') ~= nil) or (mediaDirName:match('%.fuse$') ~= nil) then
--			-- This is a Lut file and Fusion can open it
--			filepath = cmp:MapPath(mediaDirName)
--			ocio = cmp:AddTool('OCIOFileTransform', -32768, -32768)
--			ocio.LUTFile = filepath

--			filepath = comp:MapPath(mediaDirName)
--			flut = cmp:AddTool('FileLUT', -32768, -32768)
--			flut.LUTFile = filepath

--			view = cmp:GetPreviewList().Left.View.CurrentViewer
--			if view ~= nil then
--				print('[Opening LUT in Viewer] "' .. filepath .. '"')
--				view:LoadLUTFile(filename)
--				view:EnableLUT(true)
--				-- view:ShowLUTEditor()
--			else
--				print('[LUT Viewer Error] An image must be loaded in the Left Viewer before a LUT can be applied')
--			end
--			print('[Adding FileLUT] "' .. filepath .. '"')

			filepath = cmp:MapPath(mediaDirName)
			flut = cmp:AddTool('FileLUT', -32768, -32768)
			flut.LUTFile = filepath
			bmd.openfileexternal('Open', filepath)
			print('[Opening LUT File] "' .. filepath .. '"')
		elseif (mediaDirName:match('%.ocio$') ~= nil) then
			-- This is an OCIO config file that Fusion can open with the OCIOColorspace node 
			filepath = cmp:MapPath(mediaDirName)
			ocio = cmp:AddTool('OCIOColorSpace', -32768, -32768)
			ocio.SourceSpace = 'raw'
			ocio.OutputSpace = 'sRGB'
			-- ocioAttrs = ocio:GetAttrs()
			ocio.OCIOConfig = filepath
			print('[Adding OCIOColorspace Node] "' .. filepath .. '"')
		elseif (mediaDirName:match('%.cc$') ~= nil) or (mediaDirName:match('%.ccc$') ~= nil) then
			-- This is an OCIO ASC CDL .cc or ASC CDL Collection.ccc file that Fusion can open with the OCIOCDLTransform node 
			filepath = cmp:MapPath(mediaDirName)
			ocio = comp:AddTool('OCIOCDLTransform', -32768, -32768)
			-- ocioAttrs = ocio:GetAttrs()
			ocio.LUTFile = filepath
			print('[Adding OCIOCDLTransform Node] "' .. filepath .. '"')
		elseif (mediaDirName:match('%.abc$') ~= nil) then
			-- This is a ABC model and Fusion can open
			filepath = cmp:MapPath(mediaDirName)
			
			-- Should Keyboard Maestro be used to reload a mesh via the import menu?
			if enableKeyboardMaestro and enableKeyboardMaestro == true then
				tempFolder = cmp:MapPath('/private/tmp/Fusion/')
				-- tempFolder = comp:MapPath('Temp:/Fusion/')
				bmd.createdir(tempFolder)
				bmd.writefile(tempFolder .. 'AlembicClipboard.txt', filepath);
				os.execute([[osascript -e 'tell app "Keyboard Maestro Engine" to do script "A2 Alembic - Load AlembicClipboard Textfile Into Named Clipboard"' &]])
				os.execute([[osascript -e 'tell app "Keyboard Maestro Engine" to do script "A3 Alembic - Re-import Alembic Menu Actions"' &]])
			else
				-- Lock the comp flow area
				cmp:Lock()

				-- Use the Fusion native AlembicMesh3D import mode
				mesh3D = cmp:AddTool('SurfaceAlembicMesh', -32768, -32768)
				-- mesh3DAttrs = mesh3D:GetAttrs()
				mesh3D.Filename = filepath

				-- Unlock the comp flow area
				cmp:Unlock()
			end
			print('[Reloading Alembic Scene] ' .. filepath)
		elseif (mediaDirName:match('%.fbx$') ~= nil) or (mediaDirName:match('%.obj$') ~= nil) then
			-- This is a FBX model and Fusion can open
			filepath = cmp:MapPath(mediaDirName)

			-- Should Keyboard Maestro be used to reload a mesh via the import menu?
			if enableKeyboardMaestro and enableKeyboardMaestro == true then
				tempFolder = cmp:MapPath('/private/tmp/Fusion/')
				-- tempFolder = comp:MapPath('Temp:/Fusion/')
				bmd.createdir(tempFolder)
				bmd.writefile(tempFolder .. 'FBXClipboard.txt', filepath);
				os.execute([[osascript -e 'tell app "Keyboard Maestro Engine" to do script "B2 FBX - Load FBXClipboard Textfile Into Named Clipboard"' &]])
				os.execute([[osascript -e 'tell app "Keyboard Maestro Engine" to do script "B3 FBX - Re-import FBX Menu Actions"' &]])
				print('[Reloading FBX Scene] ' .. filepath)
			else
				-- Lock the comp flow area
				cmp:Lock()

				-- Use the Fusion native FBXMesh3D import mode
				mesh3D = comp:AddTool('SurfaceFBXMesh', -32768, -32768)
				-- mesh3DAttrs = mesh3D:GetAttrs()
				mesh3D.ImportFile = filepath

				-- Unlock the comp flow area
				cmp:Unlock()
			end
		elseif (mediaDirName:match('%.psd$') ~= nil) then
			-- This is a psd layered image and Fusion can open
			filepath = cmp:MapPath(mediaDirName)
			-- Should Keyboard Maestro be used to reload a mesh via the import menu?
			if enableKeyboardMaestro and enableKeyboardMaestro == true then
				tempFolder = cmp:MapPath('/private/tmp/Fusion/')
				-- tempFolder = comp:MapPath('Temp:/Fusion/')
				bmd.createdir(tempFolder)
				bmd.writefile(tempFolder .. 'PSDClipboard.txt', filepath);
				os.execute([[osascript -e 'tell app "Keyboard Maestro Engine" to do script "C2 PSD - Load PSDClipboard Textfile Into Named Clipboard"' &]])
				os.execute([[osascript -e 'tell app "Keyboard Maestro Engine" to do script "C3 PSD - Re-import PSD Menu Actions"' &]])
			else
				-- Use the Fusion native image import mode
				print('[Adding Loader Node] "' .. filepath .. '"')
				AddLoaderPreview('LoaderPreview', filepath, 1)
			end
			print('[Reloading PSD Layered Image] ' .. filepath)
		elseif (mediaDirName:match('%.lua$') ~= nil) or (mediaDirName:match('%.eyeonscript$') ~= nil) then
			-- This is a Lua script and Fusion can run it
			filepath = cmp:MapPath(mediaDirName)
			comp:RunScript(filepath)
			print('[Running Lua Script] "' .. filepath .. '"')
		elseif (mediaDirName:match('%.py') ~= nil) or (mediaDirName:match('%.py2') ~= nil) or (mediaDirName:match('%.py3') ~= nil) then
			-- This is a Python script and Fusion can run it
			filepath = cmp:MapPath(mediaDirName)
			comp:RunScript(filepath)
			print('[Running Script] "' .. filepath .. '"')
		elseif (mediaDirName:match('%.htm$') ~= nil) or (mediaDirName:match('%.html$') ~= nil) then
			-- This is a html file that your webbrowser can open
			filepath = cmp:MapPath(mediaDirName)
			bmd.openfileexternal('Open', filepath)
			print('[Opening Webpage] "' .. filepath .. '"')
		elseif (mediaDirName:match('%.webloc$') ~= nil) or (mediaDirName:match('%.URL$') ~= nil) or (mediaDirName:match('%.url$') ~= nil) then
			-- This is an html URL link that your webbrowser can open
			filepath = cmp:MapPath(mediaDirName)
			bmd.openfileexternal('Open', filepath)
			print('[Opening Webpage Link] "' .. filepath .. '"')
		elseif (mediaDirName:match('%.txt$') ~= nil) then
			-- This is a txt file that your webbrowser can open
			filepath = cmp:MapPath(mediaDirName)
			bmd.openfileexternal('Open', filepath)
			print('[Opening Text File] "' .. filepath .. '"')
		else
			-- Convert the filepath into the base directory name
			filepath = Dirname(comp:MapPath(mediaDirName))

			-- Open an explorer/finder/nautilus folder browser view using
			bmd.openfileexternal('Open', filepath)
			print('[Opening Directory] "' .. filepath .. '"')
		end
	else
		print('[File Missing] "' .. filepath .. '"')
	end
end

-- Find out the current directory from a file path
-- Example: print(Dirname("/Users/Shared/file.txt"))
function Dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end

------------------------------------------------------------------------
-- Copy text to the operating system's clipboard
-- Example: CopyToClipboard('Hello World!')
function CopyToClipboard(textString)
	-- The system temporary directory path (Example: $TEMP/Fusion/)
	outputDirectory = comp:MapPath('Temp:\\Fusion\\')
	clipboardTempFile = outputDirectory .. 'ClipboardText.txt'

	-- Create the temp folder if required
	bmd.createdir(outputDirectory)

	-- Write out the textfile
	bmd.writefile(clipboardTempFile, textString)

	if platform == 'Windows' then
		-- The Windows copy to clipboard command is "clip"
		command = 'clip < "' .. clipboardTempFile .. '"'
	elseif platform == 'Mac' then
		-- The Mac copy to clipboard command is "pbcopy"
		command = 'pbcopy < "' .. clipboardTempFile .. '"'
	elseif platform == 'Linux' then
		-- The Linux copy to clipboard command is "xclip"
		-- This requires a custom xclip tool install on Linux:
 
		-- Debian/Ubuntu:
		-- sudo apt-get install xclip
 
		-- Redhat/Centos/Fedora:
		-- yum install xclip
		command = 'cat "' .. clipboardTempFile .. '" | xclip -selection clipboard &'
	end

	print('[Copy to Clipboard] "' .. textString .. '"')
	os.execute(command)
end


-- ----------------------------------------------------------------------------
-- Load the Preferences

-- Should the tree view be updated live infront of your eyes while you wait?
liveUpdateTreeView = getPreferenceData("AndrewHazelden.DirectoryTree.LiveUpdateTreeView", true)

-- Should relative pathmaps be expanded to absolute paths?
expandPathMapCheckbox = getPreferenceData("AndrewHazelden.DirectoryTree.ExpandPathMapCheckbox", true)

-- Should unix files that start with a . (period) in their name be skipped?
ignoreUnixHiddenFiles = getPreferenceData("AndrewHazelden.DirectoryTree.IgnoreUnixHiddenFiles", true)

-- Sort Order - "AscendingOrder" or "DescendingOrder"
defaultSortOrder = getPreferenceData("AndrewHazelden.DirectoryTree.DefaultSortOrder", 'AscendingOrder')

-- ----------------------------------------------------------------------------
-- UI Manager View

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 1200,420

-- Create the window table
win = disp:AddWindow({
	ID = 'DirectoryTreeWin',
	TargetID = 'DirectoryTreeWin',
	WindowTitle = 'Directory Tree',
	Geometry = {1000, 700, width, height},
	Spacing = 0,
	ui:VGroup{
		ID = 'root',
		-- Add your GUI elements here:
		-- Tree View Controls
		ui:HGroup{
			Weight = 0.001,

			-- Add some space
			ui:HGap(),
			ui:Label{
				Weight = 0.001,
				ID = 'ViewControlsLabel',
				Text = 'Tree View Controls: ',
			},
			ui:CheckBox{
				Weight = 0.001,
				ID = 'LiveUpdateTreeView',
				Text = 'Live Update Tree View',
				Checked = liveUpdateTreeView,
			},
			ui:CheckBox{
				Weight = 0.001,
				ID = 'ExpandPathMapCheckbox',
				Text = 'Expand PathMaps',
				Checked = expandPathMapCheckbox,
			},
			ui:CheckBox{
				Weight = 0.001,
				ID = 'IgnoreUnixHiddenFiles',
				Text = 'Ignore Unix Hidden Files',
				Checked = ignoreUnixHiddenFiles,
			},
			ui:Label{
				Weight = 0.001,
				ID = 'SortOrderLabel',
				Text = 'Sort Order: ',
			},
			ui:ComboBox{
				ID = 'SortOrderCombo',
				Text = 'Sort Order',
			},
			-- Add some space
			ui:HGap(),
		},
		-- File List Tree
		ui:Tree{
			ID = 'Tree',
			SortingEnabled = true,
			Events = {
				ItemDoubleClicked = true,
				ItemClicked = true
			},
		},
		-- Label
		ui:HGroup{
			Weight = 0.001,
			ui:Label{
				ID = 'CommentLabel',
				Text = 'Single click on a row to copy the filepath to your clipboard. Double click on a row to open the containing folder.',
				Alignment = {
					AlignHCenter = true,
					AlignTop = true
				},
			},
		},
	},
})


-- Add your GUI element based event functions here:
itm = win:GetItems()

-- Track the Fusion save events
notify = ui:AddNotify('Comp_Save', comp)

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('DirectoryTreeWin', {
		Target {
			ID = 'DirectoryTreeWin',
		},

		Hotkeys {
			Target = 'DirectoryTreeWin',
			Defaults = true,

			CONTROL_W = 'Execute{cmd = [[ app.UIManager:QueueEvent(obj, "Close", {}) ]]}',
			CONTROL_F4 = 'Execute{cmd = [[ app.UIManager:QueueEvent(obj, "Close", {}) ]]}',
		},
	})


-- The window was closed
function win.On.DirectoryTreeWin.Close(ev)
	disp:ExitLoop()
end


-- The Fusion "Save" command was used
function disp.On.Comp_Save(ev)
	print('[Update] Comp Saved. Refreshing the view.')
	UpdateTree()
end


-- This function is run when a user picks a different setting in the Sort Order ComboBox control
function win.On.SortOrderCombo.CurrentIndexChanged(ev)
	if itm.SortOrderCombo.CurrentIndex == 0 then
		-- AscendingOrder
		dprint('[Sort Order] ' .. itm.SortOrderCombo.CurrentText)
	elseif itm.SortOrderCombo.CurrentIndex == 1 then
		-- DescendingOrder
		dprint('[Sort Order] ' .. itm.SortOrderCombo.CurrentText)
	end

	defaultSortOrder = itm.SortOrderCombo.CurrentText
	selectedColumn = itm.Tree:CurrentColumn()
	dprint('[Column Selected] ' .. tostring(selectedColumn))

	-- Sort the tree by the # column - Example: itm.Tree:SortByColumn(0, "AscendingOrder")
	itm.Tree:SortByColumn(selectedColumn, defaultSortOrder)

	-- UpdateTree()
end


-- Live Update Tree View Checkbox Updated
function win.On.LiveUpdateTreeView.Clicked(ev)
	UpdateTree()
end


-- Expand PathMap Checkbox Checkbox Updated
function win.On.ExpandPathMapCheckbox.Clicked(ev)
	UpdateTree()
end


-- Ignore Unix Hidden Files Checkbox Updated
function win.On.IgnoreUnixHiddenFiles.Clicked(ev)
	UpdateTree()
end


-- Copy the filepath to the clipboard when a Tree view row is clicked on
function win.On.Tree.ItemClicked(ev)
	-- Column 3 = Filepath
	filepath = ev.item.Text[3]
	
	-- Should PathMaps be expanded or not?
	if expandPathMaps == true or expandPathMaps == 1 then
		-- Convert the PathMaps into an absolute filepath
		
		-- Copy the filepath to the clipboard
		CopyToClipboard(comp:MapPath(filepath))
	else
		-- Leave the relative PathMaps in the filepath
		
		-- Copy the filepath to the clipboard
		CopyToClipboard(filepath)
	end
end


-- Open up the folder where the media is located when a Tree view row is clicked on
function win.On.Tree.ItemDoubleClicked(ev)
	-- Column 3 = Filepath
	filepath = ev.item.Text[3]

	-- Open up the folder where the media is located
	OpenDirectory(filepath)
end


-- Update the contents of the tree view
function UpdateTree()
	-- Global table with the files list
	fileTable = {}
	fileCount = 1

	-----------------------------------------------------------
	-- Read the current settings from the GUI	 
	liveUpdateTreeView = itm.LiveUpdateTreeView.Checked
	expandPathMapCheckbox = itm.ExpandPathMapCheckbox.Checked
	ignoreUnixHiddenFiles = itm.IgnoreUnixHiddenFiles.Checked
	defaultSortOrder = itm.SortOrderCombo.CurrentText

	-- Save the Preferences
	setPreferenceData('AndrewHazelden.DirectoryTree.LiveUpdateTreeView', liveUpdateTreeView)
	setPreferenceData('AndrewHazelden.DirectoryTree.ExpandPathMapCheckbox', expandPathMapCheckbox)
	setPreferenceData('AndrewHazelden.DirectoryTree.IgnoreUnixHiddenFiles', ignoreUnixHiddenFiles)
	setPreferenceData('AndrewHazelden.DirectoryTree.DefaultSortOrder', defaultSortOrder)

	-----------------------------------------------------------
	-- Prepare to scan the folder

	-- This is the default directory to search inside of
	workingDir = 'Comp:'
	-- workingDir = 'fusion:'
	-- workingDir = 'LUTs:'

	-- Recursively scan a directory for files and folders
	print('[Scanning Folder] ' .. workingDir)
	ScanDirectory(workingDir, expandPathMapCheckbox, ignoreUnixHiddenFiles)
	-- ScanDirectory('AllData:', expandPathMapCheckbox, ignoreUnixDotFiles)
	-- ScanDirectory('Fusion:', expandPathMapCheckbox, ignoreUnixDotFiles)

	-- Clean out the previous entries in the Tree view
	itm.Tree:Clear()

	-- Add the Tree headers:
	-- 1 File exr Image.0000.exr /Media/Project22/Image.0000.exr
	hdr = itm.Tree:NewItem()
	hdr.Text[0] = '\t#\t'
	hdr.Text[1] = 'Type'
	hdr.Text[2] = 'Extension'
	hdr.Text[3] = 'File Path'
	hdr.Text[4] = 'File Name'
	-- hdr.Text[5] = 'File Size'
	itm.Tree:SetHeaderItem(hdr)

	-- Number of columns in the Tree list
	itm.Tree.ColumnCount = 5
	--itm.Tree.ColumnCount = 6

	-- Resize the header column widths
	itm.Tree.ColumnWidth[0] = 75
	itm.Tree.ColumnWidth[1] = 48
	itm.Tree.ColumnWidth[2] = 62
	itm.Tree.ColumnWidth[3] = 800
	itm.Tree.ColumnWidth[4] = 200

	-- Live Update Tree View
	if liveUpdateTreeView == false then
		itm.Tree.UpdatesEnabled = false
		-- itm.Tree.SortingEnabled = false
	end

	-- -------------------------------------------
	-- Start adding each ui:Tree element
	-- win:Hide()

	dprint('\n[File List]')	 
	-- Process all items in the fileTable
	totalFiles = table.getn(fileTable)
	for i = 1, totalFiles do
		-- Update the window title with the percentage complete
		percentStep = math.floor(totalFiles/20)
		if i % percentStep == 0 then
			percentDone = (i / totalFiles) * 100
			title = tostring('Directory Tree: ' .. tostring(totalFiles) .. ' Files (Updating View ' .. tostring(string.format("%d", percentDone)) .. '% Complete)')
			itm.DirectoryTreeWin.WindowTitle = title
		end

		kind = tostring(fileTable[i]['kind'])
		filepath = tostring(fileTable[i]['filename'])
		filename = getFilename(filepath)
		if kind == 'Folder' then
			extension = 'Folder'
			filepath = filepath .. osSeparator
		elseif string.lower(filename) == 'readme' then
			extension = 'README'
		else
			extension = string.upper(getExtension(filename))

			-- Catch situations in filenames where there are multiple . periods in the file extension field
			if (extension:match('^.+(%..+)$') ~= nil) then
				extension = string.upper(getExtension(extension))
			end
		end

		-- Add an new entry to the list
		itEntry = itm.Tree:NewItem()
		itEntry.Text[0] = string.format('%'.. string.len(tostring(totalFiles)) .. 'd', i)
		itEntry.Text[1] = kind
		itEntry.Text[2] = extension
		itEntry.Text[3] = filepath
		itEntry.Text[4] = filename

		itm.Tree:AddTopLevelItem(itEntry)

		dprint('\t[' .. i .. '] [Type] ' .. kind .. ' [Extension] ' .. extension ..' [Filepath] ' .. filepath .. ' [Name] ' .. filename )
	end

	-- Refresh the tree view
	itm.Tree.SortingEnabled = true
	itm.Tree.UpdatesEnabled = true

	-- The view has finished updating so go back to the minimal window title
	itm.DirectoryTreeWin.WindowTitle = 'Directory Tree: ' .. totalFiles .. ' Files'
end

-- Add the items to the Sort Order ComboBox menu
itm.SortOrderCombo:AddItem('AscendingOrder')
itm.SortOrderCombo:AddItem('DescendingOrder')

-- Show the main window
win:Show()

-- Update the contents of the tree view
UpdateTree()

disp:RunLoop()
win:Hide()
print('[Done]')
