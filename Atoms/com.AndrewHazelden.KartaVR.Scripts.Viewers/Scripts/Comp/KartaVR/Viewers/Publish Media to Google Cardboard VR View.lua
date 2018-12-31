--[[--
----------------------------------------------------------------------------
Publish Media to Google Cardboard VR View v4.0.1 for Fusion - 2018-12-31
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The Publish Media to Google Cardboard VR View script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that lets you customize the settings and generate a Google Cardboard VR View webpage.

How to use the Script:

Step 1. Install a HTTP based web sharing program like Apache, LAMP (LINUX), MAMP (Mac/Windows), or Uniform Server (Windows). You can still use the VR View feature without a webserver module if you set the "Web Sharing Folder" output to a folder with write permissions and then you view the index.html page in a web browser like Firefox.

Step 2. Start Fusion and open a new comp. Select saver or loader node based media in the flow area. If you select a node other than a loader or saver node a left viewport window snapshot will be created automatically.

Step 3. Run the Script > KartaVR > Publish Media to Google Cardboard VR View menu item. You can also run this script when the flow area is active with the "V" hotkey on your keyboard.

Step 3. In the "Publish Media to Google Cardboard VR View" dialog window you need to define the initial paths and settings for the script. Choose the "Web Sharing Folder", and enable the required checkbox if your panoramic images are Over/Under stereo 3D or not. Then click the "Ok" button.

--]]--

------------------------------------------------------------------------------
------------------------------------------------------------------------------

-- VR View Webpage Settings

-- Viewer Window Image Dimensions
-- Note: If you want to use a percent based size you need to use double %% characters to escape the % symbol in the variable.
vrviewWidth = '100%%'
vrviewHeight = '300px'

-- Print out extra debugging information
local printStatus = false

-- Find out if we are running Fusion 6, 7, 8, 9, or 15
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
local osSeparator = package.config:sub(1,1)

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

-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end


-- Escape the spaces and extended characters in a HTTP based URL string
-- Based upon the LUA example code: http://www.lua.org/pil/20.3.html
function encodeURL(textString)
	textString = string.gsub(textString, "([&=+%c])", function (c) return string.format("%%%02X", string.byte(c)) end)
	textString = string.gsub(textString, " ", "+")
	return textString
end


-- Open a web browser window up with the webpage
-- Note: The separator between the URL and the webpage has to be present
function openBrowser()
	command = nil
	
	webpage = ''
	
	if platform == 'Windows' then
		-- Running on Windows
		webpage = webURL .. 'index.html'
		command = 'explorer "' .. webpage .. '"'
		-- command = '"' .. webpage .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		webpage = webURL .. 'index.html'
		command = 'open "' .. webpage .. '" &'
					
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		webpage = webURL .. 'index.html'
		command = 'xdg-open "' .. webpage .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
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
	elseif platform == "Linux" then
		-- Running on Linux
		command = 'nautilus "' .. dir .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


