--[[--
------------------------------------------------------------------------------
View KartaVR Example 360VR Stitching Comps - v4.2.1 2019-11-14
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
https://www.andrewhazelden.com/projects/kartavr/docs/
------------------------------------------------------------------------------
Overview:

This script is a module from the [KartaVR](https://www.andrewhazelden.com/projects/kartavr/docs/) that will open a web browser window to and display the HTML formatted 360° video stitching media download webpage.

How to use the Script:

Step 1. Start Fusion and open a new comp.

Step 2. Then run the "Script > KartaVR > View KartaVR Example 360VR Stitching Comps" menu item.
------------------------------------------------------------------------------

--]]--

-- Print out extra debugging information
local printStatus = false

-- Track if the image was found
local err = false

-- Find out if we are running Fusion v9-16.1 or Resolve v15-16.1
local fu_major_version = tonumber(app:GetVersion()[1])

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
local osSeparator = package.config:sub(1,1)

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
	-- LUA dirname command inspired by Stackoverflow code example:
	-- http://stackoverflow.com/questions/9102126/lua-return-directory-path-from-path
	
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end



-- Open a web browser window up with the help documentation
function openBrowser()
	command = nil
	-- KartaVR local help docs
	webpage = app:MapPath('Reactor:/Deploy/Docs/KartaVR.Stitching/index.html')

	-- KartaVR online docs
	onlineDocsURL = 'https://www.andrewhazelden.com/projects/kartavr/examples/index.html'

	-- Check if the local help documentation was installed
	if bmd.fileexists(webpage) == false then
		-- Fallback to using the KartaVR online help
		print('[KartaVR Docs] The local help documentation does not appear to be installed at: ' .. tostring(webpage))
		webpage = onlineDocsURL
	end

	if platform == 'Windows' then
		command = 'explorer "' .. webpage .. '"'
		-- command = '"' .. webpage .. '"'

		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		command = 'open "' .. webpage .. '" &'

		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		command = 'xdg-open "' .. webpage .. '" &'

		print('[Launch Command] ', command)
		os.execute(command)
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
		-- audioFolderPath = '$env:programfiles\\KartaVR\\audio\\'
		audioFolderPath = app:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
		audioFilePath = audioFolderPath .. filename
		command = 'powershell -c (New-Object Media.SoundPlayer "' .. audioFilePath ..'").PlaySync();'

		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end

		os.execute(command)
	elseif platform == 'Mac' then
		audioFolderPath = app:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
		audioFilePath = audioFolderPath .. filename
		command = 'afplay "' .. audioFilePath ..'" &'

		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end

		os.execute(command)
	elseif platform == 'Linux' then
		audioFolderPath = app:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
		audioFilePath = audioFolderPath .. filename
		command = 'xdg-open "' .. audioFilePath ..'" &'

		if status == true or status == 1 then 
			print('[Audio Launch Command] ', command)
		end

		os.execute(command)
	else
		-- Windows Fallback
		-- audioFolderPath = '$env:programfiles\\KartaVR\\audio\\'
		audioFolderPath = app:MapPath('Reactor:/Deploy/Bin/KartaVR/audio/')
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


print('[KartaVR Docs] is running on ' .. platform)

-- Check if Fusion is running
if not fusion then
	print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
end

-- Open a web browser window up with the help documentation
openBrowser()

-- Play a sound effect
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

-- End of the script
print('[Done]')
return
