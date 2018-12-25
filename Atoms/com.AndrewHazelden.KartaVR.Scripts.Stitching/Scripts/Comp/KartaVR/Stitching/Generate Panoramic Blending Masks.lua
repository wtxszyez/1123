--[[--
----------------------------------------------------------------------------
Generate Panoramic Blending Masks v4.0 for Fusion - 2018-12-11
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The Generate Panoramic Blending Masks script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that lets you create a set of seamless blending alpha channel mask for the selected media files in your Fusion composite.

How to use the Script:

Step 1. Start Fusion and open a new comp. Select saver or loader node based media in the flow area.

Step 3. Run the "Script > KartaVR > Stitching > Generate Panoramic Blending Masks" menu item.

Step 3. In the "Generate Panoramic Blending Masks" dialog window you need to define the initial paths and blending settings for the script. Then click the "Ok" button.

Extra Notes:

This tool uses Enblend to perform the mask generation phase. For more information on Enblend check out:
http://enblend.sourceforge.net/enblend.doc/enblend_4.2.xhtml/enblend.html

Todo: Fix the Windows based enblend error log file output
Todo: Look at adding the enblend "--no-optimize" option to prevent seam modifications.

--]]--

------------------------------------------------------------------------------

-- Print out extra debugging information
local printStatus = false

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


-- Open a folder window up using your desktop file browser
function openDirectory(mediaDirName)
	command = nil
	
	dir = dirname(mediaDirName)
	
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


-- Check the active selection and return a list of media files
-- Example: mediaList = GenerateMediaList()
function GenerateMediaList()
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
			toolAttrs = tool:GetAttrs().TOOLS_RegID
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
			
			print("[" .. toolAttrs .. " Name] " .. nodeName .. " [Image Filename] " .. sourceMediaFile)
			
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
				media[nodeIndex] = {id = nodeIndex, nodename1 = nodeName, filepath2 = sourceMediaFile, filename3 = mediaFile, folder4 = dirname(sourceMediaFile), extension5 = mediaExtension, type6 = mediaType, xpos7 = nodeXpos, ypos8 = nodeYpos}
				
				nodeIndex = nodeIndex + 1
			end 
	end
	
	-- Iterate through each of the saver nodes
	for i, tool in ipairs(toollist2) do 
			toolAttrs = tool:GetAttrs().TOOLS_RegID
			nodeName = tool:GetAttrs().TOOLS_Name
			
			-- sourceMediaFile = comp:MapPath(tool:GetAttrs().TOOLST_Clip_Name[1])
			sourceMediaFile = comp:MapPath(tool.Clip[fu.TIME_UNDEFINED])
			-- filenameClip = (eyeon.parseFilename(toolClip))
			
			print("[" .. toolAttrs .. " Name] " .. nodeName .. " [Image Filename] " .. sourceMediaFile)
			
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
				media[nodeIndex] = {id = nodeIndex, nodename1 = nodeName, filepath2 = sourceMediaFile, filename3 = mediaFile, folder4 = dirname(sourceMediaFile), extension5 = mediaExtension, type6 = mediaType, xpos7 = nodeXpos, ypos8 = nodeYpos}
				
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


-- Copy text to the operating system's clipboard
-- Example: CopyToClipboard('Hello World!')
function CopyToClipboard(textString)
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	clipboardTempFile = outputDirectory .. 'maskClipboardText.txt'
	
	-- Create the temp folder if required
	os.execute('mkdir "' .. outputDirectory..'"')
	
	-- Open up the file pointer for the output textfile
	outClipFile, err = io.open(clipboardTempFile,'w')
	if err then 
		print("[Error Opening Clipboard Temporary File for Writing]")
		return
	end
	
	outClipFile:write(textString,'\n')
	
	-- Close the file pointer on the output textfile
	outClipFile:close()
	
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
	
	print('[Copy Text to Clipboard Command] ' .. command)
	print('[Clipboard] ' .. textString)
	os.execute(command)
end


