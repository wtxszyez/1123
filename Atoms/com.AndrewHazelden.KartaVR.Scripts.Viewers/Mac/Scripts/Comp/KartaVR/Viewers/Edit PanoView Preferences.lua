------------------------------------------------------------------------------
-- Edit PanoView Preferences v4.0 for Fusion - 2018-12-10
-- by Andrew Hazelden
-- www.andrewhazelden.com
-- andrew@andrewhazelden.com
-- 
-- KartaVR
-- http://www.andrewhazelden.com/blog/downloads/kartavr/
------------------------------------------------------------------------------
-- Overview:

-- The Edit PanoView Preferences script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that lets you customize the default settings for the PanoView image viewing script.

-- How to use the Script:

-- Step 1. Start Fusion and open a new comp. 

-- Step 2. Then run the Script > KartaVR > Edit PanoView Preferences menu item.

-- Step 3. In the Edit PanoView Preferences dialog window you need to select the viewing tool you want to use. You also have access to control the specific version of each viewer program, and can change other viewing parameters, too.

-- Note: The close X box on the dialog window does not work. You have to hit the "Cancel" button to close the window.

-- How to use the Script:

-- The "Image Format" control allows you to customize the snapshot image format used when a node other than a loader or saver is selected and a temporary image is saved to disk. This temporary image is saved using the left viewer window and then passed onto the specified media viewer tool. You can choose one of the following options: "JPEG", "TIFF", "TGA", "PNG", "BMP", or "EXR".

-- The "Sound Effect" control allows you to choose if you want to have an audio alert played when an error occurs or when the script task completes. You can choose one of the following audio playback options: "None", "On Error Only", "Steam Train Whistle Sound", "Trumpet Sound", or "Braam Sound".

-- The "Dome Tilt" control allows you to choose if you want to tip the forward tilting angle of a dome to simulate an immersive fulldome theater environment with sloped seating. The "Send Inverted Dome Tilt Angle" option allows you to mirror/flip the dome tilt angle by multiplying the current dome tilt angle value by -1 to counteract the dome tilt that is already present in the rendered images. You can choose one of the following options: "Yes - Send Dome Tilt Angle", "No - Skip Sending Dome Tilt Angle", or "Send Inverted Dome Tilt Angle".

-- The "Dome Tilt Angle" control is a numeric input field that lets you specify the exact forward tilting angle of a dome to simulate an immersive fulldome theater environment with sloped seating. The control range goes from -90 degrees to 90 degrees.

-- The "SpeedGrade" control allows you to choose the specific version of Adobe SpeedGrade you want to use when the PanoView script is run. You can choose one of the following options:	 "Adobe SpeedGrade CC 2015", "Adobe SpeedGrade CC 2014", "Adobe SpeedGrade CC", "Adobe SpeedGrade CS6", "Adobe SpeedGrade CS5", or "Adobe SpeedGrade CS4".

-- The "Amateras Dome Player Executable" text field and file dialog button allow you to specify the location of the Amateras Dome Player program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

-- The "DJV View Executable" text field and file dialog button allow you to specify the location of the DJV View program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

-- The "Kolor Eyes Executable" text field and file dialog button allow you to specify the location of the Kolor Eyes program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

-- The "Live View Rift Executable" text field and file dialog button allow you to specify the location of the Live View Rift program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

-- The "RV Executable" text field and file dialog button allow you to specify the location of the RV program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

-- The "VLC Executable" text field and file dialog button allow you to specify the location of the VLC program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

-- The "Scratch Player Executable" text field and file dialog button allow you to specify the location of the Scratch Player program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

-- The "Whirligig" control allows you to choose if you are running the free version or the paid Steam Edition of Whirligig.

-- The "Projection" control allows you to specify the Whirligig image projection that is used with PanoView. You can choose one of the following options: "Equirectangular", "Angular Fisheye", "Cubic Horizontal Cross", "Cubic Vertical Cross", "Cubic Horizontal Tee", "Cubic Vertical Tee", "Facebook Cube Map 3x2", "Facebook Pyramid", "GardenGnome Cube Map 3x2", "Gear VR", "LatLong 360x90 degree", "Rectangular", "Ricoh Theta S Camera", or "LG360 Camera".

