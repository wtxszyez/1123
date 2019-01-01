--[[--
----------------------------------------------------------------------------
PTGui Project Importer v4.0.1 2019-01-01
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------

Overview:

The PTGui Project Importer script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that will load the source image data from a PTGui .pts project file and create a node based panoramic 360° stitching composite.

How to use the Script:

Step 1. Start Fusion and open a new comp. Then run the "Script > KartaVR > Stitching > PTGui Project Importer" menu item.

Step 2. In the PTGui Project Importer dialog window you need to select a PTGui .pts file using the "PTGui Project File" text field. After customizing the settings you can click the "OK" button to load each of the images.


Note: Fusion does not read in or interpret EXIF image rotation metadata. You need to bake in and flatten the EXIF image rotation value into the image and remove that metadata setting in advance if you want PTGui and Fusion to use the exact same portrait/landscape style rotation setting when importing the imagery into a composite.

Todo:

	- The intermediate saver view# element should really be frame padded in the future.
	- Detect the PTGui simple mode (which means no cropping has been applied since that requires the advanced tab to be used)
	- Detect frame extension and try to adjust the frame range so Fusion can load it correctly (name.ext or name.0000.ext or name.0001.ext)
	- modify the function checkFrameExtension() to trim off a leading number and use that as the frame extension so random video frame numbers like name.0999.ext become starting frame 999.
	- Look at expression scripting/Lua and use quaternions or slerp spherical linear interpolations to avoid gimbal lock on the roll axis.

--------------------------------------------------------
Script settings you can Tweak:

Should a vector line for the camera3D viewing angle be displayed?
showCamera3DViewVector = 1
showCamera3DViewVector = 0

Should the "Intermediate Saver Nodes" be set to use a passthrough state when they are added to the comp?

Setting this attribute to "true" will disable the saver node in the comp by default when the PTGui Project Importer script runs. Setting it to 'false' will make the new saver nodes active and enabled when they are added to the comp.

intermediateSaverNodePassThrough = 'true';
intermediateSaverNodePassThrough = 'false';

--]]--

-- Display the extra debugging verbosity detail in the console log
-- printStatus = true
printStatus = false

-- Track if the image was found
local err = false

-- Global variable to track how many images were found in the PTGui project file
totalFrames = 0

-- Find out if we are running Fusion 7, 8, 9, or 15
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Get the file extension from a filepath
function getExtension(mediaDirName)
	local extension = ''
	if mediaDirName then
		extension = string.match(mediaDirName, '(%..+)$')
	end
	
	return extension or ''
end

-- Get the base filename from a filepath
function getFilename(mediaDirName)
	local path, basename = ''
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
	end
	
	return basename or ''
end

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

-- Get the file path
function getPath(mediaDirName)
	local path, basename
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
	end
	
	return path or ''
end

-- Remove the trailing file extension off a filepath
function trimExtension(mediaDirName)
	local path, basename
	if mediaDirName then
		path, basename = string.match(mediaDirName, '^(.+[/\\])(.+)')
	end
	return path or '' .. basename or ''
end

-- Check if Resolve is running and then disable relative filepaths
host = app:MapPath('Fusion:/')
if string.lower(host):match('resolve') then
	hostOS = 'Resolve'
else
	hostOS = 'Fusion'
end

-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
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
-- Example: playWaveAudio('trumpet-fanfare.wav')
-- or if you want to see debugging text use:
-- Example: playWaveAudio('trumpet-fanfare.wav', true)
function playDFMWaveAudio(filename, status)
	if status == true or status == 1 then 
		print('[Base Audio File] ' .. filename)
	end
	
	local audioFilePath = ''
	
	if platform == 'Windows' then
		-- Note Windows Powershell is very lame and it really really needs you to escape each space in a filepath with a backtick ` character or it simply won't work!
		audioFolderPath = comp:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
		-- audioFolderPath = '$env:ProgramData\\Blackmagic Design\\Fusion\\Reactor\\Deploy\\Bin\\KartaVR\\audio\\'
		audioFilePath = audioFolderPath .. filename
		command = 'powershell -c (New-Object Media.SoundPlayer "' .. string.gsub(audioFilePath, ' ', '` ') .. '").PlaySync();'
		
		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end
		-- Verify the audio files were installed
		if eyeon.fileexists(audioFilePath) then
			os.execute(command)
		else
			print('[Please install the KartaVR/KartaVR Audio Reactor Package]\n\t[Audio File Missing] ', audioFilePath)
			err = true
		end
	elseif platform == 'Mac' then
		audioFolderPath = comp:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
		audioFilePath = audioFolderPath .. filename
		command = 'afplay "' .. audioFilePath ..'" &'
		
		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end
		-- Verify the audio files were installed
		if eyeon.fileexists(audioFilePath) then
			os.execute(command)
		else
			print('[Please install the KartaVR/KartaVR Audio Reactor Package]\n\t[Audio File Missing] ', audioFilePath)
			err = true
		end
	elseif platform == 'Linux' then
		audioFolderPath = comp:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
		audioFilePath = audioFolderPath .. filename
		command = 'xdg-open "' .. audioFilePath ..'" &'
		
		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end
		
		-- Verify the audio files were installed
		if eyeon.fileexists(audioFilePath) then
			os.execute(command)
		else
			print('[Please install the KartaVR/KartaVR Audio Reactor Package]\n\t[Audio File Missing] ', audioFilePath)
			err = true
		end
	else
		-- Windows Fallback
		audioFolderPath = comp:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
		-- audioFolderPath = '$env:ProgramData\\Blackmagic Design\\Fusion\\Reactor\\Deploy\\Bin\\KartaVR\\audio\\'
		audioFilePath = audioFolderPath .. filename
		command = 'powershell -c (New-Object Media.SoundPlayer "' .. string.gsub(audioFilePath, ' ', '` ') ..'").PlaySync();'
		
		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end
		-- Verify the audio files were installed
		if eyeon.fileexists(audioFilePath) then
			os.execute(command)
		else
			print('[Please install the KartaVR/KartaVR Audio Reactor Package]\n\t[Audio File Missing] ', audioFilePath)
			err = true
		end
	end
	
	if status == true or status == 1 then 
		print('[Playing a KartaVR based sound file using System] ' .. audioFilePath)
	end
end


-- Play a sound effect
function CompletedSound()
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
end


-- Rewrite the image paths to use the relative Comp:/ prefix
-- Example: relativePath = ConvertToRelativePathMap('/Media/CameraA.0001.tif', comp:GetAttrs().COMPS_FileName, 'Comp:/')
function ConvertToRelativePathMap(to, from, pathMap)
	-- "to" is the absolute image filepath you are starting with
	-- "from" is the filepath to the current project
	-- "pathMap" is the prefix added to the start of the resulting relative path

	-- Make sure the from address (the PathMap) is not empty
	-- If the string is empty is means the comp was never saved
	if string.len(from) == 0 then
		print('[Warning] Please save the current Fusion composite document. Since this file has not been saved yet the "Comp:/" PathMap can\'t be resovled!')
		print('[Result] ' .. to)
		return to
	end
	
	-- Put the "To" filename on the directory path of the "From" file
	from = dirname(from) .. getFilename(to)
	
	-- Check if the strings are identical
	if from == to then
		-- It's a match so Comp:/ is the same directory as the source image
		result = pathMap .. getFilename(to)
		print('[PathMap Result] ' .. result .. ' is in the same folder as the comp.')
		return result
	end
	
--	if printStatus == 1 or printStatus == true then
	print('[PathMap Source] ' .. from)
	print('[PathMap Destination] ' .. to)
--	end
	
	-- How to convert absolute path in relative path using LUA?
	-- http://stackoverflow.com/questions/13224664/how-to-convert-absolute-path-in-relative-path-using-lua
	
	min_len = math.min(to:len(), from:len())
	mismatch = 0
	if printStatus == 1 or printStatus == true then
		print('[Length] ' .. min_len)
	end
	
	for i = 1, min_len do
		if to:sub(i, i) ~= from:sub(i, i) then
			mismatch = i
			break
		end
	end
	
	-- Handle the edge cases
	-- Process the portions of the "From" and "To" filepaths that differ
	to_diff = to:sub(mismatch)
	from_diff = from:sub(mismatch)
	
	from_file = io.open(from)
	from_is_dir = false
	if (from_file) then
		-- Check if "From" is a directory
		result, err_msg, err_no = from_file:read(0)
		if (err_no == 21) then 
			-- File read rrror 21 is EISDIR which means "From" is a directory
			print('[File Error] The source file "' .. from .. '" is actually a directory.')
			
			-- from_is_dir = true
			
			-- print('[Result] ' .. to)
			-- return to
		end
	end
	
	result = ''
	for slash in from_diff:gmatch('/') do
		result = result .. '../'
	end
	
	if from_is_dir then
		result = result .. '../'
	end

	if min_len >= 1 then
		-- There was at least one replacement done
		result = pathMap .. result .. to_diff
	else
		-- No replacements were done
		result = result .. to_diff
	end

	-- Rewritten path result like 'Comp:/Media/image.jpg'
	print('[PathMap Source] ' .. from)
	print('[PathMap Result] ' .. result)
	return result
end


-- Find out if the filename has a frame padded number extension formatted like:
-- (0) <prefix>.ext, (1) <prefix>.0000.ext, or (2) <prefix>.0001.ext
-- Example: frameExtension, frameExtensionNumber, frameExtensionFusionStartFrame	= CheckFrameExtension('/media/image.0001.ext')
function CheckFrameExtension(filename)
	mediaExtension = getExtension(filename:lower())
	if mediaExtension:match('0%.') then
		-- Check for the final digit and the period to avoid frame padding
		
		-- Start the image sequence on frame 0
		frameExtension = 1 
		frameExtensionNumber = '.0000'
		frameExtensionFusionStartFrame = 0
		print('[Start Frame] 0 <prefix>.0000.ext')
	elseif mediaExtension:match('1%.') then
		-- Check for the final digit and the period to avoid frame padding
		
		-- Start the image sequence on frame 1
		frameExtension = 2
		frameExtensionNumber = '.0001'
		frameExtensionFusionStartFrame = 1
		print('[Start Frame] 1 <prefix>.0001.ext')
	else
		 -- None (skip adding a frame extension number)
		frameExtension = 0
		frameExtensionNumber = ''
		frameExtensionFusionStartFrame = -1
		print('[Start Frame] None <prefix>.ext')
	end
	
	return frameExtension, frameExtensionNumber, frameExtensionFusionStartFrame
end


-- Return either a file extension or the Fusion file format tag
-- Example: FusionMediaExt('input-01.0000.TIFF', 'format')
-- Example: FusionMediaExt('input-01.0000.TIFF', 'ext')
function FusionMediaExt(mediaFile, returnType)
	-- mediaFile = 'input-01.0000.TIFF'
	mediaExtension = getExtension(mediaFile:lower())
	
	imageFormatExt = ''
	imageFormatFusion = ''
	if mediaExtension:match('tif$') then
		imageFormatExt = 'tif'
		imageFormatFusion = 'TiffFormat'
	elseif mediaExtension:match('tiff$') then
		imageFormatExt = 'tiff'
		imageFormatFusion = 'TiffFormat'
	elseif mediaExtension:match('tga$') then
		imageFormatExt = 'tga'
		imageFormatFusion = 'TargaFormat'
	elseif mediaExtension:match('bmp$') then
		imageFormatExt = 'bmp'
		imageFormatFusion = 'BMPFormat'
	elseif mediaExtension:match('png$') then
		imageFormatExt = 'png'
		imageFormatFusion = 'PNGFormat'
	elseif mediaExtension:match('JPG$') then
		imageFormatExt = 'jpg'
		imageFormatFusion = 'JpegFormat'
	elseif mediaExtension:match('jpeg$') then
		imageFormatExt = 'jpeg'
		imageFormatFusion = 'JpegFormat'
	elseif mediaExtension:match('exr$') then
		imageFormatExt = 'exr'
		imageFormatFusion = 'ExrFormat'
	elseif mediaExtension:match('mp4$') then
		imageFormatExt = 'mp4'
		imageFormatFusion = 'QuickTimeMovies'
	elseif mediaExtension:match('m4v$') then
		imageFormatExt = 'm4v'
		imageFormatFusion = 'QuickTimeMovies'
	elseif mediaExtension:match('mov$') then
		imageFormatExt = 'mov'
		imageFormatFusion = 'QuickTimeMovies'
	else
		-- Fallback option
		imageFormatExt = 'jpeg'
		imageFormatFusion = 'JpegFormat'
	end
	
	-- print('[' .. mediaFile .. '] ' .. imageFormatExt)
	
	-- Check if the format or file extension should be returned
	if returnType == 'format' then
		-- Provide the Fusion media format tag used in loader and saver nodes
		return imageFormatFusion
	elseif returnType == 'ext' then
		-- Provide the cleaned up image extension
		return imageFormatExt
	else
		-- The fallback option is the fusion format
		return imageFormatFusion
	end
end


-- Open a file and perform a regular expressions based find & replace
function RegexFile(inFilepath, searchString, replaceString)
	print('[' .. inFilepath .. '] [Find] ' .. searchString .. ' [Replace] ' .. replaceString)
	
	-- Trimmed pts filename without the directory path
	ptsJustFilename = getFilename(inFilepath)
	
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	os.execute('mkdir "' .. outputDirectory..'"')
	
	-- Save a copy of the .pts file being edited in the $TEMP/KartaVR/ folder
	tempFile = outputDirectory .. ptsJustFilename .. '.temp'
	-- print('[Temp File] ' .. tempFile)
	
	-- Open up the file pointer for the output textfile
	outFile, err = io.open(tempFile,'w')
	if err then 
		print("[Error Opening File for Writing]")
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
	
	-- Check if Fusion Standalone or the Resolve Fusion page is active
	host = fusion:MapPath('Fusion:/')
	if string.lower(host):match('resolve') then
		hostOS = 'Resolve'
		-- Alternative OS native copy approach
		if platform == 'Windows' then
			command = 'copy /Y "' .. tempFile .. '" "' .. inFilepath .. '" '
		else
			-- Mac / Linux
			command = 'cp "' .. tempFile .. '" "' .. inFilepath .. '" '
		end
		print('[Copy PTS File] [From] ' .. tempFile .. ' [To] ' .. inFilepath)
	
		print('[Copy PTS File Command] ' .. command)
		os.execute(command)
	else
		hostOS = 'Fusion'
		-- Copy the temp file back into the orignal .pts document
		-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8/9 "bmd.scriptlib" libraries
		eyeon.copyfile(tempFile, inFilepath)
		print('[Copy PTS File] [From] ' .. tempFile .. ' [To] ' .. inFilepath)
	end
	
	-- Return a total of how many times a string match was found
	return counter
end
 