-- Add an extra loader node to the comp
function CreateLoaderNodes(nodeNumber, booleanName, loaderName, loaderFilename, loaderFormat, nodeOriginXPos, nodeOriginYPos, align)
	-- loaderFormat holds a value like 'TiffFormat'
	-- default node starting X/Y Pos = 605, 214.5
	
	-- Node spacing per row/column
	nodeXOffset = 110
	nodeYOffset = 33.5
	
	-- Node Transforms
	if align == 'left' then
		-- Position the loader node by calculating the node index # that is being added
		loaderXPos = nodeOriginXPos
		loaderYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- The boolean node goes to the left of the loader
		boolNodeXPos = loaderXPos - nodeXOffset
		boolNodeYPos = loaderYPos
	elseif align == 'right' then
		-- Position the loader node by calculating the node index # that is being added
		loaderXPos = nodeOriginXPos
		loaderYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- The boolean node goes to the right of the loader
		boolNodeXPos = loaderXPos + nodeXOffset
		boolNodeYPos = loaderYPos
	elseif align == 'upwards' then
		-- Position the loader node by calculating the node index # that is being added
		loaderXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		loaderYPos = nodeOriginYPos
		
		-- The boolean node goes to the above of the loader
		boolNodeXPos = loaderXPos
		boolNodeYPos = loaderYPos - nodeYOffset
	elseif align == 'downwards' then
		-- Position the loader node by calculating the node index # that is being added
		loaderXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		loaderYPos = nodeOriginYPos
			
		-- The boolean node goes to the below of the loader
		boolNodeXPos = loaderXPos
		boolNodeYPos = loaderYPos + nodeYOffset
	else
		-- Position the loader node by calculating the node index # that is being added
		loaderXPos = nodeOriginXPos
		loaderYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- boolean node goes to the right of the loader
		boolNodeXPos = loaderXPos + nodeXOffset
		boolNodeYPos = loaderYPos
	end
	
	nodeString = ''
	
	-- Add a Loader node
	nodeString = nodeString .. '\t\t' .. loaderName .. ' = Loader {\n'
	nodeString = nodeString .. '\t\t\tClips = {\n'
	nodeString = nodeString .. '\t\t\t\tClip {\n'
	nodeString = nodeString .. '\t\t\t\t\tID = "Clip1",\n'
	nodeString = nodeString .. '\t\t\t\t\tFilename = "' .. loaderFilename .. '",\n'
	nodeString = nodeString .. '\t\t\t\t\tFormatID = "' .. loaderFormat .. '",\n'
	
	-- Does the final frame padding start on frame 1 or frame 0?
	nodeString = nodeString .. '\t\t\t\t\tStartFrame = ' .. frameExtensionFusionStartFrame .. ',\n'
	
	nodeString = nodeString .. '\t\t\t\t\tLengthSetManually = true,\n'
	nodeString = nodeString .. '\t\t\t\t\tTrimIn = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tTrimOut = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tExtendFirst = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tExtendLast = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tLoop = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tAspectMode = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tDepth = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tTimeCode = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tGlobalStart = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tGlobalEnd = 0\n'
	nodeString = nodeString .. '\t\t\t}\n'
	nodeString = nodeString .. '\t\t},\n'
	nodeString = nodeString .. '\t\tCtrlWZoom = false,\n'
	nodeString = nodeString .. '\t\tInputs = {\n'
	nodeString = nodeString .. '\t\t\tMissingFrames = Input { Value = 1, },\n'
	nodeString = nodeString .. '\t\t\t["Gamut.SLogVersion"] = Input { Value = FuID { "SLog2" }, },\n'
	nodeString = nodeString .. '\t\t},\n'
	
	nodeString = nodeString .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. loaderXPos .. ', ' .. loaderYPos .. ' } },\n'
	nodeString = nodeString .. '\t\t},\n'
	
	-- Add a Channel Boolean Node
	nodeString = nodeString .. '\t\t' .. booleanName .. ' = ChannelBoolean {\n'
	nodeString = nodeString .. '\t\t\tCtrlWZoom = false,\n'
	nodeString = nodeString .. '\t\t\tNameSet = true,\n'
	nodeString = nodeString .. '\t\t\tInputs = {\n'
	nodeString = nodeString .. '\t\t\t\tToAlpha = Input { Value = 13, },\n'
	nodeString = nodeString .. '\t\t\t\tBackground = Input {\n'
	nodeString = nodeString .. '\t\t\t\t\tSourceOp = "' .. loaderName .. '",\n'
	nodeString = nodeString .. '\t\t\t\t\tSource = "Output",\n'
	nodeString = nodeString .. '\t\t\t\t},\n'
	nodeString = nodeString .. '\t\t\t},\n'
	nodeString = nodeString .. '\t\tViewInfo = OperatorInfo { Pos = { ' .. boolNodeXPos .. ', ' .. boolNodeYPos .. ' } },\n'
	nodeString = nodeString .. '\t\t},\n' -- optional trailing comma
	
	return nodeString
