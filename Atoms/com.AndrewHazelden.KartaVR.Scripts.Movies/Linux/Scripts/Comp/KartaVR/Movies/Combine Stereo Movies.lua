--[[--
------------------------------------------------------------------------------
Combine Stereo Movies v4.0 for Fusion - 2018-12-11
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
------------------------------------------------------------------------------
Overview:

The Combine Stereo Movies script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that lets you take separate left and right stereo videos and merge them into Over/Under or Side by Side stereo videos. You can also transcode the video into MP4 H.264, H.265, and QuickTime ProRes video formats.

How to use the Script:

Step 1. Start Fusion and open a new comp. Then run the Script > KartaVR > Movies > Combine Stereo Movies menu item.

Step 2. In the Combine Stereo Movies dialog window you need to select the left and right movie files and define the output movie name.

Note: The close X box on the dialog window does not work. You have to hit the "Cancel" button to close the window.


Todo:
	Video duration limit UI element

	FFMPEG Tips:

	Check the active ffmpeg media formats:
	ffmpeg -formats

	Check the active ffmpeg video codecs:
	ffmpeg -codecs

	Check the active ffmpeg filters:
	ffmpeg -filters

--]]--

------------------------------------------------------------------------------

local printStatus = false

-- Find out if we are running Fusion 7 or 8
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Add the platform specific folder slash character
local osSeparator = package.config:sub(1,1)

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')


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


