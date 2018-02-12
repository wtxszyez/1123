--[[
------------------------------------------------------------------------------
Convert Movies to Image Sequences v3.0 for Fusion - 2018-02-12
by Andrew Hazelden <andrew@andrewhazelden.com>

Copyright 2015-2018 Andrew Hazelden. 
This script was originally created as a custom pipeline tool that was included with the KartaVR for Fusion toolset. It is not authorized for public re-distribution outside of WSL Reactor.
------------------------------------------------------------------------------

## Overview ##

The Convert Movies to Image Sequences script lets you extract image sequences from a folder's worth of movie files.

This script requires Fusion 9+ to function.

## Usage ##

Step 1. Start Fusion and open a new comp. Then run the Script > Andrew Hazelden > Convert Movies to Image Sequences menu item.

Step 2. In the Convert Movies to Image Sequences dialog window you need to define the output formats and settings for the extracted image sequence.

Note: The close X box on the dialog window does not work. You have to hit the "Cancel" button to close the window.


## Installation ##

Step 1. Copy the "Convert Movies to Image Sequences.lua" script to your Fusion user prefs "Scripts:/Comp/Andrew Hazelden/" folder.

Step 2. Install ffmpeg. Reactor provides an FFmpeg shared linking x64 build for Windows/MacOS that is installed to the "Reactor:/Deploy/Bin/ffmpeg/" PathMap folder.

### MacOS Tip ###
If you are on MacOS you need to adjust the MacOS permissions for FFmpeg using the following Lua command in the Fusion Console tab:</p>

-- Set the FFmpeg program on MacOS to have executable permissions so the ffmpeg command line tool can be used:
command = 'chmod -R 755 "' .. comp:MapPath('Reactor:/Deploy/Bin/ffmpeg/bin/') .. '"'
print("[Permissions Update] " .. command)
os.execute(command)

### Linux Tip ###

If you are using Fusion on Linux you need to install FFmpeg manually to use this script. You can check the current installation location of ffmpeg using the terminal command "which ffmpeg".

Windows ffmpeg Install: 

https://ffmpeg.org/download.html


MacOS Homebrew Based Install:

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install ffmpeg


CentOS Install:

sudo yum -y install ffmpeg


Ubuntu Install:

sudo add-apt-repository ppa:mc3man/trusty-media
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get -y install ffmpeg


Arch Linux / Manjaro Linux Install:

sudo pacman -S ffmpeg

--]]--

local printStatus = false

-- Check the current computer platform
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Find out if we are running Fusion 7 or 8
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system's / or \\ path separator symbol
local osSeparator = package.config:sub(1,1)

-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
-- LUA dirname command inspired by Stackoverflow code example:
-- http://stackoverflow.com/questions/9102126/lua-return-directory-path-from-path
	
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end


-- Open a folder window up using your desktop file browser
function openDirectory(mediaDirName)
	command = nil
	dir = dirname(mediaDirName)
	
	if platform == "Windows" then
		-- Running on Windows
		command = 'explorer "' .. dir .. '"'
		
		print("[Launch Command] ", command)
		os.execute(command)
	elseif platform == "Mac" then
		-- Running on Mac
		command = 'open "' .. dir .. '" &'
					
		print("[Launch Command] ", command)
		os.execute(command)
	elseif platform == "Linux" then
		-- Running on Linux
		command = 'nautilus "' .. dir .. '" &'
					
		print("[Launch Command] ", command)
		os.execute(command)
	else
		print("[Platform] ", platform)
		print("There is an invalid platform defined in the local platform variable at the top of the code.")
	end
end