-- The "Angular FOV" control allows you to specify the angular fisheye based diagonal field of view value used with Whirligig. You can choose one of the following options: "140", "160", "180", "240", or "360".


-- The "Stereo Mode" control allows you to specify the format of stereo imagery that will be sent to Whirligig.	 You can choose one of the following options: "Off", "Side by Side", or "Over Under".

-- The "Eye Order" control allows you to specify the arrangement of the left and right stereoscopic views in the media that will be sent to Whirligig. Most stereoscopic image projections have the left view on the left side of the frame and the right view on the right side of the frame. The most common exception to this rule is the Gear VR/Octane Render ORBX/Vray style of horizontal strip cubemap. You can choose one of the following options: "Left/Right", or "Right/Left".

-- The "OK" button will save the revised preferences.

-- The "Cancel" button will close the script GUI and stop the script.

------------------------------------------------------------------------------

local printStatus = false

-- Find out if we are running Fusion 6, 7, or 8
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either 'Windows', 'Mac', or 'Linux'.
local platform = ''
if string.find(comp:MapPath('Fusion:\\'), 'Program Files', 1) then
	-- Check if the OS is Windows by searching for the Program Files folder
	platform = 'Windows'
elseif string.find(comp:MapPath('Fusion:\\'), 'PROGRA~1', 1) then
	-- Check if the OS is Windows by searching for the Program Files folder
	platform = 'Windows'
elseif string.find(comp:MapPath('Fusion:\\'), 'Applications', 1) then
	-- Check if the OS is Mac by searching for the Applications folder
	platform = 'Mac'
else
	platform = 'Linux'
end


-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
-- LUA dirname command inspired by Stackoverflow code example:
-- http://stackoverflow.com/questions/9102126/lua-return-directory-path-from-path
	sep = ''
	
	if platform == 'Windows' then
		sep = '\\'
	elseif platform == 'Mac' then
		sep = '/'
	else
		-- Linux
		sep = '/'
	end
	
	return mediaDirName:match('(.*'..sep..')')
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


-- ------------------------------------
-- Load the preferences
-- ------------------------------------

local amaterasFile = ''
local djvFile = ''
local kolorEyesFile = ''
local liveViewRiftFile = ''
local rvFile = ''
local vlcFile = ''
local scratchPlayerFile = ''


local browseMode = ''
if platform == 'Windows' then
	browseMode = 'FileBrowse'
elseif platform == 'Mac' then
	-- On Mac OS X .app packages can't be selected in FileBrowse Mode so we need to make them enterable in the GUI using the Text mode
	-- browseMode = 'Text'
	browseMode = 'FileBrowse'
else
	-- Linux
	browseMode = 'FileBrowse'
end

if platform == 'Windows' then
	-- amaterasFile = 'AmaterasDomePlayer.exe'
	amaterasFile = 'AmaterasPlayer.exe'
	-- djvFile = 'djv_view.exe'
	djvFile = 'C:\\Program Files\\djv-1.2.4-Windows-64\\bin\\djv_view.exe'
	kolorEyesFile = 'C:\\Program Files\\Kolor\\Kolor Eyes 1.6\\KolorEyes_x64.exe'
	-- kolorEyesFile = 'KolorEyes_x64.exe'
	goProVRPlayerFile = 'C:\\Program Files\\GoPro\\GoPro VR Player 3.0\\GoProVRPlayer_x64.exe'
	liveViewRiftFile = 'C:\\Program Files (x86)\\Viarum\\LiveViewRift\\LiveViewRift.exe'
	quicktimePlayerFile = 'C:\\Program Files (x86)\\QuickTime\\QuickTimePlayer.exe'
	rvFile = 'rv.exe'
	vlcFile = 'C:\\Program Files (x86)\\VideoLAN\\VLC\\vlc.exe'
	scratchPlayerFile = 'C:\\Program Files\\Assimilate\\bin64\\Assimilator.exe'