-- Use FFmpeg to transcode the files
function ffmpegTranscodeMedia(leftMovie, rightMovie, stereoMovieOutput, stereoLayout, movieFormat, audioFormat, soundEffect, enableFaststart, trimDurationToShortestClip)
	-- Create the output directory
	outputDirectory = dirname(stereoMovieOutput)
	if platform == 'Windows' then
		os.execute('mkdir "' .. outputDirectory..'"')
	else
		-- Mac and Linux
		os.execute('mkdir -p "' .. outputDirectory..'"')
	end
	print('[Working Directory] ' .. outputDirectory )
	print('\n')
	
	
	-- FFMPEG output video codec
	-- Supported formats: rgb24 rgb48le pal8 rgba rgba64le gray ya8 gray16le ya16le monob monow yuv420p yuv422p yuv440p yuv444p yuv410p yuv411p
	
	-- Select the movie file format
	if movieFormat == 0 then
		-- MOV ProRes 422
		movieFormatExt = 'mov'
		videoCodecFormat = '-q:v 0 -f mov -vcodec prores_ks -profile:v 2 -vendor ap10 -pix_fmt yuv422p10le'

	-- Disabled temporarily ------------------------------
	-- elseif movieFormat == 1 then
		-- MOV ProRes 422 HQ
		-- movieFormatExt = 'mov'
		-- videoCodecFormat = '-q:v 0 -f mov -vcodec prores_ks -profile:v 3 -vendor ap10 -pix_fmt yuv422p10le'
	-- elseif movieFormat == 2 then
		-- MOV ProRes 4444
		-- movieFormatExt = 'mov'
		-- videoCodecFormat = '-f mov -vcodec prores -profile:v 4444 -vendor ap10 -pix_fmt yuva444p10le -alpha_bits 8'
	-- elseif movieFormat == 2 then
		-- MOV DNxHD
		-- movieFormatExt = 'mov'
		-- videoCodecFormat = '-q:v 1 -f mov -vcodec dnxhd -s hd1080 -b:v 175M -vendor ap10 -pix_fmt yuv422p'
	-- Disabled temporarily ------------------------------
	
	elseif movieFormat == 1 then
		-- MOV H.264
		movieFormatExt = 'mov'
		videoCodecFormat = '-q:v 1 -f mov -vcodec libx264 -pix_fmt yuv420p'
	elseif movieFormat == 2 then
		-- MP4 H.264
		movieFormatExt = 'mp4'
		videoCodecFormat = '-q:v 1 -f mp4 -vcodec libx264 -pix_fmt yuv420p'
	elseif movieFormat == 3 then
		-- MP4 H.265
		movieFormatExt = 'mp4'
		videoCodecFormat = '-q:v 1 -f mp4 -vcodec libx265 -pix_fmt yuv420p'
	elseif movieFormat == 4 then
		-- MKV H.264
		movieFormatExt = 'mkv'
		videoCodecFormat = '-q:v 1 -f mkv -vcodec libx264 -pix_fmt yuv420p'
	elseif movieFormat == 5 then
		-- MKV H.265
		movieFormatExt = 'mkv'
		videoCodecFormat = '-q:v 1 -f mkv -vcodec libx265 -pix_fmt yuv420p'
	else
		-- Fallback option
		-- MP4 H.264
		movieFormatExt = 'mp4'
		videoCodecFormat = '-q:v 1 -f mp4 -vcodec libx264 -pix_fmt yuv420p'
	end
	
	-- Select the audio file format
	if audioFormat == 0 then
		-- none
		audioCodecFormat = '-acodec aac -strict -2'
	elseif audioFormat == 1 then
		-- AAC
		audioCodecFormat = '-acodec aac -strict -2'
	elseif audioFormat == 2 then
		-- PCM signed 16-bit little-endian
		audioCodecFormat = '-acodec pcm_s16le -strict -2'
	elseif audioFormat == 3 then
		-- Copy
		audioCodecFormat = '-acodec copy -strict -2'
	else
		-- Fallback option
		-- AAC
		audioCodecFormat = '-acodec aac -strict -2'
	end
	
	
	-- Select the stereoscopic frame layout
	if stereoLayout == 0 then
		-- Over/Under
		-- https://ffmpeg.org/ffmpeg-filters.html#vstack
		
		print('[Stereo Layout] Over/Under')
		-- stereoFrameFormat = '-i "' .. leftMovie .. '" -i "' .. rightMovie .. '" -filter_complex "vstack"'
		stereoFrameFormat = '-i "' .. leftMovie .. '" -vf "[in] pad=iw:2*ih [left]; movie=' .. rightMovie .. ' [right]; [left][right] overlay=0:main_h/2 [out]"'
	elseif stereoLayout == 1 then
		-- Side by Side
		-- https://ffmpeg.org/ffmpeg-filters.html#hstack
		
		print('[Stereo Layout] Side by Side')
		-- stereoFrameFormat = '-i "' .. leftMovie .. '" -i "' .. rightMovie .. '" -filter_complex "hstack"'
		stereoFrameFormat = '-i "' .. leftMovie .. '" -vf "[in] pad=iw*2:ih [left]; movie=' .. rightMovie .. ' [right]; [left][right] overlay=main_w/2:0 [out]"'
	elseif stereoLayout == 2 then
		-- Anaglyph Red/Cyan	- doesn't quite work yet as it really needs the hstack mode to function
		-- https://ffmpeg.org/ffmpeg-filters.html#stereo3d
		
		print('[Stereo Layout] Anaglyph Red/Cyan')
		-- stereoFrameFormat = '-i "' .. leftMovie .. '" -i "' .. rightMovie .. '" -filter_complex "hstack,stereo3d=sbsl:arcc"'
		stereoFrameFormat = '-i "' .. leftMovie .. '" -vf "[in] pad=iw*2:ih [left]; movie=' .. rightMovie .. ' [right]; [left][right] overlay=main_w/2:0 [out]"'
		-- Add the anaglyph encoding stage
		stereoFrameFormat = stereoFrameFormat .. ' -vf "stereo3d=sbsl:arcc"'
	else
		-- Fallback
		-- Over/Under
		-- https://ffmpeg.org/ffmpeg-filters.html#vstack
		
		print('[Stereo Layout] Fallback Over/Under')
		-- stereoFrameFormat = '-i "' .. leftMovie .. '" -i "' .. rightMovie .. '" -filter_complex "vstack"'
		stereoFrameFormat = '-i "' .. leftMovie .. '" -vf "[in] pad=iw:2*ih [left]; movie=' .. rightMovie .. ' [right]; [left][right] overlay=0:main_h/2 [out]"'
	end
	
	-- -----------------------------------
	-- Run FFMPEG on the media clip
	-- -----------------------------------
	
	-- Always overwrite existing files
	overwriteMedia = '-y'
	
	-- Should the shortest video clip (of the left or right views) be used as the duration of the output movie
	if trimDurationToShortestClip == 1 then
		shortestClip = '-shortest'
	else
		shortestClip = ''
	end
	
	-- Enable the Quicktime fast start movie option. This control makes it faster to download and start playing the movie on the internet at the expense of a higher video encoding time.
	if enableFaststart == 1 then
		fastStartMovie = '-movflags faststart'
	else
		fastStartMovie = ''
	end
	
	-- Limit video duration in seconds
	videoDurationSeconds = ''
	-- videoDurationSeconds = '-t 10'
	
	-- FFMPEG launching string
	ffmpegCommand = overwriteMedia .. ' ' .. stereoFrameFormat .. ' ' .. videoCodecFormat .. ' ' .. audioCodecFormat .. ' '.. shortestClip .. ' ' .. videoDurationSeconds .. ' ' .. fastStartMovie .. ' ' .. '"' .. stereoMovieOutput .. '"' 
	
	-- Redirect the output from the terminal to a log file
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputTempDirectory = comp:MapPath('Temp:\\KartaVR\\')
	os.execute('mkdir "' .. outputTempDirectory..'"')
	outputLog = outputTempDirectory .. 'ffmpegVideoTranscode.txt'
	logCommand = ''
	if platform == 'Windows' then
		logCommand = ' ' .. '2>&1 | "C:\\Program Files\\KartaVR\\tools\\wintee\\bin\\wtee.exe" -a' .. ' "' .. outputLog.. '" '
	elseif platform == 'Mac' then
		logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
	elseif platform == 'Linux' then
		logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
	end
	
	-- List the newly generated sequence file names
	print('[Combine Stereo Movies] [Left] ' .. leftMovie .. ' [Right] ' .. rightMovie .. ' [Stereo] ' .. stereoMovieOutput)
	
	-- Open FFMPEG
	if platform == 'Windows' then
		-- Running on Windows
		viewerProgram = '"C:\\Program Files\\KartaVR\\tools\\ffmpeg\\bin\\ffmpeg.exe"'
		command = 'start "" ' .. viewerProgram .. ' ' .. ffmpegCommand .. logCommand
		-- command = viewerProgram .. ' ' .. ffmpegCommand .. logCommand
		print('[FFMPEG Launch Command] ', command)
		-- os.execute(command)
		print("Combine Stereo Movies is not available for Windows yet.")
	elseif platform == 'Mac' then
		-- Running on Mac
		viewerProgram = '"/Applications/KartaVR/mac_tools/ffmpeg/bin/ffmpeg"'
		-- viewerProgram = '"/opt/local/bin/ffmpeg"'
		command = viewerProgram .. ' ' .. ffmpegCommand .. logCommand
		print('[FFMPEG Launch Command] ', command)
		os.execute(command)
	else
		-- Running on Linux
		viewerProgram = '"/opt/local/bin/ffmpeg"'
		command = viewerProgram .. ' ' .. ffmpegCommand .. logCommand
		print('[FFMPEG Launch Command] ', command)
		os.execute(command)
	end
	
	
	-- Open up the output folder
	if openOutputFolder == 1 and platform ~= 'Windows' then
		openDirectory(outputDirectory)
	end
	
	print('\n')
