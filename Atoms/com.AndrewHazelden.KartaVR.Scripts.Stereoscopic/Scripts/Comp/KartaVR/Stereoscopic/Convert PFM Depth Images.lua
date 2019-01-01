--[[--
----------------------------------------------------------------------------
Convert PFM Depth Images v4.0.1 - 2019-01-01

by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The Convert PFM Depth Images script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that lets you extract 16-bit per channel greyscale images from a folder's worth of Portable Float Map .pfm depth imagery.

How to use the Script:

Step 1. Start Fusion and open a new comp. Then run the Script > KartaVR > Stereoscopic > Convert PFM Depth Images menu item.

Step 2. In the Convert PFM Depth Images dialog window you need to define the output formats and settings for the imagery.

Note: The close X box on the dialog window does not work. You have to hit the "Cancel" button to close the window.

----------------------------------------------------------------------------

Command Line pfmtopsd usage:

Tip: To pipe the pfmtopsd format .psd output directly to imagemagick use:
./pfmtopsd "$HOME/Desktop/pfm/depth16.pfm" | convert psd:- jpg:"$HOME/Desktop/pfm/image.jpg"
./pfmtopsd "$HOME/Desktop/pfm/depth16.pfm" | convert psd:- tif:"$HOME/Desktop/pfm/image.tif"
./pfmtopsd "$HOME/Desktop/pfm/depth16.pfm" | convert psd:- exr:"$HOME/Desktop/pfm/image.exr"
./pfmtopsd "$HOME/Desktop/pfm/depth16.pfm" | convert psd:- tga:"$HOME/Desktop/pfm/image.tga"

----------------------------------------------------------------------------
Todo List:

Todo: Implement the "Process Sub-Folders" checkbox
Todo: Apply a linear workflow gamma setting to the EXR media
Todo: The Default KartaVR "Cactus Lab" provided ImageMagick tool should be enabled by default.

--]]--

-- --------------------------------------------------------------------------
local printStatus = false

-- Find out if we are running Fusion 7 or 8
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

-- Take a base filename and remove just the final extension
function trimExtensionfromFilename(mediaDirName)
	name, extension = string.match(mediaDirName, '^(.+)(%..+)$')
	
	return name or ''
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


