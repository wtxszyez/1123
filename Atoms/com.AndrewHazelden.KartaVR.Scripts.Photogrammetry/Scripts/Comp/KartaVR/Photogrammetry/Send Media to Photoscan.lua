--[[--
----------------------------------------------------------------------------
Send Media to Photoscan v4.0.1 2019-01-01
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The Send Media to Photoscan script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that will send the selected Fusion imagery to a Photoscan .psx file. The Photoscan .psx project is the starting point for creating a photogrammetry based mesh reconstruction.

How to use the Script:

Step 1. Start Fusion and open a new comp. 

Step 2. Select Loader/Saver node media in the Fusion flow view. Then run the "Script > KartaVR > Photogrammetry > Send Media to Photoscan" menu item.

Todos:
	Provide a warning when nothing is selected in the comp.
	Handle cases when a new Fusion comp hasn't been saved yet
	Make it so this script can be used without having the comp saved first.
	Add the date stamp for the images
	Create mini thumbnails for each view
	In the dialog printing string write in the textual name of the menu item number based selection

	Offer to transcode the selected movie files into to a series of images and then send that footage to the photoscan project:
	Movie FPS
	Movie Output: 'PNG', 'TiFF', 'JPG', 'EXR'

	View Chunks: 'All Media in One Chunk', 'One Chunk Per Node', 'One Chunk Per Timeline Frame'
	Support creating multiple "chunks" in Photoscan either "per loader/saver" node or "per frame" in the timeline

--]]--

------------------------------------------------------------------------------

local printStatus = true

-- Find out if we are running Fusion 7, 8, 9, or 15
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
local osSeparator = package.config:sub(1,1)

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
-- Example: setPreferenceData('KartaVR.GenerateUVPass.File', '/panorama.pts', true)
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
-- Example: getPreferenceData('KartaVR.GenerateUVPass.File', '/panorama.pts', true)
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


-- Helper function copied from the scriptlib.lua file
function parseFilename(filename)
	local seq = {}
	seq.FullPath = filename
	string.gsub(seq.FullPath, '^(.+[/\\])(.+)', function(path, name) seq.Path = path seq.FullName = name end)
	string.gsub(seq.FullName, '^(.+)(%..+)$', function(name, ext) seq.Name = name seq.Extension = ext end)
	
	if not seq.Name then -- no extension?
		seq.Name = seq.FullName
	end
	
	string.gsub(seq.Name, '^(.-)(%d+)$', function(name, SNum) seq.CleanName = name seq.SNum = SNum end)
	
	if seq.SNum then 
		seq.Number = tonumber(seq.SNum) 
		seq.Padding = string.len( seq.SNum)
	else
		 seq.SNum = ''
		seq.CleanName = seq.Name
	end
	
	if seq.Extension == nil then seq.Extension = '' end
	seq.UNC = (string.sub(seq.Path, 1, 2) == [[\\]])
	
	return seq
end


-- Scan a saver node and return a new table with the list of files (from the scriptlib.lua file)
-- Example: dump(SV_GetFrames(Saver1))
function SV_GetFrames(sv)
	local fla = sv.Composition:GetAttrs()
	
	if sv.ID ~= 'Saver' then
		print('[Error] The tool ' .. sv.Name .. ' is not a Saver tool.')
		return nil
	end
	
	if sv.Normal[fu.TIME_UNDEFINED] == 1 then
		print('[Error] ' .. sv.Name .. ' is set to 2:3 pulldown. This function does not support pulldown.')
		return nil
	end
	
	-- its safe to assume [0] for Clipname since savers have no cliplists
	local sv_file = sv.Clip[0]

	if sv_file == '' then
		print('[Error] ' .. sv.Name .. 'does not yet have a filename to save to.')
		return nil
	end
	
	-- multiframe clips only have one filename
	if pathIsMovieFormat (sv.Clip[0]) == true then
		return {sv_file}
	end
	
	local seq = parseFilename(sv_file)
	
	-- Saver has a control to force the starting sequence number.
	if sv.SetSequenceStart[fu.TIME_UNDEFINED] == 0 then
		start = fla.COMPN_RenderStart
	else
		start = sv.SequenceStartFrame[fu.TIME_UNDEFINED]
					+ fla.COMPN_RenderStart 
					- fla.COMPN_GlobalStart
	end
	
	local length = fla.COMPN_RenderEnd - fla.COMPN_RenderStart

	if seq.Padding == nil then
		 -- never rendered, no numbering provided assume default fusion padding
		seq.Padding = 4
	end
	
	local files = {}
	for i = start, start + length do
		table.insert(files, seq.Path .. seq.CleanName .. string.format('%0' .. seq.Padding .. 'd', i) .. seq.Extension)
	end
	return files
end


-- Scan a loader node and return a new table with the list of files (from the scriptlib.lua file)
-- Example: dump(LD_GetFrames(Loader1))
function LD_GetFrames(ld)
	lda = ld:GetAttrs()
	
	-- is it a loader?
	if ld.ID ~= 'Loader' then
		print('[Error] The tool ' .. ld.Name .. ' is not a Loader tool.')
		return nil
	end
	
	if ld.ImportMode[fu.TIME_UNDEFINED] ~= 0 then
		print('[Error] The tool ' .. ld.Name .. ' is set to pulldown or pullup. This function does not support these import modes.')
		return nil
	end
	
	if not lda.TOOLST_Clip_Name then
		print('[Error] The tool ' .. ld.Name .. ' is not set up yet, the Loader is empty.')
		return nil
	end
	
	frames = {}
	
	for i = 1, table.getn(lda.TOOLST_Clip_Name) do
		seq = parseFilename(comp:MapPath(lda.TOOLST_Clip_Name[i]))
		if seq.Padding == nil then 
			table.insert(frames, v )
		else
			for x = lda.TOOLIT_Clip_TrimIn[i], lda.TOOLIT_Clip_TrimOut[i] do
				frame = lda.TOOLIT_Clip_InitialFrame[i] + x
				table.insert(frames, seq.Path .. seq.CleanName .. string.format('%0' .. seq.Padding .. 'd', frame) .. seq.Extension)
			end
		end
	end
	
	return frames