end


-- Play a sound effect
function CompletedSound()
	soundEffect = getPreferenceData('KartaVR.CombineStereoMovies.SoundEffect', 1, printStatus)
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


-- ------------------------------------
-- Main
-- ------------------------------------

-- Main Code
function Main()
	print('[Combine Stereo Movies]')
	
	print ('Combine Stereo Movies is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)
	
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
	compPath = dirname(comp:MapPath(comp:GetAttrs().COMPS_FileName))
	if compPath == nil then
		compPath = ''
	end
	
	-- Location of movies - use the comp path as the default starting value if the preference doesn't exist yet
	leftMovie = getPreferenceData('KartaVR.CombineStereoMovies.LeftMovie', compPath .. 'left.mp4', printStatus)
	rightMovie = getPreferenceData('KartaVR.CombineStereoMovies.RightMovie', compPath .. 'right.mp4', printStatus)
	stereoMovieOutput = getPreferenceData('KartaVR.CombineStereoMovies.StereoMovieOutput', compPath .. 'stereo_output.mp4', printStatus)
	stereoLayout = getPreferenceData('KartaVR.CombineStereoMovies.StereoLayout', 0, printStatus)
	movieFormat = getPreferenceData('KartaVR.CombineStereoMovies.MovieFormat', 3, printStatus)
	audioFormat = getPreferenceData('KartaVR.CombineStereoMovies.AudioFormat', 1, printStatus)
	soundEffect = getPreferenceData('KartaVR.CombineStereoMovies.SoundEffect', 3, printStatus)
	enableFaststart = getPreferenceData('KartaVR.CombineStereoMovies.EnableFaststart', 0, printStatus)
	trimDurationToShortestClip = getPreferenceData('KartaVR.CombineStereoMovies.TrimDurationToShortestClip', 1, printStatus)
	openOutputFolder = getPreferenceData('KartaVR.CombineStereoMovies.OpenOutputFolder', 1, printStatus)
	
	msg = 'Customize the settings for merging left and right view movies into a combined stereo 3D movie format.'
	
	stereoLayoutList = {'Over/Under', 'Side by Side'}
	-- stereoLayoutList = {'Over/Under', 'Side by Side', 'Anaglyph Red/Cyan'}
	
	-- Movie format list
	movieformatList = {'MOV ProRes 422', 'MOV H.264', 'MP4 H.264', 'MP4 H.265', 'MKV H.264', 'MKV H.265'}
	-- movieformatList = {'MOV ProRes 422', 'MOV ProRes 422 HQ', 'MOV DNxHD', 'MOV H.264', 'MP4 H.264', 'MP4 H.265', 'MKV H.264', 'MKV H.265'}
	
	audioFormatList = {'None', 'AAC', 'PCM', 'Copy'}
	
	-- Sound effect list
	soundEffectList = {'None', 'On Error Only', 'Steam Train Whistle Sound', 'Trumpet Sound', 'Braam Sound'}
	
	d = {}
	d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg}
	d[2] = {'LeftMovie', Name = 'Left Movie Input', 'FileBrowse', Default = leftMovie}
	d[3] = {'RightMovie', Name = 'Right Movie Input', 'FileBrowse', Default = rightMovie}
	d[4] = {'StereoMovieOutput', Name = 'Stereo 3D Movie Output', 'FileBrowse', Default = stereoMovieOutput}
	d[5] = {'StereoLayout', Name = 'Stereo Layout', 'Dropdown', Default = stereoLayout, Options = stereoLayoutList}
	d[6] = {'MovieFormat', Name = 'Movie Format', 'Dropdown', Default = movieFormat, Options = movieformatList}
	d[7] = {'AudioFormat', Name = 'Audio Format', 'Dropdown', Default = audioFormat, Options = audioFormatList}
	d[8] = {'SoundEffect', Name = 'Sound Effect', 'Dropdown', Default = soundEffect, Options = soundEffectList}
	d[9] = {'EnableFaststart', Name = 'Enable Faststart', 'Checkbox', Default = enableFaststart, NumAcross = 1}
	d[10] = {'TrimDurationToShortestClip', Name = 'Trim Duration to Shortest Clip', 'Checkbox', Default = trimDurationToShortestClip, NumAcross = 1}
	d[11] = {'OpenOutputFolder', Name = 'Open Output Folder', 'Checkbox', Default = openOutputFolder, NumAcross = 1}
	
	dialog = comp:AskUser('Combine Stereo Movies', d)
	if dialog == nil then
		print('You cancelled the dialog!')
		return
	else
		-- Debug - List the output from the AskUser dialog window
		dump(dialog)
		
		leftMovie = comp:MapPath(dialog.LeftMovie)
		setPreferenceData('KartaVR.CombineStereoMovies.LeftMovie', leftMovie, printStatus)
		
		rightMovie = comp:MapPath(dialog.RightMovie)
		setPreferenceData('KartaVR.CombineStereoMovies.RightMovie', rightMovie, printStatus)
		
		stereoMovieOutput = comp:MapPath(dialog.StereoMovieOutput)
		setPreferenceData('KartaVR.CombineStereoMovies.StereoMovieOutput', stereoMovieOutput, printStatus)
		
		stereoLayout = dialog.StereoLayout
		setPreferenceData('KartaVR.CombineStereoMovies.StereoLayout', stereoLayout, printStatus)
		
		movieFormat = dialog.MovieFormat
		setPreferenceData('KartaVR.CombineStereoMovies.MovieFormat', movieFormat, printStatus)
		
		audioFormat = dialog.AudioFormat
		setPreferenceData('KartaVR.CombineStereoMovies.AudioFormat', audioFormat, printStatus)
		
		soundEffect = dialog.SoundEffect
		setPreferenceData('KartaVR.CombineStereoMovies.SoundEffect', soundEffect, printStatus)
		
		enableFaststart = dialog.EnableFaststart
		setPreferenceData('KartaVR.CombineStereoMovies.EnableFaststart', enableFaststart, printStatus)
		
		trimDurationToShortestClip = dialog.TrimDurationToShortestClip
		setPreferenceData('KartaVR.CombineStereoMovies.TrimDurationToShortestClip', trimDurationToShortestClip, printStatus)
		
		openOutputFolder = dialog.OpenOutputFolder
		setPreferenceData('KartaVR.CombineStereoMovies.OpenOutputFolder', openOutputFolder, printStatus)
		
		print('[Left Movie] ' .. leftMovie)
		print('[Right Movie] ' .. rightMovie)
		print('[Stereo Movie Output] ' .. stereoMovieOutput)
		print('[Stereo Layout] ' .. stereoLayout)
		print('[Movie Format] ' .. movieFormat)
		print('[Audio Format] ' .. audioFormat)
		print('[Sound Effect] ' .. soundEffect)
		print('[Enable Faststart] ' .. enableFaststart)
		print('[Trim Duration to Shortest Clip] ' .. trimDurationToShortestClip)
		print('[Open Output Folder] ' .. openOutputFolder)
	end
	
	
	err = 0
	
	-- Check if the two input movies exist
	if eyeon.fileexists(leftMovie) == false then
		print('[The left view movie you selected is missing]')
		err = 1
	end
	
	if eyeon.fileexists(rightMovie) == false then
		print('[The right view movie you selected is missing]')
		err = 1
	end
	
	-- Use FFmpeg to transcode the files
	if err == 0 then
		-- Everything is fine and the required media exists
		ffmpegTranscodeMedia(leftMovie, rightMovie, stereoMovieOutput, stereoLayout, movieFormat, audioFormat, soundEffect, enableFaststart, trimDurationToShortestClip)
	end
	
	-- Unlock the comp flow area
	comp:Unlock()
	
	-- Open the merged stereo movie's containing folder as an Explorer/Finder/Nautilus folder view
	-- if openOutputFolder == 1 then
	-- 	openDirectory(stereoMovieOutput)
	-- end
	
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

