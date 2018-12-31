--[[--
----------------------------------------------------------------------------
Edit Send Media to Preferences v4.0.1 for Fusion - 2018-12-31
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The Edit Send Media to Preferences script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that lets you customize the settings for the "Send Frame to" and "Send Media to" collection of scripts.

How to use the Script:

Step 1. Start Fusion and open a new comp. Then run the "Script > KartaVR > Send Media to > Edit Send Media to Preferences" menu item.

Step 2. In the Edit Send Media to Preferences dialog window you need to define the executable file path location for each of the "Send Frame to" and "Send Media to" tools you want to use.

Note: The close X box on the dialog window does not work. You have to hit the "Cancel" button to close the window.


How to use the Script:

The "Image Format" control allows you to customize the viewer window's saved image format that is used when the "Send Frame to" scripts are run and a node other than a loader or saver is selected and a temporary image is saved to disk. This temporary image is saved using the left viewer window and then passed onto the specified media viewer tool. You can choose one of the following options: "JPEG", "TIFF", "TGA", "PNG", "BMP", or "EXR".

The "Sound Effect" control allows you to choose if you want to have an audio alert played when an error happens or when the script task completes. You can choose one of the following audio playback options: "None", "On Error Only", "Steam Train Whistle Sound", "Trumpet Sound", or "Braam Sound".

The "After Effects" control allows you to choose the specific version of Adobe After Effects you want to have used when the Send Frame to After Effects" or "Send Media to After Effects" scripts are run. You can choose one of the following options: "Adobe After Effects CC 2019", "Adobe After Effects CC 2018", "Adobe After Effects CC 2017", "Adobe After Effects CC 2015.3", "Adobe After Effects CC 2015", "Adobe After Effects CC 2014", "Adobe After Effects CC", "Adobe After Effects CS6", "Adobe After Effects CS5", "Adobe After Effects CS4", "Adobe After Effects CS3".

The "Illustrator" control allows you to choose the specific version of Adobe Illustrator you want to use when the "Send Frame to Illustrator" or "Send Media to Illustrator" scripts are run. You can choose one of the following options: "Adobe Illustrator CC 2019", "Adobe Illustrator CC 2018", "Adobe Illustrator CC 2017", "Adobe Illustrator CC 2015.3", "Adobe Illustrator CC 2015", "Adobe Illustrator CC 2014", "Adobe Illustrator CC", "Adobe Illustrator CS6", "Adobe Illustrator CS5", "Adobe Illustrator CS4", "Adobe Illustrator CS3".

The "Photoshop" control allows you to choose the specific version of Adobe Photoshop you want to use when the "Send Frame to Photoshop" or "Send Media to Photoshop" scripts are run. You can choose one of the following options:	"Adobe Photoshop CC 2019", "Adobe Photoshop CC 2018", "Adobe Photoshop CC 2017", "Adobe Photoshop CC 2015.5", "Adobe Photoshop CC 2015", "Adobe Photoshop CC 2014", "Adobe Photoshop CC", "Adobe Photoshop CS6", "Adobe Photoshop CS5", "Adobe Photoshop CS4", or "Adobe Photoshop CS3".

The "Mettle SkyBox" control allows you to apply a Mettle SkyBox Studio effect to your footage automatically when the media is sent to After Effects using the "Send Media to After Effects" script. You can choose one of the following options: "None", "Mettle SkyBox Converter", "Mettle SkyBox Project 2D", "Mettle SkyBox Rotate Sphere", "Mettle SkyBox Viewer".

The "Mettle Input" control allows you to choose a Mettle SkyBox Converter input image projection for your footage when the media is sent to After Effects using the "Send Media to After Effects" script. You can choose one of the following options: "2D Source", "Cube-map 4:3", "Sphere-map", "Equirectangular", "Fisheye (FullDome)", "Cube-map Facebook 3:2", "Cube-map Pano2VR 3:2", "Cube-map GearVR 6:1", "Equirectangular 16:9".

The "Mettle Output" control allows you to choose a Mettle SkyBox Converter output image projection for your footage when the media is sent to After Effects using the "Send Media to After Effects" script. You can choose one of the following options: "Cube-map 4:3", "Sphere-map", "Equirectangular", "Fisheye (FullDome)", "Cube-map Facebook 3:2", "Cube-map Pano2VR 3:2", "Cube-map GearVR 6:1", "Equirectangular 16:9".

The "Affinity Designer Executable" text field and file dialog button allow you to specify the location of the Affinity Designer program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

The "Affinity Photo Executable" text field and file dialog button allow you to specify the location of the Affinity Photo program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

The "Autopano Pro Executable" text field and file dialog button allow you to specify the location of the Autopano Pro or Autopano Giga programs on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

The "Corel Photo Paint Executable" text field and file dialog button allow you to specify the location of the Corel Photo Paint program on your hard disk.

The "Hugin Executable" text field and file dialog button allow you to specify the location of the Hugin program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

The "Photomatix Pro Executable" text field and file dialog button allow you to specify the location of the Photomatix Pro program on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

The "PTGui Pro Executable" text field and file dialog button allow you to specify the location of the PTGui or PTGui Pro programs on your hard disk. Note: On Mac OS X you will have to paste the file path in manually as the Fusion file browser dialog won't let you select .app files.

The "TouchDesigner Executable" text field and file dialog button allow you to specify the location of the TouchDesigner program on your hard disk.

The "Layer Order" control allows you to choose the layer stacking order used when sending imagery to another program. The Layer Order menu options are "No Sorting", "Node X Position", "Node Y Position", "Node Name", "Filename", "Folder + Filename".

The "Use Current Frame" checkbox lets you decide if you want to use the automatically calculated frame number and filename from an image sequence. If you disable the "Use Current Frame" checkbox the first image filename referenced in the loader node's filename text field will be used.

The "OK" button will save the revised preferences.

The "Cancel" button will close the script GUI and stop the script.

--]]--