end


-- Read a binary file to calculate the filesize in bytes
-- Example: size = getFilesize('/image.png')
function getFilesize(filename)
	fp, errMsg = io.open(filename, 'rb')
	if fp == nil then
		print('[Filesize] Error reading the file: ' .. filename)
		return 0
	end
	
	local filesize = fp:seek('end')
	fp:close()
	
	return filesize
end


-- Zip a single file
-- Example: zipFile('Temp:/archive.zip', 'Comp:/image.jpg', false)
function zipFile(zipFilename, sourceFileName, moveFile)
	-- Expand the pathmaps in the zip filename 
	pathMappedZipFilename = comp:MapPath(zipFilename)
	
	-- Create the zip output folder if required
	os.execute('mkdir "' .. dirname(pathMappedZipFilename) .. '"')
	
	-- Expand the pathmaps in the filepath 
	pathMappedSourceFileName = comp:MapPath(sourceFileName)

	-- The individual source file to be zipped with the absolute path removed
	sourceFileNoPath = getFilename(pathMappedSourceFileName)
	workingFolder = dirname(pathMappedSourceFileName)
	
	-- You can find custom zip flag options in the terminal using 'man zip'
	zipOptions = ''

	if moveFile == true or moveFile == 1 then
		-- The move option --move will remove the source files when the zip is created
		zipOptions = zipOptions .. '--move' .. ' ' 
	end
	
	-- Compression
	zipOptions = zipOptions .. '--compression-method deflate' .. ' '
	-- zipOptions = zipOptions .. '--compression-method store' .. ' '
	-- zipOptions = zipOptions .. '--compression-method bzip2' .. ' '

	-- Compression Speed
	-- -# range is -0 to -9 (where -0 = no compression just store the files and -9 = file savings)
	-- zipOptions = zipOptions .. '-0' .. ' ' -- no compression just store the files
	-- zipOptions = zipOptions .. '-6' .. ' ' -- Default compression level
	-- zipOptions = zipOptions .. '-9' .. ' ' -- Slowest but maximum compression level
	
	-- Junk Paths
	-- zipOptions = zipOptions .. '--junk-paths' .. ' ' -- remove the absolute folders from the output and store flat files in the zip with intermediate folders
	
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Command line zip program 
	if platform == 'Windows' then
		-- Running on Windows
		defaultProgram = comp:MapPath('Reactor:\\Deploy\\Bin\\cygwin\\bin\\zip.exe')
		-- defaultProgram = "C:\\cygwin64\\bin\\zip.exe"
		-- defaultProgram = 'zip.exe'
		zipProgram = getPreferenceData('KartaVR.Compression.ZipFile', defaultProgram, printStatus)
		
		-- Add the cd command to change the working directory
		-- Note: cd /D changes the drive letter and the directory
		-- command = 'cd /D "' .. workingFolder .. '" && ' .. 'start "" ' .. zipProgram .. ' ' .. zipOptions .. ' "' .. pathMappedZipFilename .. '" ' .. ' "' .. sourceFileNoPath .. '"'
		
		-- Note: cd /D changes the drive letter and the directory
		command = 'cd /D "' .. workingFolder .. '" && "' .. zipProgram .. '" ' .. zipOptions .. ' "' .. pathMappedZipFilename .. '" ' .. ' "' .. sourceFileNoPath .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		defaultProgram = '/usr/bin/zip'
		zipProgram = getPreferenceData('KartaVR.Compression.ZipFile', defaultProgram, printStatus)
		command = 'cd "' .. workingFolder .. '"; "' .. zipProgram .. '" ' .. zipOptions .. ' "' .. pathMappedZipFilename .. '" ' .. ' "' .. sourceFileNoPath .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		defaultProgram = '/usr/bin/zip'
		zipProgram = getPreferenceData('KartaVR.Compression.ZipFile', defaultProgram, printStatus)
		command = 'cd "' .. workingFolder .. '"; "' .. zipProgram .. '" ' .. zipOptions .. ' "' .. pathMappedZipFilename .. '" ' .. ' "' .. sourceFileNoPath .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