-- Use pfmtopsd to transcode the files
function pfmTranscodeMedia(pfmFolder, imageFormat, imageName, framePadding, compress, startOnFrameOne, openFolder)
	-- Select the image file format
	if imageFormat == 0 then
		imageFormatExt = 'none'
	elseif imageFormat == 1 then
		imageFormatExt = 'exr'
	elseif imageFormat == 2 then
		imageFormatExt = 'tif'
	elseif imageFormat == 3 then
		imageFormatExt = 'jpg'
	elseif imageFormat == 4 then
		imageFormatExt = 'tga'
	elseif imageFormat == 5 then
		imageFormatExt = 'png'
	elseif imageFormat == 6 then
		imageFormatExt = 'psd'
	elseif imageFormat == 7 then
		imageFormatExt = 'dpx'
	else
		-- Fallback option
		imageFormatExt = 'tif'
	end
	
	-- Image Compression Settings
	compressionMode = ''
	if compress == 0 then
		-- compressionMode = ''
		-- compressionMode = ' +compress '
		compressionMode = ' -compress NONE '
	elseif compress == 1 then
		-- RLE is known as the PackBits codec in TIFF images
		compressionMode = ' -compress RLE '
	elseif compress == 2 then
		compressionMode = ' -compress LZW '
	end
	
	-- Image DPI Setting
	dpi = ' -density 72 -units pixelsperinch '
	
	-- Bits Per Channel - Extras: -colorspace RGB -type TrueColorMatte 
	colorDepth = ' -set "colorspace:auto-grayscale" "false" -depth 16 -type truecolor'
	
	-- Parenthesis
	openParen = ''
	closeParen = ''
	if platform == 'Windows' then
		openParen = ' ( '
		closeParen = ' ) '
	elseif platform == 'Mac' then
		openParen = ' \\( '
		closeParen = ' \\) '
	elseif platform == 'Linux' then
		openParen = ' \\( '
		closeParen = ' \\) '
	else
		openParen = ' \\( '
		closeParen = ' \\) '
	end
	
	print('[Working Directory] ' .. pfmFolder )
	
	print('\n')
	
	-- Create a new LUA table for the files to process
	filesList = {}
	
	dirCommand = ''
	if platform == 'Windows' then
		-- The dir options '/b /ad' lists directories and '/b' lists just files
		dirCommand = 'dir ' .. pfmFolder .. ' /b'
	else
		dirCommand = 'ls -a "' .. pfmFolder .. '"'
	end
	
	-- print('[Directory Listing]')
	-- Search the selected directory for movie content
	for files in io.popen(dirCommand):lines() do 
		-- print(files)
		-- Add another file to the filesList table
		fileNoCase = files.lower(files)
		if fileNoCase:match('.*%.pfm') then
			table.insert(filesList, files)
		end
	end
	
	print('\n')
	
	-- List what we got in the table
	print('[PFM Listing]')
	dump(filesList)
	
	print('\n')
	
	-- Keep the frame padding a positive number
	if framePadding < 0 then
		framePadding = 0
		print('[Resetting Frame Padding] ' .. framePadding)
		setPreferenceData('KartaVR.ConvertPFM.FramePadding', framePadding, printStatus)
	end
	
	-- frameNumber = ''
	-- if startOnFrameOne == 0 then
		-- Start the image sequence on frame 0
		-- frameNumber = '0000'
	-- else
		-- Start the image sequence on frame 1
		-- frameNumber = '0001'
	-- end
	
	-- Create the frame number with the frame padding value
	-- frameNumber = '%0' .. framePadding .. 'd'
	frameNumber = '000' .. startOnFrameOne
	
	-- Track the previous output folder if a filename token is used to make folders on the fly
	previousOutputDirectory = ''
	
	-- Process the items in the current folder
	print('[Transcoded Media]')
	for i, files in ipairs(filesList) do
		-- Generate the extracted filename
		if imageName == 0 then
			-- <name>.<ext>
			imgSeqFile = pfmFolder .. trimExtensionfromFilename(files) .. '.' .. imageFormatExt
		elseif imageName == 1 then
			-- <name>.#.<ext>
			imgSeqFile = pfmFolder .. trimExtensionfromFilename(files) .. '.' .. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 2 then
			-- <name>_#.<ext>
			imgSeqFile = pfmFolder .. trimExtensionfromFilename(files) .. '_' .. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 3 then
			-- <name>#.<ext>
			imgSeqFile = pfmFolder .. trimExtensionfromFilename(files).. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 4 then
			-- <name>/<name>.#.<ext> (In a Subfolder)
			imgSeqFile = pfmFolder .. trimExtensionfromFilename(files) .. osSeparator .. getFilenameNoExt(files) .. '.' .. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 5 then
			-- <name>/<name>_#.<ext> (In a Subfolder)
			imgSeqFile = pfmFolder .. trimExtensionfromFilename(files) .. osSeparator .. getFilenameNoExt(files) .. '_' .. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 6 then
			-- <name>/#.<ext> (In a Subfolder)
			imgSeqFile = pfmFolder .. trimExtensionfromFilename(files) .. osSeparator .. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 7 then
			-- #/<name>.<ext> (In a Subfolder)
			imgSeqFile = pfmFolder .. frameNumber .. osSeparator .. getFilenameNoExt(files) .. '.' .. frameNumber .. '.' .. imageFormatExt
		else 
			-- <name>.<ext>
			imgSeqFile = pfmFolder .. trimExtensionfromFilename(files) .. '.' .. imageFormatExt
		end
		
		-- -----------------------------------
		-- Run PFM on the media clip
		-- -----------------------------------
		-- PFM input image
		sourceMovie = pfmFolder .. files
		
		-- Create the output directory
		outputDirectory = dirname(imgSeqFile)
		if platform == 'Windows' then
			os.execute('mkdir "' .. outputDirectory..'"')
		else
			-- Mac and Linux
			os.execute('mkdir -p "' .. outputDirectory..'"')
		end
		
		-- Open up the output folder
		if openFolder == 1 then
			if outputDirectory ~= previousOutputDirectory then
				if imageName == 5 then
					-- Open the based folder if the mode "#/<name>.<ext> (In a Subfolder)" is selected
					openDirectory(pfmFolder)
				else
					openDirectory(outputDirectory)
				end
			end
		end
		
		-- Select the image file format
		if imageFormat == 0 then
			print('[Skipping PFM Conversion]')
		else
			-- List the newly generated sequence file names
			print('[' .. imageFormatExt .. ' Image Conversion]' .. '[' .. i .. '] [Image Sequence] ' .. imgSeqFile)
			
			-- Redirect the output from the terminal to a log file
			outputLog = outputDirectory .. 'pfmTranscode.txt'
			logCommand = ''
			if platform == 'Windows' then
				-- logCommand = ' ' .. '2> "' .. outputLog .. '" '
				-- logCommand = ' ' .. '> "' .. outputLog .. '" 2>&1'
				logCommand = ' ' .. '2>&1 | "' .. app:MapPath('Reactor:/Deploy/Bin/wintee/bin/wtee.exe') .. '" -a "' .. outputLog .. '" '
			elseif platform == 'Mac' then
				-- logCommand = ' ' .. '2> "' .. outputLog .. '" '
				-- logCommand = ' ' .. '> "' .. outputLog .. '" 2>&1'
				logCommand = ' ' .. '2>&1 | tee -a "' .. outputLog.. '" '
			elseif platform == 'Linux' then
				-- logCommand = ' ' .. '2> "' .. outputLog .. '" '
				-- logCommand = ' ' .. '> "' .. outputLog .. '" 2>&1'
				logCommand = ' ' .. '2>&1 | tee -a "' .. outputLog.. '" '
			end 
			
			-- Launch the PFM converter tool
			if platform == 'Windows' then
				-- Running on Windows
				
				pfmProgram = app:MapPath('Reactor:/Deploy/Bin/KartaVR/tools/pfmtopsd.exe')
				defaultImagemagickProgram = comp:MapPath('Reactor:/Deploy/Bin/imagemagick/bin/imconvert.exe')
				imagemagickProgram = getPreferenceData('KartaVR.SendMedia.ImagemagickFile', defaultImagemagickProgram, printStatus)
				pfmCommand = ' "' .. pfmProgram .. '" "' .. sourceMovie .. '" | "' .. imagemagickProgram '" ' .. colorDepth .. ' psd:- ' .. ' ' .. colorDepth .. dpi .. compressionMode .. ' ' .. imageFormatExt .. ':' .. '"' .. imgSeqFile .. '"'
				command = 'start "" ' .. pfmCommand .. logCommand
				
				print('[PFM Launch Command] ', command)
				os.execute(command)
			elseif platform == 'Mac' then
				-- Running on Mac
				pfmProgram = app:MapPath('Reactor:/Deploy/Bin/KartaVR/mac_tools/pfmtopsd')
				
				-- ****** The Default KartaVR "Cactus Lab" provided ImageMagick tool should be enabled by default:
				defaultImagemagickProgram = '/opt/ImageMagick/bin/convert'
				
				-- Mac Ports Compiled/Official site downloaded ImageMagick:
				-- defaultImagemagickProgram = '/opt/local/bin/convert'
				
				-- Manual compiled ImageMagick:
				-- defaultImagemagickProgram = '/usr/local/bin/convert'
				
				imagemagickProgram = getPreferenceData('KartaVR.SendMedia.ImagemagickFile', defaultImagemagickProgram, printStatus)
				
				-- unused addons:  .. colorDepth .. dpi .. compressionMode ..
				-- pfmCommand = ' ' .. pfmProgram .. ' ' .. '"' .. sourceMovie .. '" | ' .. imagemagickProgram .. ' psd:- ' .. imageFormatExt .. ':' .. '"' .. imgSeqFile .. '"'
				
				pfmCommand = '"' .. pfmProgram .. '" "' .. sourceMovie .. '" | "' .. imagemagickProgram .. '" ' .. colorDepth .. ' psd:- ' .. ' ' .. colorDepth .. dpi .. compressionMode .. ' ' .. imageFormatExt .. ':' .. '"' .. imgSeqFile .. '"'
				command = pfmCommand .. logCommand
				
				print('[PFM Launch Command] ', command)
				os.execute(command)
			else
				-- Running on Linux
				
				-- pfm depth converter program
				pfmProgram = app:MapPath('Reactor:/Deploy/Bin/KartaVR/linux_tools/pfmtopsd')
				
				-- Imagemagick convert program
				defaultImagemagickProgram = '/usr/bin/convert'
				imagemagickProgram = getPreferenceData('KartaVR.SendMedia.ImagemagickFile', defaultViewerProgram, printStatus)
				
				pfmCommand = '"' .. pfmProgram .. '" "' .. sourceMovie .. '" | "' .. imagemagickProgram .. '" ' .. colorDepth .. ' psd:- ' .. ' ' .. colorDepth .. dpi .. compressionMode .. ' ' .. imageFormatExt .. ':' .. '"' .. imgSeqFile .. '"'
				command = pfmCommand .. logCommand
				
				print('[PFM Launch Command] ', command)
				os.execute(command)
			end
		end
		
		-- -----------------------------------
		-- Track the last folder written to
		previousOutputDirectory = outputDirectory
	end
	
	print('\n')
