--[[--
----------------------------------------------------------------------------
PanoView v4.0.1 - 2019-01-06

by Andrew Hazelden -- www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The PanoView script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that will send your currently selected file loader or saver node media files to an Oculus Rift HMD using an external media viewer / playback tool. This script can be used with Windows, Mac, or Linux versions of Blackmagic Design's Fusion compositing system. 

Note: The PanoView script supports sending any kind of node from the flow view to the your media viewer tool.

Supported media viewing tools include: 

	- Kolor Eyes
	- GoPro VR Player
	- Amateras Player
	- Adobe Speedgrade
	- DJV Viewer
	- Live View Rift
	- QuickTime
	- RV
	- Assimilate Scratch Player
	- VLC
	- Whirligig

How to use the Script:

Step 1. Use the "Edit PanoView Preferences" script GUI to choose the media viewer tool you would like use each time the PanoView script is run.

Step 2. Start Fusion and open a new comp. Select and activate a node in the flow view. Then run the Script > KartaVR > Viewers > PanoView menu item to view the media in a degree media viewer. The default tool is DJV Viewer. 

If a loader or saver node is selected in the flow, the existing media file will be opened up in the viewer tool. Otherwise if any other node is active in the flow, a snapshot of the current viewer image will be saved to the temporary image directory and sent to the viewer tool.

--]]--

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

function mediaViewerTool(mediaFileName)
	-- Use the "Edit PanoView Preferences" script GUI to choose the media viewer tool you would like use each time the PanoView script is run.
	
	-- Defaults to DJV
	showMediaUsing = getPreferenceData('KartaVR.PanoView.ShowMediaUsing', 3, printStatus)
	if showMediaUsing == 0 then
		-- None
	elseif showMediaUsing == 1 then
		-- Adobe SpeedGrade
		speedgradeViewer(mediaFileName)
	elseif showMediaUsing == 2 then
		-- Amateras Player
		amaterasPlayerViewer(mediaFileName)
	elseif showMediaUsing == 3 then
		-- DJV Viewer
		djvViewer(mediaFileName)
	elseif showMediaUsing == 4 then
		-- Kolor Eyes
		kolorEyesViewer(mediaFileName)
	elseif showMediaUsing == 5 then
		-- Live View Rift
		liveViewRiftViewer(mediaFileName)
	elseif showMediaUsing == 6 then
		-- RV
		rvViewer(mediaFileName)
	elseif showMediaUsing == 7 then
		-- Scratch Player
		scratchViewer(mediaFileName)
	elseif showMediaUsing == 8 then
		-- VLC
		vlcViewer(mediaFileName)
	elseif showMediaUsing == 9 then
		-- Whirligig
		whirligigViewer(mediaFileName)
	elseif showMediaUsing == 10 then
		-- GoPro VR Player
		GoProVRPlayer(mediaFileName)
	elseif showMediaUsing == 11 then
		-- Quicktime Player
		QuicktimePlayer(mediaFileName)
	end
end

-- Set a fusion specific preference value
-- Example: setPreferenceData('KartaVR.PanoView.Format', 3, true)
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
-- Example: getPreferenceData('KartaVR.PanoView.Format', 3, true)
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


function kolorEyesViewer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Kolor Eyes Media Viewer
	if platform == 'Windows' then
		-- Running on Windows
		defaultViewerProgram = 'C:\\Program Files\\Kolor\\Kolor Eyes 1.6\\KolorEyes_x64.exe'
		--defaultViewerProgram = 'KolorEyes_x64.exe'
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.KolorEyesFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'start "" ' .. viewerProgram .. ' --demo "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		defaultViewerProgram = '/Applications/Kolor Eyes 1.6.app'
		-- viewerProgram = '/Applications/Kolor Eyes.app'
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.KolorEyesFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'open -a ' .. viewerProgram .. ' --args --demo "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		print('Kolor Eyes is not available for Linux yet.')
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