-- Zip a folder
-- Example: zipFolder('Temp:/archive.zip', 'Comp:/', false, true)
function zipFolder(zipFilename, sourceFolderName, moveFile, excludeZips)
	-- Expand the pathmaps in the zip filename 
	pathMappedZipFilename = comp:MapPath(zipFilename)
	
	-- Create the zip output folder if required
	os.execute('mkdir "' .. dirname(pathMappedZipFilename) .. '"')
	
	-- The individual source file to be zipped with the absolute path removed
	workingFolder = comp:MapPath(sourceFolderName)
	
	-- You can find custom zip flag options in the terminal using 'man zip'
	zipOptions = ''
	
	if moveFile == true or moveFile == 1 then
		-- The move option --move will remove the source files when the zip is created
		zipOptions = zipOptions .. '--move' .. ' '
	end
	
	-- Recursively add sub-folders
	zipOptions = zipOptions .. '-r' .. ' '
	
	-- Compression
	zipOptions = zipOptions .. '--compression-method deflate' .. ' '
	-- zipOptions = zipOptions .. '--compression-method store' .. ' '
	-- zipOptions = zipOptions .. '--compression-method bzip2' .. ' '

	-- Compression Speed
	-- -# range is -0 to -9 (where -0 = no compression just store the files and -9 =	file savings)
	-- zipOptions = zipOptions .. '-0' .. ' ' -- no compression just store the files
	-- zipOptions = zipOptions .. '-6' .. ' ' -- Default compression level
	-- zipOptions = zipOptions .. '-9' .. ' ' -- Slowest but maximum compression level
	
	-- Junk Paths
	-- zipOptions = zipOptions .. '--junk-paths' .. ' ' -- remove the absolute folders from the output and store flat files in the zip with intermediate folders
	
	-- Exclude items from the zip
	if excludeZips == true or excludeZips == 1 then
		-- Exclude the .zip files and the OS generated thumbnails
		zipExcludeList = '-x "*.DS_Store" "*Thumbs.db" "*.zip"' .. ' '
	else
		-- Exclude OS generated thumbnails and other files
		zipExcludeList = '-x "*.DS_Store" "*Thumbs.db"' .. ' '
	end
	
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Command line zip program 
	if platform == 'Windows' then
		-- Running on Windows
		defaultProgram = comp:MapPath('Reactor:\\Deploy\\Bin\\cygwin\\bin\\zip.exe')
		-- defaultProgram = "C:\\cygwin64\\bin\\zip.exe"
		-- defaultProgram = 'zip.exe'
		zipProgram = getPreferenceData('KartaVR.Compression.ZipFile', defaultProgram, printStatus)
		
		-- Add the cd command to change the working directory
		-- Note: cd /D changes the drive letter and the directory
		-- command = 'cd /D "' .. workingFolder .. '" && ' .. 'start "" ' .. zipProgram .. ' ' .. zipOptions .. ' "' .. pathMappedZipFilename .. '" ' .. ' . ' .. zipExcludeList
		
		-- Note: cd /D changes the drive letter and the directory
		command = 'cd /D "' .. workingFolder .. '" && ' .. ' "' .. zipProgram .. '" ' .. zipOptions .. ' "' .. pathMappedZipFilename .. '" ' .. ' . ' .. zipExcludeList
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		defaultProgram = '/usr/bin/zip'
		zipProgram = getPreferenceData('KartaVR.Compression.ZipFile', defaultProgram, printStatus)
		command = 'cd "' .. workingFolder .. '"; "' .. zipProgram .. '" ' .. zipOptions .. ' "' .. pathMappedZipFilename .. '" ' .. ' . ' .. zipExcludeList
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		defaultProgram = '/usr/bin/zip'
		zipProgram = getPreferenceData('KartaVR.Compression.ZipFile', defaultProgram, printStatus)
		command = 'cd "' .. workingFolder .. '"; "' .. zipProgram .. '" ' .. zipOptions .. ' "' .. pathMappedZipFilename .. '" ' .. ' . ' .. zipExcludeList
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
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
	if platform == 'Windows' then
		-- Windows uses backslashes
		-- handle macOS slashes
		for slash in from_diff:gmatch('/') do
			result = result .. '..\\'
		end
		
		--- Handle Windows slashes
		for slash in from_diff:gmatch('\\') do
			result = result .. '..\\'
		end
		
		if from_is_dir then
			result = result .. '..\\'
		end
	else
		-- macOS and Linux use forwardslashes
		-- handle macOS slashes
		for slash in from_diff:gmatch('/') do
			result = result .. '../'
		end

		--- Handle Windows slashes
		for slash in from_diff:gmatch('\\') do
			result = result .. '../'
		end
		
		if from_is_dir then
			result = result .. '../'
		end
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

-- Add a chunk.xml
-- Example: chunk = addChunk(image, totalImages)
function addChunk(camera, imageCount)
	-- Adds everything in the camera table to one image chunk
	chunkString = ''
	chunkString = chunkString .. '<?xml version="1.0" encoding="UTF-8"?>\n'
	chunkString = chunkString .. '<chunk label="Chunk 1" enabled="true">\n'

	-- ------------------------------
	-- Sensor "Camera Model" elements
	-- This is a single entry for all images from the same camera
	-- -------------------------------
	
	local sensorWidth = ''
	local sensorHeight = ''
	if not camera[1] then
		sensorWidth = compPrefs.Width
		sensorHeight = compPrefs.Height
	else
		sensorWidth = camera[1].width2
		sensorHeight = camera[1].height3
	end
	
	chunkString = chunkString .. '	<sensors next_id="1">\n'
	chunkString = chunkString .. '		<sensor id="0" label="unknown" type="frame">\n'
	chunkString = chunkString .. '			<resolution width="' .. sensorWidth .. '" height="' .. sensorHeight .. '"/>\n'
	chunkString = chunkString .. '			<property name="fixed" value="false"/>\n'
	chunkString = chunkString .. '			<bands>\n'
	chunkString = chunkString .. '				<band label="Red"/>\n'
	chunkString = chunkString .. '				<band label="Green"/>\n'
	chunkString = chunkString .. '				<band label="Blue"/>\n'
	chunkString = chunkString .. '			</bands>\n'
	chunkString = chunkString .. '		</sensor>\n'
	chunkString = chunkString .. '	</sensors>\n'
	
	-- ------------------------------
	-- Cameras "Image" elements
	-- ------------------------------
	chunkString = chunkString .. '	<cameras next_id="' .. imageCount .. '" next_group_id="0">\n'
	
	for i = 1, imageCount do
		-- The filepath is cut down to just the base image name here so in AGI Photoscan's Photos window the "short" file name is displayed vs showing the full absolute filepath.
		chunkString = chunkString .. '		<camera id="'.. camera[i].imageID4 .. '" label="' .. getFilename(camera[i].filename1) .. '" sensor_id="0" enabled="' .. camera[i].enabled5 .. '">\n'
		
		-- chunkString = chunkString .. '			 <orientation>' .. camera[i].orientation6 .. '</orientation>\n'
		chunkString = chunkString .. '		</camera>\n'
	end
	
	chunkString = chunkString .. '	</cameras>\n'
	
	-- ------------------------------
	-- Frames elements
	-- ------------------------------
	
	chunkString = chunkString .. '	<frames next_id="1">\n'
	chunkString = chunkString .. '		<frame id="0" path="0/frame.zip"/>\n'
	chunkString = chunkString .. '	</frames>\n'
	
	-- ------------------------------
	-- Settings elements
	-- ------------------------------
	
	chunkString = chunkString .. '	<settings>\n'
	chunkString = chunkString .. '		<property name="accuracy_tiepoints" value="1"/>\n'
	chunkString = chunkString .. '		<property name="accuracy_cameras" value="10"/>\n'
	chunkString = chunkString .. '		<property name="accuracy_cameras_ypr" value="2"/>\n'
	chunkString = chunkString .. '		<property name="accuracy_markers" value="0.0050000000000000001"/>\n'
	chunkString = chunkString .. '		<property name="accuracy_scalebars" value="0.001"/>\n'
	chunkString = chunkString .. '		<property name="accuracy_projections" value="0.10000000000000001"/>\n'
	chunkString = chunkString .. '	</settings>\n'
	chunkString = chunkString .. '</chunk>\n'
	chunkString = chunkString .. '\n'
	
	return chunkString