-- Open a file and perform a regular expressions based find & replace
function regexFile(inFilepath, searchString, replaceString)
	print('[' .. inFilepath .. '] [Find] ' .. searchString .. ' [Replace] ' .. replaceString)
	
	-- Trimmed filename without the directory path
	justFilename = getFilename(inFilepath)
	
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	os.execute('mkdir "' .. outputDirectory..'"')
	
	-- Save a copy of the text file being edited in the $TEMP/KartaVR/ folder
	tempFile = outputDirectory .. justFilename .. '.temp'
	-- print('[Temp File] ' .. tempFile)
	
	-- Open up the file pointer for the output textfile
	outFile, err = io.open(tempFile,'w')
	if err then 
		print('[Error Opening File for Writing]')
		return
	end
	
	-- Scan through the input textfile line by line
	counter = 0
	lineCounter = 0
	for oneLine in io.lines(inFilepath) do
		-- Check if we have found a match with the searchString
		if oneLine:match(searchString) then
			-- Track the number of edits done
			counter = counter + 1
			
			-- Perform the regular expressions based line edit
			oneLine = oneLine:gsub(searchString, replaceString)
			
			-- Debug print out the line number and text we are editing
			-- print('[' .. counter .. '][Matched] ' .. oneLine .. ' [Search] ' .. searchString .. ' [Replace] ' .. replaceString)
		end
		
		-- Track the progress through the file
		lineCounter = lineCounter + 1
		-- print('[' .. lineCounter .. '] ' .. oneLine)
		
		-- Write the line entry to the output file
		if platform == 'Windows' then
			-- Add a newline character
			outFile:write(oneLine,'\n')
		else
			-- Mac and Linux
			outFile:write(oneLine,'\n')
			
			-- Skip adding the newline character
			-- outFile:write(oneLine)
		end
	end
	
	-- print('[End of File] ' .. lineCounter)
	
	-- Close the file pointer on our input and output textfiles
	outFile:close()
	
	-- Copy the temp file back into the orignal document
	-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8 "bmd.scriptlib" libraries
	copyFile(tempFile, inFilepath)
	print('[Copy File] [From] ' .. tempFile .. ' [To] ' .. inFilepath)
	
	--	if platform == 'Windows' then
	--		command = 'copy /Y "' .. tempFile .. '" "' .. inFilepath .. '" '
	--	else
	--		-- Mac / Linux
	--		command = 'cp "' .. tempFile .. '" "' .. inFilepath .. '" '
	--	end
	--	-- print('[Copy File Command] ' .. command)
	--	os.execute(command)
	
	-- Return a total of how many times a string match was found
	return counter
end


-- Copy text to the operating system's clipboard
-- Example: CopyToClipboard('http://127.0.0.1:8888/index.html')
function CopyToClipboard(textString)
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	clipboardTempFile = outputDirectory .. 'clipboardText.txt'
	
	-- Open up the file pointer for the output textfile
	outClipFile, err = io.open(clipboardTempFile,'w')
	if err then 
		print('[Error Opening Clipboard Temporary File for Writing]')
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