end
	
-- Create the new enblended mask image nodes and channel booleans for to the comp
function AddEnblendMaskNodes()
	-- Check the Node Layout aka. "Build Direction" setting
	if nodeDirection == 0 then
		-- Skip Adding Nodes
		return
	elseif nodeDirection == 1 then
		-- Build Nodes Left
		nodeAlignment = 'left'
	elseif nodeDirection == 2 then
		-- Build Nodes Right
		nodeAlignment = 'right'
	elseif nodeDirection == 3 then
		-- Build Nodes Upwards
		nodeAlignment = 'upwards'
	elseif nodeDirection == 4 then
		-- Build Nodes Downwards
		nodeAlignment = 'downwards'
	else
		-- Fallback default of Build Nodes Downwards
		nodeAlignment = 'downwards'
	end
	
	print('[Node Layout / Build Direction] ' .. nodeAlignment)
	
	-- Node Positions - read from the Fusion cursor / last node position in the future.
	nodeX = 605
	nodeY = 346
	
	-- The loader node media basefolder
	-- Todo: Double check there is a trailing folder slash in the filepath!!
	mediaBaseFolder = maskOutputFolder
	
	-- -----------------------------------------
	-- Create the block of loader node elements
	-- -----------------------------------------
	
	-- Open the Fusion comp tags
	loaderNodes = '{\n'
	loaderNodes = loaderNodes .. '\tTools = ordered() {\n'
	
	-- Loop through loading each of the mask images
	-- Total Mask Loader Node Count = (Total Nodes - 1)
	totalNodes = (totalSavers + totalLoaders) - 1
	
	-- Track the current node for the placement in the scene and the node name
	for nodeNumber=1,totalNodes do
		-- Generate the current mask image filename assuming no mask number frame padding
		mediaClipName = mediaBaseFolder .. maskFilenamePrefix .. 'mask' .. nodeNumber .. frameExtensionNumber .. '.' .. imageFormatExt
		
		if eyeon.fileexists(mediaClipName) then
			-- Try finding the mask image with no padding first
			print('[Media File Found] ' .. mediaClipName)
		elseif totalNodes >= 10 then
			-- Then check if the mask is present with image frame padding when greater than 10 masks are present
			
			-- Generate a frame padding number like: %4d
			framePaddingString = '%0' .. string.len(totalNodes) .. 'd'
			nodeNumberPadded = string.format(framePaddingString, nodeNumber)
			
			mediaClipName = mediaBaseFolder .. maskFilenamePrefix .. 'mask' .. nodeNumberPadded .. frameExtensionNumber .. '.' .. imageFormatExt
			
			if eyeon.fileexists(mediaClipName) then
				print('[Media File Found] ' .. mediaClipName)
			else
				-- Skip adding a filename to the loader node if the mask image is not present
				print('[Media File Not Found] ' .. mediaClipName)
				err = true
			end
		end
		
		nodeLoaderName = 'MaskLoader' .. nodeNumber
		nodeBooleanName = 'MaskChannelBoolean' .. nodeNumber
		
		if err == true then
			-- Skipping the loader node as the media is missing
			print('[Skipping Loader Node] ' .. nodeLoaderName .. ' [Media] ' .. mediaClipName)
		else
			-- Add the newest loader node
			print('[Adding Loader Node] ' .. nodeLoaderName .. ' [Media] ' .. mediaClipName)
			loaderNodes = loaderNodes .. CreateLoaderNodes(nodeNumber, nodeBooleanName, nodeLoaderName, mediaClipName, imageFormatFusion, nodeX, nodeY, nodeAlignment)
		end
	end
	
	-- Close the Fusion comp tags
	loaderNodes = loaderNodes .. '\t}\n}'
	
	print('[Creating Loader Nodes]')
	-- print(loaderNodes)
	
	-- Add the new loader nodes to the system clipboard buffer
	print('[Copying Loader Nodes to Clipboard]')
	CopyToClipboard(loaderNodes)
end


