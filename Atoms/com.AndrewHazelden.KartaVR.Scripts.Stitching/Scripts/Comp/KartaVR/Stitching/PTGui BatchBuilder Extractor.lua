--[[--
----------------------------------------------------------------------------
PTGui BatchBuilder Extractor v4.0 for Fusion - 2018-12-11
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The PTGui BatchBuilder Extractor script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) will convert your currently selected loader and saver node based media from inside numbered PTGui BatchBuilder folders into a flat image sequence.


As an example a PTGui BatchBuilder "folderized" image sequence named in the format of: `####/name.ext` will be copied and placed into a standard image sequence:	`name.####.ext`

Installation and Usage:

Step 1. Start Fusion and open a new comp. Select loader or saver nodes in the flow view.

Step 2. Then run the "Script > KartaVR > Stitching > PTGui BatchBuilder Extractor" menu item.

Step 3. Select the output folder where you would like to save your renamed imagery. You can also customize the filename prefix and the amount of frame padding applied to the numbered folder names. You can choose if you want to move or copy the extracted imagery.

Todo: Add a checkbox "Update Paths in Loader/Saver Nodes" to the UI that tracks the real path for the move or copy command destination

--]]--

------------------------------------------------------------------------------

local printStatus = false

-- Find out if we are running Fusion 7 or 8
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)


-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
-- LUA dirname command inspired by Stackoverflow code example:
-- http://stackoverflow.com/questions/9102126/lua-return-directory-path-from-path
	-- Add the platform specific folder slash character
	osSeparator = package.config:sub(1,1)
	
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end


-- Split apart a filepath and get the parent dir, the current dir, the filename, filename without the extension, and the file extension.
-- Example: parentDirectory, currentDirectory, currentFile, currentFileNoExt, currentExtension = splitFilepath('/Volumes/Media/Bridge/Under the Bridge.0000.tif')
function splitFilepath(dirpath)
	-- Break the elements apart using the matching pattern '(.*/)(.*/)')
	local parentDir, currentDir = string.match(dirpath, '(.*' .. osSeparator ..')(.*' .. osSeparator ..')')
 
	local filename = eyeon.getfilename(dirpath)
	local filenameNoExt = eyeon.trimExtension(filename)
	local ext = eyeon.getextension(filename)
	
	return parentDir, currentDir, filename, filenameNoExt, ext
end


-- Check if a directory exists
-- Example: directoryExists('/Users/Andrew/Desktop/')
function directoryExists(mediaDirName)
	if mediaDirName == nil then
		-- print('[Directory Variable is Empty] ', mediaDirName)
		return false
	else
		if fu_major_version >= 8 then
			-- The script is running on Fusion 8+ so we will use the fileexists command
			if eyeon.fileexists(mediaDirName) then
				return true
			else
				-- print('[Directory Missing] ', mediaDirName)
				return false
			end
		else
			-- The script is running on Fusion 6/7 so we will use the direxists command
			if eyeon.direxists(mediaDirName) then
				return true
			else
				-- print('[Directory Missing] ', mediaDirName)
				return false
			end
		end
	end
end


-- Open a folder window up using your desktop file browser
-- Example: openDirectory('/Volumes/Media/Bridge/')
function openDirectory(mediaDirName)
	dir = dirname(mediaDirName)
	
	-- Double check that the folder actually exists before trying to open it
	if directoryExists(dir) == true then
		command = ''
		if platform == 'Windows' then
			-- Running on Windows
			command = 'explorer "' .. dir .. '"'
			print('[Launch Command] ', command)
			os.execute(command)
		elseif platform == 'Mac' then
			-- Running on Mac
			command = 'open "' .. dir .. '" &'
			print('[Launch Command] ', command)
			os.execute(command)
		elseif platform == 'Linux' then
			-- Running on Linux
			command = 'nautilus "' .. dir .. '" &'
			print('[Launch Command] ', command)
			os.execute(command)
		else
			print('[Platform] ', platform)
			print('There is an invalid platform defined in the local platform variable at the top of the code.')
		end
	end
end



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


