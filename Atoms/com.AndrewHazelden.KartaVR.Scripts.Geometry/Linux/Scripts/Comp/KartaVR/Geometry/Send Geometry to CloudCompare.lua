------------------------------------------------------------------------------
-- Send Geometry to CloudCompare v4.0 for Fusion - 2018-12-19
-- by Andrew Hazelden
-- www.andrewhazelden.com
-- andrew@andrewhazelden.com
--
-- KartaVR
-- http://www.andrewhazelden.com/blog/downloads/kartavr/
------------------------------------------------------------------------------
-- Overview:

-- The Send Geometry to CloudCompare script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that will take the AlembicMesh3D / FBXMesh3D / ExporterFBX nodes that are selected in the flow and send it to CloudCompare.

-- Note: CloudCompare is primarily used to examine meshes and point clouds

-- How to use the Script:

-- Step 1. Start Fusion and open a new comp. Select and activate a node in the flow view. 

-- Step 2. Run the "Script > KartaVR > Geometry > Send Geometry to CloudCompare" menu item.

------------------------------------------------------------------------------


-- --------------------------------------------------------
-- --------------------------------------------------------
-- --------------------------------------------------------

local printStatus = false

-- Track if the image was found
local err = false

-- Find out if we are running Fusion 6, 7, or 8
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

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
	-- Add the platform specific folder slash character
	osSeparator = package.config:sub(1,1)
	
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


-- Open the selected Fusion mesh in an external tool
-- If you want to see debugging text use:
-- Example: openGeometry('Comp:/cube.obj', 'SurfaceFBXMesh', true)
function openGeometry(filename, nodeType, status)
	-- ------------------------------------
	-- Load the preferences
	-- ------------------------------------
	
	if platform == 'Windows' then
		-- Reactor Install
		defaultCloudCompareFile = comp:MapPath('Reactor:/Deploy/Bin/cloudcompare/CloudCompare.exe')
		-- defaultCloudCompareFile = comp:MapPath('C:\\Program Files\\CloudCompare\\CloudCompare.exe')
	elseif platform == 'Mac' then
		defaultCloudCompareFile =  comp:MapPath('Reactor:/Deploy/Bin/cloudcompare/') .. 'CloudCompare.app'
	else
		defaultCloudCompareFile = '/usr/bin/CloudCompare'
		-- defaultCloudCompareFile = 'ccViewer'
	end
	
	-- Note: The AskUser dialog settings are covered on page 63 of the Fusion Scripting Guide
	compPath = dirname(comp:GetAttrs().COMPS_FileName)
	
	-- Location of CloudCompare
	CloudCompareFile = getPreferenceData('KartaVR.SendGeometry.CloudCompareFile', defaultCloudCompareFile, printStatus)
	soundEffect = getPreferenceData('KartaVR.SendGeometry.SoundEffect', 1, printStatus)
	
	msg = 'Customize the settings for sending geometry files to CloudCompare. Please close CloudCompare before running this tool.'
	
	-- Sound effect list
	soundEffectList = {'None', 'On Error Only', 'Steam Train Whistle Sound', 'Trumpet Sound', 'Braam Sound'}
	
	d = {}
	d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 4, Wrap = true, Default = msg}
	d[2] = {'CloudCompareFile', Name = 'CloudCompare Path', 'PathBrowse', Default = CloudCompareFile}
	d[3] = {'SoundEffect', Name = 'Sound Effect', 'Dropdown', Default = soundEffect, Options = soundEffectList}
	
	dialog = comp:AskUser('Send Geometry to CloudCompare', d)
	if dialog == nil then
		print('You cancelled the dialog!')
		
		-- Unlock the comp flow area
		comp:Unlock()
		
		return
	else
		-- Debug - List the output from the AskUser dialog window
		dump(dialog)
		
		CloudCompareFile = comp:MapPath(dialog.CloudCompareFile)
		setPreferenceData('KartaVR.SendGeometry.CloudCompareFile', CloudCompareFile, printStatus)
			
		soundEffect = dialog.SoundEffect
		setPreferenceData('KartaVR.SendGeometry.SoundEffect', soundEffect, printStatus)
		
		print('[CloudCompareFile] ' .. CloudCompareFile)
		print('[SoundEffect] ' .. soundEffect)
	end
	
	-- Open the CloudCompare tool
	if platform == 'Windows' then
		-- Running on Windows
		command = 'start "" "' .. CloudCompareFile .. '" ' .. '"' .. filename .. '" '
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		command = 'open -a ' .. CloudCompareFile .. ' --args ' .. '"' .. filename .. '" '
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		command = CloudCompareFile .. ' ' .. '"' .. filename .. '" '
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end

print ('Send Geometry to CloudCompare is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

-- Check if Fusion is running
if not fusion then
	print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
end


-- Lock the comp flow area
comp:Lock()

local mediaDirName = nil

-- List the selected Node in Fusion 
selectedNode = comp.ActiveTool

if selectedNode then
	print('[Selected Node] ', selectedNode.Name)
	
	toolAttrs = selectedNode:GetAttrs()
	nodeType = toolAttrs.TOOLS_RegID
	
	-- Read data from either a the loader and saver nodes
	if nodeType == 'SurfaceFBXMesh' then
		loadedMesh = comp:MapPath(selectedNode:GetInput('ImportFile'))
		mediaDirName = dirname(loadedMesh)
		print('[FBXMesh3D file] ', loadedMesh)
	elseif nodeType == 'SurfaceAlembicMesh' then
		loadedMesh = comp:MapPath(selectedNode:GetInput('Filename'))
		mediaDirName = dirname(loadedMesh)
		print('[AlembicMesh3D file] ', loadedMesh)
	elseif nodeType == 'ExporterFBX' then
		loadedMesh = comp:MapPath(selectedNode:GetInput('Filename'))
		mediaDirName = dirname(loadedMesh)
		print('[ExporterFBX file] ', loadedMesh)
	end
	
	-- Launch the viewer tool with this media clip
	if loadedMesh ~= nil then
		if eyeon.fileexists(loadedMesh) then
			openGeometry(loadedMesh, nodeType, true)
		else
			print('[Geometry File Missing] ', loadedMesh)
			err = true
		end
	end

else
	print('[Send Geometry to CloudCompare] No geometry node was selected. Please select and activate a FBXMesh3D, ExporterFBX or AlembicMesh3D node in the flow view.')
	err = true
end


-- Play a sound effect
soundEffect = getPreferenceData('KartaVR.SendGeometry.SoundEffect', 1, printStatus)
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