-- Extract the images
function ImageRegex(ptguiFile, framePadding, startOnFrameOne)
	-- Create a multi-dimensional table for the media and frame cropping data
	media = {}
	globalLens = {}
	crop = {}
	output = {}
	
	-- Newly edited .pts filename with the extension swapped and the directory removed
	ptsName = getFilenameNoExt(ptguiFile) .. '_temp.pts'
	
	-- .pts file directory
	ptsDir = dirname(ptguiFile)
	
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	os.execute('mkdir "' .. outputDirectory ..'"')
	
	-- Save a copy of the .pts file being edited in the $TEMP/KartaVR/ folder
	pts = outputDirectory .. ptsName
	print('[Temp File] ' .. pts)
	
	-- Save a copy of the edited PTGui .pts file
	if platform == 'Windows' then
		-- Running on Windows
		
		-- Make a copy of the .pts file
		print('[Copy PTS File] [From] ' .. ptguiFile .. ' [To] ' .. pts)
		
		-- Check if Fusion Standalone or the Resolve Fusion page is active
		host = fusion:MapPath('Fusion:/')
		if string.lower(host):match('resolve') then
			hostOS = 'Resolve'
			
			command = 'copy /Y "' .. ptguiFile .. '" "' .. pts .. '"'
			
			print('[Copy PTS File Command] ', command)
			os.execute(command)
		else
			hostOS = 'Fusion'
			-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8 "bmd.scriptlib" libraries
			eyeon.copyfile(ptguiFile, pts)
		end
	elseif platform == 'Mac' then
		-- Running on Mac
		
		print('[Copy PTS File] [From] ' .. ptguiFile .. ' [To] ' .. pts)
		-- Check if Fusion Standalone or the Resolve Fusion page is active
		host = fusion:MapPath('Fusion:/')
		if string.lower(host):match('resolve') then
			hostOS = 'Resolve'
			
			command = 'cp "' .. ptguiFile .. '" "' .. pts .. '" '
			print('[Copy PTS File Command] ', command)
			os.execute(command)
		else
			hostOS = 'Fusion'
			
			-- Make a copy of the .pts file
			-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8/9 "bmd.scriptlib" libraries
			eyeon.copyfile(ptguiFile, pts)
		end
	elseif platform == 'Linux' then
		-- Running on Linux
		
		print('[Copy PTS File] [From] ' .. ptguiFile .. ' [To] ' .. pts)
		-- Check if Fusion Standalone or the Resolve Fusion page is active
		host = fusion:MapPath('Fusion:/')
		if string.lower(host):match('resolve') then
			hostOS = 'Resolve'
			
			command = 'cp "' .. ptguiFile .. '" "' .. pts .. '" '
			print('[Copy PTS File Command] ', command)
			os.execute(command)
		else
			hostOS = 'Fusion'
			
			-- Make a copy of the .pts file
			-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8/9 "bmd.scriptlib" libraries
			eyeon.copyfile(ptguiFile, pts)
		end
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end

	-- ----------------------------------------
	-- ----------------------------------------

	-- #-imgfile 2048 1360 "input-01.0000.JPG"
	searchString = '#%-imgfile%s.*'
	print('[Scanning for imgfile Lines] ' .. searchString)
	-- Scan through the input textfile line by line
	imageCounter = 0
	lineCounter = 0
	for oneLine in io.lines(ptguiFile) do
		-- Check if we have found a match with the searchString
		if oneLine:match(searchString) then
			-- Track the number of edits done
			imageCounter = imageCounter + 1
			
			-- if printStatus == 1 or printStatus == true then
			--	 print('[Image ' .. imageCounter .. '] ' .. oneLine)
			-- end
			
			-- http://lua-users.org/wiki/PatternsTutorial
			width, height, sourceMediaFile = string.match(oneLine, '(%d+) (%d+) "(.+)"', 11)
			if sourceMediaFile ~= nil and width ~= nil and height ~= nil then
				-- Detect the file type
				mediaExtension = FusionMediaExt(sourceMediaFile, 'format')
				
				-- Node Name Loader1
				nodeName = 'ptLoader' .. imageCounter
				
				print('[Image ' .. imageCounter .. '] ' .. sourceMediaFile .. '\t[Image Size] ' .. width .. ' x ' .. height .. ' px' .. '\t [Format] ' .. mediaExtension)
				-- [Image 1]	[Name] photo.jpg	[Image Size] 2048 x 1360 px [Format] JpegFormat
				
				-- Define the source directory for each of the PTGui images
				sourceMediaDir = ptsDir
				
				media[imageCounter] = {id = imageCounter, nodename1 = nodeName, filepath2 = sourceMediaFile, folder3 = sourceMediaDir, extension5 = mediaExtension, width6 = width, height7 = height, lineNumber8 = lineCounter}
			end
		end
		
		-- Track the progress through the file
		lineCounter = lineCounter + 1
	end
	
	print('[End of File - #-imgfile Lines] ' .. lineCounter)
	
	-- ----------------------------------------
	-- ----------------------------------------
	
	-- o w1 h1 y0 r0 p0 v188.2614112237964 a0 b-0.02502104010657595 c0 f2 d0 e0 g0 t0
	searchString = '^o%sw.*'
	print('[Scanning for o - global lens Lines] ' .. searchString)

	-- Scan through the input textfile line by line
	globalLensCounter = 0
	lineCounter = 0
	for oneLine in io.lines(ptguiFile) do
		-- Check if we have found a match with the searchString
		if oneLine:match(searchString) then
			-- Track the number of edits done
			globalLensCounter = globalLensCounter + 1
			
			-- if printStatus == 1 or printStatus == true then
			-- 	print('[Global Lens ' .. globalLensCounter .. '] ' .. oneLine)
			-- end
			
			-- http://lua-users.org/wiki/PatternsTutorial
			globalFOV = string.match(oneLine, 'v([%w%-]+)')
			globalDistortA = string.match(oneLine, 'a([%w%-%.]+)')
			globalDistortB = string.match(oneLine, 'b([%w%-%.]+)')
			globalDistortC = string.match(oneLine, 'c([%w%-%.]+)')
				 
			if globalFOV ~= nil and globalDistortA ~= nil and globalDistortB ~= nil and globalDistortC ~= nil then
				print('[Global Lens ' .. globalLensCounter .. '] ' .. '\t[Horizontal FOV] ' .. globalFOV	.. '\t[Distort A] ' .. globalDistortA .. '\t[Distort B] ' .. globalDistortB .. '\t[Distort C] ' .. globalDistortC)
				-- [Global Lens 1] [Horizontal FOV] 180 [Distort A] 0 [Distort B] -0.025	[Distort C] 0
				
				globalLens[globalLensCounter] = {id = globalLensCounter, fov1 = globalFOV, a2 = globalDistortA, b3 = globalDistortB, c4 = globalDistortC}
			end
		end
		
		-- Track the progress through the file
		lineCounter = lineCounter + 1
	end
	
	print('[End of File o - global lens Lines] ' .. lineCounter)
	
	-- ----------------------------------------
	-- ----------------------------------------
	
	-- p w3840 h1920 f2 v360 u0 n"JPEG g0 q95"
	-- p w3840 h1920 f2 v360 u0 n"TIFF"
	searchString = 'p%sw.*'
	print('[Scanning for p - Output Lines] ' .. searchString)
	-- Scan through the output textfile line by line
	outputCounter = 0
	lineCounter = 0
	for oneLine in io.lines(ptguiFile) do
		-- Check if we have found a match with the searchString
		if oneLine:match(searchString) then
			-- Track the number of edits done
			outputCounter = outputCounter + 1
			
			-- if printStatus == 1 or printStatus == true then
			-- 	print('[Output ' .. outputCounter .. '] ' .. oneLine)
			-- end
			
			-- http://lua-users.org/wiki/PatternsTutorial
			outputWidth, outputHeight = string.match(oneLine, 'w(%d+)%sh(%d+)')
			outputFOV = string.match(oneLine, 'v([%w%-%.]+)')
			
			-- Work out the output file format
			rawFormat = string.match(oneLine, 'n"(%a+)')
			if rawFormat ~= nil then
				if rawFormat == 'TIFF' then
					outputFormat = 'TiffFormat'
					outputExtension = 'tif'
				elseif rawFormat == 'JPEG' then
					outputFormat = 'JpegFormat'
					outputExtension = 'jpg'
				elseif rawFormat == 'MOV' then
					outputFormat = 'QuickTimeMovies'
					outputExtension = 'mov'
				else
					-- Fallback option of Tiff
					outputFormat = 'TiffFormat'
					outputExtension = 'tif'
					print('[Output Format Fallback Selected] ' .. outputFormat .. '\t[Found] ' .. rawFormat)
				end
			else
				-- Fallback option of Tiff
				outputFormat = 'TiffFormat'
				outputExtension = 'tif'
				print('[Output Format Fallback Selected] ' .. outputFormat .. '\t[Found] nil')
			end
			
			if outputWidth ~= nil and outputHeight ~= nil and outputHeight ~= nil and outputFOV ~= nil then
				print('[Output ' .. outputCounter .. '] ' .. '\t[Width] ' .. outputWidth .. '\t[Height] ' .. outputHeight .. '\t[Output Format] ' .. outputFormat ..	'\t[Output Extension] ' .. outputExtension .. '\t[Output FOV] ' .. outputFOV)
				-- [Output 1]	 [Width] 3840 [Height] 1920 [Output Format] TiffFormat	[Output FOV] 360
				
				nodeName = 'ptSaverOutput' .. outputCounter
				
				output[outputCounter] = {id = outputCounter, nodename1 = nodeName, width2 = outputWidth, height3 = outputHeight, format4 = outputFormat, extension5 = outputExtension, fov6 = outputFOV, lineNumber7 = lineCounter}
			end
		end
		
		-- Track the progress through the file
		lineCounter = lineCounter + 1
	end
	
	print('[End of File p - Output Lines] ' .. lineCounter)
	 
	-- ----------------------------------------
	-- ----------------------------------------
	
	-- Rectilinear 
	-- o f0 y36 r0 p0 v=0 a=0 b=0 c=0 d=0 e=0 g=0 t=0
	
	-- Circular Fisheye
	-- o f2 y10.0 r20.0 p30.0 v=0 a=0 b=0 c=0 d=0 e=0 g=0 t=0 C354,3408,-537,2517
	searchString = '^o%sf.*'
	print('[Scanning for o image Lines] ' .. searchString)
	-- Scan through the input textfile line by line
	cropCounter = 0
	lineCounter = 0
	for oneLine in io.lines(ptguiFile) do
		-- Check if we have found a match with the searchString
		if oneLine:match(searchString) then
			-- Track the number of edits done
			cropCounter = cropCounter + 1
			
			-- if printStatus == 1 or printStatus == true then
			--	 print('[Crop ' .. cropCounter .. '] ' .. oneLine)
			-- end
			
			-- Input image lens type detection
			-- f0 = Rectilinear / f2 = Circular Fisheye
			lensFormat = string.match(oneLine, 'f(%d+)')
			if lensFormat == nil then
				-- print('[Lens Data Fallback Mode] Circular Fisheye')
				-- lensFormat = 2
				
				-- print('[Lens Data Fallback Mode] Rectilinear')
				-- lensFormat = 0
				
				print('[Lens Data Fallback Mode]')
				lensFormat = -1
			end
			
			-- http://lua-users.org/wiki/PatternsTutorial
			cropLeft,cropRight,cropTop,cropBottom = string.match(oneLine, 'C([%w%-]+),([%w%-]+),([%w%-]+),([%w%-]+)')
			
			-- Load the camera rotation settings
			yawRotate = string.match(oneLine, 'y([%w%-%.]+)')
			rollRotate = string.match(oneLine, 'r([%w%-%.]+)')
			pitchRotate = string.match(oneLine, 'p([%w%-%.]+)')
			
			if cropLeft == nil and cropRight == nil and cropTop == nil and cropBottom == nil then
				print('[Crop Data Fallback Mode]')
				-- As a missing crop data fallback use the use image dimensions
				width = media[cropCounter].width6
				height = media[cropCounter].height7
				
				-- missing media table fallback
				if width == nil then
					width = 3840
				end
				
				if height == nil then
					height = 2160
				end
				
				-- The crop settings are null so reset them
				-- Is the frame orientation a Portrait or Landscape layout?
--				if imageRotate == 0 or imageRotate == 2 then
--					-- Portrait (rotated 90° axis transform)
--					cropLeft = 0
--					cropRight = height
--					cropTop = 0
--					cropBottom = width
--				else
					-- Landscape (default no transform)
					cropLeft = 0
					cropRight = width
					cropTop = 0
					cropBottom = height
				--end
			end
			
			-- Missing yaw/roll/pitch fallback
			if yawRotate == nil and rollRotate == nil and pitchRotate == nil then
				print('[View Rotation Data Fallback Mode]')
				yawRotate = 0
				rollRotate = 0
				pitchRotate = 0
			end
		
			-- Node Name Crop1
			nodeName = 'ptCrop' .. cropCounter
--			
--			-- Is the frame orientation a Portrait or Landscape layout?
--			if imageRotate == 0 or imageRotate == 2 then
--				-- Store the temp values before swapping
--				cropLeftTemp = cropLeft
--				cropRightTemp = cropRight
--				cropTopTemp = cropTop
--				cropBottomTemp = cropBottom
--				
--				-- Landscape (rotated 90° axis transform)
--				cropLeft = cropTop
--				cropRight = cropBottomTemp
--				cropTop = cropLeftTemp
--				cropBottom = cropRightTemp
--			end
			
			-- Calculate the cropped width and height values (they should be a 1:1 ratio for a circular fisheye image)
			if lensFormat == 2 then
				-- Circular Fisheye
				cropWidth = cropRight - cropLeft
				cropHeight = cropBottom - cropTop
			else
				-- rectilinear - rotate the width and height axis
				cropWidth = cropRight - cropLeft
				cropHeight = cropBottom - cropTop
				
--				cropLeftTemp = cropLeft
--				cropRightTemp = cropRight
--				cropTopTemp = cropTop
--				cropBottomTemp = cropBottom
--
--				-- Landscape (rotated 90° axis transform)
--				cropLeft = cropTop
--				cropRight = cropBottomTemp
--				cropTop = cropLeftTemp
--				cropBottom = cropRightTemp
--
--				cropWidth = cropRight - cropLeft
--				cropHeight = cropBottom - cropTop
			end
			
			print('[Crop ' .. cropCounter .. '] ' .. '\t[Left] ' .. cropLeft .. '\t[Right] ' .. cropRight .. '\t[Top] ' .. cropTop .. '\t[Bottom] ' .. cropBottom .. '\t[Crop Width] ' .. cropWidth .. '\t[Crop Height] ' .. cropHeight .. '\t[Yaw] ' .. yawRotate .. '\t[Roll] ' .. rollRotate .. '\t[Pitch] ' .. pitchRotate .. '\t[Lens] ' .. lensFormat)
			-- [Crop 1]	 [Left] 354 [Right] 3408 [Top] -537 [Bottom] 2517 [Crop Width] 3054 [Crop Height] 3054	[Yaw] 0 [Roll] 0 [Pitch] 0 [Lens] 0
			
			crop[cropCounter] = {id = cropCounter, nodename1 = nodeName, left2 = cropLeft, right3 = cropRight, top4 = cropTop, bottom5 = cropBottom, width6 = cropWidth, height7 = cropHeight, yaw8 = yawRotate, roll9 = rollRotate, pitch10 = pitchRotate, lens11 = lensFormat, lineNumber12 = lineCounter}
		end
		
		-- Track the progress through the file
		lineCounter = lineCounter + 1
	end
	
	print('[End of File - o image Lines] ' .. lineCounter)

	-- ----------------------------------------
	-- ----------------------------------------
	
	-- Verify that there is a matching number of cropping nodes to image nodes
	print('[Images Found] ' .. imageCounter .. '\t[Crops Found] ' .. cropCounter)
	if cropCounter ~= imageCounter then
		print('[Warning] There is a mismatch in the number of source images vs circular fisheye cropping entries in the PTGui file. You might want to switch PTGui to use the adavanced tab.')
	end
	
	-- Return a total of how many masks were found
	return imageCounter
	
	-- Return the table array of the PTGui images
	-- return media
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
	
	if printStatus == 1 or printStatus == true then
		print('[Copy Text to Clipboard Command] ' .. command)
		print('[Clipboard] ' .. textString)
	end
	os.execute(command)
end

-- Add a note node
-- Example: nodeString = AddNoteNode('ptNote1', 'Your Comment Here', 500, 80, 1600, 176) 
function AddNoteNode(nodeName, nodeText, noteWidth, noteHeight, nodeXPos, nodeYPos)
	textBlock = ''
	textBlock = textBlock .. '\t\t' .. noteName .. ' = Note {\n'
	textBlock = textBlock .. '\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\tComments = Input { Value = "' .. nodeText .. '", }\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = StickyNoteInfo {\n'
	textBlock = textBlock .. '\t\t\t\tPos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' },\n'
	textBlock = textBlock .. '\t\t\t\tFlags = {\n'
	textBlock = textBlock .. '\t\t\t\t\tExpanded = true\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tSize = { ' .. noteWidth .. ', ' .. noteHeight .. ' }\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end


-- Add a Loader node
function AddLoaderNode(nodeName, effectMaskInputName, filename, format, startFrame, comments, lensType, nodeXPos, nodeYPos)
	
	-- Escape the backwards path slashes on Windows
	if platform == 'Windows' then
		filename = filename:gsub('\\', '\\\\')
	end
	
	textBlock = ''
	textBlock = textBlock .. '\t\t' .. nodeName .. ' = Loader {\n'
	textBlock = textBlock .. '\t\t\tClips = {\n'
	textBlock = textBlock .. '\t\t\t\tClip {\n'
	textBlock = textBlock .. '\t\t\t\t\tID = "Clip1",\n'
	textBlock = textBlock .. '\t\t\t\t\tFilename = "' .. filename .. '",\n'
	textBlock = textBlock .. '\t\t\t\t\tFormatID = "' .. format .. '",\n'
	
	-- Load the frame as a still image that has no duration (-1)
	-- textBlock = textBlock .. '\t\t\t\t\tStartFrame = -1,\n'
	-- Does the final frame padding start on frame 1 or frame 0?
	textBlock = textBlock .. '\t\t\t\t\tStartFrame = ' .. startFrame .. ',\n'
	
	textBlock = textBlock .. '\t\t\t\t\tLengthSetManually = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tTrimIn = 0,\n'
	textBlock = textBlock .. '\t\t\t\t\tTrimOut = 0,\n'
	textBlock = textBlock .. '\t\t\t\t\tExtendFirst = 0,\n'
	textBlock = textBlock .. '\t\t\t\t\tExtendLast = 0,\n'
	textBlock = textBlock .. '\t\t\t\t\tLoop = 0,\n'
	textBlock = textBlock .. '\t\t\t\t\tAspectMode = 0,\n'
	textBlock = textBlock .. '\t\t\t\t\tDepth = 0,\n'
	textBlock = textBlock .. '\t\t\t\t\tTimeCode = 0,\n'
	textBlock = textBlock .. '\t\t\t\t\tGlobalStart = 0,\n'
	textBlock = textBlock .. '\t\t\t\t\tGlobalEnd = 0\n'
	textBlock = textBlock .. '\t\t\t}\n'
	textBlock = textBlock .. '\t\t},\n'
	textBlock = textBlock .. '\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\tMissingFrames = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t["Gamut.SLogVersion"] = Input { Value = FuID { "SLog2" }, },\n'
	
	-- Connect an EffectsMask to the loader node
	if effectMaskInputName == 'none' then
		print('[Loader] Skipping ' .. nodeName .. ' [Effect Mask] ' .. effectMaskInputName .. ' [Type] ' .. lensType)
	else
		-- The import Vector Masks checkbox is enabled
		if importVectorMasks == 1 then
			textBlock = textBlock .. '\t\t\t\tEffectMask = Input {\n'
			
			-- Add a regular rectangle mask
			textBlock = textBlock .. '\t\t\t\t\tSourceOp = "' .. effectMaskInputName .. '",\n'
			
			print('[Loader] ' .. nodeName .. ' [Effect Mask] ' .. effectMaskInputName .. ' [Type] ' .. lensType)
			
			-- What type of source is the EffectMask input? Output/Mask are the typical options
			if lensType == '2' or lensType == 2 then
				-- Circular Fisheye Lens - 2
				textBlock = textBlock .. '\t\t\t\t\tSource = "Output",\n'
			else
				-- Rectilinear Lens - 0
				textBlock = textBlock .. '\t\t\t\t\tSource = "Mask",\n'
			end
			
			textBlock = textBlock .. '\t\t\t\t},\n'
		end
	end
	
	-- Comments text field
	-- textBlock = textBlock .. '\t\t\tComments = Input { Value = "' .. comments .. '", },\n'
	
	textBlock = textBlock .. '\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' } },\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end

-- Add a Merge node
-- Example: merge = AddMergeNode('ptMerge_1', 'UVRenderer3D_2', 'Output', 'UVRenderer3D_1',	 'Output', mergeNodeXPos, mergeNodeYPos)
function AddMergeNode(nodeName, backgroundNode, backgroundSourceType, foregroundNode,	 foregroundSourceType, nodeXPos, nodeYPos)
	textBlock = ''
	textBlock = textBlock .. '\t\t' .. nodeName .. ' = Merge {\n'
	textBlock = textBlock .. '\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\tBackground = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "' .. backgroundNode .. '",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "' .. backgroundSourceType .. '",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tForeground = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "' .. foregroundNode .. '",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "' .. foregroundSourceType .. '",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tPerformDepthMerge = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' } },\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end