-- Create the VR View webpage by processing the template
function processTemplate()
	-- Copy the VR View Media to the web publishing folder
	-- Todo: Copy the data folder, and the vr_view.html file
	-- Todo: Process the template file and render out the media files
	
	vrviewTemplatePath = comp:MapPath('Reactor:/Deploy/Bin/KartaVR/vr_view/')
	
	-- Create the Web Sharing folder if required
	os.execute('mkdir "' .. webSharingFolder..'"')
	
	if webTemplate == 0 then
		-- Custom Template
		templateNamePrefix = 'custom'
		print('The Custom Template was selected: ' .. webTemplate)
	elseif webTemplate == 1 then
		-- Charcoal Template
		templateNamePrefix = 'charcoal'
		print('The Charcoal Template was selected: ' .. webTemplate)
	else
		-- Midnight Template
		templateNamePrefix = 'midnight'
		print('The Midnight Template was selected: ' .. webTemplate)
	end
	
	-- Copy the template files
	sourceTemplateHTMLFile = vrviewTemplatePath .. templateNamePrefix .. '_template.html'
	sourceTemplateCSSFile = vrviewTemplatePath .. templateNamePrefix .. '_template.css'
	sourceVrviewFile = vrviewTemplatePath .. 'vr_view.html'
	sourceDataDir = vrviewTemplatePath .. 'data'
	
	destinationTemplateHTMLFile = webSharingFolder .. 'index.html'
	destinationTemplateCSSFile = webSharingFolder .. templateNamePrefix .. '_template.css'
	destinationVrviewFile = webSharingFolder .. 'vr_view.html'
	-- destinationDataDir = webSharingFolder .. 'data'
	
	-- Copy the template into the web sharing folder's index.html file
	-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8 "bmd.scriptlib" libraries
	copyFile(sourceTemplateHTMLFile, destinationTemplateHTMLFile)
	print('[Copy HTML File] [From] ' .. sourceTemplateHTMLFile .. ' [To] ' .. destinationTemplateHTMLFile)
	
	copyFile(sourceTemplateCSSFile, destinationTemplateCSSFile)
	print('[Copy CSS File] [From] ' .. sourceTemplateCSSFile .. ' [To] ' .. destinationTemplateCSSFile)
	
	copyFile(sourceVrviewFile, destinationVrviewFile)
	print('[Copy Vr View iFrame File] [From] ' .. sourceVrviewFile .. ' [To] ' .. destinationVrviewFile)
	
	-- Copy the Google VR View webpage elements
	if platform == 'Windows' then
	-- Copy the data directory
	destinationDataDir = webSharingFolder .. 'data' .. osSeparator
	command = 'Xcopy /E /I /Y "' .. sourceDataDir .. '" "' .. destinationDataDir .. '" '
	print('[Copy Data Directory Command] ' .. command)
	os.execute(command)
	else
	-- Copy the data directory
	destinationDataDir = webSharingFolder .. osSeparator 
	command = 'cp -R "' .. sourceDataDir .. '" "' .. destinationDataDir .. '" '
	print('[Copy Data Directory Command] ' .. command)
	os.execute(command)
	end
	
	-- Get the name of the Fusion .comp file
	compName = getFilename(comp:GetAttrs().COMPS_FileName)
	if compName ~= nil then
		-- The comp has been saved to disk and has a name
		compName = '"' .. compName .. '"'
	else
		-- The comp has not been saved to disk yet
		compName = '"Untitled Comp"'
	end
	
	-- Create the sub directory where the VR View media files are placed relative to the generated index.html file
	mediaSubfolder = 'media'
	os.execute('mkdir "' .. webSharingFolder .. mediaSubfolder ..'"')
	
	-- Web Page VR View Header Block Elements
	webpageString = vrviewHeader
	webpageString = webpageString .. vrviewIntroParagraph
	webpageString = webpageString .. '		<!-- Start of VR View Media Elements -->\n\n'
	
	-- Check if the media file is in stereo 3D
	if mediaIsStereo == 1 then
		-- This is a stereo 3D view
		vrviewIsStereo = 'true'
	else
		-- This is a 2D mono view
		vrviewIsStereo = 'false'
	end
	
	
	-- This is the file format that will be used when a Fusion node is snapshotted in the viewer window and saved to disk 
	local viewportSnapshotImageFormat = ''
	if imageFormat == 0 then
		viewportSnapshotImageFormat = 'jpg'
	elseif imageFormat == 1 then
		viewportSnapshotImageFormat = 'png'
	else
		viewportSnapshotImageFormat = 'jpg'
	end
	
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
		
		-- List the selected Node in Fusion 
		selectedNode = comp.ActiveTool
		
		if selectedNode then
			print('[Selected Node] ', selectedNode.Name)
			
			-- Create the final web publishing media filename
			destinationMediaFile = webSharingFolder .. mediaSubfolder .. osSeparator .. 'kvr_'	.. selectedNode.Name .. '.' .. viewportSnapshotImageFormat
			
			if fu_major_version >= 15 then
			-- Resolve 15 workflow for saving an image
			comp:GetPreviewList().LeftView.View.CurrentViewer:SaveFile(destinationMediaFile)
			elseif fu_major_version >= 8 then
				-- Fusion 8 workflow for saving an image
				comp:GetPreviewList().Left.View.CurrentViewer:SaveFile(destinationMediaFile)
			else
				-- Fusion 7 workflow for saving an image
				-- Save the image in the Viewer A buffer
				comp.CurrentFrame.LeftView.CurrentViewer:SaveFile(destinationMediaFile)
			end
			
			-- Extract the base media filename without the path
			mediaFilename = getFilename(destinationMediaFile)
			
			-- Everything worked fine and an image was saved
			print('[Saved Image] ', destinationMediaFile, ' [Selected Node] ', selectedNode.Name)
			
			mediaExtension = getExtension(mediaFilename)
			if mediaExtension and mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
				mediaType = 'video'
				print('[The ' .. mediaFilename .. ' media file was detected as a movie format.]')
			else
				mediaType = 'image'
				print('[The ' .. mediaFilename .. ' media file was detected as an image format.]')
			end
			
			webpageString = webpageString .. '		<h2>' .. mediaFilename .. '</h2>\n'
			webpageString = webpageString .. '		<iframe width="' .. vrviewWidth .. '" height="' .. vrviewHeight .. '" allowfullscreen frameborder="0" src="vr_view.html?' .. mediaType .. '=' .. mediaSubfolder .. '/' .. encodeURL(mediaFilename) .. '&is_stereo=' .. vrviewIsStereo .. '&start_yaw=' .. startYawAngle .. '"></iframe>\n\n'
		
		else
			-- Nothing was selected at all in the comp!
			
			-- Regular Expressions search & replace the [vrview] tag in the HTML template file
			searchString = '%[vrview%]'
			replaceString = '<h2>No Media Selected in Fusion</h2>\n<p>There were no active nodes selected when the publishing tool was run. Please select loader or saver nodes in your Fusion composite and then run the <strong>Publish Media to Google Cardboard VR View</strong> script again.</p>\n\n'
			regexFile(destinationTemplateHTMLFile, searchString, replaceString)
			
			-- Exit this function instantly on error
			return
		end
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
				print('[Send Media - Use Current Frame] Disabled')
				-- sourceMediaFile = comp:MapPath(tool:GetAttrs().TOOLST_Clip_Name[1])
				sourceMediaFile = comp:MapPath(tool.Clip[fu.TIME_UNDEFINED])
				-- filenameClip = (eyeon.parseFilename(toolClip))
			end
			
			print('[' .. toolAttrs .. ' Name] ' .. nodeName .. ' [Image Filename] ' .. sourceMediaFile)
			
			-- Extract the base media filename without the path
			mediaFilename = getFilename(sourceMediaFile)
			
			-- Create the final web publishing media filename
			destinationMediaFile = webSharingFolder .. mediaSubfolder .. osSeparator .. getFilename(sourceMediaFile)
			
			copyFile(sourceMediaFile, destinationMediaFile)
			print('[Copy Media File] [From] ' .. sourceMediaFile .. ' [To] ' .. destinationMediaFile)
			
			mediaExtension = getExtension(mediaFilename)
			if mediaExtension and mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
				mediaType = 'video'
				print('[The ' .. mediaFilename .. ' media file was detected as a movie format.]')
			else
				mediaType = 'image'
				print('[The ' .. mediaFilename .. ' media file was detected as an image format.]')
			end
			
			webpageString = webpageString .. '		<h2>' .. mediaFilename .. '</h2>\n'
			webpageString = webpageString .. '		<iframe width="' .. vrviewWidth .. '" height="' .. vrviewHeight .. '" allowfullscreen frameborder="0" src="vr_view.html?' .. mediaType .. '=' .. mediaSubfolder .. '/' .. encodeURL(mediaFilename) .. '&is_stereo=' .. vrviewIsStereo .. '&start_yaw=' .. startYawAngle .. '"></iframe>\n\n'
	end
	
	-- Iterate through each of the saver nodes
	for i, tool in ipairs(toollist2) do 
			toolAttrs = tool:GetAttrs().TOOLS_RegID
			nodeName = tool:GetAttrs().TOOLS_Name
		
			-- sourceMediaFile = comp:MapPath(tool:GetAttrs().TOOLST_Clip_Name[1])
			sourceMediaFile = comp:MapPath(tool.Clip[fu.TIME_UNDEFINED])
			-- filenameClip = (eyeon.parseFilename(toolClip))
			
			print('[' .. toolAttrs .. ' Name] ' .. nodeName .. ' [Image Filename] ' .. sourceMediaFile)
			
			-- Extract the base media filename without the path
			mediaFilename = getFilename(sourceMediaFile)
			
			-- Create the final web publishing media filename
			destinationMediaFile = webSharingFolder .. mediaSubfolder .. osSeparator .. getFilename(sourceMediaFile)
			
			copyFile(sourceMediaFile, destinationMediaFile)
			print('[Copy Media File] [From] ' .. sourceMediaFile .. ' [To] ' .. destinationMediaFile)
			
			-- File size in MB
			mediaFileSize = ' '
			-- mediaFileSize = ' (' .. '4.4 MB' .. ') '
			
			mediaExtension = getExtension(mediaFilename)
			if mediaExtension and mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
				mediaType = 'video'
				print('[The ' .. mediaFilename .. ' media file was detected as a movie format.]')
			else
				mediaType = 'image'
				print('[The ' .. mediaFilename .. ' media file was detected as an image format.]')
			end
			
			webpageString = webpageString .. '		<h2>' .. mediaFilename .. '</h2>\n'
			webpageString = webpageString .. '		<iframe width="' .. vrviewWidth .. '" height="' .. vrviewHeight .. '" allowfullscreen frameborder="0" src="vr_view.html?' .. mediaType .. '=' .. mediaSubfolder .. '/' .. mediaFilename .. '&is_stereo=' .. vrviewIsStereo .. '&start_yaw=' .. startYawAngle .. '"></iframe>\n'		 
	end
	
	webpageString = webpageString .. '		<!-- End of VR View Media Elements -->\n'
	
	-- -------------------------------------------
	-- End adding each image and movie element
	-- -------------------------------------------
	
	-- Regular Expressions search & replace the [vrview] tag in the HTML template file
	searchString = '%[vrview%]'
	replaceString = webpageString
	regexFile(destinationTemplateHTMLFile, searchString, replaceString)
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