function GoProVRPlayer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- GoPro VR Viewer
	if platform == 'Windows' then
		-- Running on Windows
		
		defaultViewerProgram = 'C:\\Program Files\\GoPro\\GoPro VR Player 3.0\\GoProVRPlayer_x64.exe'
		-- defaultViewerProgram = 'GoProVRPlayer_x64.exe'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.GoProVRPlayerFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'start "" ' .. viewerProgram .. ' "' .. mediaFileName .. '"'
		
		print("[Launch Command] ", command)
		os.execute(command)
	elseif platform == "Mac" then
		-- Running on Mac
		
		defaultViewerProgram = '/Applications/GoPro VR Player 3.0.app'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.GoProVRPlayerFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'open -a ' .. viewerProgram .. ' --args "' .. mediaFileName .. '"'
		
		print("[Launch Command] ", command)
		os.execute(command)
	elseif platform == "Linux" then
		-- Running on Linux
		
		-- defaultViewerProgram = 'GoProVRPlayer'
		defaultViewerProgram = '/usr/bin/GoProVRPlayer'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.GoProVRPlayerFile', defaultViewerProgram, printStatus)) .. '"'
		command = viewerProgram .. ' "' .. mediaFileName .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end

function amaterasPlayerViewer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Amateras Dome Player
	if platform == 'Windows' then
		-- Running on Windows
		
		defaultViewerProgram = 'AmaterasPlayer.exe'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.AmaterasFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'start "" ' .. viewerProgram .. ' "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		
		defaultViewerProgram = '/Applications/Amateras3/Amateras.app'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.AmaterasFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'open -a ' .. viewerProgram .. ' --args "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		
		defaultViewerProgram = 'amateras'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.AmaterasFile', defaultViewerProgram, printStatus)) .. '"'
		command = viewerProgram .. ' "' .. mediaFileName .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


function djvViewer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- DJV Viewer
	if platform == 'Windows' then
		-- Running on Windows
		
		defaultViewerProgram = 'Reactor:/Deploy/Bin/djv/bin/djv_view.exe'
		-- defaultViewerProgram = 'C:\\Program Files\\DJV\\bin\\djv_view.exe'
		-- defaultViewerProgram = 'C:\\Program Files\\djv-1.2.4-Windows-64\\bin\\djv_view.exe'
		-- defaultViewerProgram = 'C:\\Program Files\\djv-1.1.0-Windows-64\\bin\\djv_view.exe'
		-- defaultViewerProgram = 'djv_view.exe'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.DJVFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'start "" ' .. viewerProgram .. ' "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		
		defaultViewerProgram = 'Reactor:/Deploy/Bin/djv/DJV.app'
		-- defaultViewerProgram = '/Applications/djv.app'
		-- defaultViewerProgram = '/Applications/djv-1.2.4-OSX-64.app'
		-- defaultViewerProgram = '/Applications/djv-1.1.0-OSX-64.app'
		-- defaultViewerProgram = '/Applications/djv-1.0.5-OSX-64.app'
		-- defaultViewerProgram = '/Applications/djv-OSX-64.app'
		
		viewerProgram = '"' .. string.gsub(comp:MapPath(getPreferenceData('KartaVR.PanoView.DJVFile', defaultViewerProgram, printStatus)), '[/]$', '') .. '"'
		command = 'open -a ' .. viewerProgram .. ' --args "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		
		defaultViewerProgram = 'Reactor:/Deploy/Bin/djv/bin/djv_view'
		-- defaultViewerProgram = 'djv_view'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.DJVFile', defaultViewerProgram, printStatus)) .. '"'
		command = viewerProgram .. ' "' .. mediaFileName .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


function liveViewRiftViewer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Live View Rift
	if platform == 'Windows' then
		-- Running on Windows
		
		defaultViewerProgram = 'C:\\Program Files (x86)\\Viarum\\LiveViewRift\\LiveViewRift.exe'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.LiveViewRiftFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'start "" ' .. viewerProgram .. ' "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		
		defaultViewerProgram = '/Applications/LiveViewRift.app'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.LiveViewRiftFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'open -a ' .. viewerProgram .. ' "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		
		defaultViewerProgram = 'LiveViewRift'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.LiveViewRiftFile', defaultViewerProgram, printStatus)) .. '"'
		command = viewerProgram .. ' "' .. mediaFileName .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


function scratchViewer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Assimilate Scratch
	if platform == 'Windows' then
		-- Running on Windows
		
		defaultViewerProgram = 'C:\\Program Files\\Assimilate\\bin64\\Assimilator.exe'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.ScratchPlayerFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'start "" ' .. viewerProgram .. ' "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		
		defaultViewerProgram = '/Applications/Scratch.app'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.ScratchPlayerFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'open -a ' .. viewerProgram .. ' --args "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		
		defaultViewerProgram = 'Assimilator'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.ScratchPlayerFile', defaultViewerProgram, printStatus)) .. '"'
		command = viewerProgram .. ' "' .. mediaFileName .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