-- Play a KartaVR "audio" folder based wave audio file using a native Mac/Windows/Linux method:
-- Example: playWaveAudio('sound.wav')
-- or if you want to see debugging text use:
-- Example: playWaveAudio('sound.wav', true)
function playDFMWaveAudio(filename, status)
	if status == true or status == 1 then 
		print('[Base Audio File] ' .. filename)
	end
	
	local audioFilePath = ''
	
	if platform == 'Windows' then
		-- Note Windows Powershell is very lame and it really really needs you to escape each space in a filepath with a backtick ` character or it simply won't work!
		-- audioFolderPath = 'C:\\Program` Files\\KartaVR\\audio\\'
		audioFolderPath = '$env:programfiles\\KartaVR\\audio\\'
		audioFilePath = audioFolderPath .. filename
		command = 'powershell -c (New-Object Media.SoundPlayer "' .. audioFilePath ..'").PlaySync();'
		
		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end
		
		os.execute(command)
	elseif platform == 'Mac' then
		audioFolderPath = '/Applications/KartaVR/audio/'
		audioFilePath = audioFolderPath .. filename
		command = 'afplay "' .. audioFilePath ..'" &'
		
		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end
		os.execute(command)
	elseif platform == 'Linux' then
		audioFolderPath = '/opt/KartaVR/audio/'
		audioFilePath = audioFolderPath .. filename
		command = 'xdg-open "' .. audioFilePath ..'" &'
		
		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end
		
		os.execute(command)
	else
		-- Windows Fallback
		audioFolderPath = '$env:programfiles\\KartaVR\\audio\\'
		audioFilePath = audioFolderPath .. filename
		command = 'powershell -c (New-Object Media.SoundPlayer "' .. audioFilePath ..'").PlaySync();'
		
		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end
		os.execute(command)
	end
	
	if status == true or status == 1 then 
		print('[Playing a KartaVR based sound file using System] ' .. audioFilePath)
	end
end