-- Set a fusion specific preference value
-- Example: setPreferenceData('AndrewHazelden.SendMedia.Format', 3, true)
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
-- Example: getPreferenceData('AndrewHazelden.SendMedia.Format', 3, true)
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
		setPreferenceData('AndrewHazelden.ConvertMovies.FramePadding', framePadding, printStatus)
	end

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
			-- (In a Subfolder) <audio name>.<ext>
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
		if openFolder == 1 or openFolder == true then
			if outputDirectory ~= previousOutputDirectory then
				if imageName == 5 then
					-- Open the based folder if the mode "#/<name>.<ext> (In a Subfolder)" is selected
					openDirectory(movieFolder)
				else
					openDirectory(outputDirectory)
				end
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
				logCommand = ' ' .. '2>&1 | "' .. winteePath .. '" -a' .. ' "' .. outputLog .. '" '
			elseif platform == 'Mac' then
				logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog .. '" '
			elseif platform == 'Linux' then
				logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog .. '" '
			end

			-- Open FFMPEG
			if platform == 'Windows' then
				-- Running on Windows
				launchProgram = '"' .. ffmpegFile .. '"'
				command = 'start "" ' .. launchProgram .. ' ' .. ffmpegCommand .. logCommand
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			elseif platform == 'Mac' then
				-- Running on Mac
				launchProgram = '"' .. ffmpegFile .. '"'
				command = launchProgram .. ' ' .. ffmpegCommand .. logCommand
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			else
				-- Running on Linux
				launchProgram = '"' .. ffmpegFile .. '"'
				command = launchProgram .. ' ' .. ffmpegCommand .. logCommand
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			end
		end

		-- -----------------------------------
		--		Run FFMPEG to extract audio
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
				logCommand = ' ' .. '2>&1 | "' .. winteePath .. '" -a' .. ' "' .. outputLog .. '" '
			elseif platform == 'Mac' then
				logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog .. '" '
				logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog .. '" '
			end
			
			-- Open FFMPEG
			if platform == 'Windows' then
				-- Running on Windows
				launchProgram = '"' .. ffmpegFile .. '"'
				command = 'start "" ' .. launchProgram .. ' ' .. ffmpegAudioCommand .. logCommand
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			elseif platform == 'Mac' then
				-- Running on Mac
				launchProgram = '"' .. ffmpegFile .. '"'
				command = launchProgram .. ' ' .. ffmpegAudioCommand .. logCommand
				print('[FFMPEG Launch Command] ', command)
				os.execute(command)
			else
				-- Running on Linux
				launchProgram = '"' .. ffmpegFile .. '"'
				command = launchProgram .. ' ' .. ffmpegAudioCommand .. logCommand
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


