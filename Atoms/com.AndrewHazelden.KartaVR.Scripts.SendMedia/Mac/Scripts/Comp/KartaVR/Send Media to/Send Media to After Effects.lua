--[[--
----------------------------------------------------------------------------
Send Media to After Effects v4.0.1 for Fusion - 2018-12-31
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The Send Media to After Effects script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that will send all of the selected loader node files to Adobe After Effects.

How to use the Script:

Step 1. Start Fusion and open a new comp. Select a set of loader and saver nodes in the flow view. Then run the "Script > KartaVR > Send Media to > Send Media to After Effects" menu item to load the media in After Effects.


Todo: Read the sound effects clips that are active in Fusion and pass them through to AE

--]]--

function mediaViewerTool()
	-- Choose one of the following media viewer tools:
	afterEffectsLauncher()
end

-- --------------------------------------------------------
-- --------------------------------------------------------
-- --------------------------------------------------------

local printStatus = false

-- Track if the image was found
local err = false

-- Find out if we are running Fusion 7, 8, 9, or 15
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end

-- Duplicate a file
function copyFile(src, dest)
	host = app:MapPath('Fusion:/')
	if string.lower(host):match('resolve') then
		hostOS = 'Resolve'
		
		if platform == 'Windows' then
			command = 'copy /Y "' .. src .. '" "' .. dest .. '" '
		else
			-- Mac / Linux
			command = 'cp "' .. src .. '" "' .. dest .. '" '
		end
		
		print('[Copy File Command] ' .. command)
		os.execute(command)
	else
		hostOS = 'Fusion'
		
		-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8/9 "bmd.scriptlib" libraries
		eyeon.copyfile(src, dest)
	end
end

-- Get the file extension from a filepath
function getExtension(src)
	local extension = string.match(src, '(%..+)$')
	
	return extension or ''
end

-- Get the base filename from a filepath
function getFilename(src)
	local path, basename = string.match(src, "^(.+[/\\])(.+)")
	
	return basename or ''
end


-- Get the base filename without the file extension or frame number from a filepath
function getFilenameNoExt(mediaDirName)
	local path, basename = string.match(mediaDirName, "^(.+[/\\])(.+)")
	local name, extension = string.match(basename, "^(.+)(%..+)$")
	local barename, sequence = string.match(name, "^(.-)(%d+)$")
	
	return barename or ''
end


-- Read a binary file to calculate the filesize in bytes
-- Example: size = getFilesize('/image.png')
function getFilesize(filename)
	fp, errMsg = io.open(filename, "rb")
	if fp == nil then
		print('[Filesize] Error reading the file: ' .. filename)
		return 0
	end
	
	local filesize = fp:seek('end')
	fp:close()
	
	return filesize
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


-- Check the active selection and return a list of AE media files
-- Example: aeMediaString = GenerateAEMediaList()
function GenerateAEMediaList(aeCompIndex)
	layerOrder = getPreferenceData('KartaVR.SendMedia.LayerOrder', 2, printStatus)
	
	-- Create a multi-dimensional table
	media = {}
	
	-- Track the node index when creating the media {} table elements
	nodeIndex = 1
	
	-- Create a list of media files
	mediaFileNameList = ''
	aeLoadSequenceString = ''
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
		mediaFilename = getFilename(sourceMediaFile)
		
		mediaExtension = getExtension(mediaFilename)
		if mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
			mediaType = 'video'
			print('[The ' .. mediaFilename .. ' media file was detected as a movie format. Please extract a frame from the movie file as PTGui does not support working with video formats directly.]')
		else
			mediaType = 'image'
			print('[The ' .. mediaFilename .. ' media file was detected as an image format.]')
		end
		
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
	
	-- Iterate through each of the saver nodes
	for i, tool in ipairs(toollist2) do 
		toolAttrs = tool:GetAttrs().TOOLS_RegID
		nodeName = tool:GetAttrs().TOOLS_Name
		
		--sourceMediaFile = comp:MapPath(tool:GetAttrs().TOOLST_Clip_Name[1])
		sourceMediaFile = comp:MapPath(tool.Clip[fu.TIME_UNDEFINED])
		-- filenameClip = (eyeon.parseFilename(toolClip))
	
		print('[' .. toolAttrs .. ' Name] ' .. nodeName .. ' [Image Filename] ' .. sourceMediaFile)
		
		-- Extract the base media filename without the path
		mediaFilename = getFilename(sourceMediaFile)
		
		mediaExtension = getExtension(mediaFilename)
		if mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
			mediaType = 'video'
			print('[The ' .. mediaFilename .. ' media file was detected as a movie format. Please extract a frame from the movie file as PTGui does not support working with video formats directly.]')
		else
			mediaType = 'image'
			print('[The ' .. mediaFilename .. ' media file was detected as an image format.]')
		end
		
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
	
	-- Layer Transfer Mode
	local transferModeName = 'BlendingMode.NORMAL'
	
	-- Timeline in point offset
	local startFrameInSeconds = 0.0
	
	-- Generate the media filename string from the table
	for i, media in ipairs(media) do
		aeLoadSequenceString = aeLoadSequenceString .. '	// ' .. media.nodename1 .. ' Render Layer\n'
		aeLoadSequenceString = aeLoadSequenceString .. '	 loadSequence(newComp' .. aeCompIndex .. ', mediaFolder, ' .. transferModeName .. ', workingMediaDir, "'
		
		-- Escape the folder path slashes on windows
		if platform == 'Windows' then
			aeLoadSequenceString = aeLoadSequenceString .. string.gsub(media.filepath2, '\\', '\\\\')
		else
			aeLoadSequenceString = aeLoadSequenceString .. media.filepath2
		end
		
		aeLoadSequenceString = aeLoadSequenceString .. '", "' .. media.nodename1 .. '"'
		aeLoadSequenceString = aeLoadSequenceString .. ', ' .. startFrameInSeconds .. ', ' .. compWidth .. ', ' .. compHeight
		aeLoadSequenceString = aeLoadSequenceString .. ');\n'
		aeLoadSequenceString = aeLoadSequenceString .. '\n'
	end
	
	-- Send back the quoted list of selected loader and saver node imagery
	return aeLoadSequenceString
