--[[--
----------------------------------------------------------------------------
Send Media to Corel Photo Paint v4.0 for Fusion - 2018-12-25
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The Send Media to Corel Photo Paint script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that will send all of the selected loader node files to Corel Photo Paint. 

How to use the Script:

Step 1. Start Fusion and open a new comp. Select a set of loader and saver nodes in the flow view. Then run the "Script > KartaVR > Send Media to > Send Media to Corel Photo Paint" menu item to load the media in Corel Photo Paint.

The existing loader and saver media files will be opened up in the viewer tool.

--]]--

function mediaViewerTool()
	-- Choose one of the following media viewer tools:
	corelLauncher()
end


-- --------------------------------------------------------
-- --------------------------------------------------------
-- --------------------------------------------------------

local printStatus = false

-- Track if the image was found
local err = false

-- Find out if we are running Fusion 7 or 8
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
-- LUA dirname command inspired by Stackoverflow code example:
-- http://stackoverflow.com/questions/9102126/lua-return-directory-path-from-path
	-- Add the platform specific folder slash character
	osSeparator = package.config:sub(1,1)
	
	return mediaDirName:match('(.*' .. osSeparator .. ')')
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

-- Check the active selection and return a list of media files
-- Example: mediaList = GenerateMediaList()
function GenerateMediaList()
	layerOrder = getPreferenceData('KartaVR.SendMedia.LayerOrder', 2, printStatus)
	
	-- Create a multi-dimensional table
	media = {}
	
	-- Track the node index when creating the media {} table elements
	nodeIndex = 1
	
	-- Create a list of media files
	mediaFileNameList = ''
	
	-- -------------------------------------------
	-- Start adding each image element:
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
		print('[There were no Loader or Saver Nodes selected] ')
		
		-- Exit this function instantly on error
		return
	end
	
	local mediaFileNames = ''
	
	-- Iterate through each of the loader nodes
	for i, tool in ipairs(toollist1) do 
			toolAttrs = tool:GetAttrs().TOOLS_RegID
			nodeName = tool:GetAttrs().TOOLS_Name
			
			-- Was the "Use Current Frame" checkbox enabled in the preferences?
			useCurrentFrame = getPreferenceData('KartaVR.SendMedia.UseCurrentFrame', 0, printStatus)
			
			if useCurrentFrame == 1 then
				-- Expression for the current frame from the image sequence
				-- It will report a 'nil' when outside of the active frame range
				print('[Send Media - Use Current Frame] Enabled')
				print('Note: If you see an error in the console it means that you have scrubbed the timeline beyond the actual frame range of the media file.')
				sourceMediaFile = tool.Output[comp.CurrentTime].Metadata.Filename
			else
				-- Get the file name directly from the clip
				print('[Send Media - Use Current Frame] Disabled')
				-- sourceMediaFile = comp:MapPath(tool:GetAttrs().TOOLST_Clip_Name[1])
				sourceMediaFile = comp:MapPath(tool.Clip[fu.TIME_UNDEFINED])
				-- filenameClip = (eyeon.parseFilename(toolClip))
			end
			
			print('[' .. toolAttrs .. ' Name] ' .. nodeName .. ' [Image Filename] ' .. sourceMediaFile)
			
			-- Extract the base media filename without the path
			mediaFilename = eyeon.getfilename(sourceMediaFile)
			
			mediaExtension = eyeon.getextension(mediaFilename)
			if mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
				mediaType = 'video'
				print('[The ' .. mediaFilename .. ' media file was detected as a movie format. Please extract a frame from the movie file as PTGui does not support working with video formats directly.]')
			else
				mediaType = 'image'
				print('[The ' .. mediaFilename .. ' media file was detected as an image format.]')
				
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
				media[nodeIndex] = {id = nodeIndex, nodename1 = nodeName, filepath2 = sourceMediaFile, filename3 = mediaFilename, folder4 = dirname(sourceMediaFile), extension5 = mediaExtension, type6 = mediaType, xpos7 = nodeXpos, ypos8 = nodeYpos}
				
				nodeIndex = nodeIndex + 1
			end
	end
	
	-- Iterate through each of the saver nodes
	for i, tool in ipairs(toollist2) do 
			toolAttrs = tool:GetAttrs().TOOLS_RegID
			nodeName = tool:GetAttrs().TOOLS_Name
			
			--sourceMediaFile = comp:MapPath(tool:GetAttrs().TOOLST_Clip_Name[1])
			sourceMediaFile = comp:MapPath(tool.Clip[fu.TIME_UNDEFINED])
			-- filenameClip = (eyeon.parseFilename(toolClip))
			
			print('[' .. toolAttrs .. ' Name] ' .. nodeName .. ' [Image Filename] ' .. sourceMediaFile)
			
			-- Extract the base media filename without the path
			mediaFilename = eyeon.getfilename(sourceMediaFile)
			
			mediaExtension = eyeon.getextension(mediaFilename)
			if mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
				mediaType = 'video'
				print('[The ' .. mediaFilename .. ' media file was detected as a movie format. Please extract a frame from the movie file as PTGui does not support working with video formats directly.]')
			else
				mediaType = 'image'
				print('[The ' .. mediaFilename .. ' media file was detected as an image format.]')
				
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
				media[nodeIndex] = {id = nodeIndex, nodename1 = nodeName, filepath2 = sourceMediaFile, filename3 = mediaFilename, folder4 = dirname(sourceMediaFile), extension5 = mediaExtension, type6 = mediaType, xpos7 = nodeXpos, ypos8 = nodeYpos}
				
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
	
	
	-- Generate the media filename string from the table
	for i, media in ipairs(media) do
		mediaFileNameList = mediaFileNameList .. ' "' .. media.filepath2 .. '"'
	end
	
	-- Send back the quoted list of selected loader and saver node imagery
	return mediaFileNameList
end


function corelLauncher()
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Check the active selection and return a list of media files
	mediaList = GenerateMediaList()
	
	if mediaList == nil then
		print('[Error] Please select a loader or saver node and run this script again!')
		
		-- Exit this function instantly on error
		err = true
		return
	end
	
	-- Open the Viewer tool
	if platform == 'Windows' then
		-- Running on Windows
		defaultViewerProgram = 'C:\\Program Files\\Corel\\CorelDRAW Graphics Suite X7\\Programs64\\CorelPP.exe'
		
		viewerProgram = '"' .. getPreferenceData('KartaVR.SendMedia.corelPhotoPaintFile', defaultViewerProgram, printStatus) .. '"'
		command = 'start "" ' .. viewerProgram .. ' ' .. mediaList
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		print('Corel Photo Paint has not beed tested with Blackmagic Design Fusion on Mac OS X yet.')
		-- defaultViewerProgram = '/Applications/CorelPP.app'
		
		-- viewerProgram = '"' .. string.gsub(comp:MapPath(getPreferenceData('KartaVR.SendMedia.corelPhotoPaintFile', defaultViewerProgram, printStatus)), '[/]$', '') .. '"'
		-- command = 'open -a ' .. viewerProgram .. mediaList
		
		-- print('[Launch Command] ', command)
		-- os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		print('Corel Photo Paint is not available for Linux yet.')
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
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


print ('Send Media to Corel Photo Paint is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

-- Check if Fusion is running
if not fusion then
	print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
end

-- Lock the comp flow area
comp:Lock()

-- Launch the viewer tool
mediaViewerTool()

-- Play a sound effect
soundEffect = getPreferenceData('KartaVR.SendMedia.SoundEffect', 1, printStatus)
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

-- End of the script
print('[Done]')
return