elseif platform == 'Mac' then
	amaterasFile = '/Applications/Amateras3/Amateras.app'
	-- djvFile = '/Applications/djv-1.2.4-OSX-64.app'
	-- djvFile = '/Applications/djv-OSX-64.app'
	djvFile = '/Applications/djv.app'
	kolorEyesFile = '/Applications/Kolor Eyes 1.6.app'
	goProVRPlayerFile = '/Applications/GoPro VR Player 3.0.app'
	liveViewRiftFile = '/Applications/LiveViewRift.app'
	-- quicktimePlayerFile = '/Applications/QuickTime Player 7.app'
	quicktimePlayerFile = '/Applications/QuickTime Player.app'
	rvFile = '/Applications/RV64.app'
	vlcFile = '/Applications/VLC.app'
	scratchPlayerFile = '/Applications/Scratch.app'
else
	-- djvFile = '/usr/bin/djv_view'
	djvFile = 'djv_view'
	rvFile = 'rv'
	-- vlcFile = '/usr/bin/vlc'
	vlcFile = 'vlc'
	liveViewRiftFile = 'LiveViewRift'
	-- goProVRPlayerFile = 'GoProVRPlayer'
	goProVRPlayerFile = '/usr/bin/GoProVRPlayer'
end

-- Defaults to DJV
showMediaUsing = getPreferenceData('KartaVR.PanoView.ShowMediaUsing', 3, printStatus)
imageFormat = getPreferenceData('KartaVR.PanoView.Format', 0, printStatus)
soundEffect = getPreferenceData('KartaVR.PanoView.SoundEffect', 1, printStatus)
sendDomeTilt = getPreferenceData('KartaVR.PanoView.SendDomeTilt', 1, printStatus)
domeTiltAngle = getPreferenceData('KartaVR.PanoView.DomeTiltAngle', 0, printStatus)
useCurrentFrame = getPreferenceData('KartaVR.PanoView.UseCurrentFrame', 1, printStatus)
adobeSpeedGradeVersion = getPreferenceData('KartaVR.PanoView.AdobeSpeedGradeVersion', 5, printStatus)
amaterasFile = getPreferenceData('KartaVR.PanoView.AmaterasFile', amaterasFile, printStatus)
djvFile = getPreferenceData('KartaVR.PanoView.DJVFile', djvFile, printStatus)
kolorEyesFile = getPreferenceData('KartaVR.PanoView.KolorEyesFile', kolorEyesFile, printStatus)
goProVRPlayerFile = getPreferenceData('KartaVR.PanoView.GoProVRPlayerFile', goProVRPlayerFile, printStatus)
liveViewRiftFile = getPreferenceData('KartaVR.PanoView.LiveViewRiftFile', liveViewRiftFile, printStatus)
quicktimePlayerFile = getPreferenceData('KartaVR.PanoView.QuicktimePlayerFile', quicktimePlayerFile, printStatus)
rvFile = getPreferenceData('KartaVR.PanoView.RVFile', rvFile, printStatus)
vlcFile = getPreferenceData('KartaVR.PanoView.VLCFile', vlcFile, printStatus)
scratchPlayerFile = getPreferenceData('KartaVR.PanoView.ScratchPlayerFile', scratchPlayerFile, printStatus)
whirligigVersion = getPreferenceData('KartaVR.PanoView.WhirligigVersion', 0, printStatus)
whirligigProjection = getPreferenceData('KartaVR.PanoView.WhirligigProjection', 0, printStatus)
whirligigAngularFOV = getPreferenceData('KartaVR.PanoView.WhirligigAngularFOV', 2, printStatus)
whirligigStereoMode = getPreferenceData('KartaVR.PanoView.WhirligigStereoMode', 0, printStatus)
whirligigEyeOrder = getPreferenceData('KartaVR.PanoView.WhirligigEyeOrder', 0, printStatus)

-- ------------------------------------


msg = "Select the viewing options you would like to use for PanoView."

-- Viewing Program List
showMediaUsingList = {"None", "Adobe SpeedGrade", "Amateras Dome Player", "DJV Viewer", "Kolor Eyes", "Live View Rift", "RV", "Scratch Player", "VLC", "Whirligig", "GoPro VR Player", "QuickTime Player"}

-- Image format List
formatList = {"JPEG", "TIFF", "TGA", "PNG", "BMP", "EXR"}

-- PanoView Sound Effect List
soundEffectList = {"None", "On Error Only", "Steam Train Whistle Sound", "Trumpet Sound", "Braam Sound"}