end


-- project.xml
-- Example: project = addProject()
function addProject()
	-- Adds everything to one image chunk
	projectString = ''
	projectString = projectString .. '<?xml version="1.0" encoding="UTF-8"?>\n'
	projectString = projectString .. '<document version="1.2.0">\n'
	projectString = projectString .. '	<chunks next_id="1">\n'
	projectString = projectString .. '		<chunk id="0" path="0/chunk.zip"/>\n'
	projectString = projectString .. '	</chunks>\n'
	projectString = projectString .. '</document>\n'
	projectString = projectString .. '\n'
	
	return projectString
end

-- frame.xml
-- Example: frame = addFrame(imageTable, totalImages)
function addFrame(camera, imageCount)
	frameString = ''
	frameString = frameString .. '<?xml version="1.0" encoding="UTF-8"?>\n'
	frameString = frameString .. '<frame>\n'
	
	-- ------------------------------
	-- Cameras "Image" elements
	-- -------------------------------
	
	frameString = frameString .. '	<cameras>\n'
	
	for i = 1, imageCount do
		frameString = frameString .. '		<camera camera_id="' .. camera[i].imageID4 .. '">\n'
		
		-- Check if the images should be stored in the project using absolute paths or relative to the .psx document imagepaths.
		if useRelativePaths == 1 then
			-- Relative imagepath
			
			-- The absolute saver image path that is being re-written
			toFile = camera[i].filename1
			
			-- The location of the reference file that is used to do the relative path trimming
			-- fromFile = comp:GetAttrs().COMPS_FileName
			-- The reference folder needs to help you move down from the Photoscan.files\0\o- folder
			fromFile = outputDirectory .. photoscanProjectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '0' .. osSeparator .. getFilename(camera[i].filename1)
			
			-- The pathmap prefix value that is added to the final relative path result
			relativePathMap = ''
			
			-- Build the saver node image path
			outputFilename = ConvertToRelativePathMap(toFile, fromFile, relativePathMap)
			
			frameString = frameString .. '			<photo path="' .. outputFilename .. '">\n'
			-- frameString = frameString .. '			 <photo path="../../../' .. camera[i].filename1 .. '">\n'
		else
			-- Absolute imagepath
			frameString = frameString .. '			<photo path="' .. camera[i].filename1 .. '">\n'
		end
		
		frameString = frameString .. '				<meta>\n'
		-- frameString = frameString .. '					 <property name="Exif/Orientation" value="' ..	camera[i].orientation6 .. '"/>\n'
		frameString = frameString .. '					<property name="File/ImageHeight" value="' .. camera[i].height3 .. '"/>\n'
		frameString = frameString .. '					<property name="File/ImageWidth" value="' .. camera[i].width2 .. '"/>\n'
		-- frameString = frameString .. '					 <property name="System/FileModifyDate" value="' .. camera[i].date7 .. '"/>\n'
		frameString = frameString .. '					<property name="System/FileSize" value="' .. camera[i].filesizeBytes8 .. '"/>\n'
		frameString = frameString .. '				</meta>\n'
		frameString = frameString .. '			</photo>\n'
		frameString = frameString .. '		</camera>\n'
	end
	
	frameString = frameString .. '	</cameras>\n'
	
	-- Check if alpha masks have been generated for each of the camera views
	if useAlphaMasks == 1 then
		frameString = frameString .. '	<masks path="masks/masks.zip"/>\n'
	end
	
	-- frameString = frameString .. '	 <thumbnails path="thumbnails/thumbnails.zip"/>\n'
	frameString = frameString .. '</frame>\n'
	frameString = frameString .. '\n'
	
	return frameString
end

-- thumbnail.xml
-- Example: thumbnail = addThumbnail(imageTable, totalImages)
function addThumbnail(camera, imageCount)
	thumbnailString = ''
	thumbnailString = thumbnailString .. '<?xml version="1.0" encoding="UTF-8"?>\n'
	thumbnailString = thumbnailString .. '<thumbnails version="1.2.0">\n'
	
	for i = 1, imageCount do
		-- This is the .jpg format preview image on disk that is scaled to 160x191 px
		-- Todo: Use imagemagick to generate and scale the thumbnail images 
		thumbnailString = thumbnailString .. '	<thumbnail camera_id="' .. camera[i].imageID4 .. '" path="' .. camera[i].filename1 .. '"/>\n'
	end
	
	thumbnailString = thumbnailString .. '</thumbnails>\n'
	thumbnailString = thumbnailString .. '\n'
	return thumbnailString
end

-- mask.xml
-- Example: mask = addMask(imageTable, totalImages)
function addMask(camera, imageCount)
	maskString = ''
	maskString = maskString .. '<?xml version="1.0" encoding="UTF-8"?>\n'
	maskString = maskString .. '<masks version="1.2.0">\n'
	
	for i = 1, imageCount do
		sourceImage = camera[i].filename
		destinationImagename = 'c' .. camera[i].imageID4 .. '.png'
		
		-- This is an imagemagick generated 8 bit 72dpi greyscale .png format image that is saved in the masks folder with the same image witdh and height as the source image with a filename like "c0.png" that matches the naming template of "c<camera_id>.png".
		maskString = maskString .. '	<mask camera_id="' .. camera[i].imageID4 .. '" path="' .. destinationImagename .. '"/>\n'
	end
	
	maskString = maskString .. '</masks>\n'
	maskString = maskString .. '\n'
	return maskString
end

