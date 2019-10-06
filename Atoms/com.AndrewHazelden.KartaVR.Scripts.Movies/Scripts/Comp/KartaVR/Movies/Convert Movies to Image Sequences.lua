--[[--
----------------------------------------------------------------------------
Convert Movies to Image Sequences v4.0.1 2019-01-01

by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The Convert Movies to Image Sequences script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that lets you extract image sequences from a folder's worth of movie files.

How to use the Script:

Step 1. Start Fusion and open a new comp. Then run the Script > KartaVR > Movies > Convert Movies to Image Sequences menu item.

Step 2. In the Convert Movies to Image Sequences dialog window you need to define the output formats and settings for the extracted image sequence.

Note: The close X box on the dialog window does not work. You have to hit the "Cancel" button to close the window.

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


-- Use FFmpeg to transcode the files
function ffmpegTranscodeMedia(movieFolder, audioFormat, imageFormat, imageName, framePadding, compress, frameRate)
	-- Select the audio file format
	if audioFormat == 0 then
		audioFormatExt = ''
	elseif audioFormat == 1 then
		audioFormatExt = 'aiff'
	elseif audioFormat == 2 then
		audioFormatExt = 'mp3'
	elseif audioFormat == 3 then
		audioFormatExt = 'wav'
	else
		audioFormatExt = 'wav'
	end
	
	
	-- Select the image file format
	if imageFormat == 0 then
		imageFormatExt = 'none'
	elseif imageFormat == 1 then
		imageFormatExt = 'jpg'
	elseif imageFormat == 2 then
		imageFormatExt = 'tif'
	elseif imageFormat == 3 then
		imageFormatExt = 'tga'
	elseif imageFormat == 4 then
		imageFormatExt = 'png'
	elseif imageFormat == 5 then
		imageFormatExt = 'bmp'
	elseif imageFormat == 6 then
		imageFormatExt = 'dpx'
	elseif imageFormat == 7 then
		imageFormatExt = 'exr'
	else
		-- Fallback option
		imageFormatExt = 'png'
	end
	
	print('[Working Directory] ' .. movieFolder )
	
	print('\n')
	
	-- Create a new LUA table for the files to process	
	filesList = {}

	dirCommand = ''
	if platform == 'Windows' then
		-- The dir options '/b /ad' lists directories and '/b' lists just files
		dirCommand = 'dir ' .. movieFolder .. ' /b'
	else
		dirCommand = 'ls -a "' .. movieFolder .. '"'
	end
	
	-- print('[Directory Listing]')
	-- Search the selected directory for movie content
	for files in io.popen(dirCommand):lines() do 
		-- print(files)
		-- Add another file to the filesList table
		fileNoCase = files.lower(files)
		if fileNoCase:match('.*%.mp4') or fileNoCase:match('.*%.m4v') or fileNoCase:match('.*%.mov') or fileNoCase:match('.*%.avi') or fileNoCase:match('.*%.mkv') then
			table.insert(filesList, files)
		end
	end
	
	print('\n')
	
	-- List what we got in the table
	print('[Movie Listing]')
	dump(filesList)
	
	print('\n')

	-- Keep the frame padding a positive number
	if framePadding < 0 then
		framePadding = 0
		print('[Resetting Frame Padding] ' .. framePadding)
		setPreferenceData('KartaVR.ConvertMovies.FramePadding', framePadding, printStatus)
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
	frameNumber = '%0' .. framePadding .. 'd'
	
	-- Track the previous output folder if a filename token is used to make folders on the fly
	previousOutputDirectory = ''
	
	-- Process the items in the current folder
	print('[Transcoded Media]')
	for i, files in ipairs(filesList) do
		-- Generate the extracted audio filename
		if imageName == 0 then
			-- <name>.#.<ext>
			imgSeqFile = movieFolder .. eyeon.trimExtension(files) .. '.' .. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 1 then
			-- <name>_#.<ext>
			imgSeqFile = movieFolder .. eyeon.trimExtension(files) .. '_' .. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 2 then
			-- <name>#.<ext>
			imgSeqFile = movieFolder .. eyeon.trimExtension(files).. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 3 then
			-- <name>/<name>.#.<ext> (In a Subfolder)
			imgSeqFile = movieFolder .. eyeon.trimExtension(files) .. osSeparator .. eyeon.trimExtension(files) .. '.' .. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 4 then
			-- <name>/<name>_#.<ext> (In a Subfolder)
			imgSeqFile = movieFolder .. eyeon.trimExtension(files) .. osSeparator .. eyeon.trimExtension(files) .. '_' .. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 5 then
			-- <name>/#.<ext> (In a Subfolder)
			imgSeqFile = movieFolder .. eyeon.trimExtension(files) .. osSeparator .. frameNumber .. '.' .. imageFormatExt
		elseif imageName == 6 then
			-- #/<name>.<ext> (In a Subfolder)
			imgSeqFile = movieFolder .. frameNumber .. osSeparator .. eyeon.trimExtension(files) .. '.' .. frameNumber .. '.' .. imageFormatExt
		else 
			-- Fallback to <name>.#.<ext>
			imgSeqFile = movieFolder .. eyeon.trimExtension(files) .. '.' .. frameNumber .. '.' .. imageFormatExt
		end
		
		-- Generate the extracted audio filename
		if imageName == 3 or imageName == 4 or imageName == 5 then
			-- (In a Subfolder)	<audio name>.<ext>
			audioFile = movieFolder .. eyeon.trimExtension(files) .. osSeparator .. eyeon.trimExtension(files) .. '.' .. audioFormatExt
		else
			-- Just name the audio file format with <audio name>.ext
			audioFile = movieFolder .. eyeon.trimExtension(files) .. '.' .. audioFormatExt
		end
		
		-- -----------------------------------
		-- Run FFMPEG on the media clip
		-- -----------------------------------
		-- FFMPEG input video clip
		sourceMovie = movieFolder .. files
		
		-- Create the output directory
		outputDirectory = dirname(imgSeqFile)
		if platform == 'Windows' then
			os.execute('mkdir "' .. outputDirectory..'"')
		else
			-- Mac and Linux
			os.execute('mkdir -p "' .. outputDirectory..'"')
		end
		
		-- Open up the image sequence output folder
		if outputDirectory ~= previousOutputDirectory then
			if imageName == 5 then
				-- Open the based folder if the mode "#/<name>.<ext> (In a Subfolder)" is selected
				openDirectory(movieFolder)
			else
				openDirectory(outputDirectory)
			end
		end
		
		-- Select the image file format
		if imageFormat == 0 then
			print('[Skipping Video Conversion]')
		else
			-- List the newly generated sequence file names
			print('[' .. imageFormatExt .. ' Video Conversion]' .. '[' .. i .. '] [Image Sequence] ' .. imgSeqFile)
			
			-- FFMPEG maximum image quality = -q:v 1
			quality = '-q:v 1'
			
			-- FFMPEG extracted image sequence frame rate
			videoframeRate = '-r ' .. frameRate
			--frameRate = '-r 29.97'
			
			-- FFMPEG output image pixel format
			pixelFormat = ''
			
			-- Check the tiff compression modes
			-- packbits raw lzw deflate
			if imageFormat == 2 then
				-- We are compressing a tiff image!
				
				-- FFMPEG output image pixel format
				-- Supported formats: rgb24 rgb48le pal8 rgba rgba64le gray ya8 gray16le ya16le monob monow yuv420p yuv422p yuv440p yuv444p yuv410p yuv411p
				pixelFormat = '-pix_fmt rgb24'
			
				-- Select the compression format
				if compress == 0 then
					-- use default options
					compressionFormat = ''
				elseif compress == 1 then
					-- RLE is known as packbits
					compressionFormat = 'packbits'
				elseif compress == 2 then
					-- lzw compression
					compressionFormat = 'lzw'
				else
					compressionFormat = ''
				end
					
				pixelFormat = pixelFormat .. ' ' .. '-compression_algo' .. ' ' .. compressionFormat
				
				-- Set the DPI Dots Per Inch rez
				pixelDPI = '-dpi 72'
				-- pixelDPI = ' '
				pixelFormat = pixelFormat .. ' ' .. pixelDPI
			end
			
			-- Always overwrite existing files
			overwriteMedia = '-y'
		
			-- FFMPEG launching string
			ffmpegCommand = overwriteMedia .. ' ' .. ' -i ' .. '"' .. sourceMovie .. '"' .. ' ' .. videoframeRate .. ' ' ..quality .. ' ' .. pixelFormat .. ' ' .. '"' .. imgSeqFile .. '"' 
			-- print('[FFMPEG Command String] ' .. ffmpegCommand)
			
			-- Redirect the output from the terminal to a log file
			outputLog = outputDirectory .. 'ffmpegVideoTranscode.txt'
			logCommand = ''
			if platform == 'Windows' then
				logCommand = ' ' .. '2>&1 | "' .. app:MapPath('Reactor:/Deploy/Bin/wintee/bin/wtee.exe') .. '" -a' .. ' "' .. outputLog.. '" '
			elseif platform == 'Mac' then
				logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
			elseif platform == 'Linux' then
				logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
			end
			
			-- Open FFMPEG
			if platform == 'Windows' then
				-- Running on Windows
				
				defaultffmpegProgram = comp:MapPath('Reactor:/Deploy/Bin/ffmpeg/bin/ffmpeg.exe')
				-- defaultffmpegProgram = 'C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe'
				-- defaultffmpegProgram = 'C:\\ffmpeg\\bin\\ffmpeg.exe'
				ffmpegProgram = getPreferenceData('KartaVR.SendMedia.ffmpegFile', defaultffmpegProgram, printStatus)
				command = 'start "" "' .. ffmpegProgram .. '" ' .. ffmpegCommand .. logCommand
				
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			elseif platform == 'Mac' then
				-- Running on Mac
				
				defaultffmpegProgram = comp:MapPath('Reactor:/Deploy/Bin/ffmpeg/bin/ffmpeg')
				-- defaultffmpegProgram = '/opt/local/bin/ffmpeg'
				ffmpegProgram = getPreferenceData('KartaVR.SendMedia.ffmpegFile', defaultffmpegProgram, printStatus)
				command = '"' .. ffmpegProgram .. '" ' .. ffmpegCommand .. logCommand
				
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			else
				-- Running on Linux
				
				defaultffmpegProgram = '/opt/local/bin/ffmpeg'
				ffmpegProgram = getPreferenceData('KartaVR.SendMedia.ffmpegFile', defaultffmpegProgram, printStatus)
				command = '"' .. ffmpegProgram .. '" ' .. ffmpegCommand .. logCommand
				
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			end
		end
		
		-- -----------------------------------
		-- Run FFMPEG to extract audio
		-- -----------------------------------
		
		-- Select the audio file format
		if audioFormat == 0 then
			print('[Skipping Audio Conversion]')
		else
			print('[' .. audioFormatExt .. ' Audio Conversion]' .. '[' .. i .. '] [Audio] ' .. audioFile)
			
			-- Choose an audio format
			audioFormat = '-vn -f ' .. audioFormatExt
			-- audioFormat = '-vn -f wav'
			-- audioFormat = '-vn -f wav -ac 2'
			
			-- Audio frequency / audio rate in KHz
			audioFrequency = ' '
			-- audioFrequency = '-ar 44100'
			-- audioFrequency = '-ar 48000'
			-- audioFrequency = '-ar 96000'
			
			-- Always overwrite existing files
			overwriteMedia = '-y'
			
			-- FFMPEG Audio launching string
			ffmpegAudioCommand = overwriteMedia .. ' ' .. ' -i ' .. '"' .. sourceMovie .. '"' .. ' ' .. audioFormat .. ' ' .. audioFrequency .. ' ' .. '"' .. audioFile .. '"' 
			-- print('[FFMPEG Command String] ' .. ffmpegCommand)

			
			-- Redirect the output from the terminal to a log file
			outputLog = outputDirectory .. 'ffmpegAudioTranscode.txt'
			logCommand = ''
			if platform == 'Windows' then
				logCommand = ' ' .. '2>&1 | "' .. app:MapPath('Reactor:/Deploy/Bin/wintee/bin/wtee.exe') .. '" -a' .. ' "' .. outputLog.. '" '
			elseif platform == 'Mac' then
				logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
				logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
			end
			
			-- Open FFMPEG
			if platform == 'Windows' then
				-- Running on Windows
				
				defaultffmpegProgram = comp:MapPath('Reactor:/Deploy/Bin/ffmpeg/bin/ffmpeg.exe')
				-- defaultffmpegProgram = 'C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe'
				-- defaultffmpegProgram = 'C:\\ffmpeg\\bin\\ffmpeg.exe'
				ffmpegProgram = getPreferenceData('KartaVR.SendMedia.ffmpegFile', defaultffmpegProgram, printStatus)
				command = 'start "" "' .. ffmpegProgram .. '" ' .. ffmpegAudioCommand .. logCommand
				
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			elseif platform == 'Mac' then
				-- Running on Mac
				
				defaultffmpegProgram = comp:MapPath('Reactor:/Deploy/Bin/ffmpeg/bin/ffmpeg')
				-- defaultffmpegProgram = '/opt/local/bin/ffmpeg'
				ffmpegProgram = getPreferenceData('KartaVR.SendMedia.ffmpegFile', defaultffmpegProgram, printStatus)
				command = '"' .. ffmpegProgram .. '" ' .. ffmpegAudioCommand .. logCommand
				
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			else
				-- Running on Linux
				
				defaultffmpegProgram = '/opt/local/bin/ffmpeg'
				ffmpegProgram = getPreferenceData('KartaVR.SendMedia.ffmpegFile', defaultffmpegProgram, printStatus)
				command = '"' .. ffmpegProgram .. '" ' .. ffmpegAudioCommand .. logCommand
				
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			end
			
		end
		
		-- -----------------------------------
		
		-- Track the last folder written to
		previousOutputDirectory = outputDirectory
	end
	
	print('\n')
end


print('Convert Movies to Image Sequences is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

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

-- Location of movies - use the comp path as the default starting value if the preference doesn't exist yet
movieFolder = getPreferenceData('KartaVR.ConvertMovies.MovieFolder', compPath, printStatus)

audioFormat = getPreferenceData('KartaVR.ConvertMovies.AudioFormat', 3, printStatus)

-- audioChannels = getPreferenceData('KartaVR.ConvertMovies.AudioChannels', 1, printStatus)


-- if imageName is 0 = <name>.#.<ext> and 4 = <name>/<name>.#.<ext>
imageName = getPreferenceData('KartaVR.ConvertMovies.ImageName', 3, printStatus)
imageFormat = getPreferenceData('KartaVR.ConvertMovies.ImageFormat', 2, printStatus)
compress = getPreferenceData('KartaVR.ConvertMovies.Compression', 2, printStatus)
framePadding = getPreferenceData('KartaVR.ConvertMovies.FramePadding', 4, printStatus)
frameRate = getPreferenceData('KartaVR.ConvertMovies.FrameRate', 30, printStatus)
-- startOnFrameOne = getPreferenceData('KartaVR.ConvertMovies.StartOnFrameOne', 0, printStatus)
soundEffect = getPreferenceData('KartaVR.ConvertMovies.SoundEffect', 3, printStatus)


msg = 'Customize the settings for converting a folder of movies into image sequences.'

audioFormatList = {'None', 'AIFF', 'MP3', 'WAVE'}
-- audioChannelsList = { 'Mono', 'Left/Right Stereo', 'Ambisonic B-Format'}

namingList = {'<name>.#.<ext>', '<name>_#.<ext>', '<name>#.<ext>', '<name>/<name>.#.<ext> (In a Subfolder)', '<name>/<name>_#.<ext> (In a Subfolder)', '<name>/#.<ext> (In a Subfolder)'}

-- Extra option needs a numbered folder creation: '#/<name>.<ext> (In a Subfolder)'
-- namingList = {'<name>.#.<ext>', '<name>_#.<ext>', '<name>#.<ext>', '<name>/<name>.#.<ext> (In a Subfolder)', '<name>/<name>_#.<ext> (In a Subfolder)', '<name>/#.<ext> (In a Subfolder)', '#/<name>.<ext> (In a Subfolder)'}

-- Image format list
formatList = {'None', 'JPEG', 'TIFF', 'TGA', 'PNG', 'BMP'}
-- Image format list with high bit depth formats
-- formatList = {'None', 'JPEG', 'TIFF', 'TGA', 'PNG', 'BMP', 'DPX', 'EXR'}

-- Image compression list
compressionList = {'None', 'RLE', 'LZW'}

-- Sound effect list
soundEffectList = {'None', 'On Error Only', 'Steam Train Whistle Sound', 'Trumpet Sound', 'Braam Sound'}

d = {}
d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg}

d[2] = {'MovieFolder', Name = 'Movie Folder', 'PathBrowse', Default = movieFolder}

d[3] = {'ImageName', Name = 'Image Name', 'Dropdown', Default = imageName, Options = namingList}
d[4] = {'ImageFormat', Name = 'Image Format', 'Dropdown', Default = imageFormat, Options = formatList}
d[5] = {'Compression', Name = 'Compression', 'Dropdown', Default = compress, Options = compressionList}
d[6] = {'FramePadding', Name = 'Frame Padding', 'Slider', Default = framePadding, Integer = true, Min = 0, Max = 8}
d[7] = {'FrameRate', Name = 'Frame Rate', 'Screw', Default = frameRate, Min = 1, Max = 120} 
-- d[8] = {'StartOnFrameOne', Name = 'Start on Frame 1', 'Checkbox', Default = startOnFrameOne, NumAcross = 2}

d[8] = {'AudioFormat', Name = 'Audio Format', 'Dropdown', Default = audioFormat, Options = audioFormatList}
-- d[9] = {'AudioChannels', Name = 'Audio Channels', 'Dropdown', Default = audioChannels, Options = audioChannelsList}


d[9] = {'SoundEffect', Name = 'Sound Effect', 'Dropdown', Default = soundEffect, Options = soundEffectList}


dialog = comp:AskUser('Convert Movies to Image Sequences', d)
if dialog == nil then
	print('You cancelled the dialog!')
	return
else
	-- Debug - List the output from the AskUser dialog window
	dump(dialog)
	
	movieFolder = comp:MapPath(dialog.MovieFolder)
	setPreferenceData('KartaVR.ConvertMovies.MovieFolder', movieFolder, printStatus)
	
	audioFormat = dialog.AudioFormat
	setPreferenceData('KartaVR.ConvertMovies.AudioFormat', audioFormat, printStatus)
	
	-- audioChannels = dialog.AudioChannels
	-- setPreferenceData('KartaVR.ConvertMovies.AudioChannels', audioChannels, printStatus)
	
	imageName = dialog.ImageName
	setPreferenceData('KartaVR.ConvertMovies.ImageName', imageName, printStatus)
	
	imageFormat = dialog.ImageFormat
	setPreferenceData('KartaVR.ConvertMovies.ImageFormat', imageFormat, printStatus)
	
	compress = dialog.Compression
	setPreferenceData('KartaVR.ConvertMovies.Compression', compress, printStatus)
	
	framePadding = dialog.FramePadding
	setPreferenceData('KartaVR.ConvertMovies.FramePadding', framePadding, printStatus)
	
	frameRate = dialog.FrameRate
	setPreferenceData('KartaVR.ConvertMovies.FrameRate', frameRate, printStatus)
	
	-- startOnFrameOne = dialog.StartOnFrameOne
	-- setPreferenceData('KartaVR.ConvertMovies.StartOnFrameOne', startOnFrameOne, printStatus)
	
	soundEffect = dialog.SoundEffect
	setPreferenceData('KartaVR.ConvertMovies.SoundEffect', soundEffect, printStatus)
end


-- Use FFmpeg to transcode the files
ffmpegTranscodeMedia(movieFolder, audioFormat, imageFormat, imageName, framePadding, compress, frameRate)


-- Unlock the comp flow area
comp:Unlock()

-- Play a sound effect
soundEffect = getPreferenceData('KartaVR.ConvertMovies.SoundEffect', 1, printStatus)
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