-- Process the footage into the new BatchBuilder folders
-- Example: BatchBuilderRename('/Volumes/Media/Bridge/Under the Bridge.0000.tif')
function BatchBuilderRename(mediaFileName)
	mediaExtension = eyeon.getextension(eyeon.getfilename(mediaFileName))
	if mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
		mediaType = 'video'
		print('[The ' .. mediaFileName .. ' media file was detected as a movie format. Please convert the footage to image sequences as PTGui only supports working with image formats directly.]')
	else
		mediaType = 'image'
		print('[The ' .. mediaFileName .. ' media file was detected as an image format.]')
		-- This is an image sequence being loaded
		
		-- Find out the base directory for the image sequence
		dirName = outputFolder
		-- print('[Base Dir] ' .. dirName)
		
		if fu_major_version >= 8 then
			-- The script is running on Fusion 8+ so we will use the fileexists command
			if eyeon.fileexists(outputFolder) == false then
				print('[Output Directory Created] ', outputFolder)
				-- Create the output directory
				os.execute('mkdir "' .. dirName .. '" ')
			end
		else
			-- The script is running on Fusion 6/7 so we will use the direxists command
			if eyeon.direxists(outputFolder) == false then
				print('[Output Directory Created] ', outputFolder)
				-- Create the output directory
				os.execute('mkdir "' .. dirName .. '" ')
			end
		end


		if directoryExists(dirName) then
			print ('[Output Directory] ' .. dirName)
			-- Find out the start / end frames 
			-- (Using a simpler version of the Fusion SV_GetFrames code from the script lib without saver relative numbering)
			
			if frameRange == 0 then
				-- Custom frame range
				-- (Loader clip frame range / Saver render time range)
				start_frame =	 mediaStartFrame 
				end_frame = mediaEndFrame
				print('[Using the Clip Time Frame Range]')
			elseif frameRange == 1 then
				-- Render time frame range
				start_frame = comp:GetAttrs().COMPN_RenderStart
				end_frame = comp:GetAttrs().COMPN_RenderEnd
				print('[Using the Render Time Frame Range]')
			elseif frameRange == 2 then 
				-- Global time frame range
				start_frame = comp:GetAttrs().COMPN_GlobalStart
				end_frame = comp:GetAttrs().COMPN_GlobalEnd
				print('[Using the Render Time Frame Range]')
			end
			length = end_frame - start_frame
			
			print('[Sequence Range] ' .. start_frame .. ' - ' .. end_frame .. ' [Frame Length] ' .. length)
			
			
			-- Process the media file into a table entry
			parsedTable = eyeon.parseFilename(mediaFileName)
			-- print('[Parsed Filename]')
			-- dump(parsedTable)
			-- print('\n')
			
			-- Split apart the initial frame filepath to get the base BatchBuilder based image name
			-- print('[Filename Splitting] ' .. mediaFileName)
			parentDirectory, currentDirectory, currentFile, currentFileNoExt, currentExtension = splitFilepath(mediaFileName)
			
			
			-- Copy the imagery in place
			for i = start_frame, start_frame + length do
				-- Sequence padded directory number 
				dirPaddedFrame = string.format('%0' .. framePadding .. 'd', i)
				seqDir = parentDirectory .. dirPaddedFrame .. osSeparator
				
				-- Detect the source image frame padding
				srcFramePadding = framePadding
				-- srcFramePadding = parsedTable.Padding
				
				stillFrameDotBeforeExtension = ''
				-- Check if this is a still frame
				if srcFramePadding == nil then
					-- This is a still frame with no frame value in the filename
					srcPaddedSequenceFrame = ''
					
					-- Add back a period to the destination filename because there is no frame number section present
					stillFrameDotBeforeExtension = '.'
				else
					-- Generate the frame padding for the current frame
					srcPaddedSequenceFrame = string.format('%0' .. srcFramePadding .. 'd', i)
				end
				
				-- Detect the source image extension 
				srcExtension = parsedTable.Extension
				
				-- Source image name
				srcFile = seqDir .. currentFile
				
				-- Final Dummy Frame Extension + image extension
				-- This starts on either none, frame 0000, or frame 0001
				-- extractFrameExtensionNumber = ''
				-- if extractFrameExtension == 0 then
					-- None (skip adding a frame extension number)
					-- trim off the period at the start of the parsed file extension '.jpg' becomes 'jpg'
					-- trimmedExtension = parsedTable.Extension:match("[^.]+$")
					-- extractFrameExtensionNumber = '' .. stillFrameDotBeforeExtension .. trimmedExtension
				-- elseif extractFrameExtension == 1 then
					-- Start the image sequence on frame 0
					-- extractFrameExtensionNumber = stillFrameDotBeforeExtension .. '0000' .. parsedTable.Extension
				-- else
					-- Start the image sequence on frame 1
					-- extractFrameExtensionNumber = stillFrameDotBeforeExtension .. '0001' .. parsedTable.Extension
				-- end
				
				
				-- Destination image name
				destFile = ''
				if extractFrameExtension == 0 then
					-- <name>.#.<ext>
					destFile = outputFolder .. currentFileNoExt .. '.' .. dirPaddedFrame .. srcExtension
				elseif extractFrameExtension == 1 then
					-- <name>_#.<ext>
					destFile = outputFolder .. currentFileNoExt .. '_' .. dirPaddedFrame .. srcExtension
				elseif extractFrameExtension == 2 then
					-- <name> #.<ext>
					destFile = outputFolder .. currentFileNoExt .. ' ' .. dirPaddedFrame .. srcExtension
				elseif extractFrameExtension == 3 then
					-- <name>/#.<ext>
					destFile = outputFolder .. dirPaddedFrame .. srcExtension
				elseif extractFrameExtension == 4 then
					-- <name>/<name>.#.<ext> (In a Subfolder)
					destFile = outputFolder .. currentFileNoExt .. osSeparator .. currentFileNoExt .. '.' .. dirPaddedFrame .. srcExtension
				elseif extractFrameExtension == 5 then
					-- <name>/<name>_#.<ext> (In a Subfolder)
					destFile = outputFolder .. currentFileNoExt .. osSeparator .. currentFileNoExt .. '_' .. dirPaddedFrame .. srcExtension
				elseif extractFrameExtension == 6 then
					-- <name>/<name> #.<ext> (In a Subfolder)
					destFile = outputFolder .. currentFileNoExt .. osSeparator .. currentFileNoExt .. ' ' .. dirPaddedFrame .. srcExtension
				elseif extractFrameExtension == 7 then
					-- <name>/#.<ext> (In a Subfolder)
					destFile = outputFolder .. osSeparator.. dirPaddedFrame .. srcExtension
				else 
					-- Fallback to <name>.#.<ext>
					destFile = outputFolder .. currentFileNoExt .. '.' .. dirPaddedFrame .. srcExtension
				end
				
				destFolder = dirname(destFile)
				if fu_major_version >= 8 then
					-- The script is running on Fusion 8+ so we will use the fileexists command
					if eyeon.fileexists(destFolder) == false then
						print("[Output Directory Created] ", destFolder)
						-- Create the output directory
						os.execute('mkdir "' .. destFolder .. '" ')
					end
				else
					-- The script is running on Fusion 6/7 so we will use the direxists command
					if eyeon.direxists(destFolder) == false then
						print("[Output Directory Created] ", destFolder)
						-- Create the output directory
						os.execute('mkdir "' .. destFolder .. '" ')
					end
				end
				
				-- Check if the source image exists before making the new folder
				if eyeon.fileexists(srcFile) then
					-- Should the extracted images be copied or moved?
					if fileManagement == 0 then
						-- File Mode: "Copy Images" Selected
						
						-- Write a renamed copy of the source image to the destination location
						eyeon.copyfile(srcFile, destFile)
						
						-- Check if the file was written to the destination image location
						if eyeon.fileexists(destFile) then
							print ('[Copied Image] ' .. ' [From] ' .. srcFile .. ' [To] ' .. destFile)
						else
							print ('[Error Copying Image] ' .. ' [From] ' .. srcFile .. ' [To] ' .. destFile)
						end
					else
						-- File Mode: "Move Images" Selected
						
						-- Write a moved version of the source image to the destination location
						renameResult = os.rename(srcFile, destFile) 
						-- ToDo: check if the result is nil that means the rename operation failed (renameResult ~= nil means success)
						
						-- Check if the file was written to the destination image location
						if eyeon.fileexists(destFile) then
							print ('[Moved Image] ' .. ' [From] ' .. srcFile .. ' [To] ' .. destFile)
						else
							print ('[Error Moved Image] ' .. ' [From] ' .. srcFile .. ' [To] ' .. destFile)
						end
					end
				else
					print ('[Source Image Missing] ' .. srcFile)
				end
			end
		else
			print ('[Error Creating Output Directory] ' .. dirName)
		end
	end