------------------------------------------------------------------------------

local printStatus = false

-- Find out if we are running Fusion 7 or 8
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
local osSeparator = package.config:sub(1,1)

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
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


-- ------------------------------------
-- Load the preferences
-- ------------------------------------

local afterEffectsFile = ''
local illustratorFile = ''
local photoshopFile = ''
local affinityDesignerFile = ''
local affinityPhotoFile = ''
local autopanoProFile = ''
local corelPhotoPaintFile = ''
local huginFile = ''
local photomatixProFile = ''
local ptGuiFile = ''
-- local synthEyesFile = ''
local touchDesignerFile = ''

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
	affinityDesignerFile = 'C:\\Program Files\\Affinity\\Affinity Designer\\Designer.exe'
	affinityPhotoFile = 'C:\\Program Files\\Affinity\\Affinity Photo\\Photo.exe'
	autopanoProFile = 'C:\\Program Files\\Kolor\\Autopano Pro 4.2\\AutopanoPro_x64.exe'
	corelPhotoPaintFile = 'C:\\Program Files\\Corel\\CorelDRAW Graphics Suite X7\\Programs64\\CorelPP.exe'
	huginFile = 'C:\\Program Files (x86)\\Hugin\\bin\\hugin.exe'
	-- huginFile = 'C:\\Program Files\\Hugin\\bin\\hugin.exe'
	imagemagickFile = app:MapPath('Reactor:\\Deploy\\Bin\\imagemagick\\bin\\imconvert.exe')
	-- photomatixProFile = 'C:\\Program Files\\PhotomatixPro5\\PhotomatixPro.exe'
	photomatixProFile = 'C:\\Program Files\\PhotomatixPro6\\PhotomatixPro.exe'
	ptGuiFile = 'C:\\Program Files\\PTGui\\PTGui.exe'
	-- synthEyesFile = 'C:\\Program Files\\Andersson Technologies LLC\\SynthEyes\\SynthEyes64.exe'
	touchDesignerFile = 'C:\\Program Files\\Derivative\\TouchDesigner088\\bin\\touchdesigner088.exe'
	-- touchDesignerFile = 'C:\\Program Files\\Derivative\\TouchDesigner099\\bin\\touchdesigner099.exe'
elseif platform == 'Mac' then
	affinityDesignerFile = '/Applications/Affinity Designer.app'
	affinityPhotoFile = '/Applications/Affinity Photo.app'
	autopanoProFile = '/Applications/Autopano Pro 4.2.app'
	-- huginFile = '/Applications/Hugin.app'
	huginFile = '/Applications/Hugin/Hugin.app'
	imagemagickFile = '/opt/ImageMagick/bin/convert'
	-- imagemagickFile = '/opt/local/bin/convert'
	-- imagemagickFile = '/usr/local/bin/convert'
	-- photomatixProFile = '/Applications/Photomatix Pro 5.app'
	photomatixProFile = '/Applications/Photomatix Pro 6.app'
	ptGuiFile = '/Applications/PTGui Pro.app'
	-- synthEyesFile = '/Applications/SynthEyes/SynthEyes.app'
	touchDesignerFile = '/Applications/TouchDesigner099.app'