-- Get the name of the Fusion .comp file
compName = getFilename(comp:GetAttrs().COMPS_FileName)
if compName ~= nil then
	-- The comp has been saved to disk and has a name
	compName = '"' .. compName .. '"'
else
	-- The comp has not been saved to disk yet
	compName = '"Untitled Comp"'
end

-- VR View Header Block Element
vrviewHeader = '<h1>VR View - ' .. compName .. '</h1>\n'

-- VR View Page Introduction text
vrviewIntroParagraph = '		<p>The VR View webpage allows you to explore panoramic imagery in your web browser or with a Google Cardboard HMD.</p>\n\n'


print('Publish Media to Google Cardboard VR View is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

-- Check if Fusion is running
if not fusion then
	print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
end

-- Lock the comp flow area
comp:Lock()

-- ------------------------------------
-- Load the preferences
-- ------------------------------------

msg = 'Customize the Google Cardboard VR View settings.'

-- Image format List
formatList = {'JPEG', 'PNG'}

-- Sound Effect List
soundEffectList = {'None', 'On Error Only', 'Steam Train Whistle Sound', 'Trumpet Sound', 'Braam Sound'}

-- Web Template List
webTemplateList = {'Custom Template', 'Charcoal Template', 'Midnight Template'}

-- Find out the Machine's local IP address
-- localhostIP = "127.0.0.1"
-- localhostDNS = "blk-255-255-255.eastlink.ca"

if platform == 'Windows' then
	-- webURL = 'http://localhost:8888/'
	-- webURL = 'http://localhost:8080/'
	-- webURL = 'http://localhost:8081/'
	-- webURL = 'http://localhost:80/'
	-- webURL = 'http://localhost:81/'
	webURL = 'http://localhost/'
	
	webSharingFolder = comp:MapPath('C:\\MAMP\\htdocs\\')
	-- webSharingFolder = comp:MapPath('C:\\UniServerZ\\www\\')
elseif platform == 'Mac' then
	webURL = 'http://localhost:8888/'
	-- webURL = 'http://localhost/'
	
	webSharingFolder = comp:MapPath('/Applications/MAMP/htdocs/')
	-- webSharingFolder = comp:MapPath('/Library/WebServer/Documents/')
	-- webSharingFolder = comp:MapPath('~/Sites/')
else
	-- Linux
	-- webURL = 'http://localhost:8888/'
	webURL = 'http://localhost/'
	
	webSharingFolder = comp:MapPath('/var/www/html/')
end


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


imageFormat = getPreferenceData('KartaVR.PublishVRView.Format', 0, printStatus)
soundEffect = getPreferenceData('KartaVR.PublishVRView.SoundEffect', 1, printStatus)
useCurrentFrame = getPreferenceData('KartaVR.PublishVRView.UseCurrentFrame', 1, printStatus)
-- scaleImageRatio = getPreferenceData('KartaVR.PublishVRView.ScaleImageRatio', 1, printStatus)
copyURLToClipboard = getPreferenceData('KartaVR.PublishVRView.CopyURLToClipboard', 1, printStatus)
mediaIsStereo = getPreferenceData('KartaVR.PublishVRView.MediaIsStereo', 0, printStatus)
webTemplate = getPreferenceData('KartaVR.PublishVRView.WebTemplate', 2, printStatus)
openPublishingFolder = getPreferenceData('KartaVR.PublishVRView.OpenPublishingFolder', 1, printStatus)
openWebpage = getPreferenceData('KartaVR.PublishVRView.OpenWebpage', 1, printStatus)
webURL = getPreferenceData('KartaVR.PublishVRView.WebURL', webURL, printStatus)
webSharingFolder = getPreferenceData('KartaVR.PublishVRView.WebSharingFolder', webSharingFolder, printStatus)

startYawAngle = getPreferenceData('KartaVR.PublishVRView.StartYawAngle', 0, printStatus)

d = {}
d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg}
d[2] = {'Format', Name = 'Image Format', 'Dropdown', Default = imageFormat, Options = formatList }
d[3] = {'SoundEffect', Name = 'Sound Effect', 'Dropdown', Default = soundEffect, Options = soundEffectList}
-- d[4] = {'LocalhostIP', Name = 'Localhost IP (Read Only)', 'Text', ReadOnly = true, Lines = 1, Default = localhostIP}
-- d[5] = {'LocalhostDNS', Name = 'Localhost DNS (Read Only)', 'Text', ReadOnly = true, Lines = 1, Default = localhostDNS}
d[4] = {'WebSharingFolder', Name = 'Web Sharing Folder', browseMode, Lines = 1, Default = webSharingFolder}
d[5] = {'WebURL', Name = 'Web URL', 'Text', Lines = 1, Default = webURL}
d[6] = {'WebTemplate', Name = 'Web Template', 'Dropdown', Default = webTemplate, Options = webTemplateList}
d[7] = {'StartYawAngle', Name = 'Starting Yaw Angle', 'Screw', Default = startYawAngle, Min = -360, Max = 360}
d[8] = {'UseCurrentFrame', Name = 'Use Current Frame', 'Checkbox', Default = useCurrentFrame, NumAcross = 1}
d[9] = {'MediaIsStereo', Name = 'Media is Over/Under Stereo 3D', 'Checkbox', Default = mediaIsStereo, NumAcross = 1}
-- d[12] = {'ScaleImageRatio', Name = 'Scale Image Ratio to 1:1', 'Checkbox', Default = scaleImageRatio, NumAcross = 1}
d[10] = {'CopyURLToClipboard', Name = 'Copy URL to Clipboard', 'Checkbox', Default = copyURLToClipboard, NumAcross = 1}
d[11] = {'OpenPublishingFolder', Name = 'Open Publishing Folder', 'Checkbox', Default = openPublishingFolder, NumAcross = 1}
d[12] = {'OpenWebpage', Name = 'Open Webpage', 'Checkbox', Default = openWebpage, NumAcross = 0}