-- Add a Rectangle node
-- Example: AddRectangleNode('ptRectangle1', 0.02, -0.04, 1920, 1080, 1, 1, 1363.59, 757.935)
function AddRectangleNode(nodeName, softEdge, borderWidth, maskWidth, maskHeight, scaleX, scaleY, nodeXPos, nodeYPos)
	textBlock = ''
	textBlock = textBlock .. '\t\t'.. nodeName .. ' = RectangleMask {\n'
	textBlock = textBlock .. '\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\tSoftEdge = Input { Value = '.. softEdge .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tBorderWidth = Input { Value = '.. borderWidth .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tMaskWidth = Input { Value = '.. maskWidth .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tMaskHeight = Input { Value = '.. maskHeight .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tPixelAspect = Input { Value = { 1, 1 }, },\n'
	textBlock = textBlock .. '\t\t\t\tClippingMode = Input { Value = FuID { "None" }, },\n'
	textBlock = textBlock .. '\t\t\t\tWidth = Input { Value = '.. scaleX .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tHeight = Input { Value = '.. scaleY .. ', },\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' } },\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end

-- Add a Split View Masking Stereo Rectangle node
-- Example: AddSplitViewMaskRectangleNode('ptSplitViewMaskRectangle', 0.04, 1920, 1080, 1363.59, 757.935)
function AddSplitViewMaskRectangleNode(nodeName, softEdge, maskWidth, maskHeight, nodeXPos, nodeYPos)
	textBlock = ''
	textBlock = textBlock .. '\t\t'.. nodeName .. ' = MacroOperator {\n'
	textBlock = textBlock .. '\t\t	CustomData = {\n'
	textBlock = textBlock .. '				HelpPage = "http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide.html#SplitViewMaskRectangle",\n'
	textBlock = textBlock .. '			},\n'
	textBlock = textBlock .. '\t\t\tInputs = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\tInput1 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "EffectMask",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput2 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "SpitView",\n'
	textBlock = textBlock .. '\t\t\t\t\tPage = "Controls",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput3 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "MaskWidth",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = '.. maskWidth .. ',\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput4 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "MaskHeight",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = '.. maskHeight .. ',\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput5 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Depth",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput6 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Level",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 1,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput7 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Invert",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput8 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Solid",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 1,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput9 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Filter",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput10 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "SoftEdge",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = '.. softEdge .. ',\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput11 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "CornerRadius",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tOutputs = {\n'
	textBlock = textBlock .. '\t\t\t\tMainOutput1 = InstanceOutput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "SplitViewMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Mask",\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = GroupInfo { Pos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' } },\n'
	textBlock = textBlock .. '\t\t\tTools = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\tSplitViewMask' .. '_' .. nodeNumber ..' = RectangleMask {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tCurrentSettings = 4,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSoftEdge = Input { Value = 0.04, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tBorderWidth = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = -0.04,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "SoftEdge*-1",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tOutputSize = Input { Value = FuID { "Custom" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaskWidth = Input { Value = 3840, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaskHeight = Input { Value = 2160, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tPixelAspect = Input { Value = { 1, 1 }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tClippingMode = Input { Value = FuID { "None" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tCenter = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = { 0.5, 0.25 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "Point(iif(SplitViewMask' .. '_' .. nodeNumber ..'.SpitView == 4, 0.5,iif(SplitViewMask' .. '_' .. nodeNumber ..'.SpitView >= 2, 0.5, iif(SplitViewMask' .. '_' .. nodeNumber ..'.SpitView == 1, 0.75, 0.25))), iif(SplitViewMask' .. '_' .. nodeNumber ..'.SpitView == 4, 0.5,iif(SplitViewMask' .. '_' .. nodeNumber ..'.SpitView <= 1, 0.5, iif(SplitViewMask' .. '_' .. nodeNumber ..'.SpitView == 2, 0.75, 0.25))))",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tWidth = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 1,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "iif(SplitViewMask' .. '_' .. nodeNumber ..'.SpitView == 4, 1,iif(SplitViewMask' .. '_' .. nodeNumber ..'.SpitView >= 2, 1, 0.5))",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tHeight = Input { Expression = "iif(SplitViewMask' .. '_' .. nodeNumber ..'.SpitView == 4, 1, iif(SplitViewMask' .. '_' .. nodeNumber ..'.SpitView >= 2, 0.5, 1))", },\n'
	
	-- Assign the default Split View masking value (0-4) from the Ask User dialog
	textBlock = textBlock .. '\t\t\t\t\t\tSpitView = Input { Value = ' .. splitView .. ', },\n'
	
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 439.475, 116.608 } },\n'
	textBlock = textBlock .. '\t\t\t\t\tUserControls = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSpitView = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ CCS_AddString = "Left" },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ CCS_AddString = "Right" },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ CCS_AddString = "Top" },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ CCS_AddString = "Bottom" },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ CCS_AddString = "Full Frame" },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tINP_Integer = false,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tLINKID_DataType = "Number",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tICS_ControlPage = "Controls",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tCC_LabelPosition = "Horizontal",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tINPID_InputControl = "ComboControl",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tLINKS_Name = "Spit View"\n'
	textBlock = textBlock .. '\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end