else
	huginFile = 'hugin'
	imagemagickFile = '/usr/bin/convert'
	-- synthEyesFile = 'syntheyes'
end


imageFormat = getPreferenceData('KartaVR.SendMedia.Format', 3, printStatus)
soundEffect = getPreferenceData('KartaVR.SendMedia.SoundEffect', 1, printStatus)
layerOrder = getPreferenceData('KartaVR.SendMedia.LayerOrder', 2, printStatus)
afterEffectsVersion = getPreferenceData('KartaVR.SendMedia.AfterEffectsVersion', afterEffectsVersion, printStatus)
illustratorVersion = getPreferenceData('KartaVR.SendMedia.IllustratorVersion', illustratorVersion, printStatus)
photoshopVersion = getPreferenceData('KartaVR.SendMedia.PhotoshopVersion', photoshopVersion, printStatus)
affinityDesignerFile = getPreferenceData('KartaVR.SendMedia.AffinityDesignerFile', affinityDesignerFile, printStatus)
affinityPhotoFile = getPreferenceData('KartaVR.SendMedia.AffinityPhotoFile', affinityPhotoFile, printStatus)
autopanoProFile = getPreferenceData('KartaVR.SendMedia.AutopanoProFile', autopanoProFile, printStatus)
corelPhotoPaintFile = getPreferenceData('KartaVR.SendMedia.CorelPhotoPaintFile', corelPhotoPaintFile, printStatus)
huginFile = getPreferenceData('KartaVR.SendMedia.HuginFile', huginFile, printStatus)
imagemagickFile = getPreferenceData('KartaVR.SendMedia.ImagemagickFile', imagemagickFile, printStatus)
photomatixProFile = getPreferenceData('KartaVR.SendMedia.PhotomatixProFile', photomatixProFile, printStatus)
ptGuiFile = getPreferenceData('KartaVR.SendMedia.PTGuiFile', ptGuiFile, printStatus)
-- synthEyesFile = getPreferenceData('KartaVR.SendMedia.SynthEyesFile', synthEyesFile, printStatus)
touchDesignerFile = getPreferenceData('KartaVR.SendMedia.TouchDesignerFile', touchDesignerFile, printStatus)
useCurrentFrame = getPreferenceData('KartaVR.SendMedia.UseCurrentFrame', 0, printStatus)

-- ------------------------------------

msg = 'Customize the settings for the "Send Frame to" and "Send Media to" collection of scripts.'

-- Image format List
formatList = {'JPEG', 'TIFF', 'TGA', 'PNG', 'BMP', 'EXR'}

-- Sound Effect List
soundEffectList = {'None', 'On Error Only', 'Steam Train Whistle Sound', 'Trumpet Sound', 'Braam Sound'}

-- Layer Order
layerOrderList = {'No Sorting', 'Node X Position', 'Node Y Position', 'Node Name', 'Filename', 'Folder + Filename'}

adobeAfterEffectsList = {'Adobe After Effects CS3', 'Adobe After Effects CS4', 'Adobe After Effects CS5', 'Adobe After Effects CS6', 'Adobe After Effects CC', 'Adobe After Effects CC 2014', 'Adobe After Effects CC 2015', 'Adobe After Effects CC 2015.3', 'Adobe After Effects CC 2017', 'Adobe After Effects CC 2018', 'Adobe After Effects CC 2019'}

adobeIllustratorList = {'Adobe Illustrator CS3', 'Adobe Illustrator CS4', 'Adobe Illustrator CS5', 'Adobe Illustrator CS6', 'Adobe Illustrator CC', 'Adobe Illustrator CC 2014', 'Adobe Illustrator CC 2015', 'Adobe Illustrator CC 2015.3', 'Adobe Illustrator CC 2017', 'Adobe Illustrator CC 2018', 'Adobe Illustrator CC 2019'}

adobePhotoshopList = {'Adobe Photoshop CS3', 'Adobe Photoshop CS4', 'Adobe Photoshop CS5', 'Adobe Photoshop CS6', 'Adobe Photoshop CC', 'Adobe Photoshop CC 2014', 'Adobe Photoshop CC 2015', 'Adobe Photoshop CC 2015.5', 'Adobe Photoshop CC 2017', 'Adobe Photoshop CC 2018', 'Adobe Photoshop CC 2019'}