end


function afterEffectsLauncher()
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	composition = fusion:GetCurrentComp()
	local attrs = comp:GetAttrs()
	local prefs = comp:GetPrefs()
	
	local compName = 'KVR Fusion Comp'
	
	-- Initial default value for comp:
	local compFilename = attrs.COMPS_FileName
	local renderStart = attrs.COMPN_RenderStartTime
	local renderEnd = attrs.COMPN_RenderEndTime
	local frameRate = prefs.Comp.FrameFormat.Rate
	
	local frameDuration = 1 / frameRate	 -- 0.0416667 seconds / frame
	local compDuration = ((renderEnd - renderStart) + 1.0) * frameDuration 
	
	-- Comp Number
	local compIndex = 1
	
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
	
	local imagesLoaded = 0
	
	-- List the selected Node in Fusion 
	selectedNode = comp.ActiveTool
	
	defaultCompWidth = 1920
	defaultCompHeight = 1080
	
	compWidth = 1920
	compHeight = 1080
	
	if selectedNode == nil then
		-- There was a selection box drawn but no specific node is highlighted in yellow
		local prefs = composition:GetPrefs()
		compWidth = prefs.Comp.FrameFormat.Width
		compHeight = prefs.Comp.FrameFormat.Height
	elseif selectedNode then
		-- A node was selected and is highlighted in yellow
		print('[Selected Node] ', selectedNode.Name)
		toolAttrs = selectedNode:GetAttrs()
		
		-- print('[Node Attrs]')
		-- dump(toolAttrs)
		-- print('\n')
		
		if selectedNode:GetAttrs().TOOLS_RegID == 'Loader' then
			compWidth = toolAttrs.TOOLIT_Clip_Width[1]
			compHeight = toolAttrs.TOOLIT_Clip_Height[1]
		elseif selectedNode:GetAttrs().TOOLS_RegID == 'Saver' then
			compWidth = toolAttrs.TOOLI_ImageWidth
			compHeight = toolAttrs.TOOLI_ImageHeight
		end
		
		if compWidth == nil or compWidth == 0 then
			compWidth = defaultCompWidth
		end
		
		if compHeight == nil or compHeight == 0 then
			compHeight = defaultCompHeight
		end
	end
	
	print('[AE Comp Size] [Width] ' .. compWidth .. ' [Height] ' .. compHeight)
	
	-- Track the number of frames loaded from Fusion
	-- compWidth = selectedNode:GetAttrs().TOOLI_ImageWidth or 1920
	-- compHeight = selectedNode:GetAttrs().TOOLI_ImageHeight or 1080
	
	-- AE Comper
	
	-- ----------------------------------------------------------------------
	-- Create the After Effects JSX script in the system temp folder
	-- ----------------------------------------------------------------------
	
	local aeTextString = ''
	
	aeTextString = aeTextString .. '#target aftereffects\n\n'
	aeTextString = aeTextString .. '/*\n'
	aeTextString = aeTextString .. 'AE Comper V1.0 ' .. os.date('%Y-%m-%d %I:%M:%S %p') .. '\n'
	aeTextString = aeTextString .. 'Build an AE comp from the current Fusion composite.\n'
	aeTextString = aeTextString .. '\n'
	aeTextString = aeTextString .. '*/\n'
	
	aeTextString = aeTextString .. 'start();\n'
	aeTextString = aeTextString .. '\n'
	
	aeTextString = aeTextString .. 'function start(){\n'
	
	aeTextString = aeTextString .. '	// Create a new After Effects Project\n'
	aeTextString = aeTextString .. '	createAeProject();\n'
	aeTextString = aeTextString .. '\n'
	
	aeTextString = aeTextString .. '	// Set up a 32-bit float linear workflow\n'
	aeTextString = aeTextString .. '	setLinearWorkflow();\n'
	aeTextString = aeTextString .. '\n'
	
	-- Add the image processing functions
	aeTextString = aeTextString .. '	// Import the media files\n'
	aeTextString = aeTextString .. '	importRenderedMedia();\n'
	aeTextString = aeTextString .. '\n'
	
	-- Stop AE from quitting automatically
	aeTextString = aeTextString .. '	// Stop AE from quitting automatically\n'
	aeTextString = aeTextString .. '	app.exitAfterLaunchAndEval = false;\n'
	aeTextString = aeTextString .. '	\n'
	
	-- Set the Return value for the main function to 0 if everything worked out fine.
	aeTextString = aeTextString .. '	return 0;\n'
	aeTextString = aeTextString .. '}\n'
	aeTextString = aeTextString .. '\n'
	
	-- ------------------------------------------------
	
	-- Bulk part of the script - createAeProject & setLinearWorkflow 
	aeTextString = aeTextString .. '// Create a new After Effects Project\n'
	aeTextString = aeTextString .. 'function createAeProject(){\n'
	aeTextString = aeTextString .. '	app.project.close(CloseOptions.DO_NOT_SAVE_CHANGES);\n'
	aeTextString = aeTextString .. '	app.newProject();\n'
	aeTextString = aeTextString .. '}\n'
	aeTextString = aeTextString .. '\n'
	
	aeTextString = aeTextString .. '// Set up a 32-bit float linear workflow\n'
	aeTextString = aeTextString .. 'function setLinearWorkflow(){\n'
	aeTextString = aeTextString .. '	// Set the project to 32-bits per channel\n'
	aeTextString = aeTextString .. '	app.project.bitsPerChannel = 32;\n'
	aeTextString = aeTextString .. '	writeLn("Bit Depth: " + app.project.bitsPerChannel + " bits per channel");\n'
	aeTextString = aeTextString .. '}\n'
	aeTextString = aeTextString .. '\n'
	
	-- Check if the "Add a Solid Background" Checkbox is enabled
	-- Add the background solid
	aeTextString = aeTextString .. '// Add the background solid\n'
	aeTextString = aeTextString .. 'function addSolidBackground(newComp){\n'
	aeTextString = aeTextString .. '	// Create a shape layer that is fit to the document size\n'
	
	-- ------------------------------------------------------------------------------
	-- Set the solid shape background color
	-- Note: After Effects uses a 0-1 RGB Color range too
	-- ------------------------------------------------------------------------------
	
	-- Use a black color the for solid shape
	bgColorRed = 0.0
	bgColorGreen = 0.0
	bgColorBlue = 0.0
	
	aeTextString = aeTextString .. '	var bgLayer = newComp.layers.addSolid([' .. bgColorRed .. ',' .. bgColorGreen .. ',' .. bgColorBlue .. '], "Background Solid", newComp.width, newComp.height, newComp.pixelAspect, newComp.duration);\n'
	
	aeTextString = aeTextString .. '	bgLayer.threeDLayer = true;\n'
	aeTextString = aeTextString .. '}\n'
	aeTextString = aeTextString .. '\n'
	
	-- Load a new sequence into after effects
	aeTextString = aeTextString .. '// Load a new sequence into after effects\n'
	aeTextString = aeTextString .. 'function loadSequence(comp, mediaFolder, transferMode, dirName, imageName, layerName, startTime, sequenceWidth, sequenceHeight){\n'
	aeTextString = aeTextString .. '	var imgPath = dirName + imageName;\n'
	aeTextString = aeTextString .. '	var io = new ImportOptions(File(imgPath));\n'
	aeTextString = aeTextString .. '	\n'
	
	-- Set Fusion to load only still images not image sequences
	-- Todo fix this when the fusion scriptlib is used to check if the media is a still image or sequence
	aeTextString = aeTextString .. '	// Set the import options to load sequences not frames\n'
	--aeTextString = aeTextString .. '	io.sequence = true;\n'
	aeTextString = aeTextString .. '	// Tell After Effects to handle missing frames gracefully including renders with frame skipping enabled\n'
	
	-- Toggle frame skipping on the AE import process
	-- aeTextString = aeTextString .. 'io.forceAlphabetical = true;\n'
	
	aeTextString = aeTextString .. '	\n	// Import an image sequence into the current project\n'
	aeTextString = aeTextString .. '	var img = app.project.importFile(io);\n'
	aeTextString = aeTextString .. '	writeLn("Added image: " + img.name);\n'
	aeTextString = aeTextString .. '	\n'
	
	aeTextString = aeTextString .. '	// Keep the imported media organized into folders\n'
	aeTextString = aeTextString .. '	img.parentFolder = mediaFolder;\n'
	aeTextString = aeTextString .. '	\n'
	
	aeTextString = aeTextString .. '	// Interpret as pre-multiplied footage against black\n'
	aeTextString = aeTextString .. '	img.mainSource.alphaMode = AlphaMode.PREMULTIPLIED;\n'
	aeTextString = aeTextString .. '	img.mainSource.premulColor = [0,0,0];\n'
	aeTextString = aeTextString .. '	\n'
	
	aeTextString = aeTextString .. '	// Apply the layer transfer mode\n'
	aeTextString = aeTextString .. '	var imgLayer = comp.layers.add(img);\n'
	aeTextString = aeTextString .. '	imgLayer.blendingMode = transferMode;\n'
	aeTextString = aeTextString .. '\n'
	
	aeTextString = aeTextString .. '	// Rename the AE image layer to the Fusion Loader or Saver name\n'
	aeTextString = aeTextString .. '	imgLayer.name = layerName;\n'
	aeTextString = aeTextString .. '	\n'
	
	-- Add the Mettle SkyBox Rotate Sphere Effect
	mettleSkyBoxAE = getPreferenceData('KartaVR.SendMedia.MettleSkyBoxAE', 0, printStatus)
	
	if mettleSkyBoxAE == 0 then
		-- Mettle Disabled
		print('[Mettle SkyBox Mode] ' .. 'None')
	elseif mettleSkyBoxAE == 1 then
		-- Mettle SkyBox Rotate Converter
		print('[Mettle SkyBox Mode] ' .. 'Mettle SkyBox Converter')
		aeTextString = aeTextString .. '	// Add a base set of effects to the layer\n\n'
		aeTextString = aeTextString .. '	// Mettle SkyBox Converter\n'
		aeTextString = aeTextString .. '	var fxA = imgLayer.Effects.addProperty("Mettle SkyBox Converter");\n'
		aeTextString = aeTextString .. '	fxA.enabled = true;\n'
		aeTextString = aeTextString .. '	\n\n\n'
		
		-- Apply a default image projection conversion
		
		-- Read the input format menu value and add +1 to it to map a Fusion enum menu (index starting at 0) to an AE enum menu (index starting at 1)
		mettleSkyBoxInputProjections = getPreferenceData('KartaVR.SendMedia.MettleSkyBoxInputProjections', 3, printStatus) + 1
		-- '2D Source', 'Cube-map 4:3', 'Sphere-map', 'Equirectangular', 'Fisheye (FullDome)', 'Cube-map Facebook 3:2', 'Cube-map Pano2VR 3:2', 'Cube-map NVIDIA 6:1', 'Equirectangular 16:9'
		
		aeTextString = aeTextString .. '	// Input image projection\n'
		-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Input").setValue(' .. mettleSkyBoxInputProjections .. ');\n'
		-- Input
		aeTextString = aeTextString .. '	imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Mettle SkyBox Converter-0002").setValue(' .. mettleSkyBoxInputProjections .. ');\n'
		
		aeTextString = aeTextString .. '	// SkyBox Coverter v1.75 input formats\n'
		aeTextString = aeTextString .. '	// 1 = 2D Source\n'
		aeTextString = aeTextString .. '	// 2 = Cube-map 4:3\n'
		aeTextString = aeTextString .. '	// 3 = Sphere-map\n'
		aeTextString = aeTextString .. '	// 4 = Equirectangular 2:1\n'
		aeTextString = aeTextString .. '	\n'
		
		aeTextString = aeTextString .. '	// SkyBox Coverter v2.X input formats\n'
		aeTextString = aeTextString .. '	// 1 = 2D Source\n'
		aeTextString = aeTextString .. '	// 2 = Cube-map 4:3\n'
		aeTextString = aeTextString .. '	// 3 = Sphere-map\n'
		aeTextString = aeTextString .. '	// 4 = Equirectangular 2:1\n'
		aeTextString = aeTextString .. '	// 5 = Fisheye (FullDome)\n'
		aeTextString = aeTextString .. '	// 6 = Cube-map Facebook 3:2\n'
		aeTextString = aeTextString .. '	// 7 = Cube-map Pano2VR 3:2\n'
		aeTextString = aeTextString .. '	// 8 = Cube-map GearVR 6:1\n'
		aeTextString = aeTextString .. '	// 9 = Equirectangular 16:9\n'
		aeTextString = aeTextString .. '	\n\n'
		
		
		-- Read the output format menu value and add +1 to it to map a Fusion enum menu (index starting at 0) to an AE enum menu (index starting at 1)
		mettleSkyBoxOutputProjectionsList = getPreferenceData('KartaVR.SendMedia.MettleSkyBoxOutputProjections', 2, printStatus) + 1
		-- 'Cube-map 4:3', 'Sphere-map', 'Equirectangular', 'Fisheye (FullDome)', 'Cube-map Facebook 3:2', 'Cube-map Pano2VR 3:2', 'Cube-map NVIDIA 6:1', 'Equirectangular 16:9'
		
		aeTextString = aeTextString .. '	// Output image projection\n'
		-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Output").setValue(' .. mettleSkyBoxOutputProjectionsList .. ');\n'
		-- Output
		aeTextString = aeTextString .. '	imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Mettle SkyBox Converter-0003").setValue(' .. mettleSkyBoxOutputProjectionsList .. ');\n'
		
		aeTextString = aeTextString .. '	// SkyBox Coverter v1.75 output formats\n'
		aeTextString = aeTextString .. '	// 1 = Cube-map 4:3\n'
		aeTextString = aeTextString .. '	// 2 = spherSphere-mapemap\n'
		aeTextString = aeTextString .. '	// 3 = Equirectangular 2:1\n'
		aeTextString = aeTextString .. '	// 4 = Fulldome\n'
		aeTextString = aeTextString .. '	\n'
		
		aeTextString = aeTextString .. '	// SkyBox Coverter v2.X output formats\n'
		aeTextString = aeTextString .. '	// 1 = Cube-map 4:3\n'
		aeTextString = aeTextString .. '	// 2 = Sphere-map\n'
		aeTextString = aeTextString .. '	// 3 = Equirectangular\n'
		aeTextString = aeTextString .. '	// 4 = Fisheye (FullDome)\n'
		aeTextString = aeTextString .. '	// 5 = Cube-map Facebook 3:2\n'
		aeTextString = aeTextString .. '	// 6 = Cube-map Pano2VR 3:2\n'
		aeTextString = aeTextString .. '	// 7 = Cube-map GearVR 6:1\n'
		aeTextString = aeTextString .. '	// 8 = Equirectangular 16:9\n'
		aeTextString = aeTextString .. '	\n'
		
		-- Skybox Image Size
		aeTextString = aeTextString .. '	// Change the image dimension of the output:\n'
		-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Output Frame Width").setValue(sequenceWidth);\n'
		-- Output Frame Width
		aeTextString = aeTextString .. '	imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Mettle SkyBox Converter-0004").setValue(sequenceWidth);\n'
		
		aeTextString = aeTextString .. '	\n'
		
		-- Field of View
		-- aeTextString = aeTextString .. '	 // Change the Fulldome output Field of View\n'
		-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Mettle SkyBox Converter-0010").setValue(180);\n'
		
		-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("FOV").setValue(180);\n'
		-- aeTextString = aeTextString .. '	 //imgLayer.property("Effects").property("Mettle SkyBox Converter").property("FOV").setValue(220);\n'
		-- aeTextString = aeTextString .. '		\n'
		
		-- Read the Dome Tilt Setting
		sendDomeTilt = getPreferenceData('KartaVR.PanoView.SendDomeTilt', 1, printStatus)
		domeTiltAngle = getPreferenceData('KartaVR.PanoView.DomeTiltAngle', 0, printStatus)
		if sendDomeTilt == 0 then
			-- Yes - Send Dome Tilt Angle
			aeTextString = aeTextString .. '	// Rotate the panorama:\n'
			aeTextString = aeTextString .. '	imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Tilt (X axis)").setValue(' .. domeTiltAngle .. ');\n'
			--aeTextString = aeTextString .. '	imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Pan (Y axis)").setValue(' .. domeTiltAngle .. ');\n'
			--aeTextString = aeTextString .. '	imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Roll (Z axis)").setValue(' .. domeTiltAngle .. ');\n'
			aeTextString = aeTextString .. '	\n'
		elseif sendDomeTilt == 1 then
			-- No - Skip Sending Dome Tilt Angle
		elseif sendDomeTilt == 2 then
			-- Send Inverted Dome Tilt Angle
			
			-- ------------------------------------------------------
			-- There are two possibilities for inverting the motion:
			-- ------------------------------------------------------
			
			-- Option #1 Invert the control state checkbox to invert the angle
			aeTextString = aeTextString .. '	// Toggle the invert rotation control:\n'
			
			-- Invert Rotation
			aeTextString = aeTextString .. '	imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Mettle SkyBox Converter-0011").setValue(true);\n'
			
			-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Invert Rotation").setValue(true);\n'
			aeTextString = aeTextString .. '	\n'
			
			-- Option #2 - Take the tilt angle and multiply it by -1 for the flipping effect
			-- domeTiltAngle = -1 * domeTiltAngle
			
			aeTextString = aeTextString .. '	// Rotate the panorama:\n'
			
			-- Tilt (X axis)
			aeTextString = aeTextString .. '	imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Mettle SkyBox Converter-0006").setValue(' .. domeTiltAngle .. ');\n'
			-- Pan (Y axis)
			-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Mettle SkyBox Converter-0007").setValue(' .. domeTiltAngle .. ');\n'
			-- Roll (Z axis)
			-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Mettle SkyBox Converter-0008").setValue(' .. domeTiltAngle .. ');\n'
			
			-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Tilt (X axis)").setValue(' .. domeTiltAngle .. ');\n'
			-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Pan (Y axis)").setValue(' .. domeTiltAngle .. ');\n'
			-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Converter").property("Roll (Z axis)").setValue(' .. domeTiltAngle .. ');\n'
			aeTextString = aeTextString .. '	\n'
		end
	elseif mettleSkyBoxAE == 2 then
		-- Mettle SkyBox Project 2D
		print('[Mettle SkyBox Mode] ' .. 'Mettle SkyBox Project 2D')
		aeTextString = aeTextString .. '	// Add a base set of effects to the layer\n\n'
		aeTextString = aeTextString .. '	// Mettle SkyBox Project 2D\n'
		aeTextString = aeTextString .. '	var fxA = imgLayer.Effects.addProperty("Mettle SkyBox Project 2D");\n\n'
		aeTextString = aeTextString .. '	fxA.enabled = true;\n'
		aeTextString = aeTextString .. '	\n\n\n'
	elseif mettleSkyBoxAE == 3 then
		-- Mettle SkyBox Rotate Sphere
		print('[Mettle SkyBox Mode] ' .. 'Mettle SkyBox Rotate Sphere')
		aeTextString = aeTextString .. '	// Add a base set of effects to the layer\n\n'
		aeTextString = aeTextString .. '	// Mettle SkyBox Rotate Sphere\n'
		aeTextString = aeTextString .. '	var fxA = imgLayer.Effects.addProperty("Mettle SkyBox Rotate Sphere");\n\n'
		aeTextString = aeTextString .. '	fxA.enabled = true;\n'
		aeTextString = aeTextString .. '	\n\n\n'
	elseif mettleSkyBoxAE == 4 then
		-- Mettle SkyBox Viewer
		print('[Mettle SkyBox Mode] ' .. 'Mettle SkyBox Viewer')
		aeTextString = aeTextString .. '	// Add a base set of effects to the layer\n\n'
		aeTextString = aeTextString .. '	// Mettle SkyBox Viewer\n'
		aeTextString = aeTextString .. '	var fxA = imgLayer.Effects.addProperty("Mettle SkyBox Viewer");\n\n'
		aeTextString = aeTextString .. '	fxA.enabled = true;\n'
		aeTextString = aeTextString .. '	\n\n\n'
		
		-- Apply an input projection conversion to remap the valid options for SkyBox Viewer
		-- Read the input format menu value and add +1 to it to map a Fusion enum menu (index starting at 0) to an AE enum menu (index starting at 1)
		mettleSkyBoxInputProjections = getPreferenceData('KartaVR.SendMedia.MettleSkyBoxInputProjections', 3, printStatus) + 1
		-- '2D Source', 'Cube-map 4:3', 'Sphere-map', 'Equirectangular', 'Fisheye (FullDome)', 'Cube-map Facebook 3:2', 'Cube-map Pano2VR 3:2', 'Cube-map NVIDIA 6:1', 'Equirectangular 16:9'
		
		if mettleSkyBoxInputProjections == 2 then 
			-- Cube-map 4:3
			print('[Mettle SkyBox Viewer] ' .. 'Cube-map 4:3')
			mettleSkyBoxViewerInputProjections = 1
		elseif mettleSkyBoxInputProjections == 3 then 
			-- Sphere-map
			print('[Mettle SkyBox Viewer] ' .. 'Sphere-map')
			mettleSkyBoxViewerInputProjections = 2
		elseif mettleSkyBoxInputProjections == 4 then 
			-- Equirectangular
			print('[Mettle SkyBox Viewer] ' .. 'Equirectangular')
			mettleSkyBoxViewerInputProjections = 3
		else
			-- Fallback to Equirectangular
			print('[Mettle SkyBox Viewer] ' .. 'Equirectangular Fallback Mode')
			mettleSkyBoxViewerInputProjections = 3
		end
		
		aeTextString = aeTextString .. '	// Input image projection\n'
		-- Input Format
		aeTextString = aeTextString .. '	imgLayer.property("Effects").property("Mettle SkyBox Viewer").property("Mettle SkyBox Viewer-0002").setValue(' .. mettleSkyBoxViewerInputProjections .. ');\n'
		-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Viewer").property("Input Format").setValue(' .. mettleSkyBoxViewerInputProjections .. ');\n'
		
		aeTextString = aeTextString .. '	// SkyBox Viewer v1.75 input formats\n'
		aeTextString = aeTextString .. '	// 1 = Cube-map 4:3\n'
		aeTextString = aeTextString .. '	// 2 = Sphere-map\n'
		aeTextString = aeTextString .. '	// 3 = Equirectangular\n'
		aeTextString = aeTextString .. '	\n'
		
		-- Force a frame size for the AE composite based upon the SkyBox Viewer updating the value
		aeTextString = aeTextString .. '	// Output Frame Width\n'
		-- Output Frame Width
		aeTextString = aeTextString .. '	imgLayer.property("Effects").property("Mettle SkyBox Viewer").property("Mettle SkyBox Viewer-0003]").setValue(sequenceWidth);\n'
		-- aeTextString = aeTextString .. '	 imgLayer.property("Effects").property("Mettle SkyBox Viewer").property("Output Frame Width").setValue(sequenceWidth);\n'
	end
	
	-- Offset the start time of a clip in the timeline
	-- aeTextString = aeTextString .. '	 -- Offset the start time of a clip\n'
	-- Have the clip start shifted inwards on the timeline
	-- aeTextString = aeTextString .. '	 imgLayer.startTime = startTime;\n'
	-- aeTextString = aeTextString .. '	\n'
	
	-- Close the loadSequence function
	aeTextString = aeTextString .. '	return img;\n'
	aeTextString = aeTextString .. '}\n'
	aeTextString = aeTextString .. '\n'
	
	-- Load a new audio clip into after effects
	--	aeTextString = aeTextString .. '// Load a new audio clip into after effects\n'
	--	aeTextString = aeTextString .. 'function loadAudio(comp, mediaFolder, dirName, audioName, layerName){\n'
	--	aeTextString = aeTextString .. '	var sndPath = dirName .. audioName;\n'
	--	aeTextString = aeTextString .. '	var io = new ImportOptions(File(sndPath));\n'
	--	aeTextString = aeTextString .. '	\n'
	--	
	--	aeTextString = aeTextString .. '	// Import a sound file into the current project\n'
	--	aeTextString = aeTextString .. '	var snd = app.project.importFile(io);\n'
	--	aeTextString = aeTextString .. '	writeLn("Imported Audio: " .. snd.name);\n'
	--	aeTextString = aeTextString .. '	\n'
	--	
	--	aeTextString = aeTextString .. '	// Keep the imported media organized into folders\n'
	--	aeTextString = aeTextString .. '	snd.parentFolder = mediaFolder;\n'
	--	aeTextString = aeTextString .. '	\n'
	--	
	--	aeTextString = aeTextString .. '	// Add the sound clip to the timeline layer\n'
	--	aeTextString = aeTextString .. '	var sndLayer = comp.layers.add(snd);\n'
	--	aeTextString = aeTextString .. '\n'
	--	
	--	aeTextString = aeTextString .. '	// Rename the AE sound layer to the Maya timeline audio file name\n'
	--	aeTextString = aeTextString .. '	sndLayer.name = layerName;\n'
	--	aeTextString = aeTextString .. '	\n'
	
	-- Close the loadAudio function
	--	aeTextString = aeTextString .. '	return snd;\n'
	--	aeTextString = aeTextString .. '}\n'
	--	aeTextString = aeTextString .. '\n'
	
	-- ------------------------------------------------
	
	-- Add the createNewComp function
	aeTextString = aeTextString .. '// Add a new comp to the current AE project\n'
	aeTextString = aeTextString .. 'function createNewComp(sequenceName, sequenceWidth, sequenceHeight, sequenceDuration, compFolder){\n'
	aeTextString = aeTextString .. '	var sequencePixelAspect = 1;\n'
	aeTextString = aeTextString .. '	var SequenceFrameRate = ' .. frameRate .. ';\n'
	aeTextString = aeTextString .. '	\n'
	
	aeTextString = aeTextString .. '	var comp = app.project.items.addComp(sequenceName, sequenceWidth, sequenceHeight, sequencePixelAspect, sequenceDuration, SequenceFrameRate);\n'
	aeTextString = aeTextString .. '	writeLn("New Comp: " + comp.name);\n'
	aeTextString = aeTextString .. '	\n'
	
	aeTextString = aeTextString .. '	comp.parentFolder = compFolder;\n'
	aeTextString = aeTextString .. '	return comp;\n'
	aeTextString = aeTextString .. '}\n\n'
	
	-- Add a new folder to the current AE project
	aeTextString = aeTextString .. '// Add a new folder to the current AE project\n'
	aeTextString = aeTextString .. 'function createNewFolder(folderName){\n'
	aeTextString = aeTextString .. '	var folder = app.project.items.addFolder(folderName);\n'
	aeTextString = aeTextString .. '	\n'
	aeTextString = aeTextString .. '	return folder;\n'
	aeTextString = aeTextString .. '}\n\n'
	
	-- Import the media files
	aeTextString = aeTextString .. '// Import the media files\n'
	aeTextString = aeTextString .. 'function importRenderedMedia(comp){\n'
	aeTextString = aeTextString .. '	var workingMediaDir = "'
	-- aeTextString = aeTextString ..	 rc_getImageSequenceFolder()
	aeTextString = aeTextString ..	'";\n'
	
	aeTextString = aeTextString .. '	// Keep the imported media organized into folders\n'
	aeTextString = aeTextString .. '	var mediaFolder = createNewFolder("Media");\n'
	aeTextString = aeTextString .. '	var compFolder = createNewFolder("Comps");\n'
	aeTextString = aeTextString .. '	\n'
	
	aeTextString = aeTextString .. '	// Load in the Fusion Loader and Saver node images\n'
	aeTextString = aeTextString .. '	\n'
	
	aeTextString = aeTextString .. '	// Create a new comp\n'
	aeTextString = aeTextString .. '	var newComp' .. compIndex .. ' = createNewComp("' .. compName .. '", ' .. compWidth .. ', ' .. compHeight .. ', ' .. compDuration .. ', compFolder);\n'
	aeTextString = aeTextString .. '\n'
	
	 -- Add the background solid
	aeTextString = aeTextString .. '	// Add the background solid\n'
	aeTextString = aeTextString .. '	addSolidBackground(newComp' .. compIndex .. ');\n'
	aeTextString = aeTextString .. '\n'
	
	-- Check the active selection and return a list of AE media files
	aeTextString = aeTextString .. GenerateAEMediaList(compIndex)
	
	-- ----------------------------------------------------------------------
	
	aeTextString = aeTextString .. '	// Show the comp\n'
	aeTextString = aeTextString .. '	showComp(newComp' .. compIndex .. ');\n'
	
	-- Close the import function
	aeTextString = aeTextString .. '}\n'
	
	-- Show the comp function
	aeTextString = aeTextString .. '\n'
	aeTextString = aeTextString .. '// Show the comp\n'
	aeTextString = aeTextString .. 'function showComp(comp){\n'
	aeTextString = aeTextString .. '	comp.openInViewer();\n'
	aeTextString = aeTextString .. '\n'
	
	aeTextString = aeTextString .. '	// Adjust the Selection\n'
	aeTextString = aeTextString .. '	for (var i = 1; i <= app.project.numItems; i++){ \n'
	aeTextString = aeTextString .. '		app.project.item(i).selected = false;\n'
	aeTextString = aeTextString .. '	}\n'
	aeTextString = aeTextString .. '\n'
	
	aeTextString = aeTextString .. '	// Select the finished comp\n'
	aeTextString = aeTextString .. '	comp.selected = true;\n'
	aeTextString = aeTextString .. '}\n'
	
	-- ----------------------------------------------------------------------
	
	-- JSX Script filename with extension.
	scriptFilename = 'after_effects_comper.jsx'
	
	-- Find out the Fusion temporary directory path
	dirName = comp:MapPath('Temp:\\KartaVR\\')
	
	-- Create the temporary directory 
	os.execute('mkdir "' .. dirName.. '"')
	
	-- Create the jsx filepath
	scriptFilepath = dirName .. scriptFilename
	
	-- Open the JSX Script file for writing
	jsxFile = io.open(scriptFilepath, 'w')
	jsxFile:write(aeTextString)
	jsxFile:close()
	
	-- Display the output filepath
	print('[Created a new Adobe JSX Script] ' .. scriptFilepath .. '\n')
	
	-- List the full AE Comper script text
	print('[AE Comper Script] ' .. aeTextString)
	
	-- Open the Viewer tool
	if platform == 'Windows' then
		-- Running on Windows
		afterEffectsVersion = getPreferenceData('KartaVR.SendMedia.AfterEffectsVersion', 10, printStatus)
		
		if afterEffectsVersion == 0 then
			-- Adobe After Effects CS3
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CS3\\Support Files\\AfterFX.exe'
		elseif afterEffectsVersion == 1 then
			-- Adobe After Effects CS4
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CS4\\Support Files\\AfterFX.exe'
		elseif afterEffectsVersion == 2 then
			-- Adobe After Effects CS5
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CS5\\Support Files\\AfterFX.exe'
		elseif afterEffectsVersion == 3 then
			-- Adobe After Effects CS6
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CS6\\Support Files\\AfterFX.exe'
		elseif afterEffectsVersion == 4 then
			-- Adobe After Effects CC
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CC\\Support Files\\AfterFX.exe'
		elseif afterEffectsVersion == 5 then
			-- Adobe After Effects CC 2014
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CC 2014\\Support Files\\AfterFX.exe'
		elseif afterEffectsVersion == 6 then
			-- Adobe After Effects CC 2015
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CC 2015\\Support Files\\AfterFX.exe'
		elseif afterEffectsVersion == 7 then
			-- Adobe After Effects CC 2015.3
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CC 2015.3\\Support Files\\AfterFX.exe'
		elseif afterEffectsVersion == 8 then
			-- Adobe After Effects CC 2017
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CC 2017\\Support Files\\AfterFX.exe'
		elseif afterEffectsVersion == 9 then
			-- Adobe After Effects CC 2018
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CC 2018\\Support Files\\AfterFX.exe'
		elseif afterEffectsVersion == 10 then
			-- Adobe After Effects CC 2019
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CC 2019\\Support Files\\AfterFX.exe'
		else
			-- Fallback
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe After Effects CC 2019\\Support Files\\AfterFX.exe'
		end
		
		viewerProgram = defaultViewerProgram
		
		-- The After Effects Run script command is -r
		command = '"' .. viewerProgram .. '" -r ' .. scriptFilepath
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		afterEffectsVersion = getPreferenceData('KartaVR.SendMedia.AfterEffectsVersion', 10, printStatus)
		
		if afterEffectsVersion == 0 then
			-- Adobe After Effects CS3
			defaultViewerProgram = 'Adobe After Effects CS3'
		elseif afterEffectsVersion == 1 then
			-- Adobe After Effects CS4
			defaultViewerProgram = 'Adobe After Effects CS4'
		elseif afterEffectsVersion == 2 then
			-- Adobe After Effects CS5
			defaultViewerProgram = 'Adobe After Effects CS5'
		elseif afterEffectsVersion == 3 then
			-- Adobe After Effects CS6
			defaultViewerProgram = 'Adobe After Effects CS6'
		elseif afterEffectsVersion == 4 then
			-- Adobe After Effects CC
			defaultViewerProgram = 'Adobe After Effects CC'
		elseif afterEffectsVersion == 5 then
			-- Adobe After Effects CC 2014
			defaultViewerProgram = 'Adobe After Effects CC 2014'
		elseif afterEffectsVersion == 6 then
			-- Adobe After Effects CC 2015
			defaultViewerProgram = 'Adobe After Effects CC 2015'
		elseif afterEffectsVersion == 7 then
			-- Adobe After Effects CC 2015.3
			defaultViewerProgram = 'Adobe After Effects CC 2015'
		elseif afterEffectsVersion == 8 then
			-- Adobe After Effects CC 2017
			defaultViewerProgram = 'Adobe After Effects CC 2017'
		elseif afterEffectsVersion == 9 then
			-- Adobe After Effects CC 2018
			defaultViewerProgram = 'Adobe After Effects CC 2018'
		elseif afterEffectsVersion == 10 then
			-- Adobe After Effects CC 2019
			defaultViewerProgram = 'Adobe After Effects CC 2019'
		else
			-- Fallback
			defaultViewerProgram = 'Adobe After Effects CC 2019'
		end
		
		viewerProgram = defaultViewerProgram
		-- Use Apple Script from the command line to launch After Effects
		command = 'osascript -e "tell application \\"' .. viewerProgram .. '\\" to activate" -e "tell application \\"' .. viewerProgram .. '\\" to DoScriptFile ' .. ' \\"' .. scriptFilepath .. '\\"" ' .. '&'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		print('After Effects is not available for Linux yet.')
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

print ('Send Media to After Effects is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

-- Check if Fusion is running
if not fusion then
	print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
end

-- Lock the comp flow area
comp:Lock()

-- Launch the viewer tool
mediaViewerTool()

soundEffect = getPreferenceData('KartaVR.SendMedia.SoundEffect', 1, printStatus)
-- Play a sound effect
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