print('Generate Panoramic Blending Masks is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

-- Check if Fusion is running
if not fusion then
	print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
end

-- Lock the comp flow area
comp:Lock()

-- ------------------------------------
-- Load the preferences
-- ------------------------------------

msg = 'Each time the script is run the mask images are placed as loader nodes in your clipboard so they can be pasted into your composite.'

-- Image format List
imageFormatList = {'TIFF', 'TGA', 'BMP', 'PNG', 'JPEG'}

-- Image compression list
compressionList = {"None", "Deflate", "LZW", "RLE"}

-- Sound Effect List
soundEffectList = {'None', 'On Error Only', 'Steam Train Whistle Sound', 'Trumpet Sound', 'Braam Sound'}

-- Edge Wrapping List
edgeWrapList = {'Horizontal', 'Vertical', 'Horizontal & Vertical', 'None'}

-- Seam Blending List
seamBlendList = {'Nearest Feature Transform (NFT)', 'Graph-Cut Segmentation (GC)'}

-- Layer Order
layerOrderList = {'No Sorting', 'Node X Position', 'Node Y Position', 'Node Name', 'Filename', 'Folder + Filename'}

-- Node Build Direction
nodeDirectionList = {'Skip Adding Nodes', 'Build Nodes Left', 'Build Nodes Right', 'Build Nodes Upwards', 'Build Nodes Downwards'}

-- Frame Extension List
frameExtensionList = {'<prefix>mask#.ext', '<prefix>mask#.0000.ext', '<prefix>mask#.0001.ext'}


if platform == 'Windows' then
	maskOutputFolder = comp:MapPath('Comp:/')
	-- GPU Enable defaults to ON on Windows
	gpuEnable = getPreferenceData('KartaVR.GenerateMask.GpuEnable', 1, printStatus)
elseif platform == 'Mac' then
	maskOutputFolder = comp:MapPath('Comp:/')
	-- GPU Enable defaults to OFF on Mac OS X
	gpuEnable = getPreferenceData('KartaVR.GenerateMask.GpuEnable', 0, printStatus)
else
	-- Linux
	maskOutputFolder = comp:MapPath('Comp:/')
	-- GPU Enable defaults to ON on Linux
	gpuEnable = getPreferenceData('KartaVR.GenerateMask.GpuEnable', 1, printStatus)
end

maskFilenamePrefix = getPreferenceData('KartaVR.GenerateMask.MaskFilenamePrefix', 'blend-', printStatus)

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


soundEffect = getPreferenceData('KartaVR.GenerateMask.SoundEffect', 2, printStatus)
imageFormat = getPreferenceData('KartaVR.GenerateMask.ImageFormat', 0, printStatus)
compress = getPreferenceData('KartaVR.GenerateMask.Compression', 2, printStatus)
edgeWrap = getPreferenceData('KartaVR.GenerateMask.EdgeWrap', 0, printStatus)
seamBlend = getPreferenceData('KartaVR.GenerateMask.SeamBlend', 1, printStatus)
layerOrder = getPreferenceData('KartaVR.GenerateMask.LayerOrder', 2, printStatus)
nodeDirection = getPreferenceData('KartaVR.GenerateMask.NodeDirection', 2, printStatus)
frameExtension = getPreferenceData('KartaVR.GenerateMask.FrameExtension', 1, printStatus)
startOnFrameOne = getPreferenceData('KartaVR.GenerateMask.StartOnFrameOne', 1, printStatus)
openOutputFolder = getPreferenceData('KartaVR.GenerateMask.OpenOutputFolder', 1, printStatus)
fineMask = getPreferenceData('KartaVR.GenerateMask.FineMask', 1, printStatus)
useCurrentFrame = getPreferenceData('KartaVR.GenerateMask.UseCurrentFrame', 1, printStatus)


d = {}
d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg}
d[2] = {'MaskOutputFolder', Name = 'Mask Output Folder', browseMode, Lines = 1, Default = maskOutputFolder}
d[3] = {'MaskFilenamePrefix', Name = 'Mask Filename Prefix', 'Text', Lines = 1, Default = maskFilenamePrefix}
d[4] = {'SoundEffect', Name = 'Sound Effect', 'Dropdown', Default = soundEffect, Options = soundEffectList}
d[5] = {'ImageFormat', Name = 'Image Format', 'Dropdown', Default = imageFormat, Options = imageFormatList}
d[6] = {'Compression', Name = 'Compression', 'Dropdown', Default = compress, Options = compressionList}
d[7] = {'EdgeWrap', Name = 'Edge Wrap', 'Dropdown', Default = edgeWrap, Options = edgeWrapList}
d[8] = {'SeamBlend', Name = 'Seam Blend', 'Dropdown', Default = seamBlend, Options = seamBlendList}
d[9] = {'LayerOrder', Name = 'Layer Order', 'Dropdown', Default = layerOrder, Options = layerOrderList}
d[10] = {'NodeDirection', Name = 'Node Layout', 'Dropdown', Default = nodeDirection, Options = nodeDirectionList}
d[11] = {'FrameExtension', Name = 'Frame Ext.', 'Dropdown', Default = frameExtension, Options = frameExtensionList}
d[12] = {'OpenOutputFolder', Name = 'Open Output Folder', 'Checkbox', Default = openOutputFolder, NumAcross = 1}
d[13] = {'StartOnFrameOne', Name = 'Mask Numbering Starts on 1', 'Checkbox', Default = startOnFrameOne, NumAcross = 1}
d[14] = {'FineMask', Name = 'Create Fine Mask', 'Checkbox', Default = fineMask, NumAcross = 1}
d[15] = {'GpuEnable', Name = 'GPU Accelerate', 'Checkbox', Default = gpuEnable, NumAcross = 1}
d[16] = {'UseCurrentFrame', Name = 'Use Current Frame', 'Checkbox', Default = useCurrentFrame, NumAcross = 1}