mettleSkyBoxAEList = {'None', 'Mettle SkyBox Converter', 'Mettle SkyBox Project 2D', 'Mettle SkyBox Rotate Sphere', 'Mettle SkyBox Viewer'}
mettleSkyBoxInputProjectionsList = {'2D Source', 'Cube-map Horizontal Cross 4:3', 'Sphere-map', 'Equirectangular', 'Angular Fisheye (Fulldome)', 'Cube-map Facebook 3:2', 'Cube-map Pano2VR 3:2', 'Cube-map GearVR 6:1', 'Equirectangular 16:9'}
mettleSkyBoxOutputProjectionsList = {'Cube-map Horizontal Cross 4:3', 'Sphere-map', 'Equirectangular', 'Angular Fisheye (Fulldome)', 'Cube-map Facebook 3:2', 'Cube-map Pano2VR 3:2', 'Cube-map GearVR 6:1', 'Equirectangular 16:9'}


afterEffectsVersion = getPreferenceData('KartaVR.SendMedia.AfterEffectsVersion', 10, printStatus)
illustratorVersion = getPreferenceData('KartaVR.SendMedia.IllustratorVersion', 10, printStatus)
photoshopVersion = getPreferenceData('KartaVR.SendMedia.PhotoshopVersion', 10, printStatus)
mettleSkyBoxAE = getPreferenceData('KartaVR.SendMedia.MettleSkyBoxAE', 0, printStatus)
mettleSkyBoxInputProjections = getPreferenceData('KartaVR.SendMedia.MettleSkyBoxInputProjections', 3, printStatus)
mettleSkyBoxOutputProjections = getPreferenceData('KartaVR.SendMedia.MettleSkyBoxOutputProjections', 2, printStatus)

d = {}
d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg}
d[3] = {'Format', Name = 'Image Format', 'Dropdown', Default = imageFormat, Options = formatList }
d[4] = {'SoundEffect', Name = 'Sound Effect', 'Dropdown', Default = soundEffect, Options = soundEffectList}
d[5] = {'AfterEffectsVersion', Name = 'After Effects', 'Dropdown', Default = afterEffectsVersion, Options = adobeAfterEffectsList}
d[6] = {'IllustratorVersion', Name = 'Illustrator', 'Dropdown', Default = illustratorVersion, Options = adobeIllustratorList}
d[7] = {'PhotoshopVersion', Name = 'Photoshop', 'Dropdown', Default = photoshopVersion, Options = adobePhotoshopList}
d[8] = {'MettleSkyBoxAE', Name = 'Mettle SkyBox Effects', 'Dropdown', Default = mettleSkyBoxAE, Options = mettleSkyBoxAEList}
d[9] = {'MettleSkyBoxInputProjections', Name = 'Mettle Input', 'Dropdown', Default = mettleSkyBoxInputProjections, Options = mettleSkyBoxInputProjectionsList}
d[10] = {'MettleSkyBoxOutputProjections', Name = 'Mettle Output', 'Dropdown', Default = mettleSkyBoxOutputProjections, Options = mettleSkyBoxOutputProjectionsList}
d[11] = {'AffinityDesignerFile', Name = 'Affinity Designer Executable', browseMode, Lines = 1, Default = affinityDesignerFile}
d[12] = {'AffinityPhotoFile', Name = 'Affinity Photo Executable', browseMode, Lines = 1, Default = affinityPhotoFile}
d[13] = {'AutopanoProFile', Name = 'Autopano Pro Executable', browseMode, Lines = 1, Default = autopanoProFile}
d[14] = {'CorelPhotoPaintFile', Name = 'Corel Photo Paint Executable', browseMode, Lines = 1, Default = corelPhotoPaintFile}
d[15] = {'HuginFile', Name = 'Hugin Executable', browseMode, Lines = 1, Default = huginFile}
d[16] = {'ImagemagickFile', Name = 'Imagemagick Executable', browseMode, Lines = 1, Default = imagemagickFile}
d[17] = {'PhotomatixProFile', Name = 'Photomatix Pro Executable', browseMode, Lines = 1, Default = photomatixProFile}
d[18] = {'PTGuiFile', Name = 'PTGui Pro Executable', browseMode, Lines = 1, Default = ptGuiFile}
-- d[19] = {'SynthEyesFile', Name = 'SynthEyes Executable', browseMode, Lines = 1, Default = synthEyesFile}
d[19] = {'TouchDesignerFile', Name = 'TouchDesigner Executable', browseMode, Lines = 1, Default = touchDesignerFile}
d[20] = {'LayerOrder', Name = 'Layer Order', 'Dropdown', Default = layerOrder, Options = layerOrderList, NumAcross = 2}
d[21] = {'UseCurrentFrame', Name = 'Use Current Frame', 'Checkbox', Default = useCurrentFrame, NumAcross = 2}