-- Send Dome Tilt to Viewer List
sendDomeTiltList = {"Yes - Send Dome Tilt Angle", "No - Skip Sending Dome Tilt Angle", "Send Inverted Dome Tilt Angle"}

-- Adobe SpeedGrade Executable List
adobeSpeedGradeList = {"Adobe SpeedGrade CS4", "Adobe SpeedGrade CS5", "Adobe SpeedGrade CS6", "Adobe SpeedGrade CC", "Adobe SpeedGrade CC 2014", "Adobe SpeedGrade CC 2015"}

-- Whirligig List
whirligigVersionList = {"Free Edition", "Steam Edition"}

whirligigProjectionList = {"Equirectangular", "Angular Fisheye", "Cubic Horizontal Cross", "Cubic Vertical Cross", "Cubic Horizontal Tee", "Cubic Vertical Tee", "Facebook Cube Map 3x2", "Facebook Pyramid", "GardenGnome Cube Map 3x2", "Gear VR", "LatLong 360x90 degree", "Rectangular", "Ricoh Theta S Camera", "LG360 Camera", "Samsung Gear 360 Camera"}

whirligigAngularFOVList = {"140", "160", "180", "240", "360"}

whirligigStereoModeList = {"Off", "Side by Side", "Over Under"}

whirligigEyeOrderList = {"Left/Right", "Right/Left"}


d = {}
-- d[1] = {"Msg", Name = "Warning", "Text", ReadOnly = true, Lines = 3, Wrap = true, Default = msg}
d[1] = {"ShowMediaUsing", Name = "Media Viewer", "Dropdown", Default = showMediaUsing, Options = showMediaUsingList}
d[2] = {"Format", Name = "Image Format", "Dropdown", Default = imageFormat, Options = formatList}
d[3] = {"SoundEffect", Name = "Sound Effect", "Dropdown", Default = soundEffect, Options = soundEffectList}
d[4] = {"SendDomeTilt", Name = "Dome Tilt", "Dropdown", Default = sendDomeTilt, Options = sendDomeTiltList}
d[5] = {"DomeTiltAngle", Name = "Dome Tilt Angle", "Screw", Default = domeTiltAngle, Min = -90, Max = 90}
d[6] = {"UseCurrentFrame", Name = "Use Current Frame", "Checkbox", Default = useCurrentFrame, NumAcross = 1}
d[7] = {"AdobeSpeedGradeVersion", Name = "SpeedGrade", "Dropdown", Default = adobeSpeedGradeVersion, Options = adobeSpeedGradeList}
d[8] = {"AmaterasFile", Name = "Amateras Dome Player Executable", browseMode, Lines = 1, Default = amaterasFile}
d[9] = {"DJVFile", Name = "DJV View Executable", browseMode, Lines = 1, Default = djvFile}
d[10] = {"KolorEyesFile", Name = "Kolor Eyes Executable", browseMode, Lines = 1, Default = kolorEyesFile}
d[11] = {"GoProVRPlayerFile", Name = "GoPro VR Player Executable", browseMode, Lines = 1, Default = goProVRPlayerFile}
d[12] = {"LiveViewRiftFile", Name = "Live View Rift Executable", browseMode, Lines = 1, Default = liveViewRiftFile}
d[13] = {"QuicktimePlayerFile", Name = "QuickTime Player Executable", browseMode, Lines = 1, Default = quicktimePlayerFile}
d[14] = {"RVFile", Name = "RV Executable", browseMode, Lines = 1, Default = rvFile}
d[15] = {"VLCFile", Name = "VLC Executable", browseMode, Lines = 1, Default = vlcFile}
d[16] = {"ScratchPlayerFile", Name = "Scratch Player Executable", browseMode, Lines = 1, Default = scratchPlayerFile}
d[17] = {"WhirligigVersion", Name = "Whirligig", "Dropdown", Default = whirligigVersion, Options = whirligigVersionList}
d[18] = {"WhirligigProjection", Name = "Projection", "Dropdown", Default = whirligigProjection, Options = whirligigProjectionList}
d[19] = {"WhirligigAngularFOV", Name = "Angular FOV", "Dropdown", Default = whirligigAngularFOV, Options = whirligigAngularFOVList}
d[20] = {"WhirligigStereoMode", Name = "Stereo Mode", "Dropdown", Default = whirligigStereoMode, Options = whirligigStereoModeList}
d[21] = {"WhirligigEyeOrder", Name = "Eye Order", "Dropdown", Default = whirligigEyeOrder, Options = whirligigEyeOrderList}