dialog = comp:AskUser('Generate Panoramic Blending Masks', d)
if dialog == nil then
	print('You cancelled the dialog!')
	err = true
	
	-- Unlock the comp flow area
	comp:Unlock()
	
	return
else
	-- Debug - List the output from the AskUser dialog window
	dump(dialog)
	
	maskOutputFolder = comp:MapPath(dialog.MaskOutputFolder)
	setPreferenceData('KartaVR.GenerateMask.MaskOutputFolder', maskOutputFolder, printStatus)
	
	maskFilenamePrefix = dialog.MaskFilenamePrefix
	setPreferenceData('KartaVR.GenerateMask.MaskFilenamePrefix', maskFilenamePrefix, printStatus)
	
	soundEffect = dialog.SoundEffect
	setPreferenceData('KartaVR.GenerateMask.SoundEffect', soundEffect, printStatus)
	
	imageFormat = dialog.ImageFormat
	setPreferenceData('KartaVR.GenerateMask.ImageFormat', imageFormat, printStatus)
	
	compress = dialog.Compression
	setPreferenceData('KartaVR.GenerateMask.Compression', compress, printStatus)
	
	edgeWrap = dialog.EdgeWrap
	setPreferenceData('KartaVR.GenerateMask.EdgeWrap', edgeWrap, printStatus)

	seamBlend = dialog.SeamBlend
	setPreferenceData('KartaVR.GenerateMask.SeamBlend', seamBlend, printStatus)
	
	layerOrder = dialog.LayerOrder
	setPreferenceData('KartaVR.GenerateMask.LayerOrder', layerOrder, printStatus)
	
	nodeDirection = dialog.NodeDirection
	setPreferenceData('KartaVR.GenerateMask.NodeDirection', nodeDirection, printStatus)
	
	frameExtension = dialog.FrameExtension
	setPreferenceData('KartaVR.GenerateMask.FrameExtension', frameExtension, printStatus)
	
	startOnFrameOne = dialog.StartOnFrameOne
	setPreferenceData('KartaVR.GenerateMask.StartOnFrameOne', startOnFrameOne, printStatus)
		
	useCurrentFrame = dialog.UseCurrentFrame
	setPreferenceData('KartaVR.GenerateMask.UseCurrentFrame', useCurrentFrame, printStatus)
	
	openOutputFolder = dialog.OpenOutputFolder
	setPreferenceData('KartaVR.GenerateMask.OpenOutputFolder', openOutputFolder, printStatus)
	
	fineMask = dialog.FineMask
	setPreferenceData('KartaVR.GenerateMask.FineMask', fineMask, printStatus)
	
	gpuEnable = dialog.GpuEnable
	setPreferenceData('KartaVR.GenerateMask.GpuEnable', gpuEnable, printStatus)
end


-- Select the image file format
if imageFormat == 0 then
	imageFormatExt = 'tif'
	imageFormatFusion = 'TiffFormat'
elseif imageFormat == 1 then
	imageFormatExt = 'tga'
	imageFormatFusion = 'TargaFormat'
elseif imageFormat == 2 then
	imageFormatExt = 'bmp'
	imageFormatFusion = 'BMPFormat'