dialog = comp:AskUser('Edit Send Media to Preferences', d)
if dialog == nil then
	print('You cancelled the dialog!')
	
	-- Unlock the comp flow area
	comp:Unlock()
	
	return
else
	-- Debug - List the output from the AskUser dialog window
	dump(dialog)
	
	imageFormat = dialog.Format
	setPreferenceData('KartaVR.SendMedia.Format', imageFormat, printStatus)
	
	soundEffect = dialog.SoundEffect
	setPreferenceData('KartaVR.SendMedia.SoundEffect', soundEffect, printStatus)
	
	layerOrder = dialog.LayerOrder
	setPreferenceData('KartaVR.SendMedia.LayerOrder', layerOrder, printStatus)
	
	afterEffectsVersion = dialog.AfterEffectsVersion
	setPreferenceData('KartaVR.SendMedia.AfterEffectsVersion', afterEffectsVersion, printStatus)
	
	illustratorVersion = dialog.IllustratorVersion
	setPreferenceData('KartaVR.SendMedia.IllustratorVersion', illustratorVersion, printStatus)
	
	photoshopVersion = dialog.PhotoshopVersion
	setPreferenceData('KartaVR.SendMedia.PhotoshopVersion', photoshopVersion, printStatus)
	
	mettleSkyBoxAE = dialog.MettleSkyBoxAE
	setPreferenceData('KartaVR.SendMedia.MettleSkyBoxAE', mettleSkyBoxAE, printStatus)
	
	mettleSkyBoxInputProjections = dialog.MettleSkyBoxInputProjections
	setPreferenceData('KartaVR.SendMedia.MettleSkyBoxInputProjections', mettleSkyBoxInputProjections, printStatus)
	
	mettleSkyBoxOutputProjections = dialog.MettleSkyBoxOutputProjections
	setPreferenceData('KartaVR.SendMedia.MettleSkyBoxOutputProjections', mettleSkyBoxOutputProjections, printStatus)
	
	affinityDesignerFile = dialog.AffinityDesignerFile
	setPreferenceData('KartaVR.SendMedia.AffinityDesignerFile', affinityDesignerFile, printStatus)
	
	affinityPhotoFile = dialog.AffinityPhotoFile
	setPreferenceData('KartaVR.SendMedia.AffinityPhotoFile', affinityPhotoFile, printStatus)
	
	autopanoProFile = dialog.AutopanoProFile
	setPreferenceData('KartaVR.SendMedia.AutopanoProFile', autopanoProFile, printStatus)
	
	corelPhotoPaintFile = dialog.CorelPhotoPaintFile
	setPreferenceData('KartaVR.SendMedia.CorelPhotoPaintFile', corelPhotoPaintFile, printStatus)
	
	huginFile = dialog.HuginFile
	setPreferenceData('KartaVR.SendMedia.HuginFile', huginFile, printStatus)
	
	imagemagickFile = dialog.ImagemagickFile
	setPreferenceData('KartaVR.SendMedia.ImagemagickFile', imagemagickFile, printStatus)
	
	photomatixProFile = dialog.PhotomatixProFile
	setPreferenceData('KartaVR.SendMedia.PhotomatixProFile', photomatixProFile, printStatus)
	
	ptGuiFile = dialog.PTGuiFile
	setPreferenceData('KartaVR.SendMedia.PTGuiFile', ptGuiFile, printStatus)
	
	-- synthEyesFile = dialog.SynthEyesFile
	-- setPreferenceData('KartaVR.SendMedia.SynthEyesFile', synthEyesFile, printStatus)
	
	touchDesignerFile = dialog.TouchDesignerFile
	setPreferenceData('KartaVR.SendMedia.TouchDesignerFile', touchDesignerFile, printStatus)
	
	useCurrentFrame = dialog.UseCurrentFrame
	setPreferenceData('KartaVR.SendMedia.UseCurrentFrame', useCurrentFrame, printStatus)
end

-- End of the script
print('[Done]')
return