dialog = comp:AskUser('Publish Media to Google Cardboard VR View', d)
if dialog == nil then
	print('You cancelled the dialog!')
	
	-- Unlock the comp flow area
	comp:Unlock()
	
	-- Exit the script
	return
else
	-- Debug - List the output from the AskUser dialog window
	dump(dialog)
	
	imageFormat = dialog.Format
	setPreferenceData('KartaVR.PublishVRView.Format', imageFormat, printStatus)
	
	soundEffect = dialog.SoundEffect
	setPreferenceData('KartaVR.PublishVRView.SoundEffect', soundEffect, printStatus)
	
	webSharingFolder = comp:MapPath(dialog.WebSharingFolder)
	setPreferenceData('KartaVR.PublishVRView.WebSharingFolder', webSharingFolder, printStatus)
	
	webURL = dialog.WebURL
	setPreferenceData('KartaVR.PublishVRView.WebURL', webURL, printStatus)
	
	webTemplate = dialog.WebTemplate
	setPreferenceData('KartaVR.PublishVRView.WebTemplate', webTemplate, printStatus)
	
	startYawAngle = dialog.StartYawAngle
	setPreferenceData('KartaVR.PublishVRView.StartYawAngle', startYawAngle, printStatus)
	
	useCurrentFrame = dialog.UseCurrentFrame
	setPreferenceData('KartaVR.PublishVRView.UseCurrentFrame', useCurrentFrame, printStatus)
	
	mediaIsStereo = dialog.MediaIsStereo
	setPreferenceData('KartaVR.PublishVRView.MediaIsStereo', mediaIsStereo, printStatus)
	