-- Extract the alpha channels from the source images and save them into png greyscale masks
-- This is an imagemagick generated 8 bit 72dpi greyscale .png format image that is saved in the masks folder with the same image witdh and height as the source image with a filename like "c0.png" that matches the naming template of "c<camera_id>.png".
function generateMaskImages(camera, imageCount, workingFolder)
	-- Debugging
	-- print('Camera Table')
	-- dump(camera)
	-- print('\n')
	-- 
	-- exit()
	
	-- Create a multi-dimensional table
	maskTable = {}
	
	-- Select the image file format
	-- PNG format mask output
	imageFormat = 5
	
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
	-- Use RLE Compression for the mask images
	compress = 1
	
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
	-- Reduce the output to a 1 bit style image with only black or white visible in the matte
	
	colorDepth = ' '
	-- colorDepth = ' -colors 2'
	-- colorDepth = ' -set "colorspace:auto-grayscale" "false" -depth 8 -type truecolor'

	-- Extract the alpha channel from the image and keep the mask background transparent
	-- alphaChannel = ' -alpha extract -alpha on '
	
	-- Extract the alpha channel from the image but flatten the mask background
	alphaChannel = ' -alpha extract -alpha off '
	
	-- Create the working folder where the png images are saved:
	-- Example: Temp:\\KartaVR\\photoscan.files\\0\\0\\masks\\
	os.execute('mkdir "' .. workingFolder ..'"')
	
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	os.execute('mkdir "' .. outputDirectory..'"')
	
	-- Redirect the output from the terminal to a log file
	outputLog = outputDirectory .. 'photoscanMaskExtract.txt'
	logCommand = ''
	if platform == 'Windows' then
		-- logCommand = ' ' .. '2> "' .. outputLog.. '" '
		-- logCommand = ' ' .. '> "' .. outputLog.. '" 2>&1'
		logCommand = ' ' .. '2>&1 | "' .. comp:MapPath('Reactor:\\Deploy\\Bin\\wintee\\bin\\wtee.exe') .. '" -a' .. ' "' .. outputLog.. '" '
	elseif platform == 'Mac' then
		-- logCommand = ' ' .. '2> "' .. outputLog.. '" '
		-- logCommand = ' ' .. '> "' .. outputLog.. '" 2>&1'
		logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
	elseif platform == 'Linux' then
		-- logCommand = ' ' .. '2> "' .. outputLog.. '" '
		-- logCommand = ' ' .. '> "' .. outputLog.. '" 2>&1'
		logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
	end
	
	-- Process each of the images
	for i = 1, imageCount do
		sourceImagepath = comp:MapPath(camera[i].filename1)
		
		-- Example: Temp:\\KartaVR\\photoscan.files\\0\\0\\masks\\c01.png
		destinationImagename = 'c' .. camera[i].imageID4 .. '.png'
		destinationImagepath = comp:MapPath(workingFolder .. destinationImagename)
		
		-- Add a new entry to the media table that is returned from the function and used to create the masks.zip file that holds the mask images + doc.xml file
		media[i] = {id = i, folder1 = workingFolder, filename2 = destinationImagename, filepath3 = destinationImagepath}
		
		 -- Launch the Imagemagick converter tool
		if platform == 'Windows' then
			-- Running on Windows
			defaultImagemagickProgram =  comp:MapPath('Reactor:\\Deploy\\Bin\\imagemagick\\bin\\imconvert.exe')
			imagemagickProgram = getPreferenceData('KartaVR.SendMedia.ImagemagickFile', defaultImagemagickProgram, printStatus)
			command = 'start "" ' .. ' "' .. imagemagickProgram .. '" "' .. sourceImagepath .. '" ' .. alphaChannel .. colorDepth .. dpi .. compressionMode .. ' ' .. imageFormatExt .. ':' .. '"' .. destinationImagepath .. '"' .. logCommand
			
			print('[Launch Command] ', command)
			os.execute(command)
		elseif platform == 'Mac' then
			-- Running on Mac
			-- ****** The Default KartaVR "Cactus Lab" provided ImageMagick tool should be enabled by default:
			defaultImagemagickProgram = '/opt/ImageMagick/bin/convert'
			
			-- Mac Ports Compiled/Official site downloaded ImageMagick:
			-- defaultImagemagickProgram = '/opt/local/bin/convert'
			
			-- Manual compiled ImageMagick:
			-- defaultImagemagickProgram = '/usr/local/bin/convert'
			
			imagemagickProgram = string.gsub(comp:MapPath(getPreferenceData('KartaVR.SendMedia.ImagemagickFile', defaultImagemagickProgram, printStatus)), '[/]$', '')
			
			command = '"' .. imagemagickProgram .. '" "' .. sourceImagepath .. '" ' .. alphaChannel .. colorDepth .. dpi .. compressionMode .. ' ' .. imageFormatExt .. ':' .. '"' .. destinationImagepath .. '"' .. logCommand
			print('[Launch Command] ', command)
			os.execute(command)
		else
			-- Running on Linux
			defaultImagemagickProgram = '/usr/bin/convert'
			
			imagemagickProgram = '"' .. getPreferenceData('KartaVR.SendMedia.ImagemagickFile', defaultImagemagickProgram, printStatus) .. '"'
			
			command = '"' .. imagemagickProgram .. '" "' .. sourceImagepath .. '" ' .. alphaChannel .. colorDepth .. dpi .. compressionMode .. ' ' .. imageFormatExt .. ':' .. '"' .. destinationImagepath .. '"' .. logCommand
			print('[Launch Command] ', command)
			os.execute(command)
		end
	end
	
	-- List the contents of the maskTable
	-- dump(maskTable)
	
	return maskTable
end


-- photoscan.xml
-- Example: photoscan = addPhotoscan()
function addPhotoscan()
	photoscanString = ''
	photoscanString = photoscanString .. '<?xml version="1.0" encoding="UTF-8"?>\n'
	photoscanString = photoscanString .. '<document version="1.2.0" path="{projectname}.files/project.zip"/>\n'
	photoscanString = photoscanString .. '\n'
	
	return photoscanString
end