-- Add an Ellipse node
function AddEllipseNode(nodeName, softEdge, borderWidth, maskWidth, maskHeight, scaleX, scaleY, nodeXPos, nodeYPos)
	textBlock = ''
	textBlock = textBlock .. '\t\t' .. nodeName .. ' = EllipseMask {\n'
	textBlock = textBlock .. '\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\tSoftEdge = Input { Value =' .. softEdge .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tBorderWidth = Input { Value = ' .. borderWidth .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tMaskWidth = Input { Value = ' .. maskWidth ..', },\n'
	textBlock = textBlock .. '\t\t\t\tMaskHeight = Input { Value = ' .. maskHeight .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tPixelAspect = Input { Value = { 1, 1 }, },\n'
	textBlock = textBlock .. '\t\t\t\tClippingMode = Input { Value = FuID { "None" }, },\n'
	textBlock = textBlock .. '\t\t\t\tWidth = Input { Value = ' .. scaleX .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tHeight = Input { Value = ' .. scaleY .. ', },\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' } },\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end


-- Add a FisheyeCropMask macro to the scene
function AddFisheyeCropMaskNode(nodeName, inputNodeName, maskWidth, maskHeight, scaleX, scaleY, centerX, centerY, angle, softEdge, borderWidth, cropSoftEdge, cropBorderWidth, matteBlur, invertGarbageMatte, nodeXPos, nodeYPos)
	textBlock = ''
	textBlock = textBlock .. '\t\t' .. nodeName .. ' = MacroOperator {\n'
	textBlock = textBlock .. '\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\tHelpPage = "http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide.html#FisheyeCropMask",\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tInputs = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\tInput2 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptEllipseMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "MaskWidth",\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 8192,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 3840,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput3 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptEllipseMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "MaskHeight",\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 8192,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 2160,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput4 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptEllipseMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Width",\n'
	textBlock = textBlock .. '\t\t\t\t\tName = "Scale X",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0.79,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput5 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptEllipseMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Height",\n'
	textBlock = textBlock .. '\t\t\t\t\tName = "Scale Y",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0.79,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput6 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptEllipseMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Center",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput7 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptEllipseMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Angle",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput8 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptEllipseMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "SoftEdge",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0.02,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput9 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptEllipseMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "BorderWidth",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = -0.02,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput10 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptRectangleMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "SoftEdge",\n'
	textBlock = textBlock .. '\t\t\t\t\tName = "Crop Soft Edge",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0.02,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput11 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptRectangleMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "BorderWidth",\n'
	textBlock = textBlock .. '\t\t\t\t\tName = "Crop Border Width",\n'
	textBlock = textBlock .. '\t\t\t\t\tMinScale = -0.4,\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 0.4,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = -0.04,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput12 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptMatteControl' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "MatteBlur",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput13 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptMatteControl' .. '_' .. nodeNumber .. '",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "InvertGarbageMatte",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput1 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptMatteControl' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "GarbageMatte",\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tOutputs = {\n'
	textBlock = textBlock .. '\t\t\t\tMainOutput1 = InstanceOutput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "ptMatteControl' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = GroupInfo { Pos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' } },\n'
	textBlock = textBlock .. '\t\t\tTools = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\tptMatteControl' .. '_' .. nodeNumber ..' = MatteControl {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMatteCombine = Input { Value = 4, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tCombineOp = Input { Value = 5, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMatteBlur = Input { Value = ' .. matteBlur .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tClippingMode = Input { Value = FuID { "None" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tInvertGarbageMatte = Input { Value = ' .. invertGarbageMatte .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMultiplyGarbageMatte = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tBackground = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "ptEllipseMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Mask",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tForeground = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "ptRectangleMask' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Mask",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	
	-- Add a garbage mask input
--	if (string.len(inputNodeName) >= 1) then
--		textBlock = textBlock .. '\t\t\t\t\t\tGarbageMatte = Input {\n'
--		textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "' .. inputNodeName .. '",\n'
--		textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Mask",\n'
--		textBlock = textBlock .. '\t\t\t\t\t\t},\n'
--	end
	
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 55, 42.4281 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tptRectangleMask' .. '_' .. nodeNumber ..' = RectangleMask {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSoftEdge = Input { Value = ' .. cropSoftEdge .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tBorderWidth = Input { Value = ' .. cropBorderWidth .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tOutputSize = Input { Value = FuID { "Custom" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaskWidth = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 3840,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "ptEllipseMask' .. '_' .. nodeNumber ..'.MaskWidth*2",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaskHeight = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 2160,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "ptEllipseMask' .. '_' .. nodeNumber ..'.MaskHeight",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tPixelAspect = Input { Value = { 1, 1 }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tClippingMode = Input { Value = FuID { "None" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tCenter = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = { 0.25, 0.5 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "ptEllipseMask' .. '_' .. nodeNumber ..'.Center - Point(0.25,0)",\n' 
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tWidth = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tHeight = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tAngle = Input { Expression = "ptEllipseMask' .. '_' .. nodeNumber ..'.Angle", },\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -55, 42.4281 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tptEllipseMask' .. '_' .. nodeNumber ..' = EllipseMask {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSoftEdge = Input { Value = ' .. softEdge .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tBorderWidth = Input { Value = ' .. borderWidth .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tOutputSize = Input { Value = FuID { "Custom" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaskWidth = Input { Value = ' .. maskWidth ..', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaskHeight = Input { Value = ' .. maskHeight .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tPixelAspect = Input { Value = { 1, 1 }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tClippingMode = Input { Value = FuID { "None" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tCenter = Input { Value = { ' .. centerX .. ', ' .. centerY .. ' }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tWidth = Input { Value = ' .. scaleX .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tHeight = Input { Value = ' .. scaleY .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -55, 9.42813 } },\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end


-- Add a GridWarp node to the comp
-- Example: gridWarp = AddGridWarpNode('ptGridWarp1', 'UVRenderer3D_1', 'Output', gridWarpNodeXPos, gridWarpNodeYPos)
function AddGridWarpNode(nodeName, inputNodeName, inputSourceType, nodeXPos, nodeYPos)
	textBlock = ''
	textBlock = textBlock .. '\t\t' .. nodeName .. ' = GridWarp {\n'
	textBlock = textBlock .. '\t\t\tSrcDrawMode = 1,\n'
	textBlock = textBlock .. '\t\t\tDestDrawMode = 1,\n'
	textBlock = textBlock .. '\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\tMagnetDistance = Input { Value = 0.05, },\n'
	textBlock = textBlock .. '\t\t\t\tDstXGridSize = Input { Value = 6, },\n'
	textBlock = textBlock .. '\t\t\t\tDstYGridSize = Input { Value = 4, },\n'
	textBlock = textBlock .. '\t\t\t\tSrcXGridSize = Input { Value = 6, },\n'
	textBlock = textBlock .. '\t\t\t\tSrcYGridSize = Input { Value = 4, },\n'
	textBlock = textBlock .. '\t\t\t\tSrcGridChange = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\tValue = Mesh {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tCount = 35,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tCol = 7,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tDeltaR = 0.25,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tDeltaC = 0.166666666666667,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tP1X = -0.5,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tP1Y = -0.5,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tPoints = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.5, Y = -0.5, L_CX = 0, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.333333333333333, Y = -0.5, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.166666666666667, Y = -0.5, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0, Y = -0.5, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.166666666666667, Y = -0.5, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.333333333333333, Y = -0.5, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.5, Y = -0.5, T_CY = 0, R_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.5, Y = -0.25, L_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.333333333333333, Y = -0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.166666666666667, Y = -0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0, Y = -0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.166666666666667, Y = -0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.333333333333333, Y = -0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.5, Y = -0.25, R_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.5, Y = 0, L_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.333333333333333, Y = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.166666666666667, Y = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0, Y = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.166666666666667, Y = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.333333333333333, Y = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.5, Y = 0, R_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.5, Y = 0.25, L_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.333333333333333, Y = 0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.166666666666667, Y = 0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0, Y = 0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.166666666666667, Y = 0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.333333333333333, Y = 0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.5, Y = 0.25, R_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.5, Y = 0.5, L_CX = 0, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.333333333333333, Y = 0.5, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.166666666666667, Y = 0.5, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0, Y = 0.5, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.166666666666667, Y = 0.5, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.333333333333333, Y = 0.5, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.5, Y = 0.5, R_CX = 0, B_CY = 0, }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSavePoints = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tSrcPolyline = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\tValue = Polyline {\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tDstGridChange = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\tValue = Mesh {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tCount = 35,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tCol = 7,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tDeltaR = 0.25,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tDeltaC = 0.166666666666667,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tP1X = -0.5,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tP1Y = -0.5,\n'
	textBlock = textBlock .. '\t\t\t\t\t\tPoints = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.5, Y = -0.5, L_CX = 0, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.333333333333333, Y = -0.5, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.166666666666667, Y = -0.5, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0, Y = -0.5, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.166666666666667, Y = -0.5, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.333333333333333, Y = -0.5, T_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.5, Y = -0.5, T_CY = 0, R_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.5, Y = -0.25, L_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.333333333333333, Y = -0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.166666666666667, Y = -0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0, Y = -0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.166666666666667, Y = -0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.333333333333333, Y = -0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.5, Y = -0.25, R_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.5, Y = 0, L_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.333333333333333, Y = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.166666666666667, Y = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0, Y = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.166666666666667, Y = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.333333333333333, Y = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.5, Y = 0, R_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.5, Y = 0.25, L_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.333333333333333, Y = 0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.166666666666667, Y = 0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0, Y = 0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.166666666666667, Y = 0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.333333333333333, Y = 0.25, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.5, Y = 0.25, R_CX = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.5, Y = 0.5, L_CX = 0, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.333333333333333, Y = 0.5, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = -0.166666666666667, Y = 0.5, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0, Y = 0.5, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.166666666666667, Y = 0.5, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.333333333333333, Y = 0.5, B_CY = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t{ X = 0.5, Y = 0.5, R_CX = 0, B_CY = 0, }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSavePoints = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tDstPolyline = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\tValue = Polyline {\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tAntiAliasing = Input { Value = 2, },\n'
	
	-- Connect the Fisheye2Equirectangular node UVRenderer3D_1 output
	if string.len(inputNodeName) >= 1 then
	 textBlock = textBlock .. '\t\t\t\tInput = Input {\n'
	 textBlock = textBlock .. '\t\t\t\t\tSourceOp = "' .. inputNodeName .. '",\n'
	 textBlock = textBlock .. '\t\t\t\t\tSource = "' .. inputSourceType .. '",\n'
	 textBlock = textBlock .. '\t\t\t\t},\n'
	end
	
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' } },\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end

-- Add a crop node to the scene
function AddCropNode(nodeName, inputNodeName, cropXOffset, cropYOffset, cropXSize, cropYSize, nodeXPos, nodeYPos)
	textBlock = ''
	textBlock = textBlock .. '\t\t' .. nodeName .. ' = Crop {\n'
	textBlock = textBlock .. '\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\tXOffset = Input { Value = ' .. cropXOffset .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tYOffset = Input { Value = ' .. cropYOffset .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tXSize = Input { Value = ' .. cropXSize .. ', },\n'
	textBlock = textBlock .. '\t\t\t\tYSize = Input { Value = ' .. cropYSize .. ', },\n'
	
	-- Link the Loader node to the crop node
	if importImages == 1 then
		textBlock = textBlock .. '\t\t\t\tInput = Input {\n'
		textBlock = textBlock .. '\t\t\t\t\tSourceOp = "' .. inputNodeName .. '",\n'
		textBlock = textBlock .. '\t\t\t\t\tSource = "Output",\n'
		textBlock = textBlock .. '\t\t\t\t},\n'
	end
	
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' } },\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end

-- Add a Fisheye2Equirectangular node to the scene
function AddFisheye2EquirectangularNode(nodeName, inputNodeName, nodeNumber, rotateX, rotateY, rotateZ, fov, height, nodeXPos, nodeYPos)
	textBlock = ''
	
	-- Add a unique name for the newly added Fisheye2Equirectangular node
	textBlock = textBlock .. '\t\t' .. fisheyeName .. ' = GroupOperator {\n'
	-- textBlock = textBlock .. '\t\t' .. fisheyeName .. ' = MacroOperator {\n'
	
	textBlock = textBlock .. '\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\tHelpPage = "http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide.html#Fisheye2Equirectangular",\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tInputs = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\tMainInput1 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "InputScaling' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Input",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput1 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "InputScaling' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Height",\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 8192,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 1920,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput2 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "UVRenderer3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Depth",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput3 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "FOVCustomTool' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "NumberIn1",\n'
	textBlock = textBlock .. '\t\t\t\t\tName = "FOV Angle",\n'
	textBlock = textBlock .. '\t\t\t\t\tMinScale = 1,\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 360,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 180,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput4 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "FOVCustomTool' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "NumberIn2",\n'
	textBlock = textBlock .. '\t\t\t\t\tMinScale = -360,\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 360,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput5 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "FOVCustomTool' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "NumberIn3",\n'
	textBlock = textBlock .. '\t\t\t\t\tMinScale = -360,\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 360,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput6 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "FOVCustomTool' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "NumberIn4",\n'
	textBlock = textBlock .. '\t\t\t\t\tMinScale = -360,\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 360,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput7 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "BackgroundColor' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "TopLeftRed",\n'
	textBlock = textBlock .. '\t\t\t\t\tName = "Background Color",\n'
	textBlock = textBlock .. '\t\t\t\t\tControlGroup = 6,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput8 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "BackgroundColor' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "TopLeftGreen",\n'
	textBlock = textBlock .. '\t\t\t\t\tControlGroup = 6,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput9 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "BackgroundColor' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "TopLeftBlue",\n'
	textBlock = textBlock .. '\t\t\t\t\tControlGroup = 6,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput10 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "BackgroundColor' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "TopLeftAlpha",\n'
	textBlock = textBlock .. '\t\t\t\t\tControlGroup = 6,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tOutputs = {\n'
	textBlock = textBlock .. '\t\t\t\tMainOutput1 = InstanceOutput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "UVRenderer3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = GroupInfo {\n'
	textBlock = textBlock .. '\t\t\t\tPos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' },\n'
	textBlock = textBlock .. '\t\t\t\tFlags = {\n'
	
	-- Should the GroupOperator Macro be expanded and visible
	-- textBlock = textBlock .. '\t\t\t\t\tExpanded = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tExpanded = false,\n'
	
	textBlock = textBlock .. '\t\t\t\t\tAllowPan = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tAutoSnap = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tRemoveRouters = true\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tSize = { 1331, 207.717, 695.5, 37 },\n'
	textBlock = textBlock .. '\t\t\t\tDirection = "Horizontal",\n'
	textBlock = textBlock .. '\t\t\t\tPipeStyle = "Direct",\n'
	textBlock = textBlock .. '\t\t\t\tScale = 1,\n'
	textBlock = textBlock .. '\t\t\t\tOffset = { -24, 0 }\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tTools = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\tUVRenderer3D' .. '_' .. nodeNumber ..' = Renderer3D {\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tWidth = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 3840,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "InputScaling' .. '_' .. nodeNumber ..'.Height*2",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tHeight = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 1920,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "InputScaling' .. '_' .. nodeNumber ..'.Height",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Gamut.SLogVersion"] = Input { Value = FuID { "SLog2" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSceneInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "Shape3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tRendererType = Input { Value = FuID { "RendererOpenGLUV" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["RendererOpenGLUV.UVGutterSize"] = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["RendererOpenGLUV.Texturing"] = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["RendererOpenGLUV.TextureDepth"] = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 550, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tShape3D' .. '_' .. nodeNumber ..' = Shape3D {\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tCurrentSettings = 3,\n'
	textBlock = textBlock .. '\t\t\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSettings = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[1] = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\tTools = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\tShape3D' .. '_' .. nodeNumber ..' = Shape3D {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tMaterialInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSourceOp = "SphereMap' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSource = "MaterialOutput"\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfacePlaneInputs.ObjectID.ObjectID"] = Input { Value = 7 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.SubdivisionLevelHeight"] = Input { Value = 256 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["MtlStdInputs.MaterialID"] = Input { Value = 6 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.SubdivisionLevelBase"] = Input { Value = 256 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.ObjectID.ObjectID"] = Input { Value = 8 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tShape = Input { Value = FuID { "SurfaceSphereInputs" } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.Radius"] = Input { Value = 500 }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 522.5, 74.5672 } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[2] = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\tTools = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\tShape3D' .. '_' .. nodeNumber ..' = Shape3D {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Transform3DOp.ScaleLock"] = Input { Value = 0 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfacePlaneInputs.ObjectID.ObjectID"] = Input { Value = 7 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.SubdivisionLevelHeight"] = Input { Value = 256 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.ObjectID.ObjectID"] = Input { Value = 8 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Transform3DOp.Scale.X"] = Input { Value = -1000 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tMaterialInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSourceOp = "SphereMap' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSource = "MaterialOutput"\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Transform3DOp.Rotate.Y"] = Input { Value = 180 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Transform3DOp.Scale.Z"] = Input { Value = 1000 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Transform3DOp.Scale.Y"] = Input { Value = 1000 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.SubdivisionLevelBase"] = Input { Value = 256 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["MtlStdInputs.MaterialID"] = Input { Value = 6 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tShape = Input { Value = FuID { "SurfaceSphereInputs" } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.Radius"] = Input { Value = 500 }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 522.5, 74.5672 } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[3] = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\tTools = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\tShape3D' .. '_' .. nodeNumber ..' = Shape3D {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Transform3DOp.ScaleLock"] = Input { Value = 0 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfacePlaneInputs.ObjectID.ObjectID"] = Input { Value = 7 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.SubdivisionLevelHeight"] = Input { Value = 256 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.SubdivisionLevelBase"] = Input { Value = 256 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.ObjectID.ObjectID"] = Input { Value = 8 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["MtlStdInputs.MaterialID"] = Input { Value = 6 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Transform3DOp.Scale.X"] = Input { Value = -1000 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tMaterialInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSourceOp = "SphereMap' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSource = "MaterialOutput"\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.EndSweep"] = Input { Value = 450 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.StartSweep"] = Input { Value = 90 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Transform3DOp.Scale.Y"] = Input { Value = 1000 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Transform3DOp.Rotate.Y"] = Input { Value = 180 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Transform3DOp.Scale.Z"] = Input { Value = 1000 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tShape = Input { Value = FuID { "SurfaceSphereInputs" } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["SurfaceSphereInputs.Radius"] = Input { Value = 500 }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tName = "Shape3D",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 522.5, 74.5672 } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfacePlaneInputs.ObjectID.ObjectID"] = Input { Value = 7, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Transform3DOp.Rotate.RotOrder"] = Input { Value = FuID { "ZXY" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Transform3DOp.ScaleLock"] = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Transform3DOp.Scale.X"] = Input { Value = -1000, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Transform3DOp.Scale.Y"] = Input { Value = 1000, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Transform3DOp.Scale.Z"] = Input { Value = -1000, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShape = Input { Value = FuID { "SurfaceSphereInputs" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaterialInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "SphereMap' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "MaterialOutput",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["MtlStdInputs.MaterialID"] = Input { Value = 6, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfaceSphereInputs.Radius"] = Input { Value = 500, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfaceSphereInputs.SubdivisionLevelBase"] = Input { Value = 256, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfaceSphereInputs.SubdivisionLevelHeight"] = Input { Value = 256, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfaceSphereInputs.ObjectID.ObjectID"] = Input { Value = 8, }\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 440, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tSphereMap' .. '_' .. nodeNumber ..' = SphereMap {\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSettings = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[1] = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\tTools = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\tSphereMap' .. '_' .. nodeNumber ..' = SphereMap {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tRotation = Input { Value = 1 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["FilterMode.Nest"] = Input { Value = 1 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tImage = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSourceOp = "Loader1",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSource = "Output"\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Rotate.Y"] = Input { Value = 90 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tMaterialID = Input { Value = 1 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["FilterMode.GL.LowQ"] = Input { Value = FuID { "Trilinear" } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["FilterMode.SW.LowQ"] = Input { Value = FuID { "Bilinear" } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["FilterMode.GL.HiQ"] = Input { Value = FuID { "SAT" } }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tName = "SphereMap",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 440, 115.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[2] = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\tTools = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\tSphereMap' .. '_' .. nodeNumber ..' = SphereMap {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tRotation = Input { Value = 1 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["FilterMode.Nest"] = Input { Value = 1 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["Rotate.Y"] = Input { Value = 90 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tMaterialID = Input { Value = 1 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t["FilterMode.SW.HiQ"] = Input { Value = FuID { "Nearest" } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tImage = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSourceOp = "Loader1",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSource = "Output"\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 440, 115.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tRotation = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Rotate.RotOrder"] = Input { Value = FuID { "ZXY" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Rotate.X"] = Input { Expression = "FOVCustomTool' .. '_' .. nodeNumber ..'.NumberIn4 * -1", },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Rotate.Y"] = Input { Expression = "FOVCustomTool' .. '_' .. nodeNumber ..'.NumberIn2", },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Rotate.Z"] = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = -90,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "FOVCustomTool' .. '_' .. nodeNumber ..'.NumberIn3-90",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["FilterMode.Nest"] = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["FilterMode.SW.LowQ"] = Input { Value = FuID { "Bilinear" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tImage = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "FOVMerge' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaterialID = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 330, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tFOVMerge' .. '_' .. nodeNumber ..' = Merge {\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tBackground = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "BackgroundColor' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tForeground = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "FOVTransform' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tFlattenTransform = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tPerformDepthMerge = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 165, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tBackgroundColor' .. '_' .. nodeNumber ..' = Background {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tWidth = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 3840,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "InputScaling' .. '_' .. nodeNumber ..'.Height*2",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tHeight = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 1920,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "InputScaling' .. '_' .. nodeNumber ..'.Height",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Gamut.SLogVersion"] = Input { Value = FuID { "SLog2" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tTopLeftAlpha = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tGradient = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = Gradient {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\tColors = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t[0] = { 0, 0, 0, 1 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t[1] = { 1, 1, 1, 1 }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 165, 148.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tFOVCustomTool' .. '_' .. nodeNumber ..' = Custom {\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	
	-- Adjust the circular fisheye FOV (field of view) setting
	textBlock = textBlock .. '\t\t\t\t\t\tNumberIn1 = Input { Value = ' .. fov .. ', },\n'
	
	-- Is the frame orientation a Portrait or Landscape layout?
	
	frameRotation = 0
--	if imageRotate == 0 then
--		-- 0° Portrait
--		frameRotation = 0
--	elseif imageRotate == 1 then
--		-- -90° Landscape
--		frameRotation = 90
--	elseif imageRotate == 2 then
--		-- 180° Portrait
--		frameRotation = 180
--	elseif imageRotate == 3 then
--		-- 90° Landscape
--		frameRotation = -90
--	else
--		-- Fallback 0° Portrait
--		frameRotation = 0
--	end
	
	-- Calculate view rotation offsets
	-- Yaw (Y Rotation)
	rotateYOffset = rotateY - yRotation
	textBlock = textBlock .. '\t\t\t\t\t\tNumberIn2 = Input { Value = ' .. rotateYOffset .. ', },\n'
	
	-- Pitch (Z Rotation)
	rotateZOffset = rotateZ - zRotation
	textBlock = textBlock .. '\t\t\t\t\t\tNumberIn3 = Input { Value = ' .. rotateZOffset .. ', },\n'
	
	-- Roll (X Rotation)
	rotateXOffset = rotateX - xRotation - frameRotation 
	textBlock = textBlock .. '\t\t\t\t\t\tNumberIn4 = Input { Value = ' .. rotateXOffset .. ', },\n'
	
	textBlock = textBlock .. '\t\t\t\t\t\tLUTIn1 = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "FOVCustomToolLUTIn1",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Value",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tLUTIn2 = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "FOVCustomToolLUTIn2",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Value",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tLUTIn3 = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "FOVCustomToolLUTIn3",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Value",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tLUTIn4 = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "FOVCustomToolLUTIn4",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Value",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tNumberControls = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tNameforNumber1 = Input { Value = "FOV", },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tNameforNumber2 = Input { Value = "Yaw (Y Rotation)", },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tNameforNumber3 = Input { Value = "Pitch (Z Rotation)", },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tNameforNumber4 = Input { Value = "Roll (X Rotation)", },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowNumber5 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowNumber6 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowNumber7 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowNumber8 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tPointControls = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowPoint1 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowPoint2 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowPoint3 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowPoint4 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tLUTControls = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowLUT1 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowLUT2 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowLUT3 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShowLUT4 = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 55, 16.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tFOVCustomToolLUTIn1 = LUTBezier {\n'
	textBlock = textBlock .. '\t\t\t\t\tKeyColorSplines = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t[0] = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[0] = { 0, RH = { 0.333333333333333, 0.333333333333333 }, Flags = { Linear = true } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[1] = { 1, LH = { 0.666666666666667, 0.666666666666667 }, Flags = { Linear = true } }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tSplineColor = { Red = 204, Green = 0, Blue = 0 },\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tFOVCustomToolLUTIn2 = LUTBezier {\n'
	textBlock = textBlock .. '\t\t\t\t\tKeyColorSplines = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t[0] = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[0] = { 0, RH = { 0.333333333333333, 0.333333333333333 }, Flags = { Linear = true } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[1] = { 1, LH = { 0.666666666666667, 0.666666666666667 }, Flags = { Linear = true } }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tSplineColor = { Red = 0, Green = 204, Blue = 0 },\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tFOVCustomToolLUTIn3 = LUTBezier {\n'
	textBlock = textBlock .. '\t\t\t\t\tKeyColorSplines = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t[0] = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[0] = { 0, RH = { 0.333333333333333, 0.333333333333333 }, Flags = { Linear = true } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[1] = { 1, LH = { 0.666666666666667, 0.666666666666667 }, Flags = { Linear = true } }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tSplineColor = { Red = 0, Green = 0, Blue = 204 },\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tFOVCustomToolLUTIn4 = LUTBezier {\n'
	textBlock = textBlock .. '\t\t\t\t\tKeyColorSplines = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t[0] = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[0] = { 0, RH = { 0.333333333333333, 0.333333333333333 }, Flags = { Linear = true } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[1] = { 1, LH = { 0.666666666666667, 0.666666666666667 }, Flags = { Linear = true } }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tSplineColor = { Red = 204, Green = 204, Blue = 204 },\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tFOVTransform' .. '_' .. nodeNumber ..' = Transform {\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tPivot = Input { Value = { 0.5, 1 }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tUseSizeAndAspect = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tYSize = Input { Expression = "FOVCustomTool' .. '_' .. nodeNumber ..'.NumberIn1*(1/360)", },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "ViewRotate' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 55, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tViewRotate' .. '_' .. nodeNumber ..' = Transform {\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tAngle = Input { Value = 180, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "ViewResize' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -55, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tViewResize' .. '_' .. nodeNumber ..' = BetterResize {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tWidth = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 3840,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "InputScaling' .. '_' .. nodeNumber ..'.Height*2",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tHeight = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 1920,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "InputScaling' .. '_' .. nodeNumber ..'.Height",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tPixelAspect = Input { Value = { 1, 1 }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tFilterMethod = Input { Value = 6, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "EquirectConversionCrop' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -165, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tEquirectConversionCrop' .. '_' .. nodeNumber ..' = Crop {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tXSize = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 1920,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "InputScaling' .. '_' .. nodeNumber ..'.Height",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tYSize = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 1350,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "EquirectConversionCrop' .. '_' .. nodeNumber ..'.XSize/1.422222222222222",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "ViewSlide' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -275, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tViewSlide' .. '_' .. nodeNumber ..' = Transform {\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tCurrentSettings = 2,\n'
	textBlock = textBlock .. '\t\t\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSettings = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t[1] = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\tTools = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\tViewSlide' .. '_' .. nodeNumber ..' = Transform {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSourceOp = "EquirectConversion' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t\tSource = "Output"\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tEdges = Input { Value = 1 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t\tCenter = Input { Value = { 0.75, 0.5 } }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -412.5, 74.5672 } },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tCenter = Input { Value = { 0.25, 0.5 }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tEdges = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "EquirectConversion' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -385, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tEquirectConversion' .. '_' .. nodeNumber ..' = CoordSpace {\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "InputScaling' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -495, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInputScaling' .. '_' .. nodeNumber ..' = BetterResize {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tWidth = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = ' .. height .. ',\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "Height",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	
	-- Adjust the height output setting for the Fisheye2Equirectangular node
	textBlock = textBlock .. '\t\t\t\t\t\tHeight = Input { Value = ' .. height .. ', },\n'
	
	textBlock = textBlock .. '\t\t\t\t\t\tPixelAspect = Input { Value = { 1, 1 }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tFilterMethod = Input { Value = 6, },\n'
	
	-- Link the fisheye2equirectangular node to the previous crop node
	-- if inputNodeName ~= nil then
	if (string.len(inputNodeName) >= 1) then
		textBlock = textBlock .. '\t\t\t\t\t\tInput = Input {\n'
		textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "' .. inputNodeName .. '",\n'
		textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
		textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	end
	
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -605, 82.5 } },\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end

-- Add a Rectilinear2Equirectangular node to the comp
-- RectilinearNodeXPos = -247
-- RectilinearNodeYPos = 76.15
-- Example: rect = AddRectilinearNode('ptRectilinear2Equirectangular1', 1, 'UVRenderer3D_1', 'Output', 1920, 960, 108, 0, 0, 0, RectilinearNodeXPos, RectilinearNodeYPos)
function AddRectilinearNode(nodeName, nodeNumber, inputNodeName, inputSourceType, width, height, fov, roll, yaw, pitch, nodeXPos, nodeYPos)
	-- The macro's input RectilinearProjector3D node's input connection is called "ProjectiveImage".
	-- The macro's output is called "'BackgroundColorMerge' .. '_' .. nodeNumber" and has a type of "output"
	
	-- Rectilinear2Equirectangular settings
	-- Rotation Axis Order
	-- cameraRotationOrder = 'XYZ'
	-- cameraRotationOrder = 'XZY'
	-- cameraRotationOrder = 'YXZ'
	-- cameraRotationOrder = 'YZX'
	cameraRotationOrder = 'ZXY'
	-- cameraRotationOrder = 'ZYZ'
	
	textBlock = ''
	textBlock = textBlock .. '\t\t' .. nodeName .. ' = MacroOperator {\n'
	textBlock = textBlock .. '\t\t\tCustomData = {\n'
	textBlock = textBlock .. '\t\t\t\tHelpPage = "http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide.html#Rectilinear2Equirectangular",\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tInputs = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\tMainInput1 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "RectilinearProjector3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "ProjectiveImage",\n'
	textBlock = textBlock .. '\t\t\t\t\tName = "Input",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput1 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "RectilinearUVRenderer3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Width",\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 8192,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 3840,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput2 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "RectilinearUVRenderer3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Height",\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 8192,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 1920,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput3 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "RectilinearUVRenderer3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Depth",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput4 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "RectilinearProjector3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Angle",\n'
	textBlock = textBlock .. '\t\t\t\t\tName = "FOV",\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 90,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput5 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "RectilinearProjector3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Fit",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput6 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "RectilinearProjector3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Transform3DOp.Rotate.RotOrder",\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput7 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "RectilinearProjector3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Transform3DOp.Rotate.X",\n'
	textBlock = textBlock .. '\t\t\t\t\tMinScale = -360,\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 360,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput8 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "RectilinearProjector3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Transform3DOp.Rotate.Y",\n'
	textBlock = textBlock .. '\t\t\t\t\tMinScale = -360,\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 360,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput9 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "RectilinearProjector3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Transform3DOp.Rotate.Z",\n'
	textBlock = textBlock .. '\t\t\t\t\tMinScale = -360,\n'
	textBlock = textBlock .. '\t\t\t\t\tMaxScale = 360,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput10 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "BackgroundColor' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "TopLeftRed",\n'
	textBlock = textBlock .. '\t\t\t\t\tName = "Color",\n'
	textBlock = textBlock .. '\t\t\t\t\tControlGroup = 1,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput11 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "BackgroundColor' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "TopLeftGreen",\n'
	textBlock = textBlock .. '\t\t\t\t\tControlGroup = 1,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput12 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "BackgroundColor' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "TopLeftBlue",\n'
	textBlock = textBlock .. '\t\t\t\t\tControlGroup = 1,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tInput13 = InstanceInput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "BackgroundColor' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "TopLeftAlpha",\n'
	textBlock = textBlock .. '\t\t\t\t\tControlGroup = 1,\n'
	textBlock = textBlock .. '\t\t\t\t\tDefault = 0,\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tOutputs = {\n'
	textBlock = textBlock .. '\t\t\t\tMainOutput1 = InstanceOutput {\n'
	textBlock = textBlock .. '\t\t\t\t\tSourceOp = "BackgroundColorMerge' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t\tViewInfo = GroupInfo { Pos = { ' .. nodeXPos .. ', ' .. nodeYPos .. ' } },\n'
	textBlock = textBlock .. '\t\t\tTools = ordered() {\n'
	textBlock = textBlock .. '\t\t\t\tBackgroundColor' .. '_' .. nodeNumber ..' = Background {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tWidth = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 1920,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "RectilinearUVRenderer3D' .. '_' .. nodeNumber ..'.Width",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tHeight = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = 960,\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tExpression = "RectilinearUVRenderer3D' .. '_' .. nodeNumber ..'.Height",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tDepth = Input { Expression = "RectilinearUVRenderer3D' .. '_' .. nodeNumber ..'.Depth", },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Gamut.SLogVersion"] = Input { Value = FuID { "SLog2" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tTopLeftAlpha = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tGradient = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tValue = Gradient {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\tColors = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t[0] = { 0, 0, 0, 1 },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t\t[1] = { 1, 1, 1, 1 }\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 247.5, 142.15 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tBackgroundColorMerge' .. '_' .. nodeNumber ..' = Merge {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tBackground = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "BackgroundColor' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tForeground = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "RectilinearFlipTransform' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tFlattenTransform = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tPerformDepthMerge = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 247.5, 76.15 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tRectilinearFlipTransform' .. '_' .. nodeNumber ..' = Transform {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tFlipHoriz = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "RectilinearUVRenderer3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { 82.5, 76.15 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tRectilinearUVRenderer3D' .. '_' .. nodeNumber ..' = Renderer3D {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tWidth = Input { Value = ' .. width .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tHeight = Input { Value = ' .. height .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Gamut.SLogVersion"] = Input { Value = FuID { "SLog2" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSceneInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "RectilinearSphereShape3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\tRendererType = Input { Value = FuID { "RendererOpenGLUV" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["RendererOpenGLUV.UVGutterSize"] = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["RendererOpenGLUV.LightingEnabled"] = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["RendererOpenGLUV.TextureDepth"] = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -27.5, 76.15 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tRectilinearSphereShape3D' .. '_' .. nodeNumber ..' = Shape3D {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfacePlaneInputs.ObjectID.ObjectID"] = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tSceneInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "RectilinearProjector3D' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Transform3DOp.ScaleLock"] = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tShape = Input { Value = FuID { "SurfaceSphereInputs" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaterialInput = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "RectilinearCatcher' .. '_' .. nodeNumber ..'",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "MaterialOutput",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["MtlStdInputs.MaterialID"] = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfaceSphereInputs.Radius"] = Input { Value = 500, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfaceSphereInputs.SubdivisionLevelBase"] = Input { Value = 256, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfaceSphereInputs.SubdivisionLevelHeight"] = Input { Value = 256, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfaceSphereInputs.StartSweep"] = Input { Value = 90, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfaceSphereInputs.EndSweep"] = Input { Value = 450, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["SurfaceSphereInputs.ObjectID.ObjectID"] = Input { Value = 2, }\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -137.5, 76.15 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tRectilinearProjector3D' .. '_' .. nodeNumber ..' = LightProjector {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWZoom = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Transform3DOp.Rotate.RotOrder"] = Input { Value = FuID { "' .. cameraRotationOrder .. '" }, },\n'
	
	-- Apply the rectilinear XYZ view rotations
	-- Transform3DOp.Rotate.Y = Pans the camera around horizontally on the rig
	-- Transform3DOp.Rotate.Z = 90 Rotates the camera into the portrait layout
	
	-- Is the frame orientation a Portrait or Landscape layout?
	frameRotation = 0
-- if imageRotate == 0 then
--		-- 0° Portrait
--		frameRotation = 0
--	elseif imageRotate == 1 then
--		-- -90° Landscape
--		frameRotation = 90
--	elseif imageRotate == 2 then
--		-- 180° Portrait
--		frameRotation = 180
--	elseif imageRotate == 3 then
--		-- 90° Landscape
--		frameRotation = -90
--	else
--		-- Fallback 0° Portrait
--		frameRotation = 0
--	end
	
	-- Calculate view rotation offsets
	rotateXOffset = pitch - xRotation
	rotateYOffset = (yaw * -1) - yRotation
	rotateZOffset = ((roll * -1) - frameRotation) - zRotation
	
	-- rotateXOffset = pitch - xRotation
	-- rotateYOffset = yaw - yRotation
	-- rotateZOffset = (roll - frameRotation) - zRotation
	
	textBlock = textBlock .. '\t\t\t\t\t\t["Transform3DOp.Rotate.X"] = Input { Value = ' .. rotateXOffset .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Transform3DOp.Rotate.Y"] = Input { Value = ' .. rotateYOffset .. ', },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["Transform3DOp.Rotate.Z"] = Input { Value = ' .. rotateZOffset .. ', },\n'

	textBlock = textBlock .. '\t\t\t\t\t\tAngle = Input { Value = ' .. fov .. ', },\n'
	
	-- node input
	textBlock = textBlock .. '\t\t\t\t\t\tProjectiveImage = Input {\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSourceOp = "' .. inputNodeName .. '",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t\tSource = "Output",\n'
	textBlock = textBlock .. '\t\t\t\t\t\t},\n'
	
	-- Is the frame orientation a Portrait (0/2) or Landscape (1/3) layout?
--	if imageRotate == 1 or imageRotate == 3 then
--		-- Landscape
--		textBlock = textBlock .. '\t\t\t\t\t\tFit = Input { Value = FuID { "Height" }, },\n'
--	else
		-- Portrait
		textBlock = textBlock .. '\t\t\t\t\t\tFit = Input { Value = FuID { "Width" }, },\n'
--	end
	
	textBlock = textBlock .. '\t\t\t\t\t\tProjectionMode = Input { Value = 2, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["ShadowLightInputs3D.Nest"] = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\t["ShadowLightInputs3D.ShadowsEnabled"] = Input { Value = 0, },\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -247.5, 76.15 } },\n'
	textBlock = textBlock .. '\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\tRectilinearCatcher' .. '_' .. nodeNumber ..' = TexCatcher {\n'
	textBlock = textBlock .. '\t\t\t\t\tCtrlWShown = false,\n'
	textBlock = textBlock .. '\t\t\t\t\tNameSet = true,\n'
	textBlock = textBlock .. '\t\t\t\t\tInputs = {\n'
	textBlock = textBlock .. '\t\t\t\t\t\tColorAccumulationMode = Input { Value = FuID { "Blend" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tAlphaAccumulationMode = Input { Value = FuID { "Blend" }, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaterialIDNest = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t\tMaterialID = Input { Value = 1, },\n'
	textBlock = textBlock .. '\t\t\t\t\t},\n'
	textBlock = textBlock .. '\t\t\t\t\tViewInfo = OperatorInfo { Pos = { -137.5, 10.15 } },\n'
	textBlock = textBlock .. '\t\t\t\t}\n'
	textBlock = textBlock .. '\t\t\t},\n'
	textBlock = textBlock .. '\t\t},\n'
	
	return textBlock
end


-- Add a saver node to the comp
function AddIntermediateSaverNode(nodeNumber, saverName, nodeInput, nodeInputConnection, saverNodeXPos, saverNodeYPos, saverFormat, saverFilename, nodePassThrough)
	-- Escape the backwards path slashes on Windows
	if platform == 'Windows' then
		saverFilename = saverFilename:gsub("\\","\\\\")
	end
	
	nodeString = nodeString .. '\t\t' .. saverName .. ' = Saver {\n'
	
	if nodePassThrough then
	-- The nodePassThrough variable can be set to the string value of 'true' or 'false'.
	-- Setting this attribute to "true" will disable the saver node in the comp by default when the PTGui Project Importer script runs.
	nodeString = nodeString .. '\t\t\tPassThrough = ' .. nodePassThrough .. ',\n'
	else
		-- Fallback when nodePassThrough is nil
		-- Setting this attribute to "true" will disable the saver node in the comp by default when the PTGui Project Importer script runs.
		nodeString = nodeString .. '\t\t\tPassThrough = ' .. 'true' .. ',\n'
	end
	
	nodeString = nodeString .. '\t\t\tCtrlWZoom = false,\n'
	nodeString = nodeString .. '\t\t\tInputs = {\n'
	nodeString = nodeString .. '\t\t\t\tProcessWhenBlendIs00 = Input { Value = 0, },\n'
	nodeString = nodeString .. '\t\t\t\tClip = Input {\n'
	nodeString = nodeString .. '\t\t\t\t\tValue = Clip {\n'
	nodeString = nodeString .. '\t\t\t\t\t\tFilename = "' .. saverFilename .. '",\n'
	nodeString = nodeString .. '\t\t\t\t\t\tFormatID = "' .. saverFormat .. '",\n'
	nodeString = nodeString .. '\t\t\t\t\t\tLength = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\t\tSaving = true,\n'
	nodeString = nodeString .. '\t\t\t\t\t\tTrimIn = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\t\tExtendFirst = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\t\tExtendLast = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\t\tLoop = 1,\n'
	nodeString = nodeString .. '\t\t\t\t\t\tAspectMode = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\t\tDepth = 0,\n'
	
	nodeString = nodeString .. '\t\t\t\t\t\tGlobalStart = 0,\n'
	-- nodeString = nodeString .. '\t\t\t\t\t\tGlobalStart = -2000000000,\n'
	
	nodeString = nodeString .. '\t\t\t\t\t\tGlobalEnd = 0\n'
	nodeString = nodeString .. '\t\t\t\t\t},\n'
	nodeString = nodeString .. '\t\t\t\t},\n'
	nodeString = nodeString .. '\t\t\t\tCreateDir = Input { Value = 1, },\n'
	nodeString = nodeString .. '\t\t\t\tOutputFormat = Input { Value = FuID { "' .. saverFormat .. '" }, },\n'
	nodeString = nodeString .. '\t\t\t\t["Gamut.SLogVersion"] = Input { Value = FuID { "SLog2" }, },\n'

	nodeString = nodeString .. '\t\t\t\tInput = Input {\n'
	nodeString = nodeString .. '\t\t\t\t\tSourceOp = "' .. nodeInput .. '",\n'
	
	-- nodeInputConnection is 'Output'
	nodeString = nodeString .. '\t\t\t\t\tSource = "' .. nodeInputConnection .. '",\n'
	nodeString = nodeString .. '\t\t\t\t},\n'

	if saverFormat == 'TiffFormat' then
		-- No Alpha
		-- nodeString = nodeString .. '\t\t\t\t["TiffFormat.SaveAlpha"] = Input { Value = 0, },\n'
		
		-- With Alpha
		nodeString = nodeString .. '\t\t\t\t["TiffFormat.SaveAlpha"] = Input { Value = 1, },\n'
	end
	
	nodeString = nodeString .. '\t\t\t},\n'
	nodeString = nodeString .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. saverNodeXPos .. ',' .. saverNodeYPos .. ' } },\n'
	nodeString = nodeString .. '\t\t},\n'
	
	return nodeString
end

-- Add a saver node to the comp
function CreateSaverNode(nodeNumber, saverName, nodeOriginXPos, nodeOriginYPos, align, width, height, saverFormat, saverFilename)
	-- Node spacing per row/column
	nodeXOffset = 110
	nodeYOffset = 33.5
	
	-- Number of inline nodes in the branch to shift over by
	nodeBranchShift = importImages + importCropping + (importLensSettings * 2)
	-- nodeBranchShift = 3
	
	-- Node Transforms
	if align == 'left' then
		-- Position the saver node to the left by calculating the node index # that is being added
		saverNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		saverNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
	elseif align == 'right' then
		-- Position the loader node to the right by calculating the node index # that is being added
		saverNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		saverNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
	elseif align == 'upwards' then
		-- Position the saver node above by calculating the node index # that is being added
		saverNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		saverNodeYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
	elseif align == 'downwards' then
		-- Position the loader node below by calculating the node index # that is being added
		saverNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		saverNodeYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
	else
		-- Fallback - Position the loader node to the right by calculating the node index # that is being added
		saverNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		saverNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
	end
	
	-- Add a Saver node
	if importSaver == 1 then
		-- Escape the backwards path slashes on Windows
		if platform == 'Windows' then
			saverFilename = saverFilename:gsub("\\","\\\\")
		end
		
		nodeString = nodeString .. '\t\t' .. saverName .. ' = Saver {\n'
		nodeString = nodeString .. '\t\t\tCtrlWZoom = false,\n'
		nodeString = nodeString .. '\t\t\tInputs = {\n'
		nodeString = nodeString .. '\t\t\t\tProcessWhenBlendIs00 = Input { Value = 0, },\n'
		nodeString = nodeString .. '\t\t\t\tClip = Input {\n'
		nodeString = nodeString .. '\t\t\t\t\tValue = Clip {\n'
		nodeString = nodeString .. '\t\t\t\t\t\tFilename = "' .. saverFilename .. '",\n'
		nodeString = nodeString .. '\t\t\t\t\t\tFormatID = "' .. saverFormat .. '",\n'
		nodeString = nodeString .. '\t\t\t\t\t\tLength = 0,\n'
		nodeString = nodeString .. '\t\t\t\t\t\tSaving = true,\n'
		nodeString = nodeString .. '\t\t\t\t\t\tTrimIn = 0,\n'
		nodeString = nodeString .. '\t\t\t\t\t\tExtendFirst = 0,\n'
		nodeString = nodeString .. '\t\t\t\t\t\tExtendLast = 0,\n'
		nodeString = nodeString .. '\t\t\t\t\t\tLoop = 1,\n'
		nodeString = nodeString .. '\t\t\t\t\t\tAspectMode = 0,\n'
		nodeString = nodeString .. '\t\t\t\t\t\tDepth = 0,\n'
		
		nodeString = nodeString .. '\t\t\t\t\t\tGlobalStart = 0,\n'
		-- nodeString = nodeString .. '\t\t\t\t\t\tGlobalStart = -2000000000,\n'
		
		nodeString = nodeString .. '\t\t\t\t\t\tGlobalEnd = 0\n'
		nodeString = nodeString .. '\t\t\t\t\t},\n'
		nodeString = nodeString .. '\t\t\t\t},\n'
		nodeString = nodeString .. '\t\t\t\tCreateDir = Input { Value = 1, },\n'
		nodeString = nodeString .. '\t\t\t\tOutputFormat = Input { Value = FuID { "' .. saverFormat .. '" }, },\n'
		nodeString = nodeString .. '\t\t\t\t["Gamut.SLogVersion"] = Input { Value = FuID { "SLog2" }, },\n'
		
		-- Link in the final merge node
		if importLensSettings == 1 then
			if nodeNumber >= 2 then
				-- If there are two or more images then link the saver node to the merge node
				mergeNode = 'ptMerge' .. (nodeNumber - 1)
				nodeString = nodeString .. '\t\t\t\tInput = Input {\n'
				nodeString = nodeString .. '\t\t\t\t\tSourceOp = "' .. mergeNode .. '",\n'
				nodeString = nodeString .. '\t\t\t\t\tSource = "Output",\n'
				nodeString = nodeString .. '\t\t\t\t},\n'
			end
		end
		
		if saverFormat == 'TiffFormat' then
			nodeString = nodeString .. '\t\t\t\t["TiffFormat.SaveAlpha"] = Input { Value = 0, },\n'
		end
		
		nodeString = nodeString .. '\t\t\t},\n'
		nodeString = nodeString .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. saverNodeXPos .. ',' .. saverNodeYPos .. ' } },\n'
		nodeString = nodeString .. '\t\t},\n'
	end
	
	return nodeString
end


-- Add an extra loader node to the comp
function CreateLoaderNodes(nodeNumber, loaderName, loaderFilename, loaderFormat, nodeOriginXPos, nodeOriginYPos, align, cropName, cropXOffset, cropYOffset, cropXSize, cropYSize, roll, yaw, pitch, fisheyeFOV, lensType, originalWidth, originalHeight, fisheyeHeight, fisheyeCenterX, fisheyeCenterY)
	-- loaderFormat holds a value like 'TiffFormat'
	-- default node starting X/Y Pos = 605, 214.5
	
	-- Adjust the height output setting for the Fisheye2Equirectangular node
	-- fisheyeHeight = 1920
	
	-- Adjust the circular fisheye FOV (field of view) setting
	-- fisheyeFOV = 180.0
	
	-- Apply the fisheye XYZ view rotations
	-- fisheyeXRotate = 90
	-- fisheyeYRotate = 0
	-- fisheyeZRotate = 0
	
	-- Node spacing per row/column
	nodeXOffset = 110
	nodeYOffset = 33.5
	
	-- Number of inline nodes in the branch to shift over by
	nodeBranchShift = 0
	
	-- Node Transforms
	if align == 'left' then
		-- The mask goes to the right of the loader
		nodeBranchShift = -1
		ellipseXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		ellipseYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		fisheyeCropMaskNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		fisheyeCropMaskNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Position the loader node by calculating the node index # that is being added
		nodeBranchShift = 0
		loaderXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		loaderYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- The Note node goes above the loader node
		nodeBranchShift = nodeBranchShift
		noteNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		noteNodeYPos = nodeOriginYPos + (nodeYOffset * (nodeNumber - 3))
		
		-- The crop node goes to the left of the loader
		nodeBranchShift = nodeBranchShift + importCropping
		cropNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		cropNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- The Fisheye2Equirectangular node goes to the left of the crop
		nodeBranchShift = nodeBranchShift + importLensSettings
		fisheyeNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		fisheyeNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add a GridWarp node
		nodeBranchShift = nodeBranchShift + importGridWarp
		gridWarpNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		gridWarpNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add an intermediate Saver node
		nodeBranchShift = nodeBranchShift + importIntermediateSaver
		intermediateSaverNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		intermediateSaverNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add Merge node
		nodeBranchShift = nodeBranchShift + importLensSettings
		mergeNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		mergeNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- The Camera3D nodes go to the right of the Fisheye2Equirectangular node
		nodeBranchShift = nodeBranchShift + importCamera3D + 3
		loader3DNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		loader3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		nodeBranchShift = nodeBranchShift + importCamera3D
		camera3DNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		camera3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- The Merge3D node goes to the left of the Camera3D
		nodeBranchShift = nodeBranchShift + importCamera3D
		merge3DNodeXPos = nodeOriginXPos - (nodeXOffset * nodeBranchShift)
		merge3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
	elseif align == 'right' then
		-- Add the mask node before the loader node
		nodeBranchShift = -1
		ellipseXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		ellipseYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		fisheyeCropMaskNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		fisheyeCropMaskNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add the loader node by calculating the node index # that is being added
		nodeBranchShift = 0
		loaderXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		loaderYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- The Note node goes above the loader node
		nodeBranchShift = nodeBranchShift
		noteNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		noteNodeYPos = nodeOriginYPos + (nodeYOffset * (nodeNumber - 3))
		
		-- Add the crop node to the right of the loader node
		nodeBranchShift = nodeBranchShift + importCropping
		cropNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		cropNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add Fisheye2Equirectangular node
		nodeBranchShift = nodeBranchShift + importLensSettings
		fisheyeNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		fisheyeNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add a GridWarp node
		nodeBranchShift = nodeBranchShift + importGridWarp
		gridWarpNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		gridWarpNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add an intermediate Saver node
		nodeBranchShift = nodeBranchShift + importIntermediateSaver
		intermediateSaverNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		intermediateSaverNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add Merge node
		nodeBranchShift = nodeBranchShift + importLensSettings
		mergeNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		mergeNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add the Camera3D node
		nodeBranchShift = nodeBranchShift + importCamera3D + 3
		camera3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		camera3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add the Merge3D for the Camera3D node
		nodeBranchShift = nodeBranchShift + importCamera3D
		merge3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		merge3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add the Loader 3D node
		nodeBranchShift = nodeBranchShift + importCamera3D + 2
		loader3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		loader3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add the Projector3D 3D node
		nodeBranchShift = nodeBranchShift + importCamera3D
		projector3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		projector3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
	elseif align == 'upwards' then
		-- The mask goes to the below the loader
		nodeBranchShift = -1
		ellipseXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		ellipseYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
		fisheyeCropMaskNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		fisheyeCropMaskNodeYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
		
		-- Position the loader node by calculating the node index # that is being added
		nodeBranchShift = 0
		loaderXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		loaderYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
	
		-- The Note node goes right of the loader node
		nodeBranchShift = nodeBranchShift
		noteNodeXPos = nodeOriginXPos + (nodeXOffset * (nodeNumber - 6))
		noteNodeYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
		
		-- The crop node goes above the loader
		nodeBranchShift = nodeBranchShift + importCropping
		cropNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		cropNodeYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
		
		-- The Fisheye2Equirectangular node goes above of the crop node
		nodeBranchShift = nodeBranchShift + importLensSettings
		fisheyeNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		fisheyeNodeYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
		
		-- Add a GridWarp node
		nodeBranchShift = nodeBranchShift + importGridWarp
		gridWarpNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		gridWarpNodeYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
		
		-- Add an intermediate Saver node
		nodeBranchShift = nodeBranchShift + importIntermediateSaver
		intermediateSaverNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		intermediateSaverNodeYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
		
		-- Add Merge node
		nodeBranchShift = nodeBranchShift + importLensSettings
		mergeNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		mergeNodeYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift) 
		
		-- The Camera3D node goes above of the Fisheye2Equirectangular node
		nodeBranchShift = nodeBranchShift + importCamera3D + 3
		camera3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		camera3DNodeYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
		
		-- The Merge3D node goes above of the Camera3D node
		nodeBranchShift = nodeBranchShift + importCamera3D
		merge3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		merge3DNodeYPos = nodeOriginYPos - (nodeYOffset * nodeBranchShift)
	elseif align == 'downwards' then
		-- The mask goes to the below the loader
		nodeBranchShift = -1
		ellipseXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		ellipseYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
		fisheyeCropMaskNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		fisheyeCropMaskNodeYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
		
		-- Position the loader node by calculating the node index # that is being added
		nodeBranchShift = 0
		loaderXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		loaderYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
		
		-- The Note node goes left of the loader node
		nodeBranchShift = nodeBranchShift
		noteNodeXPos = nodeOriginXPos + (nodeXOffset * (nodeNumber - 6))
		noteNodeYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
		
		-- The crop node goes below the loader node
		nodeBranchShift = nodeBranchShift + importCropping
		cropNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		cropNodeYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
		
		-- The Fisheye2Equirectangular node goes below the crop node
		nodeBranchShift = nodeBranchShift + importLensSettings
		fisheyeNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		fisheyeNodeYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
		
		-- Add a GridWarp node
		nodeBranchShift = nodeBranchShift + importGridWarp
		gridWarpNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		gridWarpNodeYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
		
		-- Add an intermediate Saver node
		nodeBranchShift = nodeBranchShift + importIntermediateSaver
		intermediateSaverNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		intermediateSaverNodeYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
		
		-- Add Merge node
		nodeBranchShift = nodeBranchShift + importLensSettings
		mergeNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		mergeNodeYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
		
		-- The Camera3D node goes below the Fisheye2Equirectangular node
		nodeBranchShift = nodeBranchShift + importCamera3D + 3
		camera3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		camera3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
		
		-- The Merge3D node goes below the Camera3D node
		nodeBranchShift = nodeBranchShift + importCamera3D
		merge3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		merge3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeBranchShift)
	else
		-- Fallback to 'right'
		-- Add the mask node before the loader node
		nodeBranchShift = -1
		ellipseXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		ellipseYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		fisheyeCropMaskNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		fisheyeCropMaskNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add the loader node by calculating the node index # that is being added
		nodeBranchShift = 0
		loaderXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		loaderYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- The Note node goes above the loader node
		nodeBranchShift = nodeBranchShift
		noteNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		noteNodeYPos = nodeOriginYPos + (nodeYOffset * (nodeNumber - 3))
		
		-- Add the crop node to the right of the loader node
		nodeBranchShift = nodeBranchShift + importCropping
		cropNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		cropNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add Fisheye2Equirectangular node
		nodeBranchShift = nodeBranchShift + importLensSettings
		fisheyeNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		fisheyeNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add a GridWarp node
		nodeBranchShift = nodeBranchShift + importGridWarp
		gridWarpNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		gridWarpNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add an intermediate Saver node
		nodeBranchShift = nodeBranchShift + importIntermediateSaver
		intermediateSaverNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		intermediateSaverNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add Merge node
		nodeBranchShift = nodeBranchShift + importLensSettings
		mergeNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		mergeNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add the Camera3D node
		nodeBranchShift = nodeBranchShift + importCamera3D + 3
		camera3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		camera3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add the Merge3D for the Camera3D node
		nodeBranchShift = nodeBranchShift + importCamera3D
		merge3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		merge3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add the Loader 3D node
		nodeBranchShift = nodeBranchShift + importCamera3D + 2
		loader3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		loader3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- Add the Projector3D 3D node
		nodeBranchShift = nodeBranchShift + importCamera3D
		projector3DNodeXPos = nodeOriginXPos + (nodeXOffset * nodeBranchShift)
		projector3DNodeYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
	end
	
	nodeString = ''
	
	-- Fisheye2Equirectangular settings
	-- fisheye Rotation Axis Order
	-- fisheyeRotationOrder = 'XYZ'
	fisheyeRotationOrder = 'XZY'
	-- fisheyeRotationOrder = 'YXZ'
	-- fisheyeRotationOrder = 'YZX'
	-- fisheyeRotationOrder = 'ZXY'
	-- fisheyeRotationOrder = 'ZYZ'
	
	if roll ~= nil then
		-- fisheyeXRotate = roll * -1
		fisheyeXRotate = roll
	else
		fisheyeXRotate = 0
	end
	
	if yaw ~= nil then
		-- fisheyeYRotate = yaw * -1
		fisheyeYRotate = yaw
	else
		fisheyeYRotate = 0
	end
	
	if pitch ~= nil then
		fisheyeZRotate = pitch
	else
		fisheyeZRotate = 0
	end
	
	-- Ellipse Mask settings
	ellipseName = 'ptEllipseMask' .. nodeNumber
	
	ellipseMaskWidth = 1920
	ellipseMaskHeight = 1080
	
	-- Note: Scale ratio is Cropped Width / Original Width
	-- Example 3054 / 3840 = 0.795
	ellipseScaleX = cropXSize / originalWidth
	ellipseScaleY = cropYSize / originalHeight
	-- ellipseScaleY = cropXSize / originalWidth
	-- ellipseScaleX = 1
	-- ellipseScaleY = 1
	
	-- Rectilinear rectangle mask settings
	if splitView == 5 then
		-- Use a regular rectangle mask
		rectangleMaskName = 'ptRectangle' .. nodeNumber
		rectangleEffectMaskName = 'ptRectangle' .. nodeNumber
	else
		-- Split view masking is active!
		rectangleMaskName = 'ptSplitViewMaskRectangle' .. nodeNumber
		rectangleEffectMaskName = 'SplitViewMask_' .. nodeNumber
	end
	
	-- rectangleMaskWidth = 1920
	-- rectangleMaskHeight = 1080
	
	rectangleMaskWidth = originalWidth
	rectangleMaskHeight = originalHeight
	
	-- Note: Scale ratio is	 Cropped Width / Original Width
	-- Example 3054 / 3840 = 0.795
	rectangleScaleX = cropXSize / originalWidth
	rectangleScaleY = cropYSize / originalHeight
	
	-- rectangleScaleY = cropXSize / originalWidth
	-- rectangleScaleX = 1
	-- rectangleScaleY = 1
	
	-- FisheyeCropMask settings
	fisheyeCropMaskName = 'ptFisheyeCropMask' .. nodeNumber
	-- Note the "ptfisheyeCropMask" linkable effects matte output has the name of:
	fisheyeCropEffectMaskName = 'ptMatteControl' .. '_' .. nodeNumber

	fisheyeMaskWidth = originalWidth
	fisheyeMaskHeight = originalHeight
	
	-- Note: Scale ratio is Cropped Width / Original Width
	-- Example 3054 / 3840 = 0.795
	fisheyeScaleX = cropXSize / originalWidth
	fisheyeScaleY = cropXSize / originalWidth
	-- fisheyeScaleY = cropYSize / originalHeight
	
	-- FisheyeCropMask Center(x,y) positions in relative 0-1 units
	-- Debugging hardcoded values:
	-- fisheyeCenterX = 0.5
	-- fisheyeCenterY = 0.5
	
	fisheyeAngle = 0
	
	blendModeName = ''
	
	-- vector mask edge feathering
	if edgeBlending == 0 then
		-- No Blending
		blendModeName = 'No Blending'
		
		ellipseSoftEdge = 0.0
		ellipseBorderWidth = 0
		
		rectangleSoftEdge = 0
		rectangleBorderWidth = 0
		
		fisheyeSoftEdge = 0
		fisheyeBorderWidth = 0
		fisheyeCropSoftEdge = 0
		fisheyeCropBorderWidth = 0
		fisheyeMatteBlur = 0
		fisheyeInvertGarbageMatte = 0
	elseif edgeBlending == 1 then
		-- Hard Blending
		blendModeName = 'Hard Blending'
		
		ellipseSoftEdge = 0.02
		ellipseBorderWidth = -0.02
		
		rectangleSoftEdge = 0.05
		rectangleBorderWidth = -0.08
		
		fisheyeSoftEdge = 0.02
		fisheyeBorderWidth = -0.04
		fisheyeCropSoftEdge = 0.02
		fisheyeCropBorderWidth = -0.04
		fisheyeMatteBlur = 0
		fisheyeInvertGarbageMatte = 0
	elseif edgeBlending == 2 then
		-- Normal Blending
		blendModeName = 'Normal Blending'
		
		ellipseSoftEdge = 0.04
		ellipseBorderWidth = -0.04
		
		rectangleSoftEdge = 0.06
		rectangleBorderWidth = -0.1
		
		fisheyeSoftEdge = 0.04
		fisheyeBorderWidth = -0.08
		fisheyeCropSoftEdge = 0.04
		fisheyeCropBorderWidth = -0.08
		fisheyeMatteBlur = 0
		fisheyeInvertGarbageMatte = 0
	elseif edgeBlending == 3 then
		-- Soft blending
		blendModeName = 'Soft Blending'
		
		ellipseSoftEdge = 0.04
		ellipseBorderWidth = -0.04
		
		rectangleSoftEdge = 0.1
		rectangleBorderWidth = -0.17
		
		fisheyeSoftEdge = 0.08
		fisheyeBorderWidth = -0.08
		fisheyeCropSoftEdge = 0.08
		fisheyeCropBorderWidth = -0.08
		fisheyeMatteBlur = 0
		fisheyeInvertGarbageMatte = 0
	end
	
	-- What lens model was found in the PTGui .pts file?
	lensTypeName = ''
	if lensType == '2' then
		-- Circular Fisheye Lens
		lensTypeName = 'Circular Fisheye'
	elseif lensType == '0' then
		-- Rectilinear Lens
		lensTypeName = 'Rectilinear'
	else
		-- Rectilinear Fallback
		lensTypeName = 'Rectilinear Fallback'
	end
	
	-- Camera3D importer settings
	camera3DNearClip = 0.1
	camera3DFarClip = 100
	-- camera3DFarClip = 1000
	
	-- --------------------------------------------------------------------------------------------
	
-- Add a ptNote node
if nodeNumber == 1 then
	noteName = 'ptNote'
	
	-- Short filename
	nodePTGuiFilename = getFilename(ptguiFile)
	-- or Long filename with the full path
	-- nodePTGuiFilename = ptguiFile
	
	-- Note Comments
	noteText = '[PTGui Project] ' .. nodePTGuiFilename .. '\\n'
	noteText = noteText .. '[Cameras] ' .. imageCounter .. '\t[Lens Type] ' .. lensTypeName .. '\t[FOV] ' .. fisheyeFOV .. '\t[Image Size] ' .. originalWidth .. 'x' .. originalHeight .. '\\n'
	noteText = noteText .. '[Edge Blending] ' .. blendModeName	 .. '\\n'
	
	-- Add a note node
	nodeString = nodeString .. AddNoteNode(noteName, noteText, 500, 80, noteNodeXPos, noteNodeYPos)
end

	-- The fallback vector matte shape effect mask connection name 
	vectorEffectMaskName = 'none'
	
	-- Add an circular fisheye mask
	if importVectorMasks == 1 then
		-- Add an ellipse node
		-- nodeString = nodeString .. AddEllipseNode(ellipseName, ellipseSoftEdge, ellipseBorderWidth, ellipseMaskWidth, ellipseMaskHeight, ellipseScaleX, ellipseScaleY, ellipseXPos, ellipseYPos)
		
		-- Check the lens model
		if lensType == '2' then
			-- Circular Fisheye Lens
			-- Add an FisheyeCropMask macro
			vectorMaskName = fisheyeCropMaskName
			vectorEffectMaskName = fisheyeCropEffectMaskName
			nodeString = nodeString .. AddFisheyeCropMaskNode(vectorMaskName, '', fisheyeMaskWidth, fisheyeMaskHeight, fisheyeScaleX, fisheyeScaleY, fisheyeCenterX, fisheyeCenterY, fisheyeAngle, fisheyeSoftEdge, fisheyeBorderWidth, fisheyeCropSoftEdge, fisheyeCropBorderWidth, fisheyeMatteBlur, fisheyeInvertGarbageMatte, fisheyeCropMaskNodeXPos, fisheyeCropMaskNodeYPos)
		-- elseif lensType == '0' then
		else
			-- Rectilinear Lens
			if splitView == 5 then
				-- Add a rectangle node
				
				-- Rectilinear rectangle mask settings
				vectorMaskName = rectangleMaskName
				vectorEffectMaskName = rectangleEffectMaskName
				nodeString = nodeString .. AddRectangleNode(vectorMaskName, rectangleSoftEdge, rectangleBorderWidth, rectangleMaskWidth, rectangleMaskHeight, rectangleScaleX, rectangleScaleY, ellipseXPos, ellipseYPos)
			else
				-- Add a SplitViewMaskRectangle node
				vectorMaskName = rectangleMaskName
				vectorEffectMaskName = rectangleEffectMaskName
				nodeString = nodeString .. AddSplitViewMaskRectangleNode(vectorMaskName, rectangleSoftEdge, rectangleMaskWidth, rectangleMaskHeight, ellipseXPos, ellipseYPos)
			end
		end
	end
	
	fisheyeInputName = ''
	
	-- Add a Loader node
	if importImages == 1 then
		-- Loader Comments
		loaderText = 'FOV: ' .. fisheyeFOV .. '\\nImage: ' .. loaderFilename .. '\\nImage Size: ' .. originalWidth .. 'x' .. originalHeight
		
		-- Add a Loader node
		nodeString = nodeString .. AddLoaderNode(loaderName, vectorEffectMaskName, loaderFilename, loaderFormat, frameExtensionFusionStartFrame, loaderText, lensType, loaderXPos, loaderYPos)
		
		fisheyeInputName = loaderName
	end
	
	-- Add a Crop Node
	if importCropping == 1 then
		nodeString = nodeString .. AddCropNode(cropName, loaderName, cropXOffset, cropYOffset, cropXSize, cropYSize, cropNodeXPos, cropNodeYPos)
		
		fisheyeInputName = cropName
	end
	
	-- Add a Fisheye2Equirectangular macro
	if importLensSettings == 1 then
		fisheyeOutputName = ''
		
		print('[Final Lens Type] "' .. lensType .. '"')
		if lensType == '2' then
			-- Circular Fisheye Lens
			fisheyeName = 'ptFisheye2Equirectangular' .. nodeNumber
			fisheyeOutputName = 'UVRenderer3D_' .. nodeNumber
			
			nodeString = nodeString .. AddFisheye2EquirectangularNode(fisheyeName, fisheyeInputName, nodeNumber, fisheyeXRotate, fisheyeYRotate, fisheyeZRotate, fisheyeFOV, fisheyeHeight, fisheyeNodeXPos, fisheyeNodeYPos)
		-- elseif lensType == '0' then
		else
			-- Rectilinear Lens
			rectilinearName = 'ptRectilinear2Equirectangular' .. nodeNumber
			fisheyeOutputName = 'BackgroundColorMerge' .. '_' .. nodeNumber
			
			nodeString = nodeString .. AddRectilinearNode(rectilinearName, nodeNumber, fisheyeInputName, 'Output', (fisheyeHeight * 2), fisheyeHeight, fisheyeFOV, fisheyeXRotate, fisheyeYRotate, fisheyeZRotate, fisheyeNodeXPos, fisheyeNodeYPos)
		end
		
		-- Add a GridWarp node
		if importGridWarp == 1 then
			gridWarpName = 'ptGridWarp' .. nodeNumber
			nodeString = nodeString .. AddGridWarpNode(gridWarpName, fisheyeOutputName, 'Output', gridWarpNodeXPos, gridWarpNodeYPos)
		end
		
		-- Add an intermediate Saver node
		if importIntermediateSaver == 1 then
			intermediateSaverName = 'ptSaver' .. nodeNumber
			
			-- Input connection name for the intermediate Saver node
			if importGridWarp == 1 then
				-- Add a GridWarp node
				intermediateSaverNodeInput = 'ptGridWarp' .. nodeNumber
			elseif lensType == '2' then
				-- No Gridwarp node - Fallback to the Circular Fisheye Lens
				intermediateSaverNodeInput = 'UVRenderer3D_' .. nodeNumber
			else
				-- No Gridwarp node - Fallback to the Rectilinear Lens
				intermediateSaverNodeInput = 'BackgroundColorMerge' .. '_' .. nodeNumber
			end
			
			-- Create the image output filename for the intermediate saver node: <name>_view#.<padded frame>.<ext>
			-- Todo: The intermediate saver view# element should really be frame padded in the future.
			-- Use relative filepaths for Savers
			saverFrameExtensionNumber = '.0000'
			
			-- Read the image format setting
			-- saverFormat = output[1].format4
			-- Force the Tiff image format so an alpha channel is preserved
			saverFormat = 'TiffFormat'
			saverOutputExtension = 'tif'
			
			if useRelativePaths == 1 then
				-- Use a shortened Comp:/ centric relative path
				
				-- The absolute saver image path that is being re-written
				toIntermediateFile = trimExtension(ptguiFile) .. '_view' .. nodeNumber .. saverFrameExtensionNumber .. '.' .. saverOutputExtension
				
				-- The location of the comp file that is used to do the relative path trimming
				fromIntermediateFile = comp:GetAttrs().COMPS_FileName
				
				-- The pathmap prefix value that is added to the final relative path result
				relativePathMap = 'Comp:/'
				
				-- Build the saver node image path
				outputIntermediateFilename = ConvertToRelativePathMap(toIntermediateFile, fromIntermediateFile, relativePathMap)
			else
				-- Use the full absolute filepath
				-- Build the saver node image path
				outputIntermediateFilename = trimExtension(ptguiFile) .. '_view' .. nodeNumber .. saverFrameExtensionNumber .. '.' .. saverOutputExtension
			end
			
			nodeString = nodeString .. AddIntermediateSaverNode(nodeNumber, intermediateSaverName, intermediateSaverNodeInput, 'Output', intermediateSaverNodeXPos, intermediateSaverNodeYPos, saverFormat, outputIntermediateFilename, intermediateSaverNodePassThrough)
		end
		
		-- Add a merge node if there are two or more images in the PTGui project
		if nodeNumber == 2 then
			-- When adding the first merge node connect the first two image inputs to the merge node
			mergeName = 'ptMerge' .. nodeNumber
			
			-- Input connection name for the ptMerge node
			if importIntermediateSaver == 1 then
				-- Add an intermediate Saver node
				mergeNodeInput = 'ptSaver' .. nodeNumber
				mergeNodeInputPrev = 'ptSaver' .. nodeNumber - 1
			elseif importGridWarp == 1 then
				-- Add a GridWarp node
				mergeNodeInput = 'ptGridWarp' .. nodeNumber
				mergeNodeInputPrev = 'ptGridWarp' .. nodeNumber - 1
			elseif lensType == '2' then
				-- No Gridwarp node - Fallback to the Circular Fisheye Lens
				mergeNodeInput = 'UVRenderer3D_' .. nodeNumber
				mergeNodeInputPrev = 'UVRenderer3D_' .. nodeNumber - 1
			else
				-- No Gridwarp node - Fallback to the Rectilinear Lens
				mergeNodeInput = 'BackgroundColorMerge' .. '_' .. nodeNumber
				mergeNodeInputPrev = 'BackgroundColorMerge' .. '_' .. nodeNumber - 1
			end
			
			-- Connect the GridWarp node to the merge node
			nodeString = nodeString .. AddMergeNode(mergeName, mergeNodeInput, 'Output', mergeNodeInputPrev, 'Output', mergeNodeXPos, mergeNodeYPos)
			
			-- Connect the Fisheye2Equirectangular node to the merge node
			-- nodeString = nodeString .. AddMergeNode(mergeName, ('UVRenderer3D_' .. nodeNumber), 'Output', ('UVRenderer3D_' .. nodeNumber - 1), 'Output', mergeNodeXPos, mergeNodeYPos)
		elseif nodeNumber >= 3 then
			-- When adding the 2nd or more merge nodes Connect the new image and the previous merge node inputs to the new merge node
			mergeName = 'ptMerge' .. nodeNumber
			mergePreviousName = 'ptMerge' .. nodeNumber - 1
			
			-- Input connection name for the 2nd branch
			 if importIntermediateSaver == 1 then
				-- Add an intermediate Saver node
				mergeNodeInput = 'ptSaver' .. nodeNumber
			elseif importGridWarp == 1 then
				-- Add a GridWarp node
				mergeNodeInput = 'ptGridWarp' .. nodeNumber
			elseif lensType == '2' then
				-- No Gridwarp node - Fallback to the Circular Fisheye Lens
				mergeNodeInput = 'UVRenderer3D_' .. nodeNumber
			else
				-- No Gridwarp node - Fallback to the Rectilinear Lens
				mergeNodeInput = 'BackgroundColorMerge' .. '_' .. nodeNumber
			end
			
			-- Connect the GridWarp node to the merge node
			nodeString = nodeString .. AddMergeNode(mergeName, mergeNodeInput, 'Output', mergePreviousName, 'Output', mergeNodeXPos, mergeNodeYPos)
			
			-- Connect the Fisheye2Equirectangular node to the merge node
			-- nodeString = nodeString .. AddMergeNode(mergeName, ('UVRenderer3D_' .. nodeNumber), 'Output', mergePreviousName, 'Output', mergeNodeXPos, mergeNodeYPos)
		end
	end
	
	-- Add the Camera3D, Merge3D, and Note nodes
	if importCamera3D == 1 then
		-- camera3DFarClip = 100
		-- camera3DNearClip = 0.1
		
		-- Add a Loader3D node to the Camera3D node branch
		loader3DName = 'ptLoader3D' .. nodeNumber
		
		-- Add a Loader node
		-- nodeString = nodeString .. AddLoaderNode(loader3DName, 'none', loaderFilename, loaderFormat, frameExtensionFusionStartFrame, loaderText, lensType, loader3DNodeXPos, loader3DNodeYPos)
		
		-- --------------------------------------------------------------------------------------------
		-- Add a Camera3D node
		
		camera3DName = 'ptCamera3D' .. nodeNumber
		nodeString = nodeString .. '\t\t'.. camera3DName .. ' = Camera3D {\n'
		nodeString = nodeString .. '\t\t\tCtrlWZoom = false,\n'
		nodeString = nodeString .. '\t\t\tNameSet = true,\n'
		nodeString = nodeString .. '\t\t\tInputs = {\n'
		
		-- --------------------------------------------------------------------------------------------
		-- Camera Rotation
		
		-- Camera Rotation Axis Order
		cameraRotationOrder = 'ZYX'
		nodeString = nodeString .. '\t\t\t\t["Transform3DOp.Rotate.RotOrder"] = Input { Value = FuID { "' .. cameraRotationOrder .. '" }, },\n'
		
		-- Apply the fisheye XYZ view rotations
		-- Transform3DOp.Rotate.Y = Pans the camera around horizontally on the rig
		-- Transform3DOp.Rotate.Z = 90 Rotates the camera into the portrait layout
		
		-- Is the frame orientation a Portrait or Landscape layout?
		frameRotation = 0
	--if imageRotate == 0 then
	--		-- 0° Portrait
	--		frameRotation = 0
	--	elseif imageRotate == 1 then
	--		-- -90° Landscape
	--		frameRotation = 90
	--	elseif imageRotate == 2 then
	--		-- 180° Portrait
	--		frameRotation = 180
	--	elseif imageRotate == 3 then
	--		-- 90° Landscape
	--		frameRotation = -90
	--	else
	--		-- Fallback 0° Portrait
	--		frameRotation = 0
	--	end
		
		nodeString = nodeString .. '\t\t\t\t["Transform3DOp.Rotate.X"] = Input { Value = ' .. pitch - xRotation .. ', },\n'
		nodeString = nodeString .. '\t\t\t\t["Transform3DOp.Rotate.Y"] = Input { Value = ' .. (yaw * -1) - yRotation .. ', },\n'
		nodeString = nodeString .. '\t\t\t\t["Transform3DOp.Rotate.Z"] = Input { Value = ' .. (roll * -1) - frameRotation - zRotation .. ', },\n'
		
		-- --------------------------------------------------------------------------------------------
		-- Near and Far plane clipping
		nodeString = nodeString .. '\t\t\t\tPerspNearClip = Input { Value = ' .. camera3DNearClip .. ', },\n'
		nodeString = nodeString .. '\t\t\t\tPerspFarClip = Input { Value = ' .. camera3DFarClip .. ', },\n'
		
		-- --------------------------------------------------------------------------------------------
		-- Camera FOV
		
		-- Limit the maximum FOV value for the Camera3D node to 175° FOV
		if tonumber(fisheyeFOV) >= 175 then
			-- Override the PTGui provided FOV value
			clampedFOV = 175
		else
			-- Use the raw PTGui value
			clampedFOV = fisheyeFOV
		end
		
		-- nodeString = nodeString .. '\t\t\t\tAoV = Input { Value = 90.8530231442286, },\n'
		
		-- Calculate the focal length in mm from the field of view in degrees
		-- horizontalFilmAperture = 1.417
		-- focal = math.tan(0.00872665 * clampedFOV)
		-- focalLengthMM = (0.5 * horizontalFilmAperture) / (focal * 0.03937)
		
		-- Ir use a canned 90° FOV equavalent focal length value
		focalLengthMM = 10
		
		-- Compute the focal length from the FOV using the PVR tan code
		nodeString = nodeString .. '\t\t\t\tFLength = Input { Value = ' .. focalLengthMM .. ', },\n'
		
		nodeString = nodeString .. '\t\t\t\t["Stereo.Mode"] = Input { Value = FuID { "OffAxis" }, },\n'
		nodeString = nodeString .. '\t\t\t\tFilmBack = Input { Value = 1, },\n'
		
		-- --------------------------------------------------------------------------------------------
		-- Filmback
		
		-- Canon 5D/1D filmback
		-- nodeString = nodeString .. '\t\t\t\tFilmGate = Input { Value = FuID { "Canon_5D_1D" }, },\n'
		-- nodeString = nodeString .. '\t\t\t\tApertureW = Input { Value = 1.41732283464567, },\n'
		-- nodeString = nodeString .. '\t\t\t\tApertureH = Input { Value = 0.799212598425197, },\n'
		
		-- User defined square ratio 1" filmback for cubic cameras
		nodeString = nodeString .. '\t\t\t\tFilmGate = Input { Value = FuID { "User" }, },\n'
		nodeString = nodeString .. '\t\t\t\tApertureW = Input { Value = 1, },\n'
		nodeString = nodeString .. '\t\t\t\tApertureH = Input { Value = 1, },\n'
		
		-- --------------------------------------------------------------------------------------------
		-- Camera Manipulator Visibility
		
		nodeString = nodeString .. '\t\t\t\tControlVis = Input { Value = 1, },\n'
		nodeString = nodeString .. '\t\t\t\tFrustumVis = Input { Value = 0, },\n'
		
		-- Should a vector line for the camera3D viewing angle be displayed?
		if showCamera3DViewVector == 1 then
			nodeString = nodeString .. '\t\t\t\tViewVectorVis = Input { Value = 1, },\n'
		else
			nodeString = nodeString .. '\t\t\t\tViewVectorVis = Input { Value = 0, },\n'
		end
		
		nodeString = nodeString .. '\t\t\t\tPerspFarClipVis = Input { Value = 0, },\n'
		nodeString = nodeString .. '\t\t\t\t["SurfacePlaneInputs.ObjectID.ObjectID"] = Input { Value = 1, },\n'
		nodeString = nodeString .. '\t\t\t\t["MtlStdInputs.MaterialID"] = Input { Value = 1, },\n'
		
		-- --------------------------------------------------------------------------------------------
		-- Connect the FlipTransform node
		
		-- nodeString = nodeString .. '\t\t\t\tImageInput = Input {\n'
		-- nodeString = nodeString .. '\t\t\t\t\tSourceOp = "' .. transformNode .. '",\n'
		-- nodeString = nodeString .. '\t\t\t\t\tSource = "Output",\n'
		-- nodeString = nodeString .. '\t\t\t\t},\n'
		
		-- --------------------------------------------------------------------------------------------
		-- Connect the Loader3D node
		-- nodeString = nodeString .. '\t\t\t\tImageInput = Input {\n'
		-- nodeString = nodeString .. '\t\t\t\t\tSourceOp = "' .. loader3DName .. '",\n'
		-- nodeString = nodeString .. '\t\t\t\t\tSource = "Output",\n'
		-- nodeString = nodeString .. '\t\t\t\t},\n'
		
		-- --------------------------------------------------------------------------------------------
		-- Add Comments for the PTGui image settings
		
		nodeCamera3DText = 'FOV: ' .. fisheyeFOV .. '\\nImage: ' .. loaderFilename .. '\\nImage Size: ' .. originalWidth .. 'x' .. originalHeight
		nodeString = nodeString .. '\t\t\t\tComments = Input { Value = "' .. nodeCamera3DText .. '", },\n'
		
		nodeString = nodeString .. '\t\t\t},\n'
		nodeString = nodeString .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. camera3DNodeXPos .. ', ' .. camera3DNodeYPos .. ' } },\n'
		nodeString = nodeString .. '\t\t},\n'
		
		-- --------------------------------------------------------------------------------------------
		-- Camera Merge Node
		
		-- Add the Merge3D node inline next to the first imported Camera3D node
		if nodeNumber == 1 then
			cameraMerge3DName = 'ptMerge3D' .. nodeNumber
			
			nodeString = nodeString .. '\t\t' .. cameraMerge3DName .. ' = Merge3D {\n'
			nodeString = nodeString .. '\t\t\tCtrlWZoom = false,\n'
			nodeString = nodeString .. '\t\t\tNameSet = true,\n'
			nodeString = nodeString .. '\t\t\tInputs = {\n'
			nodeString = nodeString .. '\t\t\t\tPassThroughLights = Input { Value = 1, },\n'
			
			-- --------------------------------------------------------------------------------------------
			-- Add the Camera3D inputs to the Merge3D node
			
			for i = 1, imageCounter do
				-- Name of the input camera
				inputCamera3DName = 'ptCamera3D' .. i
			
				nodeString = nodeString .. '\t\t\t\tSceneInput' .. i .. ' = Input {\n'
				nodeString = nodeString .. '\t\t\t\t\tSourceOp = "' .. inputCamera3DName .. '",\n'
				nodeString = nodeString .. '\t\t\t\t\tSource = "Output",\n'
				nodeString = nodeString .. '\t\t\t\t},\n'
			end
			
			-- --------------------------------------------------------------------------------------------
			
			nodeString = nodeString .. '\t\t\t},\n'
			nodeString = nodeString .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. merge3DNodeXPos .. ', ' .. merge3DNodeYPos .. ' } },\n'
			nodeString = nodeString .. '\t\t},\n'
		end
	end
	
	return nodeString
end

-- Create the new image nodes for the comp
function AddImageNodes()
	-- Check the Node Layout aka. "Build Direction" setting
	if nodeDirection == 0 then
		-- Build Nodes Skip Adding Nodes
		nodeAlignment = 'Skip Adding Nodes'
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
	
	-- Exit this function if "Skip Adding Nodes" is active
	if nodeDirection == 0 then
		return
	end
	
	-- Node Positions - read from the Fusion cursor / last node position in the future.
	nodeX = 605
	nodeY = 346
	
	-- The loader node media basefolder
	-- Todo: Double check there is a trailing folder slash in the filepath!!
	-- mediaBaseFolder = ptsFolder
	
	-- -----------------------------------------
	-- Create the block of loader node elements
	-- -----------------------------------------
	
	-- Open the Fusion comp tags
	loaderNodes = '{\n'
	loaderNodes = loaderNodes .. '\tTools = ordered() {\n'
	
	-- Loop through loading each of the mask images
	-- Total Mask Loader Node Count = Total Nodes -
	totalNodes = imageCounter - 1
	nodeNumber = 1
	
	-- Generate the media filename string from the table
	for i, m in ipairs(media) do
		-- Debug Testing
		dump(m)
		
		-- Use relative filepaths for Loaders
		if useRelativePaths == 1 then
			-- Use a shortened Comp:/ centric relative path
			
			-- The absolute source image path that is being re-written
			toFile = m.folder3 .. m.filepath2
			
			-- The location of the comp file that is used to do the relative path trimming
			fromFile = comp:GetAttrs().COMPS_FileName
			
			-- The pathmap prefix value that is added to the final relative path result
			relativePathMap = 'Comp:/'
			
			mediaClipName = ConvertToRelativePathMap(toFile, fromFile, relativePathMap)
		else
			-- Use the full absolute filepath
			-- Build the loader node image path
			mediaClipName = m.folder3 .. m.filepath2
			-- mediaClipName = m.filepath2
		end
		
		nodeLoaderName = m.nodename1
		imageFormatFusion = m.extension5
		
		-- f0 = Rectilinear / f2 = Circular Fisheye
		if crop[nodeNumber].lens11 ~= nil then
			lens = crop[nodeNumber].lens11
		else
			-- Circular Fisheye
			-- lens = 2
			
			-- Rectilinear
			-- lens = 1
			
			-- Fallback
			lens = -1
		end
		
		nodeCropName = crop[nodeNumber].nodename1
		
		mediaWidth = m.width6
		mediaHeight = m.height7
		
		xSize = crop[nodeNumber].right3 - crop[nodeNumber].left2
		ySize = crop[nodeNumber].bottom5 - crop[nodeNumber].top4
		xOffset = crop[nodeNumber].left2
		yOffset = crop[nodeNumber].top4
		
		-- FisheyeCropMask Center(x,y) positions in relative 0-1 units
		maskCenterX = (crop[nodeNumber].left2 + (xSize * 0.5)) / mediaWidth
		-- Example: maskCenterX = (18 + (2844 * 0.5)) / 2880
		maskCenterY = (crop[nodeNumber].top4 + (ySize * 0.5)) / mediaHeight
		-- Example: maskCenterY = (2904 + (2844 * 0.5)) / 5760
		
		if crop[nodeNumber].roll9 ~= nil then
			roll = crop[nodeNumber].roll9
		else
			roll = 0
		end
		
		if crop[nodeNumber].yaw8 ~= nil then
			yaw = crop[nodeNumber].yaw8
		else
			yaw = 0
		end
		
		if crop[nodeNumber].pitch10 ~= nil then
			pitch = crop[nodeNumber].pitch10
		else
			pitch = 0
		end
		
		if globalLens[1].fov1 ~= nil then
			hFOV = globalLens[1].fov1
		else
			hFOV = 180.0
		end
		
		
		outputHeight = output[1].height3
		-- outputHeight = 1920
		
		print('[#] ' .. nodeNumber .. ' [Image Dimensions] ' .. ' [xOffset] ' .. xOffset .. ' [yOffset] ' .. yOffset .. ' [xSize] ' .. xSize .. ' [ySize] ' .. ySize .. ' [View Rotate] ' .. ' [Roll] ' .. roll .. ' [Yaw] ' .. yaw .. ' [Pitch] ' .. pitch .. ' [FOV] ' .. hFOV .. ' [Lens] ' .. lens .. ' [Center X/Y] ' .. maskCenterX .. '/' .. maskCenterY)
		
		if eyeon.fileexists(comp:MapPath(mediaClipName)) then
			-- Try finding the mask image with no padding first
			print('[Media File Found] ' .. mediaClipName)
		end
		
		if err == true then
			-- Skipping the loader node as the media is missing
			print('[Skipping Loader Node] ' .. nodeLoaderName .. ' [Media] ' .. mediaClipName)
		else
			-- Add the newest loader node
			print('[Adding Loader Node] ' .. nodeLoaderName .. ' [Media] ' .. mediaClipName)
			loaderNodes = loaderNodes .. CreateLoaderNodes(nodeNumber, nodeLoaderName, mediaClipName, imageFormatFusion, nodeX, nodeY, nodeAlignment, nodeCropName, xOffset, yOffset, xSize, ySize, roll, yaw, pitch, hFOV, lens, mediaWidth, mediaHeight, outputHeight, maskCenterX, maskCenterY)
		end
		
		-- Track the current node for the placement in the scene
		nodeNumber = nodeNumber + 1
	end
	
	-- Add a saver node
	if importSaver == 1 then
		nodeSaverNode = output[1].nodename1
		outputHeight = output[1].height3
		outputWidth = output[1].width2
		outputFormat = output[1].format4
		outputExtension = output[1].extension5
		outputFOV = output[1].fov6
		-- outputHeight = 1920
		
		-- Create the image output filename for the saver node: <name>.<padded frame>.<ext>
		-- Use relative filepaths for Savers
		if useRelativePaths == 1 then
			-- Use a shortened Comp:/ centric relative path
			
			-- The absolute saver image path that is being re-written
			toFile = trimExtension(ptguiFile) .. frameExtensionNumber .. '.' .. outputExtension
			
			-- The location of the comp file that is used to do the relative path trimming
			fromFile = comp:GetAttrs().COMPS_FileName
			
			-- The pathmap prefix value that is added to the final relative path result
			relativePathMap = 'Comp:/'
			
			-- Build the saver node image path
			outputFilename = ConvertToRelativePathMap(toFile, fromFile, relativePathMap)
		else
			-- Use the full absolute filepath
			-- Build the saver node image path
			outputFilename = trimExtension(ptguiFile) .. frameExtensionNumber .. '.' .. outputExtension
		end
		
		
		loaderNodes = loaderNodes .. CreateSaverNode(nodeNumber, nodeSaverNode, nodeX, nodeY, nodeAlignment, outputWidth,	 outputHeight, outputFormat, outputFilename)
	end

	-- Close the Fusion comp tags
	loaderNodes = loaderNodes .. '\t}\n}'

	print('[Creating Loader Nodes]')
	-- print(loaderNodes)

	-- Add the new loader nodes to the system clipboard buffer
	print('[Copying Loader Nodes to Clipboard]')
	CopyToClipboard(loaderNodes)
end

-- ------------------------------------
-- Main
-- ------------------------------------

-- Main Code
function Main()
	print('[PTGui Project Importer]')
	print('PTGui Project Importer is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)
	
	-- Check if Fusion is running
	if not fusion then
		print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
		return
	end

	-- Lock the comp flow area
	comp:Lock()

	-- Show the dialog window
	-- Note: The AskUser dialog settings are covered on page 63 of the Fusion Scripting Guide
	compPath = dirname(comp:GetAttrs().COMPS_FileName)
	compPrefs = comp:GetPrefs("Comp.FrameFormat")
	
	-- ------------------------------------
	-- Load the comp specific preferences
	-- ------------------------------------
	
	-- PTGui Project File - use the comp path as the default starting value if the preference doesn't exist yet
	ptguiFile = comp:MapPath(getPreferenceData('KartaVR.PTGuiImporter.File', compPath, printStatus))
	xRotation = getPreferenceData('KartaVR.PTGuiImporter.XRotation', 0, printStatus)
	yRotation = getPreferenceData('KartaVR.PTGuiImporter.YRotation', 0, printStatus)
	zRotation = getPreferenceData('KartaVR.PTGuiImporter.ZRotation', 0, printStatus)
	edgeBlending = getPreferenceData('KartaVR.PTGuiImporter.EdgeBlending', 1, printStatus)
	nodeDirection = getPreferenceData('KartaVR.PTGuiImporter.NodeDirection', 2, printStatus)
	splitView = getPreferenceData('KartaVR.PTGuiImporter.SplitView', 5, printStatus)
	
	-- frameExtension = getPreferenceData('KartaVR.PTGuiImporter.FrameExtension', 1, printStatus)
	
	framePadding = getPreferenceData('KartaVR.PTGuiImporter.FramePadding', 4, printStatus)
	importImages = getPreferenceData('KartaVR.PTGuiImporter.ImportImages', 1, printStatus)
	importCropping = getPreferenceData('KartaVR.PTGuiImporter.ImportCropping', 1, printStatus)
	importPaintedMasks = getPreferenceData('KartaVR.PTGuiImporter.ImportPaintedMasks', 0, printStatus)
	importVectorMasks = getPreferenceData('KartaVR.PTGuiImporter.ImportVectorMasks', 1, printStatus)
	importLensSettings = getPreferenceData('KartaVR.PTGuiImporter.ImportLensSettings', 1, printStatus)
	importGridWarp = getPreferenceData('KartaVR.PTGuiImporter.ImportGridWarp', 0, printStatus)
	importCamera3D = getPreferenceData('KartaVR.PTGuiImporter.ImportCamera3D', 0, printStatus)
	importSaver = getPreferenceData('KartaVR.PTGuiImporter.ImportSaver', 1, printStatus)
	importIntermediateSaver = getPreferenceData('KartaVR.PTGuiImporter.ImportIntermediateSaver', 0, printStatus)
	-- imageRotate = getPreferenceData('KartaVR.PTGuiImporter.ImageRotate', 0, printStatus)
	startOnFrameOne = getPreferenceData('KartaVR.PTGuiImporter.StartOnFrameOne', 1, printStatus)
	useRelativePaths = getPreferenceData('KartaVR.PTGuiImporter.UseRelativePaths', 1, printStatus)
	openOutputFolder = getPreferenceData('KartaVR.PTGuiImporter.OpenOutputFolder', 0, printStatus)
	
	-- Vector mask edge blending softness
	edgeBlendingList = {'No Blending', 'Hard Blending', 'Normal Blending', 'Soft Blending'}
	
	-- Node Build Direction
	nodeDirectionList = {'Skip Adding Nodes', 'Build Nodes Left', 'Build Nodes Right', 'Build Nodes Upwards', 'Build Nodes Downwards'}
	
	splitViewList = {'Left', 'Right', 'Top', 'Bottom', 'Full Frame', 'Skip Adding Split View Masking'}
	
	-- Frame Extension List
	-- frameExtensionList = {'<prefix>.ext', '<prefix>.0000.ext', '<prefix>.0001.ext'}
	
	imageRotateList = {'0° Portrait Orientation', '90° CCW Landscape Orientation', '180° Portrait Orientation', '90° CW Landscape Orientation'}
	
	msg = 'This script will load the stitching settings from a PTGui .pts project file into your clipboard. Use the Paste command to add the results to your comp.'
	
	d = {}
	d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg}
	d[2] = {'File', Name = 'PTGui Project File', 'FileBrowse', Default = ptguiFile}
	d[3] = {'YRotation', Name = 'Yaw (Y Rotation)', 'Screw', Default = yRotation, Integer = true, Min = -360, Max = 360}
	d[4] = {'ZRotation', Name = 'Pitch (Z Rotation)', 'Screw', Default = zRotation, Integer = true, Min = -360, Max = 360}
	d[5] = {'XRotation', Name = 'Roll (X Rotation)', 'Screw', Default = xRotation, Integer = true, Min = -360, Max = 360}
	d[6] = {'EdgeBlending', Name = 'Edge Blending', 'Dropdown', Default = edgeBlending, Options = edgeBlendingList}
	d[7] = {'SplitView', Name = 'Split View', 'Dropdown', Default = splitView, Options = splitViewList}
	d[8] = {'NodeDirection', Name = 'Node Layout', 'Dropdown', Default = nodeDirection, Options = nodeDirectionList}
	-- d[8] = {'ImageRotate', Name = 'Image Rotate', 'Dropdown', Default = imageRotate, Options = imageRotateList}
	-- d[9] = {'FrameExtension', Name = 'Frame Ext.', 'Dropdown', Default = frameExtension, Options = frameExtensionList}
	d[10] = {'FramePadding', Name = 'Frame Padding', 'Slider', Default = framePadding, Integer = true, Min = 0, Max = 8}
	d[11] = {'ImportSaver', Name = 'Add Saver Node', 'Checkbox', Default = importSaver, NumAcross = 2}
	d[12] = {'ImportIntermediateSaver', Name = 'Add Intermediate Saver Nodes', 'Checkbox', Default = importIntermediateSaver, NumAcross = 2}
	d[13] = {'ImportImages', Name = 'Add Image Loader Nodes', 'Checkbox', Default = importImages, NumAcross = 2}
	d[14] = {'ImportCropping', Name = 'Add Cropping Nodes', 'Checkbox', Default = importCropping, NumAcross = 2}
	--d[15] = {'ImportPaintedMasks', Name = 'Import Painted Masks', 'Checkbox', Default = importPaintedMasks, NumAcross = 2}
	d[15] = {'ImportVectorMasks', Name = 'Add Vector Masks', 'Checkbox', Default = importVectorMasks, NumAcross = 2}
	d[16] = {'ImportLensSettings', Name = 'Add Stitching Nodes', 'Checkbox', Default = importLensSettings, NumAcross = 2}
	d[17] = {'ImportGridWarp', Name = 'Add GridWarp Nodes', 'Checkbox', Default = importGridWarp, NumAcross = 2}
	d[18] = {'ImportCamera3D', Name = 'Add Camera3D Nodes', 'Checkbox', Default = importCamera3D, NumAcross = 2}
	d[19] = {'StartOnFrameOne', Name = 'Mask Numbering Starts on 1', 'Checkbox', Default = startOnFrameOne, NumAcross = 2}
	d[20] = {'UseRelativePaths', Name = 'Use Relative Paths for Loaders', 'Checkbox', Default = useRelativePaths, NumAcross = 2}
	d[201] = {'OpenOutputFolder', Name = 'Open Output Folder', 'Checkbox', Default = openOutputFolder, NumAcross = 1}
	
	dialog = comp:AskUser('PTGui Project Importer', d)
	if dialog == nil then
		print('You cancelled the dialog!')
		err = true
	
		-- Unlock the comp flow area
		comp:Unlock()
		return
	else
		-- Debug - List the output from the AskUser dialog window
		-- dump(dialog)
		
		ptguiFile = comp:MapPath(dialog.File)
		setPreferenceData('KartaVR.PTGuiImporter.File', ptguiFile, printStatus)
		
		-- imageRotate = dialog.ImageRotate
		-- setPreferenceData('KartaVR.PTGuiImporter.ImageRotate', imageRotate, printStatus)
		
		nodeDirection = dialog.NodeDirection
		setPreferenceData('KartaVR.PTGuiImporter.NodeDirection', nodeDirection, printStatus)
		
		splitView = dialog.SplitView
		setPreferenceData('KartaVR.PTGuiImporter.SplitView', splitView, printStatus)
		
		edgeBlending = dialog.EdgeBlending
		setPreferenceData('KartaVR.PTGuiImporter.EdgeBlending', edgeBlending, printStatus)
		
		-- frameExtension = dialog.FrameExtension
		-- setPreferenceData('KartaVR.PTGuiImporter.FrameExtension', frameExtension, printStatus)
		
		framePadding = dialog.FramePadding
		setPreferenceData('KartaVR.PTGuiImporter.FramePadding', framePadding, printStatus)
		
		xRotation = dialog.XRotation
		setPreferenceData('KartaVR.PTGuiImporter.XRotation', xRotation, printStatus)
		
		yRotation = dialog.YRotation
		setPreferenceData('KartaVR.PTGuiImporter.YRotation', yRotation, printStatus)
		
		zRotation = dialog.ZRotation
		setPreferenceData('KartaVR.PTGuiImporter.ZRotation', zRotation, printStatus)
		
		importImages = dialog.ImportImages
		setPreferenceData('KartaVR.PTGuiImporter.ImportImages', importImages, printStatus)
		
		importCropping = dialog.ImportCropping
		setPreferenceData('KartaVR.PTGuiImporter.ImportCropping', importCropping, printStatus)
		
		-- importPaintedMasks = dialog.ImportPaintedMasks
		-- setPreferenceData('KartaVR.PTGuiImporter.ImportPaintedMasks', importPaintedMasks, printStatus)
		
		importVectorMasks = dialog.ImportVectorMasks
		setPreferenceData('KartaVR.PTGuiImporter.ImportVectorMasks', importVectorMasks, printStatus)
		
		importLensSettings = dialog.ImportLensSettings
		setPreferenceData('KartaVR.PTGuiImporter.ImportLensSettings', importLensSettings, printStatus)
	
		importGridWarp = dialog.ImportGridWarp
		setPreferenceData('KartaVR.PTGuiImporter.ImportGridWarp', importGridWarp, printStatus)
		
		importCamera3D = dialog.ImportCamera3D
		setPreferenceData('KartaVR.PTGuiImporter.ImportCamera3D', importCamera3D, printStatus)
		
		importSaver = dialog.ImportSaver
		setPreferenceData('KartaVR.PTGuiImporter.ImportSaver', importSaver, printStatus)
		
		importIntermediateSaver = dialog.ImportIntermediateSaver
		setPreferenceData('KartaVR.PTGuiImporter.ImportIntermediateSaver', importIntermediateSaver, printStatus)
		
		startOnFrameOne = dialog.StartOnFrameOne
		setPreferenceData('KartaVR.PTGuiImporter.StartOnFrameOne', startOnFrameOne, printStatus)
		
		useRelativePaths = dialog.UseRelativePaths
		setPreferenceData('KartaVR.PTGuiImporter.UseRelativePaths', useRelativePaths, printStatus)
		
		openOutputFolder = dialog.OpenOutputFolder
		setPreferenceData('KartaVR.PTGuiImporter.OpenOutputFolder', openOutputFolder, printStatus)
		
		print('[X Rotation] ' .. xRotation)
		print('[Y Rotation] ' .. yRotation)
		print('[Z Rotation] ' .. xRotation)
		print('[Edge Blending] ' .. edgeBlending)
		print('[Node Direction] ' .. nodeDirection)
		print('[Split View Masking] ' .. splitView)
		-- print('[Frame Orientation] ' .. imageRotate)
		print('[Frame Padding] ' .. framePadding)
		print('[Import Images] ' .. importImages)
		print('[Import Cropping] ' .. importCropping)
		print('[Import Painted Masks] ' .. importPaintedMasks)
		print('[Import Vector Masks] ' .. importVectorMasks)
		print('[Import Lens Settings] ' .. importLensSettings)
		print('[Add GridWarp Node] ' .. importGridWarp)
		print('[Add Camera3D Node] ' .. importCamera3D)
		print('[Add Saver Node] ' .. importSaver)
		print('[Add Intermediate Saver Nodes] ' .. importIntermediateSaver)
		print('[Start View Numbering on 1] ' .. startOnFrameOne)
		print('[Use Relative Paths] ' .. useRelativePaths)
		print('[Open Output Folder] ' .. openOutputFolder)
	end

	-- Todo: Add a sanity check to make sure the PTGui file actually exists on disk
	print('[PTGui Project File] ' .. dialog.File)
	
	-- Check if the PTGui filename ends with the .pts file extension
	searchString = 'pts$'
	if ptguiFile:match(searchString) ~= nil then
		-- ptguiFileExtension = getExtension(ptguiFile)
		-- if ptguiFileExtension == 'pts' then
		
		print('[A PTGui project file was selected and it has the .pts file extension.]')
		
		-- The PTGui .pts project file is missing
		if eyeon.fileexists(ptguiFile) == false then
			print('[The PTGui project file you selected is missing]')
			
			-- Unlock the comp flow area
			comp:Unlock()
			
			return
		end
	else
		print('[A PTGui project file was not selected.]')
		
		-- Unlock the comp flow area
		comp:Unlock()
		
		return
	end
	
	-- PTGui project file directory
	ptsFolder = dirname(ptguiFile)
	
	--
	---- The mask image final sequence frame numbers
	---- This starts on either none, frame 0000, or frame 0001
	--frameExtensionNumber = ''
	--if frameExtension == 0 then
	-- -- None (skip adding a frame extension number)
	--	frameExtensionNumber = ''
	--	frameExtensionFusionStartFrame = -1
	--elseif frameExtension == 1 then
	--	-- Start the image sequence on frame 0
	--	frameExtensionNumber = '.0000'
	--	frameExtensionFusionStartFrame = 0
	--else
	--	-- Start the image sequence on frame 1
	--	frameExtensionNumber = '.0001'
	--	frameExtensionFusionStartFrame = 1
	--end
	
	-- Extract the images
	ImageRegex(ptguiFile, framePadding, startOnFrameOne)
	print('[Images Found] ' .. imageCounter)
	
	---- The mask image final sequence frame numbers
	---- This starts on either none, frame 0000, or frame 0001
	if imageCounter >= 1 then
	frameExtension, frameExtensionNumber, frameExtensionFusionStartFrame	= CheckFrameExtension(media[imageCounter].filepath2)
		print('[Frame Extension] ' .. frameExtension)
	end
	
	-- Create the new image nodes for the comp
	AddImageNodes()
	
	-- Unlock the comp flow area
	comp:Unlock()
	
	-- Report if the Fusion HiQ mode is enabled
	if comp:GetAttrs().COMPB_HiQ == true then
		print('[HiQ] The Fusion high quality mode is enabled so the stitching previews will look crisp.')
	else
		print('[HiQ] The Fusion high quality mode was activated so the stitching previews will look crisp. This was done by turning on the "HiQ" button in the Fusion timeline for crisper previews.')
		comp:SetAttrs{COMPB_HiQ = true}
	end
	
	-- Open the PTGui .pts folder as an Explorer/Finder/Nautilus folder view
	if openOutputFolder == 1 then
	 openDirectory(ptsFolder)
	end
	
	-- Play a sound effect
	CompletedSound()
end

-- ---------------------------------------------------------
-- ---------------------------------------------------------

-- Main Code
Main()

-- End of the script
print('[Done]')
return