end


print('Convert PFM Depth Images is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

-- Check if Fusion is running
if not fusion then
	print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
end


-- Lock the comp flow area
comp:Lock()


-- ------------------------------------
-- Load the preferences
-- ------------------------------------

-- Note: The AskUser dialog settings are covered on page 63 of the Fusion Scripting Guide
compPath = dirname(comp:GetAttrs().COMPS_FileName)
if compName ~= nil and compName ~= '' then
	-- In Resolve where there is no comp filename save the result to the Temp folder.
	compPath = comp:MapPath('Temp:\\KartaVR\\')
end

-- Location of movies - use the comp path as the default starting value if the preference doesn't exist yet
pfmFolder = getPreferenceData('KartaVR.ConvertPFM.PFMFolder', compPath, printStatus)

-- if imageName is 0 = <name>.#.<ext> and 4 = <name>/<name>.#.<ext>
imageName = getPreferenceData('KartaVR.ConvertPFM.ImageName', 0, printStatus)
imageFormat = getPreferenceData('KartaVR.ConvertPFM.ImageFormat', 2, printStatus)
compress = getPreferenceData('KartaVR.ConvertPFM.Compression', 2, printStatus)
framePadding = getPreferenceData('KartaVR.ConvertPFM.FramePadding', 4, printStatus)
startOnFrameOne = getPreferenceData('KartaVR.ConvertPFM.StartOnFrameOne', 1, printStatus)
soundEffect = getPreferenceData('KartaVR.ConvertPFM.SoundEffect', 1, printStatus)
openFolder = getPreferenceData('KartaVR.ConvertPFM.OpenFolder', 1, printStatus)
-- procesSubFolders = getPreferenceData('KartaVR.ConvertPFM.ProcesSubFolders', 1, printStatus)

msg = 'Customize the settings for converting a folder of Portable Float Map (.pfm) format greyscale depth images.'

namingList = {'<name>.<ext>', '<name>.#.<ext>', '<name>_#.<ext>', '<name>#.<ext>'}
-- namingList = {'<name>.<ext>', '<name>.#.<ext>', '<name>_#.<ext>', '<name>#.<ext>', '<name>/<name>.#.<ext> (In a Subfolder)', '<name>/<name>_#.<ext> (In a Subfolder)', '<name>/#.<ext> (In a Subfolder)'}

-- Extra option needs a numbered folder creation: '#/<name>.<ext> (In a Subfolder)'
-- namingList = {'<name>.#.<ext>', '<name>_#.<ext>', '<name>#.<ext>', '<name>/<name>.#.<ext> (In a Subfolder)', '<name>/<name>_#.<ext> (In a Subfolder)', '<name>/#.<ext> (In a Subfolder)', '#/<name>.<ext> (In a Subfolder)'}

-- Image format list with high bit depth formats
formatList = {'None', 'EXR', 'TIFF', 'JPEG', 'TGA', 'PNG', 'PSD', 'DPX'}

-- Image compression list
compressionList = {'None', 'RLE', 'LZW'}

-- Sound effect list
soundEffectList = {'None', 'On Error Only', 'Steam Train Whistle Sound', 'Trumpet Sound', 'Braam Sound'}

d = {}
d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg}
d[2] = {'PFMFolder', Name = 'PFM Folder', 'PathBrowse', Default = pfmFolder}
d[3] = {'ImageName', Name = 'Image Name', 'Dropdown', Default = imageName, Options = namingList}
d[4] = {'ImageFormat', Name = 'Image Format', 'Dropdown', Default = imageFormat, Options = formatList}
d[5] = {'Compression', Name = 'Compression', 'Dropdown', Default = compress, Options = compressionList}
d[6] = {'SoundEffect', Name = 'Sound Effect', 'Dropdown', Default = soundEffect, Options = soundEffectList}
d[7] = {'FramePadding', Name = 'Frame Padding', 'Slider', Default = framePadding, Integer = true, Min = 0, Max = 8}
d[8] = {'StartOnFrameOne', Name = 'Start on Frame 1', 'Checkbox', Default = startOnFrameOne, NumAcross = 2}
d[9] = {'OpenFolder', Name = 'Open Output Folder', 'Checkbox', Default = openFolder, NumAcross = 1}
-- d[10] = {'ProcesSubFolders', Name = 'Process Sub-Folders', 'Checkbox', Default = procesSubFolders, NumAcross = 1}