function Main()
	print ('Convert Movies to Image Sequences is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

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

	if platform == 'Windows' then
		ffmpegFile = comp:MapPath('Reactor:/Deploy/Bin/ffmpeg/bin/ffmpeg.exe')
		-- ffmpegFile = 'C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe'
		
		winteePath = comp:MapPath('Reactor:/Deploy/Bin/wintee/bin/wtee.exe')
		-- local winteePath = "C:\\Program Files\\wintee\\bin\\wtee.exe"
	elseif platform == 'Mac' then
		ffmpegFile = comp:MapPath('Reactor:/Deploy/Bin/ffmpeg/bin/ffmpeg')
		
		-- ffmpegFile = '/opt/local/bin/ffmpeg'
		-- ffmpegFile = '/usr/local/bin/ffmpeg'
		-- ffmpegFile = 'ffmpeg'
	else
		ffmpegFile = '/usr/bin/ffmpeg'
		-- ffmpegFile = '/opt/local/bin/ffmpeg'
		-- ffmpegFile = 'ffmpeg'
	end

	ffmpegFile = comp:MapPath(getPreferenceData('AndrewHazelden.ConvertMovies.FFmpegFile', ffmpegFile, printStatus))

	-- Location of movies - use the comp path as the default starting value if the preference doesn't exist yet
	movieFolder = comp:MapPath(getPreferenceData('AndrewHazelden.ConvertMovies.MovieFolder', compPath, printStatus))

	audioFormat = getPreferenceData('AndrewHazelden.ConvertMovies.AudioFormat', 3, printStatus)
	-- audioChannels = getPreferenceData('AndrewHazelden.ConvertMovies.AudioChannels', 1, printStatus)

	-- if imageName is 0 = <name>.#.<ext> and 4 = <name>/<name>.#.<ext>
	imageName = getPreferenceData('AndrewHazelden.ConvertMovies.ImageName', 3, printStatus)
	imageFormat = getPreferenceData('AndrewHazelden.ConvertMovies.ImageFormat', 2, printStatus)
	compress = getPreferenceData('AndrewHazelden.ConvertMovies.Compression', 2, printStatus)
	framePadding = getPreferenceData('AndrewHazelden.ConvertMovies.FramePadding', 4, printStatus)
	frameRate = getPreferenceData('AndrewHazelden.ConvertMovies.FrameRate', 30, printStatus)
	openFolder = getPreferenceData('AndrewHazelden.ConvertMovies.OpenFolder', 1, printStatus)
	
	msg = 'Customize the settings for converting a folder of movies into image sequences.'

	audioFormatList = {'None', 'AIFF', 'MP3', 'WAVE'}

	namingList = {'<name>.#.<ext>', '<name>_#.<ext>', '<name>#.<ext>', '<name>/<name>.#.<ext> (In a Subfolder)', '<name>/<name>_#.<ext> (In a Subfolder)', '<name>/#.<ext> (In a Subfolder)'}

	-- Extra option needs a numbered folder creation: '#/<name>.<ext> (In a Subfolder)'
	-- namingList = {'<name>.#.<ext>', '<name>_#.<ext>', '<name>#.<ext>', '<name>/<name>.#.<ext> (In a Subfolder)', '<name>/<name>_#.<ext> (In a Subfolder)', '<name>/#.<ext> (In a Subfolder)', '#/<name>.<ext> (In a Subfolder)'}

	-- Image format list
	formatList = {'None', 'JPEG', 'TIFF', 'TGA', 'PNG', 'BMP'}
	-- Image format list with high bit depth formats
	-- formatList = {"None", "JPEG", "TIFF", "TGA", "PNG", "BMP", "DPX", "EXR"}

	-- Image compression list
	compressionList = {'None', 'RLE', 'LZW'}

	d = {
		{'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg},
		{'FFmpegFile', Name = 'FFmpeg Path', 'PathBrowse', Default = ffmpegFile},
		{'MovieFolder', Name = 'Movie Folder', 'PathBrowse', Default = movieFolder},
		{'ImageName', Name = 'Image Name', 'Dropdown', Default = imageName, Options = namingList},
		{'ImageFormat', Name = 'Image Format', 'Dropdown', Default = imageFormat, Options = formatList},
		{'Compression', Name = 'Compression', 'Dropdown', Default = compress, Options = compressionList},
		{'FramePadding', Name = 'Frame Padding', 'Slider', Default = framePadding, Integer = true, Min = 0, Max = 8},
		{'FrameRate', Name = 'Frame Rate', 'Screw', Default = frameRate, Min = 1, Max = 120},
		{'AudioFormat', Name = 'Audio Format', 'Dropdown', Default = audioFormat, Options = audioFormatList},
		{"OpenFolder", Name = "Open Output Folder", "Checkbox", Default = openFolder, NumAcross = 1},
	}

	dialog = comp:AskUser('Convert Movies to Image Sequences', d)
	if dialog == nil then
		print('You cancelled the dialog!')
		return
	else
		-- Debug - List the output from the AskUser dialog window
		dump(dialog)
		
		ffmpegFile = comp:MapPath(dialog.FFmpegFile)
		setPreferenceData('AndrewHazelden.ConvertMovies.FFmpegFile', ffmpegFile, printStatus)

		movieFolder = comp:MapPath(dialog.MovieFolder)
		setPreferenceData('AndrewHazelden.ConvertMovies.MovieFolder', movieFolder, printStatus)
	
		audioFormat = dialog.AudioFormat
		setPreferenceData('AndrewHazelden.ConvertMovies.AudioFormat', audioFormat, printStatus)

		imageName = dialog.ImageName
		setPreferenceData('AndrewHazelden.ConvertMovies.ImageName', imageName, printStatus)
		
		imageFormat = dialog.ImageFormat
		setPreferenceData('AndrewHazelden.ConvertMovies.ImageFormat', imageFormat, printStatus)
		
		compress = dialog.Compression
		setPreferenceData('AndrewHazelden.ConvertMovies.Compression', compress, printStatus)
	
		framePadding = dialog.FramePadding
		setPreferenceData('AndrewHazelden.ConvertMovies.FramePadding', framePadding, printStatus)
	
		frameRate = dialog.FrameRate
		setPreferenceData('AndrewHazelden.ConvertMovies.FrameRate', frameRate, printStatus)
		
		openFolder = dialog.OpenFolder
		setPreferenceData('AndrewHazelden.ConvertMovies.OpenFolder', openFolder, printStatus)
	end

	-- Use FFmpeg to transcode the files
	ffmpegTranscodeMedia(movieFolder, audioFormat, imageFormat, imageName, framePadding, compress, frameRate)

	-- Unlock the comp flow area
	comp:Unlock()
end

-- Run the main function
Main()

-- End of the script
print('[Done]')