-- Write a string to a text file (with pathmap support)
-- Example: writeTextFile(filepath, text, printStatus)
function writeTextFile(filepath, text, status)
	-- convert the pathmaps in the file path to an absolute path
	absolutePath = comp:MapPath(filepath)
	
	-- Create the output folder if required
	os.execute('mkdir "' .. dirname(absolutePath) .. '"')
	
	-- Open up the file pointer for the output textfile
	outFile, err = io.open(absolutePath,'w')
	if err then 
		print('[Error Opening File for Writing] ' .. absolutePath)
		return
	end
	
	if (string.len(text) >= 1) then
		-- Print the file output details
		if status == 1 or status == true then
			print('[Saving File] ' .. absolutePath)
			print(text)
		end
		
		-- Write the text string to disk
		outFile:write(text)
	else
		if status == 1 or status == true then
			print('[No Text to Write]')
		end
	end
	
	-- Close the file pointer on the output textfile
	outFile:close()
end

-- Create the Photoscan project file
-- Example: createPhotoscanProject('photoscan', img, totalImg)
function createPhotoscanProject(projectName, imageTable, totalImages)
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	-- outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	
	-- Use 'Comp:/' as the output folder path
	outputDirectory = compPath
	
	-- --------------------------------------
	-- Photoscan project folder creation:
	-- --------------------------------------
	
	-- Create the DFM temp folder if required
	os.execute('mkdir "' .. outputDirectory .. '"')
	
	-- Create the Photoscan project folder
	-- Temp:\\KartaVR\\photoscan.files\\
	os.execute('mkdir "' .. outputDirectory .. projectName .. '.files' .. '"')
	
	-- Create the Photoscan\0\ Chunk folder
	-- Temp:\\KartaVR\\photoscan.files\\
	os.execute('mkdir "' .. outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '"')
	
	-- Create the Photoscan 0\0\ cameras folder
	os.execute('mkdir "' .. outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '0' .. osSeparator .. '"')
	
	-- Create the Photoscan 0\0\thumbails folder
	os.execute('mkdir "' .. outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '0' .. osSeparator .. 'thumbnails' .. '"')
	
	-- --------------------------------------
	-- Photoscan XML files
	-- --------------------------------------
	
	-- Temp:\\KartaVR\\photoscan.psx
	photoscanTempFile = outputDirectory .. projectName .. '.psx'
	
	-- Temp:\\KartaVR\\photoscan.files\\project.xml
	projectTempFile = outputDirectory .. projectName .. '.files' .. osSeparator .. 'doc' .. '.xml'
	projectZipFile = outputDirectory .. projectName .. '.files' .. osSeparator .. 'project' .. '.zip'
 
	-- Temp:\\KartaVR\\photoscan.files\\0\\chunk.xml
	chunkTempFile = outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. 'doc' .. '.xml'
	chunkZipFile = outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. 'chunk' .. '.zip'
	
	-- Temp:\\KartaVR\\photoscan.files\\0\\0\\frame.xml
	frameTempFile = outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '0' .. osSeparator .. 'doc' .. '.xml'
	frameZipFile = outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '0' .. osSeparator .. 'frame' .. '.zip'
	
	-- Temp:\\KartaVR\\photoscan.files\\0\\0\\thumbnails\\thumbnails.xml
	thumbnailsTempFile = outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '0' .. osSeparator .. 'thumbnails' .. osSeparator .. 'doc' .. '.xml'
	thumbnailsZipFile = outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '0' .. osSeparator .. 'thumbnails' .. osSeparator .. 'thumbnails' .. '.zip'
	
	-- Temp:\\KartaVR\\photoscan.files\\0\\0\\masks\\masks.xml
	masksTempFile = outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '0' .. osSeparator .. 'masks' .. osSeparator .. 'doc' .. '.xml'
	masksTempFolder = outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '0' .. osSeparator .. 'masks' .. osSeparator
	masksZipFile = outputDirectory .. projectName .. '.files' .. osSeparator .. '0' .. osSeparator .. '0' .. osSeparator .. 'masks' .. osSeparator .. 'masks' .. '.zip'
	
	print('[Writing Photoscan Project File] ' .. photoscanTempFile)
	photoscan = addPhotoscan()
	writeTextFile(photoscanTempFile, photoscan, printStatus)
	
	print('[project.xml File] ' .. projectTempFile)
	project = addProject()
	writeTextFile(projectTempFile, project, printStatus)
	zipFile(projectZipFile, projectTempFile, true)
	
	print('[chunk.xml File] ' .. chunkTempFile)
	dump(imageTable)
	chunk = addChunk(imageTable, totalImages)
	writeTextFile(chunkTempFile, chunk, printStatus)
	zipFile(chunkZipFile, chunkTempFile, true)
	
	print('[frame.xml File] ' .. frameTempFile)
	frame = addFrame(imageTable, totalImages)
	writeTextFile(frameTempFile, frame, printStatus)
	zipFile(frameZipFile, frameTempFile, true)
	
	-- print('[thumbnail.xml File] ' .. thumbnailsTempFile)
	-- thumbnail = addThumbnail(imageTable, totalImages)
	-- writeTextFile(thumbnailsTempFile, thumbnail, printStatus)
	-- zipFile(thumbnailsZipFile, thumbnailsTempFile, true)
	
	-- Check if alpha masks have been generated for each of the camera views
	if useAlphaMasks == 1 then
		print('[mask.xml File] ' .. masksTempFile)
		mask = addMask(imageTable, totalImages)
		maskImages = generateMaskImages(imageTable, totalImages, masksTempFolder)
		writeTextFile(masksTempFile, mask, printStatus)
		--zipFile(masksZipFile, masksTempFile, true)
		zipFolder(masksZipFile, masksTempFolder, true, true)
	else
		print('[mask.xml File] Skipped since the "Use Alpha Masks" checkbox is disabled')
	end
	
	-- Send back the full Photoscan.psx file path
	return photoscanTempFile
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
		exit()
	end
	
	-- Iterate through each of the loader nodes
	for i, tool in ipairs(toollist1) do 
		toolAttrs = tool:GetAttrs().TOOLS_RegID
		nodeName = tool:GetAttrs().TOOLS_Name
		
		-- Scan a loader node and return a new table with the list of files
		framesList = LD_GetFrames(tool)
		frameCount = table.getn(framesList)
		for f = 1, frameCount do
			sourceMediaFile = framesList[f]
			
			print('[' .. toolAttrs .. ' Name] ' .. nodeName .. ' [Image Filename] ' .. sourceMediaFile)
			
			-- Extract the base media filename without the path
			mediaFilename = getFilename(sourceMediaFile)
			
			mediaExtension = getExtension(mediaFilename)
			if mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
				mediaType = 'video'
				print('[The ' .. mediaFilename .. ' media file was detected as a movie format. Please extract a frame from the movie file as AGI Photoscan does not support working with video formats directly.]')
			else
				mediaType = 'image'
				-- print('[The ' .. mediaFilename .. ' media file was detected as an image format.]')
				
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
				-- nodePtr9
				media[nodeIndex] = {id = nodeIndex, nodename1 = nodeName, filepath2 = sourceMediaFile, filename3 = mediaFilename, folder4 = dirname(sourceMediaFile), extension5 = mediaExtension, type6 = mediaType, xpos7 = nodeXpos, ypos8 = nodeYpos, nodePtr9 = tool}
				
				nodeIndex = nodeIndex + 1
			end
		end
	end
	
	-- Iterate through each of the saver nodes
	for i, tool in ipairs(toollist2) do 
		toolAttrs = tool:GetAttrs().TOOLS_RegID
		nodeName = tool:GetAttrs().TOOLS_Name
		
		-- Scan a saver node and return a new table with the list of files
		framesList = SV_GetFrames(tool)
		frameCount = table.getn(framesList)
		for f = 1, frameCount do
			sourceMediaFile = framesList[f]
			print('[' .. toolAttrs .. ' Name] ' .. nodeName .. ' [Image Filename] ' .. sourceMediaFile)
			
			-- Extract the base media filename without the path
			mediaFilename = getFilename(sourceMediaFile)
			
			mediaExtension = getExtension(mediaFilename)
			if mediaExtension == 'mov' or mediaExtension == 'mp4' or mediaExtension == 'm4v' or mediaExtension == 'mpg' or mediaExtension == 'webm' or mediaExtension == 'ogg' or mediaExtension == 'mkv' or mediaExtension == 'avi' then
				mediaType = 'video'
				print('[The ' .. mediaFilename .. ' media file was detected as a movie format. Please extract a frame from the movie file as AGI Photoscan does not support working with video formats directly.]')
			else
				mediaType = 'image'
				-- print('[The ' .. mediaFilename .. ' media file was detected as an image format.]')
				
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
				-- nodePtr9
				media[nodeIndex] = {id = nodeIndex, nodename1 = nodeName, filepath2 = sourceMediaFile, filename3 = mediaFilename, folder4 = dirname(sourceMediaFile), extension5 = mediaExtension, type6 = mediaType, xpos7 = nodeXpos, ypos8 = nodeYpos, nodePtr9 = tool}
				
				nodeIndex = nodeIndex + 1
			end
		end
	end
	
	-- Check the layer stacking order setting
	layerOrder = getPreferenceData('KartaVR.Photoscan.LayerOrder', 5, printStatus)
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
	
	imageCounter = 0
	
	-- Generate the media filename string from the table
	for i, media in ipairs(media) do
		-- <camera> id="" starts with a zero index value
		imageID = i - 1
		
		-- Track the number of active images
		imageCounter = i
		
		-- rgb.15.0000.jpg
		imageFilename = comp:MapPath(media.filepath2)
		
		-- UTC creation timestamp for image
		date = '2018:11:11 02:00:00'
		
		-- Image size on disk in bytes
		filesize = getFilesize(imageFilename)
		-- filesize = 0
		
		img[imageCounter] = {id = imageCounter, filename1 = imageFilename, width2 = width, height3 = height, imageID4 = imageID, enabled5 = 'true', orientation6 = 1, date7 = date, filesizeBytes8 = filesize}
		
		print('[' .. imageCounter .. ']\t[Image] ' .. imageFilename .. '\t[Size] ' .. width .. 'x' .. height)
	end
	
	-- List the image array contents
	--	print('\n')
	--	if printStatus == 1 or printStatus == true then
	--		print('[Images Table]')
	--		dump(img)
	--	end
	
	-- Provide the total number of images as the output from the function
	return imageCounter