function speedgradeViewer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Adobe SpeedGrade
	local defaultViewerProgram = ''
	if platform == 'Windows' then
		-- Running on Windows
		
		adobeSpeedGradeVersion = getPreferenceData('KartaVR.PanoView.AdobeSpeedGradeVersion', 5, printStatus)
		if adobeSpeedGradeVersion == 0 then
			-- Adobe SpeedGrade CS4
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe SpeedGrade CS4\\SpeedGradeCmd.exe'
		elseif adobeSpeedGradeVersion == 1 then
			-- Adobe SpeedGrade CS5
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe SpeedGrade CS5\\SpeedGradeCmd.exe'
		elseif adobeSpeedGradeVersion == 2 then
			-- Adobe SpeedGrade CS6
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe SpeedGrade CS6\\SpeedGradeCmd.exe'
		elseif adobeSpeedGradeVersion == 3 then
			-- Adobe SpeedGrade CC
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe SpeedGrade CC\\SpeedGradeCmd.exe'
		elseif adobeSpeedGradeVersion == 4 then
			-- Adobe SpeedGrade CC 2014
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe SpeedGrade CC 2014\\SpeedGradeCmd.exe'
		elseif adobeSpeedGradeVersion == 5 then
			-- Adobe SpeedGrade CC 2015
			defaultViewerProgram = 'C:\\Program Files\\Adobe\\Adobe SpeedGrade CC 2015\\SpeedGradeCmd.exe'
		else
			-- Fallback
			defaultViewerProgram = 'SpeedGradeCmd.exe'
		end
		
		viewerProgram = '"' .. defaultViewerProgram .. '"'
		command = 'start "" ' .. viewerProgram .. ' "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		
		adobeSpeedGradeVersion = getPreferenceData('KartaVR.PanoView.AdobeSpeedGradeVersion', 5, printStatus)
		if adobeSpeedGradeVersion == 0 then
			-- Adobe SpeedGrade CS4
			defaultViewerProgram= '/Applications/Adobe SpeedGrade CS4/Adobe SpeedGrade CS4.app/Contents/MacOS/bin/SpeedGradeCmd'
		elseif adobeSpeedGradeVersion == 1 then
			-- Adobe SpeedGrade CS5
			defaultViewerProgram= '/Applications/Adobe SpeedGrade CS5/Adobe SpeedGrade CS5.app/Contents/MacOS/bin/SpeedGradeCmd'
		elseif adobeSpeedGradeVersion == 2 then
			-- Adobe SpeedGrade CS6
			defaultViewerProgram= '/Applications/Adobe SpeedGrade CS6/Adobe SpeedGrade CS6.app/Contents/MacOS/bin/SpeedGradeCmd'
		elseif adobeSpeedGradeVersion == 3 then
			-- Adobe SpeedGrade CC
			defaultViewerProgram= '/Applications/Adobe SpeedGrade CC/Adobe SpeedGrade CC.app/Contents/MacOS/SpeedGradeCmd'
		elseif adobeSpeedGradeVersion == 4 then
			-- Adobe SpeedGrade CC 2014
			defaultViewerProgram= '/Applications/Adobe SpeedGrade CC 2014/Adobe SpeedGrade CC 2014.app/Contents/MacOS/SpeedGradeCmd'
		elseif adobeSpeedGradeVersion == 5 then
			-- Adobe SpeedGrade CC 2015
			defaultViewerProgram = '/Applications/Adobe SpeedGrade CC 2015/Adobe SpeedGrade CC 2015.app/Contents/MacOS/SpeedGradeCmd'
		else
			-- Fallback
			defaultViewerProgram = 'SpeedGradeCmd'
		end
		
		viewerProgram = '"' .. defaultViewerProgram .. '"'
		command = 'open -a ' .. viewerProgram .. ' --args "' .. mediaFileName .. '"' .. ' &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		print('Adobe Speedgrade is not available for Linux yet.')
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


function vlcViewer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- VLC Player
	if platform == 'Windows' then
		-- Running on Windows
		options = ' --started-from-file '
		
		defaultViewerProgram = 'C:\\Program Files (x86)\\VideoLAN\\VLC\\vlc.exe'
		-- defaultViewerProgram = 'C:\\Program Files\\VideoLAN\\VLC\\vlc.exe'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.VLCFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'start "" '..viewerProgram..options..' "'..mediaFileName..'"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		
		defaultViewerProgram = '/Applications/VLC.app'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.VLCFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'open -a ' .. viewerProgram .. ' --args "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		
		defaultViewerProgram = 'vlc'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.VLCFile', defaultViewerProgram, printStatus)) .. '"'
		command = viewerProgram .. ' "' .. mediaFileName .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