dialog = comp:AskUser("Edit PanoView Preferences", d)
if dialog == nil then
	print("You cancelled the dialog!")
	return
else
	-- Debug - List the output from the AskUser dialog window
	dump(dialog)
	
	showMediaUsing = dialog.ShowMediaUsing
	setPreferenceData('KartaVR.PanoView.ShowMediaUsing', showMediaUsing, printStatus)
	
	imageFormat = dialog.Format
	setPreferenceData('KartaVR.PanoView.Format', imageFormat, printStatus)
	
	soundEffect = dialog.SoundEffect
	setPreferenceData('KartaVR.PanoView.SoundEffect', soundEffect, printStatus)
	
	sendDomeTilt = dialog.SendDomeTilt
	setPreferenceData('KartaVR.PanoView.SendDomeTilt', sendDomeTilt, printStatus)
	
	domeTiltAngle = dialog.DomeTiltAngle
	setPreferenceData('KartaVR.PanoView.DomeTiltAngle', domeTiltAngle, printStatus)
	
	useCurrentFrame = dialog.UseCurrentFrame
	setPreferenceData('KartaVR.PanoView.UseCurrentFrame', useCurrentFrame, printStatus)
	
	adobeSpeedGradeVersion = dialog.AdobeSpeedGradeVersion
	setPreferenceData('KartaVR.PanoView.AdobeSpeedGradeVersion', adobeSpeedGradeVersion, printStatus)
	
	amaterasFile = dialog.AmaterasFile
	setPreferenceData('KartaVR.PanoView.AmaterasFile', amaterasFile, printStatus)
	
	djvFile = dialog.DJVFile
	setPreferenceData('KartaVR.PanoView.DJVFile', djvFile, printStatus)
	
	kolorEyesFile = dialog.KolorEyesFile
	setPreferenceData('KartaVR.PanoView.KolorEyesFile', kolorEyesFile, printStatus)
	
	goProVRPlayerFile = dialog.GoProVRPlayerFile
	setPreferenceData('KartaVR.PanoView.GoProVRPlayerFile', goProVRPlayerFile, printStatus)
	
	liveViewRiftFile = dialog.LiveViewRiftFile
	setPreferenceData('KartaVR.PanoView.LiveViewRiftFile', liveViewRiftFile, printStatus)
	
	quicktimePlayerFile = dialog.QuicktimePlayerFile
	setPreferenceData('KartaVR.PanoView.QuicktimePlayerFile', quicktimePlayerFile, printStatus)
	
	rvFile = dialog.RVFile
	setPreferenceData('KartaVR.PanoView.RVFile', rvFile, printStatus)
	
	vlcFile = dialog.VLCFile
	setPreferenceData('KartaVR.PanoView.VLCFile', vlcFile, printStatus)
	
	scratchPlayerFile = dialog.ScratchPlayerFile
	setPreferenceData('KartaVR.PanoView.ScratchPlayerFile',scratchPlayerFile , printStatus)
	
	whirligigVersion = dialog.WhirligigVersion
	setPreferenceData('KartaVR.PanoView.WhirligigVersion', whirligigVersion, printStatus)
	
	whirligigProjection = dialog.WhirligigProjection
	setPreferenceData('KartaVR.PanoView.WhirligigProjection', whirligigProjection, printStatus)
	
	whirligigAngularFOV = dialog.WhirligigAngularFOV
	setPreferenceData('KartaVR.PanoView.WhirligigAngularFOV', whirligigAngularFOV, printStatus)
	
	whirligigStereoMode = dialog.WhirligigStereoMode
	setPreferenceData('KartaVR.PanoView.WhirligigStereoMode', whirligigStereoMode, printStatus)
	
	whirligigEyeOrder = dialog.WhirligigEyeOrder
	setPreferenceData('KartaVR.PanoView.WhirligigEyeOrder', whirligigEyeOrder, printStatus)
end

-- End of the script
print('[Done]')
return