elseif imageFormat == 3 then
	imageFormatExt = 'png'
	imageFormatFusion = 'PNGFormat'
elseif imageFormat == 4 then
	imageFormatExt = 'jpg'
	imageFormatFusion = 'JpegFormat'
else
	-- Fallback option
	imageFormatExt = 'tif'
	imageFormatFusion = 'TiffFormat'
end


-- Check the tiff compression modes
-- none, deflate, lzw, packbits
if imageFormat == 0 then
	-- We are compressing a tiff image!
	
	-- Select the compression format
	if compress == 0 then
		-- use default options
		compressionFormat = '--compression=NONE'
	elseif compress == 1 then
		-- deflate compression
		compressionFormat = '--compression=DEFLATE'
	elseif compress == 2 then
		-- lzw compression
		compressionFormat = '--compression=LZW'
	elseif compress == 3 then
		-- RLE is known as packbits
		compressionFormat = '--compression=PACKBITS'
	else
		compressionFormat = ''
	end
elseif imageFormat == 4 then
	-- We are compressing a jpeg image!
	-- JPEG Compression uses a quality value from 0-100
	compressionFormat = '--compression=100'
else
	-- All other image formats fall back to no compression
	compressionFormat = ''
end


-- Set up the panoramic edge of frame wrapping
if edgeWrap == 0 then
	-- horizontal wrapping
	wrapMode = '--wrap=horizontal'
elseif edgeWrap == 1 then
	-- vertical wrapping
	wrapMode = '--wrap=vertical'
elseif edgeWrap == 2 then
	-- horizontal & vertical wrapping
	wrapMode = '--wrap=horizontal+vertical'
elseif edgeWrap == 3 then
	-- none / open wrapping
	wrapMode = '--wrap=none'
else
	-- Fallback mode is horizontal
	wrapMode = '--wrap=horizontal'
end


-- Set up the primary seam generator
if seamBlend == 0 then
	-- Nearest Feature Transform (NFT)
	seamMode = '--primary-seam-generator=nearest-feature-transform'
elseif seamBlend == 1 then
	-- Graph-Cut Segmentation (GC)
	seamMode = '--primary-seam-generator=graph-cut'
else
	-- Fallback mode is Nearest Feature Transform (NFT)
	seamMode = '--primary-seam-generator=nearest-feature-transform'
end


-- Set up the fine masking mode that works with the seam generator
if fineMask == 0 then
	fineMaskMode = ''
elseif fineMask == 1 then
	fineMaskMode = '--fine-mask'
else
	-- Fallback mode has fine masking enabled
	fineMaskMode = '--fine-mask'
end


-- The mask image final sequence frame numbers
-- This starts on either none, frame 0000, or frame 0001
frameExtensionNumber = ''
if frameExtension == 0 then
 -- None (skip adding a frame extension number)
	frameExtensionNumber = ''
	frameExtensionFusionStartFrame = 0
elseif frameExtension == 1 then
	-- Start the image sequence on frame 0
	frameExtensionNumber = '.0000'
	frameExtensionFusionStartFrame = 0
else
	-- Start the image sequence on frame 1
	frameExtensionNumber = '.0001'
	frameExtensionFusionStartFrame = 1
end


-- The --save-masks mask number
-- %n = mask image number starting at one
-- %i = mask image number starting at zero
maskNumber = ''
if startOnFrameOne == 1 then
	-- Start the image numbering on one
	maskNumber = '%n'
else
	-- Start the image sequence on zero
	maskNumber = '%i'
end
 
-- File name template for saved masks
-- Todo: Check if this command needs an absolute file path for the image output
-- %f = the base filename of the input imagery: imageprefix
-- %d = directory path of input imagery: /example/path/
-- %n = mask image number starting at one
-- %i = mask image number starting at zero
saveMaskName = '"' .. maskOutputFolder .. maskFilenamePrefix .. 'mask' .. maskNumber .. frameExtensionNumber .. '.' .. imageFormatExt .. '" '

-- The system temporary directory path (Example: $TEMP/KartaVR/)
outputLogDirectory = comp:MapPath('Temp:\\KartaVR\\')
os.execute('mkdir "' .. outputLogDirectory..'"')