--	scaleImageRatio = dialog.ScaleImageRatio
--	setPreferenceData('KartaVR.PublishVRView.ScaleImageRatio', scaleImageRatio, printStatus)
	
	copyURLToClipboard = dialog.CopyURLToClipboard
	setPreferenceData('KartaVR.PublishVRView.CopyURLToClipboard', copyURLToClipboard, printStatus)
	
	openPublishingFolder = dialog.OpenPublishingFolder
	setPreferenceData('KartaVR.PublishVRView.OpenPublishingFolder', openPublishingFolder, printStatus)
	
	openWebpage = dialog.OpenWebpage
	setPreferenceData('KartaVR.PublishVRView.OpenWebpage', openWebpage, printStatus)
end


-- Create the VR View webpage by processing the template
processTemplate()

-- Open a web browser window up with the webpage
if openWebpage == 1 then
	print('Opening the webpage in your web browser: ' .. openWebpage)
	openBrowser()
else
	print('Skipping the loading of the webpage in your web browser: ' .. openWebpage)
end


-- Open the publishing folder as an Explorer/Finder/Nautilus folder view
if openPublishingFolder == 1 then
	if webSharingFolder ~= nil then
		if fu_major_version >= 8 then
			-- The script is running on Fusion 8+ so we will use the fileexists command
			if eyeon.fileexists(webSharingFolder) then
				openDirectory(webSharingFolder)
			else
				print('[Web Sharing Directory Missing] ', webSharingFolder)
				err = true
			end
		else
			-- The script is running on Fusion 6/7 so we will use the direxists command
			if eyeon.direxists(webSharingFolder) then
				openDirectory(webSharingFolder)
			else
				print('[Web Sharing Directory Missing] ', webSharingFolder)
				err = true
			end
		end
	end
end


-- Copy the web URL text to the Operating System's clipboard
if copyURLToClipboard == 1 then
	CopyToClipboard(webURL .. 'index.html')
end


-- Play a sound effect
soundEffect = getPreferenceData('KartaVR.PublishVRView.SoundEffect', 1, printStatus)
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