function QuicktimePlayer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Quicktime Player
	if platform == 'Windows' then
		-- Running on Windows
		
		defaultViewerProgram = 'C:\\Program Files (x86)\\QuickTime\\QuickTimePlayer.exe'
		--defaultViewerProgram = 'QuicktimePlayer.exe'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.QuicktimePlayerFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'start "" ' .. viewerProgram .. ' "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		
		-- defaultViewerProgram = '/Applications/QuickTime Player 7.app'
		defaultViewerProgram = '/Applications/QuickTime Player.app'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.QuicktimePlayerFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'open -a ' .. viewerProgram .. ' "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		print('Quicktime Player is not available for Linux')
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


function rvViewer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Tweak RV
	if platform == 'Windows' then
		-- Running on Windows
		options = ' -fullscreen '
		
		defaultViewerProgram = 'rv.exe'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.RVFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'start "" ' .. viewerProgram .. options .. ' "' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		options = " -fullscreen "
		
		defaultViewerProgram = '/Applications/RV64.app'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.RVFile', defaultViewerProgram, printStatus)) .. '"'
		command = 'open -a ' .. viewerProgram .. ' --args' .. options .. '"' .. mediaFileName .. '"'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		options = ' -fullscreen '
		
		defaultViewerProgram = 'rv'
		
		viewerProgram = '"' .. comp:MapPath(getPreferenceData('KartaVR.PanoView.RVFile', defaultViewerProgram, printStatus)) .. '"'
		command = viewerProgram .. options .. ' "' .. mediaFileName .. '" &'
		
		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