dialog = comp:AskUser('Convert PFM Depth Images', d)
if dialog == nil then
	print('You cancelled the dialog!')
	
	-- Unlock the comp flow area
	comp:Unlock()
	
	return
else
	-- Debug - List the output from the AskUser dialog window
	dump(dialog)
	
	pfmFolder = comp:MapPath(dialog.PFMFolder)
	setPreferenceData('KartaVR.ConvertPFM.PFMFolder', pfmFolder, printStatus)
	
	imageName = dialog.ImageName
	setPreferenceData('KartaVR.ConvertPFM.ImageName', imageName, printStatus)
	
	imageFormat = dialog.ImageFormat
	setPreferenceData('KartaVR.ConvertPFM.ImageFormat', imageFormat, printStatus)
	
	compress = dialog.Compression
	setPreferenceData('KartaVR.ConvertPFM.Compression', compress, printStatus)
	
	framePadding = dialog.FramePadding
	setPreferenceData('KartaVR.ConvertPFM.FramePadding', framePadding, printStatus)
	
	startOnFrameOne = dialog.StartOnFrameOne
	setPreferenceData('KartaVR.ConvertPFM.StartOnFrameOne', startOnFrameOne, printStatus)
	
	soundEffect = dialog.SoundEffect
	setPreferenceData('KartaVR.ConvertPFM.SoundEffect', soundEffect, printStatus)
	
	openFolder = dialog.OpenFolder
	setPreferenceData('KartaVR.ConvertPFM.OpenFolder', openFolder, printStatus)
	
	-- procesSubFolders = dialog.ProcesSubFolders
	-- setPreferenceData('KartaVR.ConvertPFM.ProcesSubFolders', procesSubFolders, printStatus)
end


-- Use FFmpeg to transcode the files
pfmTranscodeMedia(pfmFolder, imageFormat, imageName, framePadding, compress, startOnFrameOne, openFolder)


-- Unlock the comp flow area
comp:Unlock()

-- Play a sound effect
soundEffect = getPreferenceData('KartaVR.ConvertPFM.SoundEffect', 1, printStatus)
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

-- End of the script
print('[Done]')
return