end


-- Load up a copy of PTGui
function ptguiStitcher(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- PTgui Stitcher
	if platform == 'Windows' then
		-- Running on Windows
		defaultViewerProgram = 'C:\\Program Files\\PTGui\\PTGui.exe'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.SendMedia.PTGuiFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'start "" ' .. viewerProgram .. ' "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		defaultViewerProgram = '/Applications/PTGui Pro.app'
		
		viewerProgram = '"' .. string.gsub(comp:MapPath(getPreferenceData('KartaVR.SendMedia.PTGuiFile', defaultViewerProgram, printStatus)), '[/]$', '') .. '"'
		command = 'open -a '..viewerProgram ..' --args "' .. mediaFileName .. '"'
					
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		print('PTgui is not available for Linux yet.')
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


-- Check the active selection and return a table of media files
-- Example: mediaTable = GenerateMediaTable()
function GenerateMediaTable()
	-- Create a multi-dimensional table
	media = {}
	
	-- Track the node index when creating the media {} table elements
	nodeIndex = 1
	
	-- Create a list of media files
	mediaFileNameList = ''
	
	-- -------------------------------------------
	-- Start adding each image and video element:
	-- -------------------------------------------
	
	local toollist1 = comp:GetToolList(true, 'Loader')
	local toollist2 = comp:GetToolList(true, 'Saver')

	-- Scan the comp to check how many Loader nodes are present
	totalLoaders = table.getn(toollist1)
	totalSavers = table.getn(toollist2)
	print('[Currently Selected Loader Nodes] ', totalLoaders)
	print('[Currently Selected Saver Nodes] ', totalSavers)
	
	-- Check if no images were selected
	if totalSavers == 0 and totalLoaders == 0 then
		err = true
		print('[There were no Loader or Saver Nodes selected]')
		-- Nothing was selected at all in the comp!
		
		-- Exit this function instantly on error
		return mediaFileNameList
	end
	
	-- Iterate through each of the loader nodes
	for i, tool in ipairs(toollist1) do
			toolAttrs = tool:GetAttrs()
			toolType = tool:GetAttrs().TOOLS_RegID
			nodeName = tool:GetAttrs().TOOLS_Name
		
			if useCurrentFrame == 1 then
				-- Expression for the current frame from the image sequence
				-- It will report a 'nil' when outside of the active frame range
				print('[Use Current Frame] Enabled')
				print('Note: If you see an error in the console it means that you have scrubbed the timeline beyond the actual frame range of the media file.')
				sourceMediaFile = tool.Output[comp.CurrentTime].Metadata.Filename
			else
				-- sourceMediaFile = comp:MapPath(tool:GetAttrs().TOOLST_Clip_Name[1])
				sourceMediaFile = comp:MapPath(tool.Clip[fu.TIME_UNDEFINED])
				-- filenameClip = (eyeon.parseFilename(toolClip))
			end
			
			print("[" .. toolType .. " Name] " .. nodeName .. " [Image Filename] " .. sourceMediaFile)
			
			-- Active frame range
			sourceStartFrameRange = toolAttrs.TOOLNT_Clip_Start[1]
			sourceEndFrameRange = toolAttrs.TOOLNT_Clip_End[1]
			
			-- Extract the base media filename without the path
			mediaFile = eyeon.getfilename(sourceMediaFile)
			
			mediaExtension = eyeon.getextension(mediaFile)
			if mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
				mediaType = 'video'
				print('[The ' .. mediaFile .. ' media file was detected as a movie format. Please extract a frame from the movie file as enblend does not support working with video formats directly.]')
			else
				mediaType = 'image'
				print('[The ' .. mediaFile .. ' media file was detected as an image format.]')
				
				-- Get the node position
				flow = comp.CurrentFrame.FlowView
				nodeXpos, nodeYpos = flow:GetPos(tool)
				-- print('Node [X] ' .. nodeXpos .. ' [Y] ' .. nodeYpos)
				
				-- Add a new entry to the media {} table:
				-- id
				-- nodename1
				-- filepath2
				-- filename3
				-- folder4
				-- extension5
				-- type6
				-- xpos7
				-- ypos8
				-- startframe9
				-- endframe10
				media[nodeIndex] = {id = nodeIndex, nodename1 = nodeName, filepath2 = sourceMediaFile, filename3 = mediaFile, folder4 = dirname(sourceMediaFile), extension5 = mediaExtension, type6 = mediaType, xpos7 = nodeXpos, ypos8 = nodeYpos, startframe9 = sourceStartFrameRange, endframe10 = sourceEndFrameRange}
				
				nodeIndex = nodeIndex + 1
			end 
	end
	
	-- Iterate through each of the saver nodes
	for i, tool in ipairs(toollist2) do 
			toolAttrs = tool:GetAttrs()
			toolType = tool:GetAttrs().TOOLS_RegID
			nodeName = tool:GetAttrs().TOOLS_Name
			
			-- sourceMediaFile = comp:MapPath(tool:GetAttrs().TOOLST_Clip_Name[1])
			sourceMediaFile = comp:MapPath(tool.Clip[fu.TIME_UNDEFINED])
			-- filenameClip = (eyeon.parseFilename(toolClip))
			
			print("[" .. toolType .. " Name] " .. nodeName .. " [Image Filename] " .. sourceMediaFile)
			
			-- Active frame range
			sourceStartFrameRange = toolAttrs.TOOLNT_Clip_Start[1]
			sourceEndFrameRange = toolAttrs.TOOLNT_Clip_End[1]
			
			-- Extract the base media filename without the path
			mediaFile = eyeon.getfilename(sourceMediaFile)
			
			mediaExtension = eyeon.getextension(mediaFile)
			if mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
				mediaType = 'video'
				print('[The ' .. mediaFile .. ' media file was detected as a movie format. Please extract a frame from the movie file as enblend does not support working with video formats directly.]')
			else
				mediaType = 'image'
				print('[The ' .. mediaFile .. ' media file was detected as an image format.]')
				
				-- Get the node position
				flow = comp.CurrentFrame.FlowView
				nodeXpos, nodeYpos = flow:GetPos(tool)
				-- print('Node [X] ' .. nodeXpos .. ' [Y] ' .. nodeYpos)
				
				-- Add a new entry to the media {} table:
				-- id
				-- nodename1
				-- filepath2
				-- filename3
				-- folder4
				-- extension5
				-- type6
				-- xpos7
				-- ypos8
				-- startframe9
				-- endframe10
				media[nodeIndex] = {id = nodeIndex, nodename1 = nodeName, filepath2 = sourceMediaFile, filename3 = mediaFile, folder4 = dirname(sourceMediaFile), extension5 = mediaExtension, type6 = mediaType, xpos7 = nodeXpos, ypos8 = nodeYpos, startframe9 = sourceStartFrameRange, endframe10 = sourceEndFrameRange}
				
				nodeIndex = nodeIndex + 1
			end
	end
	
	-- Check the layer stacking order setting
	if layerOrder == 0 then
		-- No Sorting
		print('[Layer Stacking Order] ' .. 'No Sorting')
		-- Sort in ascending order by the id column
		table.sort(media, function(a,b) return a.id < b.id end)
	elseif layerOrder == 1 then
		-- Node X Position
		print('[Layer Stacking Order] ' .. 'Node X Position')
		-- Sort in ascending order by the xpos7 column
		table.sort(media, function(a,b) return a.xpos7 < b.xpos7 end)
	elseif layerOrder == 2 then
		-- Node Y Position
		print('[Layer Stacking Order] ' .. 'Node Y Position')
		-- Sort in ascending order by the ypos8 column
		table.sort(media, function(a,b) return a.ypos8 < b.ypos8 end)
	elseif layerOrder == 3 then
		-- Node Name
		print('[Layer Stacking Order] ' .. 'Node Name')
		-- Sort in ascending order by the Node Name column
		table.sort(media, function(a,b) return a.nodename1 < b.nodename1 end)
	elseif layerOrder == 4 then
		-- Filename
		print('[Layer Stacking Order] ' .. 'Filename')
		-- Sort in ascending order by the Filename column
		table.sort(media, function(a,b) return a.filename3 < b.filename3 end)
	elseif layerOrder == 5 then
		-- Filename
		print('[Layer Stacking Order] ' .. 'Folder + Filename')
		-- Sort in ascending order by the Folder + Filename column
		table.sort(media, function(a,b) return a.filepath2 < b.filepath2 end)
	else
		-- Fallback to using Node Y Position
		print('[Layer Stacking Order] ' .. 'Node Y Position')
		-- Sort in ascending order by the ypos8 column
		table.sort(media, function(a,b) return a.ypos8 < b.ypos8 end)
	end
	 
	-- Send back the quoted list of selected loader and saver node imagery
	return media
end


-- Run the main function
function main()
	print ('PTGui BatchBuilder Extractor is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)
	
	-- Check if Fusion is running
	if not fusion then
		print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
	end
	
	-- Lock the comp flow area
	comp:Lock()
	
	currentMediaFileName = ''
	
	-- -------------------------------------------
	-- Start adding each image and video element:
	-- -------------------------------------------
	
	local toollist1 = comp:GetToolList(true, 'Loader')
	local toollist2 = comp:GetToolList(true, 'Saver')
	
	-- Scan the comp to check how many Loader nodes are present
	totalLoaders = table.getn(toollist1)
	totalSavers = table.getn(toollist2)
	print('[Currently Selected Loader Nodes] ', totalLoaders)
	print('[Currently Selected Saver Nodes] ', totalSavers)
	
	-- Check if no images were selected 
	-- Exit if nothing was selected at all in the comp!
	-- if totalSavers == 0 and totalLoaders == 0 then
		-- err = true
		-- print('[There were no Loader or Saver Nodes selected]')
		
		-- Exit this script instantly on error
		-- return
	-- end
	
	
	-- ------------------------------------
	-- Load the preferences
	-- ------------------------------------

	local browseMode = ''
	if platform == 'Windows' then
		browseMode = 'PathBrowse'
	elseif platform == 'Mac' then
		-- On Mac OS X .app packages can't be selected in PathBrowse Mode so we need to make them enterable in the GUI using the Text mode
		-- browseMode = 'Text'
		browseMode = 'PathBrowse'
	else
		-- Linux
		browseMode = 'PathBrowse'
	end
	
	-- Custom Frame Range
	currentMediaTimeRangeString = 'Custom Frame Range'
	
	-- Render time frame range
	renderStartFrameRange = comp:GetAttrs().COMPN_RenderStart
	renderEndFrameRange = comp:GetAttrs().COMPN_RenderEnd
	renderTimeRangeString = 'Render Time Range [' .. renderStartFrameRange .. '-' .. renderEndFrameRange .. ']'
	
	-- Global time frame range
	globalStartFrameRange = comp:GetAttrs().COMPN_GlobalStart
	globalEndFrameRange = comp:GetAttrs().COMPN_GlobalEnd
	globalTimeRangeString = 'Global Time Range [' .. globalStartFrameRange .. '-' .. globalEndFrameRange .. ']'
	
	msg = 'Customize the Image Sequence to PTGui Batch Builder conversion settings.'
	
	-- Sound Effect List
	soundEffectList = {'None', 'On Error Only', 'Steam Train Whistle Sound', 'Trumpet Sound', 'Braam Sound'}

	-- Frame Extension List
	extractFrameExtensionList = {'<name>.#.ext', '<name>_#.ext', '<name> #.ext', '#.ext', '<name>/<name>.#.ext (In a Subfolder)', '<name>/<name>_#.ext (In a Subfolder)', '<name>/<name> #.ext (In a Subfolder)', '<name>/#.ext (In a Subfolder)'}
	
	-- Image format List
	imageFormatList = {'TIFF', 'TGA', 'BMP', 'PNG', 'JPEG', 'EXR', 'DPX'}
	
	-- File Management
	fileManagementList = {'Copy Images', 'Move Images'}
	
	-- Frame Range List
	frameRangeList = {currentMediaTimeRangeString, renderTimeRangeString, globalTimeRangeString}
	
	soundEffect = getPreferenceData('KartaVR.ConvertToBatchBuilder.SoundEffect', 1, printStatus)
	
	-- Note: The AskUser dialog settings are covered on page 63 of the Fusion Scripting Guide
	-- compPath = dirname(comp:GetAttrs().COMPS_FileName)
	-- Location of output - use the comp path as the default starting value if the preference doesn't exist yet
	compPath = comp:MapPath('Comp:/')
	
	outputFolder = getPreferenceData('KartaVR.ConvertToBatchBuilder.OutputFolder', compPath, printStatus)
	
	-- filenamePrefix = getPreferenceData('KartaVR.ConvertToBatchBuilder.FilenamePrefix', 'Camera1', printStatus)
	
	mediaStartFrame = getPreferenceData('KartaVR.ConvertToBatchBuilder.MediaStartFrame', 0, printStatus)
	
	mediaEndFrame = getPreferenceData('KartaVR.ConvertToBatchBuilder.MediaEndFrame', 143, printStatus)
	
	-- imageFormat = getPreferenceData('KartaVR.ConvertToBatchBuilder.ImageFormat', 0, printStatus)

	frameRange = getPreferenceData('KartaVR.ConvertToBatchBuilder.FrameRange', 1, printStatus)
	
	extractFrameExtension = getPreferenceData('KartaVR.ConvertToBatchBuilder.ExtractExtractFrameExtension', 0, printStatus)

	fileManagement = getPreferenceData('KartaVR.ConvertToBatchBuilder.FileManagement', 1, printStatus)

	framePadding = getPreferenceData('KartaVR.ConvertToBatchBuilder.FramePadding', 4, printStatus)
	
	openOutputFolder = getPreferenceData('KartaVR.ConvertToBatchBuilder.OpenOutputFolder', 1, printStatus)
	
	d = {}
	d[1] = {msg, Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg}
 
	d[2] = {'SoundEffect', Name = 'Sound Effect', 'Dropdown', Default = soundEffect, Options = soundEffectList}
	
	d[3] = {'OutputFolder', Name = 'Image Sequence Output Folder', browseMode, Default = outputFolder}
	
	-- d[4] = {'FilenamePrefix', Name = 'Filename Prefix', 'Text', Lines = 1, Default = filenamePrefix}
	
	-- d[5] = {'ImageFormat', Name = 'Image Format', 'Dropdown', Default = imageFormat, Options = imageFormatList}
	
	d[4] = {'ExtractFrameExtension', Name = 'Output Name', 'Dropdown', Default = extractFrameExtension, Options = extractFrameExtensionList}

	d[5] = {'FileManagement', Name = 'File Mode', 'Dropdown', Default = fileManagement, Options = fileManagementList}

	d[6] = {'FrameRange', Name = 'Frame Range', 'Dropdown', Default = frameRange, Options = frameRangeList}
		
	d[7] = {'MediaStartFrame', Name = 'Custom Start Frame', 'Slider', Lines = 1, Default = mediaStartFrame, Integer = true, Min = 0}
	
	d[8] = {'MediaEndFrame', Name = 'Custom End Frame', 'Slider', Lines = 1, Default = mediaEndFrame, Integer = true, Min = 0}
	
	d[9] = {'FramePadding', Name = 'Frame Padding', 'Slider', Default = framePadding, Integer = true, Min = 0, Max = 8}
	
	d[10] = {'OpenOutputFolder', Name = 'Open Output Folder', 'Checkbox', Default = openOutputFolder, NumAcross = 1}
	
	dialog = comp:AskUser('PTGui BatchBuilder Extractor', d)
	if dialog == nil then
		print('You cancelled the dialog!')
		-- err = true
		
		-- Unlock the comp flow area
		comp:Unlock()
		
		return
	else
		print('[You Pressed the OK Button]')
		
		-- Debug - List the output from the AskUser dialog window
		dump(dialog)
		
		soundEffect = dialog.SoundEffect
		setPreferenceData('KartaVR.ConvertToBatchBuilder.SoundEffect', soundEffect, printStatus)
		
		-- batchBuilderFolder = dialog.BatchBuilderFolder
		-- setPreferenceData('KartaVR.ConvertToBatchBuilder.BatchBuilderFolder', batchBuilderFolder, printStatus)
		
		outputFolder = dialog.OutputFolder
		setPreferenceData('KartaVR.ConvertToBatchBuilder.OutputFolder', outputFolder, printStatus)
		
		-- filenamePrefix = dialog.FilenamePrefix
		-- setPreferenceData('KartaVR.ConvertToBatchBuilder.FilenamePrefix', filenamePrefix, printStatus)
		
		mediaStartFrame = dialog.MediaStartFrame
		setPreferenceData('KartaVR.ConvertToBatchBuilder.MediaStartFrame', mediaStartFrame, printStatus)
		
		mediaEndFrame = dialog.MediaEndFrame
		setPreferenceData('KartaVR.ConvertToBatchBuilder.MediaEndFrame', mediaEndFrame, printStatus)
		
		-- imageFormat = dialog.ImageFormat
		-- setPreferenceData('KartaVR.ConvertToBatchBuilder.ImageFormat', imageFormat, printStatus)
		
		frameRange = dialog.FrameRange
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FrameRange', frameRange, printStatus)
		
		extractFrameExtension = dialog.ExtractFrameExtension
		setPreferenceData('KartaVR.ConvertToBatchBuilder.ExtractFrameExtension', extractFrameExtension, printStatus)
		
		fileManagement = dialog.FileManagement
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FileManagement', fileManagement, printStatus)
		
		framePadding = dialog.FramePadding
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FramePadding', framePadding, printStatus)
		
		openOutputFolder = dialog.OpenOutputFolder
		setPreferenceData('KartaVR.ConvertToBatchBuilder.OpenOutputFolder', openOutputFolder, printStatus)
		
		-- ------------------------------------------------------
		-- Process the footage into the new BatchBuilder folders
		-- ------------------------------------------------------
		
		-- Check the active selection and return a table of media files
		mediaTable = GenerateMediaTable()
		
		-- Generate the media filename string from the table
		for i, media in ipairs(media) do
			print('[Image ' .. i .. '] ' .. media.filepath2)
			BatchBuilderRename(media.filepath2)
		end
	end
end


-- Run the main function
main()


-- Open the image sequence folder as an Explorer/Finder/Nautilus folder view
if openOutputFolder == 1 then
	if outputFolder ~= nil then
		if fu_major_version >= 8 then
			-- The script is running on Fusion 8+ so we will use the fileexists command
			if eyeon.fileexists(outputFolder) then
				openDirectory(outputFolder)
			else
				print('[Output Directory Missing] ', outputFolder)
				err = true
			end
		else
			-- The script is running on Fusion 6/7 so we will use the direxists command
			if eyeon.direxists(outputFolder) then
				openDirectory(outputFolder)
			else
				print('[Output Directory Missing] ', outputFolder)
				err = true
			end
		end
	end
end


-- Play a sound effect
soundEffect = getPreferenceData('KartaVR.ConvertToBatchBuilder.SoundEffect', 1, printStatus)
if err == true or err == 1 then
	-- An error happend when trying to open the media file
	if soundEffect >= 1 then
		-- If the sound Effect mode is 1 or greater (not set to "None" ) than play a braam sound when an error happens
		local audioFile = 'cinematic-musical-sting-braam.wav'
		playDFMWaveAudio(audioFile)
	end
else
	if soundEffect == 0 then
		-- None
	elseif soundEffect == 1 then
		-- Braam Sound On Error Only
		-- Taken care of already
	elseif soundEffect == 2 then
		-- Steam Train Whistle Sound
		local audioFile = 'steam-train-whistle.wav'
		playDFMWaveAudio(audioFile)
	elseif soundEffect == 3 then
		-- Trumpet Sound
		local audioFile = 'trumpet-fanfare.wav'
		playDFMWaveAudio(audioFile)
	elseif soundEffect == 4 then
		-- Braam Sound
		local audioFile = 'cinematic-musical-sting-braam.wav'
		playDFMWaveAudio(audioFile)
	end
end

-- Unlock the comp flow area
comp:Unlock()

-- Warning
if fileManagement == 0 then
	-- File Mode: "Copy Images"
	print('[Note] The BatchBuilder image sequence files were copied to the folder: ' .. outputFolder)
else
	-- File Mode: "Move Images"
	print('[Note] The BatchBuilderimage sequence files were moved to the folder: ' .. outputFolder)
	print('[Note] Since the original files were moved to a new location, the loader node will show a "failed to load file" warning message until you relink the media.')
end

-- End of the script
print('[Done]')
return