end


-- Main Code
function Main()
	print('[Send Media to Photoscan]')
	print ('Send Media to Photoscan is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)
	
	-- Check if Fusion is running
	if not fusion then
		print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
		return
	end
	
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
		exit()
	end
	
	-- -------------------
	-- Global Variables 
	-- -------------------
	width = 0
	height = 0
	
	-- Iterate through each of the saver nodes
	if toollist2 ~= nil then
		for i, tool in ipairs(toollist2) do 
			-- Read the imagesize:
			imageWidth = tool:GetAttrs().TOOLI_ImageWidth or 0
			imageHeight = tool:GetAttrs().TOOLI_ImageHeight or 0
			
			if imageWidth > 0 and imageHeight > 0 then
				width = imageWidth
				height = imageHeight
			end
			
			print('[Saver] [Name] ' .. tool.Name .. ' [Size] ' .. imageWidth .. 'x' .. imageHeight)
		end
	end

	-- Iterate through each of the loader nodes
	if toollist1 ~= nil then
		for i, tool in ipairs(toollist1) do 
			-- Read the imagesize:
			-- imageWidth = tool:GetAttrs().TOOLI_ImageWidth or 0
			-- imageHeight = tool:GetAttrs().TOOLI_ImageHeight or 0
			imageWidth = tool:GetAttrs().TOOLIT_Clip_Width[1] or 0
			imageHeight = tool:GetAttrs().TOOLIT_Clip_Height[1] or 0
		
			if imageWidth > 0 and imageHeight > 0 then
				width = imageWidth
				height = imageHeight
			end
		
			print('[Loader] [Name]' .. tool.Name .. ' [Size] ' .. imageWidth .. 'x' .. imageHeight)
		end
	end

	-- Output Photoscan filename prefix
	-- Get the name of the Fusion .comp file with the extension removed
	compName = getFilenameNoExt(comp:GetAttrs().COMPS_FileName)
	if compName ~= nil and compName ~= '' then
		-- The comp has been saved to disk and has a name
		photoscanProjectName = compName
	else
		-- The comp has not been saved to disk yet so use 'Photoscan' as the default project file name
		photoscanProjectName = 'Photoscan'
		compName = 'Photoscan'
	end
	
	-- -------------------
	-- -------------------
	
	-- Lock the comp flow area
	comp:Lock()

	-- Show the dialog window
	-- Note: The AskUser dialog settings are covered on page 63 of the Fusion Scripting Guide
	-- compPath = dirname(comp:GetAttrs().COMPS_FileName)
	compPath = comp:MapPath('Comp:/')
	if compPath ~= nil and hostOS == 'Fusion' then
		-- The comp has been saved to disk and has a name
		print('[Comp:/ PathMap] ' .. compPath)
	else
		-- The comp: PathMap could not be resolved so switch to Temp:/ as a fallback location
		compPath = comp:MapPath('Temp:\\KartaVR\\')
		print('[Temp:/ PathMap] ' .. compPath)
	end
	
	compPrefs = comp:GetPrefs('Comp.FrameFormat')

	-- ------------------------------------
	-- Load the preferences
	-- ------------------------------------
	
	layerOrder = getPreferenceData('KartaVR.Photoscan.LayerOrder', 5, printStatus)
	chunk = getPreferenceData('KartaVR.Photoscan.Chunk', 0, printStatus)
	useAlphaMasks = getPreferenceData('KartaVR.Photoscan.UseAlphaMasks', 0, printStatus)
	useRelativePaths = getPreferenceData('KartaVR.Photoscan.UseRelativePaths', 1, printStatus)
	openOutputFolder = getPreferenceData('KartaVR.Photoscan.OpenOutputFolder', 1, printStatus)

	-- Layer Order
	layerOrderList = {'No Sorting', 'Node X Position', 'Node Y Position', 'Node Name', 'Filename', 'Folder + Filename'}
	
	-- View Chunks
	-- chunkList = {'All Media in One Chunk', 'One Chunk Per Node', 'One Chunk Per Timeline Frame'}
	-- chunkList = {'All Media in One Chunk', 'One Chunk Per Node'}
	chunkList = {'All Media in One Chunk'}
	
	msg = 'This script will send the current Loader/Saver node media to the AGI Photoscan photogrammetry software via a new Photoscan .psx project file.'
	
	d = {}
	d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 5, Wrap = true, Default = msg}
	d[2] = {'LayerOrder', Name = 'Layer Order', 'Dropdown', Default = layerOrder, Options = layerOrderList}
	d[3] = {'Chunk', Name = 'View Chunks', 'Dropdown', Default = chunk, Options = chunkList}
	d[4] = {'Width', Name = 'Image Width', 'Slider', Default = width, Integer = true, Min = 1, Max = 16384}
	d[5] = {'Height', Name = 'Image Height', 'Slider', Default = height, Integer = true, Min = 1, Max = 16384}
	d[6] = {'UseAlphaMasks', Name = 'Use Alpha Masks', 'Checkbox', Default = useAlphaMasks, NumAcross = 2}
	
	-- Hide a relative path control from Resolve since "Comp:/" does not exist
	if hostOS == 'Fusion' then
		d[7] = {'UseRelativePaths', Name = 'Use Relative Paths for Loaders', 'Checkbox', Default = useRelativePaths, NumAcross = 2}
	end
	
	d[8] = {'OpenOutputFolder', Name = 'Open Output Folder', 'Checkbox', Default = openOutputFolder, NumAcross = 1}

	dialog = comp:AskUser('Send Media to Photoscan', d)
	if dialog == nil then
		print('You cancelled the dialog!')
		err = true
		
		-- Unlock the comp flow area
		comp:Unlock()
		return
	else
		-- Debug - List the output from the AskUser dialog window
		-- dump(dialog)
		
		layerOrder = dialog.LayerOrder
		setPreferenceData('KartaVR.Photoscan.LayerOrder', layerOrder, printStatus)
		
		chunk = dialog.Chunk
		setPreferenceData('KartaVR.Photoscan.Chunk', chunk, printStatus)
		
		useAlphaMasks = dialog.UseAlphaMasks
		setPreferenceData('KartaVR.Photoscan.UseAlphaMasks', useAlphaMasks, printStatus)
		
		-- Only allow relative filepaths on Fusion Standalone
		useRelativePaths = ''
		if hostOS == 'Fusion' then
			useRelativePaths = dialog.UseRelativePaths
		else
			-- Resolve is running
			useRelativePaths = 0
		end
		setPreferenceData('KartaVR.Photoscan.UseRelativePaths', useRelativePaths, printStatus)
		
		openOutputFolder = dialog.OpenOutputFolder
		setPreferenceData('KartaVR.Photoscan.OpenOutputFolder', openOutputFolder, printStatus)
		
		print('[Layer Order] ' .. layerOrder)
		print('[Chunk] ' .. chunk)
		print('[Image Size] ' .. width .. 'x' .. height .. ' px')
		print('[Use Alpha Masks] ' .. useAlphaMasks)
		print('[Use Relative Paths] ' .. useRelativePaths)
		print('[Open Output Folder] ' .. openOutputFolder)
	end
	
	-- Create a stub image table
	img = {}
	
	-- Check the active selection and return a list of media files
	totalImg = GenerateMediaList()
	
	-- Create the Photoscan project file (without the .psx extension)
	psx = createPhotoscanProject(photoscanProjectName, img, totalImg)
	
	-- Open the output folder for the photoscan.psx file
	if openOutputFolder == 1 then
		psxFolder = dirname(psx)
		openDirectory(psxFolder)
	end
	
	-- Unlock the comp flow area
	comp:Unlock()
	
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