function whirligigViewer(mediaFileName)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Stereo View Eye Order
	whirligigEyeOrder = getPreferenceData('KartaVR.PanoView.WhirligigEyeOrder', 0, printStatus)
	local stereoEyeOrder = ''
	if whirligigEyeOrder == 0 then
		-- Left/Right
		stereoEyeOrder = ' -eyeorder "lr" '
	elseif whirligigEyeOrder == 1 then
		-- Right/Left
		stereoEyeOrder = ' -eyeorder "rl" '
	else
		-- Left/Right Eye Fallback mode
		stereoEyeOrder = ' -eyeorder "lr" '
	end
	
	whirligigStereoMode = getPreferenceData('KartaVR.PanoView.WhirligigStereoMode', 0, printStatus)
	local stereoMode = ''
	if whirligigStereoMode == 0 then
		-- Off
		stereoMode = ' '
	elseif whirligigStereoMode == 1 then
		-- Side by Side
		stereoMode = 'sbs'
	elseif whirligigStereoMode == 2 then
		-- Over / Under
		stereoMode = 'ou'
	else
		-- Off Fallback Mode
		stereoMode = ' '
	end
	
	
	-- Choose an Image Projection:
	local projection = ''
	whirligigProjection = getPreferenceData('KartaVR.PanoView.WhirligigProjection', 0, printStatus)
	
	if whirligigProjection == 0 then
		-- Equirectangular 360
		projection = ' -projection barrel360' .. stereoMode .. ' ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Equirectangular 360')
	elseif whirligigProjection == 1 then
		-- Angular Fisheye
	
		-- Check the Angular Fisheye field of view mode setting
		whirligigAngularFOV = getPreferenceData('KartaVR.PanoView.WhirligigAngularFOV', 2, printStatus)
		if whirligigAngularFOV == 0 then
			-- Angular fisheye 140 degree
			projection = ' -projection fisheye140' .. stereoMode .. ' '	 .. stereoEyeOrder
			print('[Panoramic Projection] ' .. 'Fisheye 140 Degree')
		elseif whirligigAngularFOV == 1 then
			-- Angular fisheye 160 degree
			projection = ' -projection fisheye160' .. stereoMode .. ' ' .. stereoEyeOrder
			print('[Panoramic Projection] ' .. 'Fisheye 160 Degree')
		elseif whirligigAngularFOV == 2 then
			-- Angular fisheye 180 degree / Domemaster
			projection = ' -projection fisheye180' .. stereoMode .. ' ' .. stereoEyeOrder
			print('[Panoramic Projection] ' .. 'Fisheye 180 Degree')
		elseif whirligigAngularFOV == 3 then
			-- Angular fisheye 240 degree
			projection = ' -projection fisheye240' .. stereoMode .. ' ' .. stereoEyeOrder
			print('[Panoramic Projection] ' .. 'Fisheye 240 Degree')
		elseif whirligigAngularFOV == 4 then
			-- Angular fisheye 360 degree
			projection = ' -projection fisheye360' .. stereoMode .. ' ' .. stereoEyeOrder
			print('[Panoramic Projection] ' .. 'Fisheye 360 Degree')
		else
			-- Fallback to Angular fisheye 180 degree / Domemaster
			projection = ' -projection fisheye180' .. stereoMode .. ' ' .. stereoEyeOrder
			print('[Panoramic Projection] ' .. 'Fisheye 180 Degree')
		end
	elseif whirligigProjection == 2 then
		-- Cubic Horizontal Cross
		projection = ' -customformat' .. stereoMode .. ' "Cube Map Horizontal.obj" ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Cubic Horizontal Cross')
	elseif whirligigProjection == 3 then
		 -- Cubic Vertical Cross
		projection = ' -customformat' .. stereoMode .. ' "Cube Map Vertical.obj" ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Cubic Vertical Cross')
	elseif whirligigProjection == 4 then
		-- Cubic Horizontal Tee
		projection = ' -customformat' .. stereoMode .. ' "Cube Map Horizontal Tee.obj" ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Cubic Horizontal Tee')
	elseif whirligigProjection == 5 then
		-- Cubic Vertical Tee
		projection = ' -customformat' .. stereoMode .. ' "Cube Map Vertical Tee.obj" ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Cubic Vertical Tee')
	elseif whirligigProjection == 6 then
		-- Facebook Cube Map 3x2
		projection = ' -customformat' .. stereoMode .. ' "Facebook Cube Map 3x2.obj" ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Facebook Cube Map 3x2')
	elseif whirligigProjection == 7 then
		-- Facebook Pyramid
		projection = ' -customformat' .. stereoMode .. ' "Facebook Pyramid.obj" ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Facebook Pyramid')
	elseif whirligigProjection == 8 then
		-- GardenGnome Cube Map 3x2
		projection = ' -customformat' .. stereoMode .. ' "GardenGnome Cube Map 3x2.obj" ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'GardenGnome Cube Map 3x2')
	elseif whirligigProjection == 9 then
		-- Gear VR\Octane VR Render\VRay 6:1 Horizontal Strip Cube Map
		projection = ' -customformat' .. stereoMode .. ' "Octane.obj" ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Gear VR')
	elseif whirligigProjection == 10 then
		-- Equirectangular 360 degree x 90 degree image - partially cropped centered vertically on horizon
		projection = ' -customformat' .. stereoMode .. ' "LatLong 360x90.obj" ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Equirectangular 360 degree x 90 degree')
	elseif whirligigProjection == 11 then
		-- Rectangular
		projection = ' -projection flatscreen' .. stereoMode .. ' ' .. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Rectangular')
	elseif whirligigProjection == 12 then
		-- Ricoh Theta S Camera
		print('[Panoramic Projection] ' .. 'Ricoh Theta S Camera')
		projection = ' -projection -customformat "Ricoh Theta S.obj" '
	elseif whirligigProjection == 13 then
		-- LG360 Camera
		print('[Panoramic Projection] ' .. 'LG360 Camera')
		projection = ' -projection -customformat "LG360.obj" ' 
	elseif whirligigProjection == 14 then
		-- Samsung Gear 360 Camera
		projection = ' -projection -customformat "Samsung Gear 360.obj" '
		print('[Panoramic Projection] ' .. 'Samsung Gear 360 Camera')
	else
		-- Fallback to Equirectangular
		projection = ' -projection barrel360' .. stereoMode .. ' '	.. stereoEyeOrder
		print('[Panoramic Projection] ' .. 'Equirectangular 360')
	end

	-- Offset the screen angle by a forward tilt angle
	sendDomeTilt = getPreferenceData('KartaVR.PanoView.SendDomeTilt', 1, printStatus)
	domeTiltAngle = getPreferenceData('KartaVR.PanoView.DomeTiltAngle', 0, printStatus)
	if sendDomeTilt == 0 then
		-- Yes - Send Dome Tilt Angle
		-- Guard against the Whirligig v0.4.4 2015-02-21 -tilt=0 command line issue that shows a blank view of the scene if the dome tilt angle is exactly 0.000 degrees.
		domeTiltAngle = domeTiltAngle + 0.01
		domeTilt = ' -tilt ' .. domeTiltAngle .. ' '
	elseif sendDomeTilt == 1 then
		-- No - Skip Sending Dome Tilt Angle
		domeTilt = ' -tilt 0.01 '
	elseif sendDomeTilt == 2 then
		-- Send Inverted Dome Tilt Angle
		-- Guard against the Whirligig v0.4.4 2015-02-21 -tilt=0 command line issue that shows a blank view of the scene if the dome tilt angle is exactly 0.000 degrees.
		domeTiltAngle = -1 * domeTiltAngle + 0.01
		domeTilt = ' -tilt ' .. domeTiltAngle .. ' '
	end

	-- -----------------------------------------
	-- -----------------------------------------
	
	-- Choose an Anaglpyh S3D stereo display mode
	-- This option is for users who don't have an Oculus Rift HMD but want to preivew stereoscopic imagery using traditional red/cyan style anaglyph 3D glasses.
	
	anaglyph = ' '
	-- anaglyph = ' -anaglyph GreyAnaglyph '
	-- anaglyph = ' -anaglyph ColourAnaglyph '
	-- anaglyph = ' -anaglyph HalfColorAnaglyph '
	-- anaglyph = ' -anaglyph OptimizedAnaglyph '
	-- anaglyph = ' -anaglyph TrueAnaglyph '
	
	-- Whirligig
	local defaultViewerProgram = ''
	if platform == 'Windows' then
		-- Running on Windows

		whirligigVersion = getPreferenceData('KartaVR.PanoView.WhirligigVersion', 0, printStatus)
		if whirligigVersion == 0 then
			-- Whirligig Free Edition
			defaultViewerProgram = 'C:\\Program Files\\Whirligig\\Whirligig64bit.exe'
		elseif whirligigVersion == 1 then
			-- Whirligig for SteamVR / HTC VIVE / OSVR
			defaultViewerProgram= 'C:\\Program Files (x86)\\Steam\\steamapps\\common\\Whirligig\\Whirligig.exe'
		else
			-- Fallback to using Whirligig Free Edition
			defaultViewerProgram = 'C:\\Program Files\\Whirligig\\Whirligig64bit.exe'
		end

		viewerProgram = '"' .. defaultViewerProgram .. '"'
		command = 'start "" ' .. viewerProgram .. ' -feature "' .. mediaFileName .. '"' .. projection .. anaglyph .. domeTilt
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		
		defaultViewerProgram = '/Applications/Whirligig.app'
		
		viewerProgram = '"' .. defaultViewerProgram .. '"'
		command = 'open -a ' .. viewerProgram .. ' --args -feature "' .. mediaFileName .. '"' .. projection .. anaglyph .. domeTilt .. '&'
		
		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		print('Whirligig is not available for Linux yet.')
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
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