-- Redirect the output from the terminal to a log file
outputLog = outputLogDirectory .. 'enblendMaskingOutputLog.txt'
logCommand = ''
if platform == 'Windows' then
	logCommand = ' > "' .. outputLog.. '" '
	-- logCommand = ' ' .. '2>&1 | "C:\\Program Files\\KartaVR\\tools\\wintee\\bin\\wtee.exe" -a' .. ' "' .. outputLog.. '" '
elseif platform == 'Mac' then
	--logCommand = ' > "' .. outputLog.. '" '
	logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
elseif platform == 'Linux' then
	-- logCommand = ' > "' .. outputLog.. '" '
	logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
end


-- Find the enblend program path
if platform == 'Windows' then
	-- Running on Windows
	-- enblendProgram = '"C:\\Program Files\\KartaVR\\tools\\panotoolsNG\\bin\\enblend.exe"'
	enblendProgram = 'start "" "C:\\Program Files\\KartaVR\\tools\\panotoolsNG\\bin\\enblend.exe"'
elseif platform == 'Mac' then
	-- Running on Mac
	enblendProgram = '"/Applications/KartaVR/mac_tools/panotoolsNG/bin/enblend"'
elseif platform == 'Linux' then
	-- Running on Linux
	 enblendProgram = '"/usr/bin/enblend"'
else
	print('[Platform] ', platform)
	print('There is an invalid platform defined in the local platform variable at the top of the code.')
	enblendProgram = '"enblend"'
end



-- GPU accelerate enblend
if gpuEnable == 1 then
	-- Enable GPU option
	gpuAcceleration = '--gpu'
else
	-- Disable the GPU option
	gpuAcceleration = ''
end


-- -------------------------
-- Enblend command string
-- -------------------------

command = enblendProgram
-- command = 'enblend'

-- Add verbose option
command = command .. ' ' .. '--verbose'

-- Add frame wrapping option
command = command .. ' ' .. wrapMode

-- Add primary seam generator option
command = command .. ' ' .. seamMode

-- Add fine masking option
command = command .. ' ' .. fineMaskMode

-- Add compression option
command = command .. ' ' .. compressionFormat

-- Add save masks option
command = command .. ' ' .. '--save-masks=' .. saveMaskName

-- Add the GPU acceleration option
command = command .. ' ' .. gpuAcceleration

-- Add a saved preview image output option
-- Todo: add a checkbox for saving an image preview to the same output folder
-- Todo: add imageformat dropdown menu based image extension
command = command .. ' ' .. '--output="' .. outputLogDirectory .. 'enblend-stitched-result.' .. imageFormatExt .. '"'

-- Add the input image names to the end of the string
--mediaList = 'camera1.0000.tif camera2.0000.tif camera3.0000.tif'
mediaList = GenerateMediaList()

if mediaList == nil then
	print('[Error] Please select a loader or saver node and run this script again!')
	
	-- Exit this function instantly on error
	err = true
	return
end
	
-- Print out details on the multi-dimensional media {} table created in the GenerateMediaList() function
print('[Media Table]')
dump(media)
print('\n')

-- Make sure there are actually media files selected before running enblend
if mediaList ~= nil then
	-- We have media files so run enblend
	command = command .. ' ' .. mediaList
	
	-- Add the tee based log .txt file redirect
	command = command .. logCommand
	
	print('[Enblend Launch Command] ', command)
	os.execute(command)
	
	print('[Mask Image Filename Template] ' .. saveMaskName)
else
	print('[Skipping Enblend Processing Stage] Warning: There are no images in the current node selection!')
	err = true
end

-- Create the new enblended mask image nodes and channel booleans for the comp
AddEnblendMaskNodes()

-- Open the publishing folder as an Explorer/Finder/Nautilus folder view
if openOutputFolder == 1 then
	if maskOutputFolder ~= nil then
		if fu_major_version >= 8 then
			-- The script is running on Fusion 8+ so we will use the fileexists command
			if eyeon.fileexists(maskOutputFolder) then
				openDirectory(maskOutputFolder)
			else
				print("[Mask Output Directory Missing] ", maskOutputFolder)
				err = true
			end
		else
			-- The script is running on Fusion 6/7 so we will use the direxists command
			if eyeon.direxists(maskOutputFolder) then
				openDirectory(maskOutputFolder)
			else
				print("[Mask Output Directory Missing] ", maskOutputFolder)
				err = true
			end
		end
	end
end


-- Play a sound effect
soundEffect = getPreferenceData('KartaVR.GenerateMask.SoundEffect', 1, printStatus)
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
 