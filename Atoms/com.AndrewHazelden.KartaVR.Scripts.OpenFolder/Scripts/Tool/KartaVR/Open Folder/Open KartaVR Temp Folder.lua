--[[--
----------------------------------------------------------------------------
Open KartaVR Temp Folder - v4.21 2019-11-12
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
https://www.andrewhazelden.com/projects/kartavr/docs/
----------------------------------------------------------------------------
Overview:

The Open KartaVR Temp Folder script is a module from [KartaVR](https://www.andrewhazelden.com/projects/kartavr/docs/) that will open a file browser window to show the temporary directory that the KartaVR uses to write out viewer snapshots and other files.

How to use the Script:

Step 1. Start Fusion and open a new comp. 

Step 2. Run the "Script > KartaVR > Open Folder > Open Containing Folder" menu item.

--]]--

-- --------------------------------------------------------
-- --------------------------------------------------------
-- --------------------------------------------------------

local printStatus = false

-- Track if the image was found
local err = false

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Set a fusion specific preference value
-- Example: SetPreferenceData('KartaVR.SendMedia.Format', 3, true)
function SetPreferenceData(pref, value, status)
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
-- Example: GetPreferenceData('KartaVR.SendMedia.Format', 3, true)
function GetPreferenceData(pref, defaultValue, status)
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
-- Example: print(Dirname("/Users/Shared/file.txt"))
function Dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end


-- Open a folder window up using your desktop file browser
function OpenDirectory(mediaDirName)
	command = nil
	dir = Dirname(mediaDirName)
	
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


-- Play a KartaVR "audio" folder based wave audio file using a native Mac/Windows/Linux method:
-- Example: playWaveAudio('trumpet-fanfare.wav')
-- or if you want to see debugging text use:
-- Example: playWaveAudio('trumpet-fanfare.wav', true)
function PlayDFMWaveAudio(filename, status)
	if status == true or status == 1 then 
		print('[Base Audio File] ' .. filename)
	end
	
	local audioFilePath = ''
	
	if platform == 'Windows' then
		-- Note Windows Powershell is very lame and it really really needs you to escape each space in a filepath with a backtick ` character or it simply won't work!
		audioFolderPath = app:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
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
		audioFolderPath = app:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
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
		audioFolderPath = app:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
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
		audioFolderPath = app:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
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


-- Find out the Fusion temporary directory path
tempDirName = app:MapPath('Temp:\\KartaVR\\')

-- Create the temporary directory
os.execute('mkdir "' .. tempDirName..'"')
-- The script is running on Fusion 8+ so we will use the fileexists command
if eyeon.fileexists(tempDirName) then
	OpenDirectory(tempDirName)
else
	print('[Temporary Directory Missing] ', tempDirName)
	err = true
end


-- Play a sound effect
soundEffect = GetPreferenceData('KartaVR.SendMedia.SoundEffect', 1, printStatus)
if err == true or err == 1 then
	-- An error happend when trying to open the media file
	if soundEffect >= 1 then
		-- If the sound Effect mode is 1 or greater (not set to "None" ) than play a braam sound when an error happens
		local audioFile = 'cinematic-musical-sting-braam.wav'
		PlayDFMWaveAudio(audioFile)
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
		PlayDFMWaveAudio(audioFile)
	elseif soundEffect == 3 then
		-- Trumpet Sound
		local audioFile = 'trumpet-fanfare.wav'
		PlayDFMWaveAudio(audioFile)
	elseif soundEffect == 4 then
		-- Braam Sound
		local audioFile = 'cinematic-musical-sting-braam.wav'
		PlayDFMWaveAudio(audioFile)
	end
end

-- End of the script
print('[Done]')
return