print('PanoView is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

-- Check if Fusion is running
if not fusion then
	print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
end



-- This is the file format that will be used when a Fusion node is snapshotted in the viewer window and saved to disk 
imageFormat = getPreferenceData('KartaVR.PanoView.Format', 0, printStatus)
local viewportSnapshotImageFormat = ''
if imageFormat == 0 then
	viewportSnapshotImageFormat = 'jpg'
elseif imageFormat == 1 then
	viewportSnapshotImageFormat = 'tif'
elseif imageFormat == 2 then
	viewportSnapshotImageFormat = 'tga'
elseif imageFormat == 3 then
	viewportSnapshotImageFormat = 'png'
elseif imageFormat == 4 then
	viewportSnapshotImageFormat = 'bmp'
elseif imageFormat == 5 then
	viewportSnapshotImageFormat = 'exr'
else
	viewportSnapshotImageFormat = 'png'
end


-- Lock the comp flow area
comp:Lock()

local mediaFileName = nil


-- List the selected Node in Fusion 
selectedNode = comp.ActiveTool

if selectedNode then
	print('[Selected Node] ', selectedNode.Name)
	toolAttrs = selectedNode:GetAttrs()
	
	-- Read data from either a the loader and saver nodes
	if toolAttrs.TOOLS_RegID == 'Loader' then
		-- Fixed starting frame of the sequence
		
		-- Was the "Use Current Frame" checkbox enabled in the preferences?
		useCurrentFrame = getPreferenceData('KartaVR.PanoView.UseCurrentFrame', 1, printStatus)
		
		if useCurrentFrame == 1 then
			-- Expression for the current frame from the image sequence
			-- It will report a 'nil' when outside of the active frame range
			print('[PanoView Use Current Frame] Enabled')
			print('Note: If you see an error in the console it means that you have scrubbed the timeline beyond the actual frame range of the media file.')
			if selectedNode.Output[comp.CurrentTime] then
				mediaFileName = selectedNode.Output[comp.CurrentTime].Metadata.Filename
			else
				print('[Loader Node Filename Field is empty] ')
				err = true
			end
		else
			-- Get the file name directly from the clip
			print('[PanoView Use Current Frame] Disabled')
			-- mediaFileName = comp:MapPath(toolAttrs.TOOLST_Clip_Name[1])
			mediaFileName = comp:MapPath(selectedNode.Clip[fu.TIME_UNDEFINED])
		end
		
		print('[Loader] ', mediaFileName)
	elseif toolAttrs.TOOLS_RegID == 'Fuse.LifeSaver' then
		print('Note: If you see an error in the console it means that you have scrubbed the timeline beyond the actual frame range of the media file.')
		if selectedNode.Output[comp.CurrentTime] then
			mediaFileName = selectedNode.Output[comp.CurrentTime].Metadata.Filename
		else
			print('[Loader Node Filename Field is empty] ')
			err = true
		end
		
		print('[LifeSaver] ', mediaFileName)
	elseif toolAttrs.TOOLS_RegID == 'MediaIn' then
		mediaFileName = comp:MapPath(selectedNode:GetData('MediaProps.MEDIA_PATH'))
		
		if mediaFileName then
		-- Find the first frame of an image sequence
			startFrame = tostring(string.match(mediaFileName, '%[(%d+)%-%d+%]'))
			endFrame = tostring(string.match(mediaFileName, '%[%d+%-(%d+)%]'))
			mediaFileName = string.gsub(mediaFileName, '%[%d+%-%d+%]', startFrame)
		end
		
		print('[MediaIn] ', mediaFileName)
	elseif toolAttrs.TOOLS_RegID == 'Saver' then
		mediaFileName = comp:MapPath(toolAttrs.TOOLST_Clip_Name[1])
		
		print('[Saver] ', mediaFileName)
	else
		-- Write out a temporary viewer snapshot so the script can send any kind of node to the viewer tool
		
		-- Image name with extension.
		imageFilename = 'kvr_preview_' .. selectedNode.Name .. '.' .. viewportSnapshotImageFormat
		
		-- Find out the Fusion temporary directory path
		dirName = comp:MapPath('Temp:\\KartaVR\\')
		
		-- Create the temporary directory
		os.execute('mkdir "' .. dirName .. '"')
		
		-- Create the image filepath for the temporary view snapshot
		localFilepath = dirName .. imageFilename
		
		if fu_major_version >= 15 then
			-- Resolve 15 workflow for saving an image
			comp:GetPreviewList().LeftView.View.CurrentViewer:SaveFile(localFilepath)
		elseif fu_major_version >= 8 then
			-- Fusion 8 workflow for saving an image
			comp:GetPreviewList().Left.View.CurrentViewer:SaveFile(localFilepath)
		else
			-- Fusion 7 workflow for saving an image
			-- Save the image in the Viewer A buffer
			comp.CurrentFrame.LeftView.CurrentViewer:SaveFile(localFilepath)
		end
		
		-- Everything worked fine and an image was saved
		print('[Saved Image] ', localFilepath ,' [Selected Node] ', selectedNode.Name)
		
		mediaFileName = localFilepath
	end
	
	-- Launch the viewer tool with this media clip
	if mediaFileName ~= nil then
		if eyeon.fileexists(mediaFileName) then
			mediaViewerTool(mediaFileName)
		else
			print('[Media File Missing] ', mediaFileName)
			err = true
		end
	else
		print('[Media File Missing] Empty Filename string')
		err = true
	end
else
	print('[Pano View] No media node was selected. Please select and activate a loader or saver node in the flow view.')
	err = true
end


-- Play a sound effect
soundEffect = getPreferenceData('KartaVR.PanoView.SoundEffect', 1, printStatus)
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
