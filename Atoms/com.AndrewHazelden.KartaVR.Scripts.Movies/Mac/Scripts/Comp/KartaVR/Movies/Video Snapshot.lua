--[[
Video Snapshot for Fusion - v4.0 2018-12-16
by Andrew Hazelden
Email: andrew@andrewhazelden.com
Web: www.andrewhazelden.com

## Overview: ##

This Fusion script takes a live video frame snapshot from a MacOS computer's AV foundation based video capture device. The script has Fusion 9 based UI Manager GUI and uses FFMPEG from the command line to do the capture.

## Installation: ##

Step 1. Install Reactor.

Step 2. Open Reactor and install the "Tools/VR/KartaVR" content. Then restart Fusion once.

Step 3. You are now ready to use the Video Snapshot script. :)


## Script Usage: ##

Step 1. Select the "Script > KartaVR > Movies > Video Snapshot" menu item in Fusion to launch the script.

Step 2. On the top row of the Video Snapshot window you can select the video input source, then you can select the captured frame size, and a frame rate.

The "Image Prefix:" text field allows you to customzie the starting part of the Screenshot filename. By default this setting is "Snapshot" and will result in the incrementing filename of "Temp:/KartaVR/Snapshot.0001.jpg" being written to disk.

The "Capture Image" button saves a new JPEG image framegrab to the "Temp:/KartaVR/" pathmap location from your selected video source.

The "Show Output Folder" button will open up the directory where the screenshots are saved in a new Finder based folder browser window.

The "Add Loader Node" button will create a new Fusion Loader node in your composite and set the clip to use the current filename of your captured image sequence. The new Loader node footage will be shown automatically on the left Fusion image viewer window. Also, the Loader clip and Fusion timeline frame range will be set to the number of screenshots saved in the current sequence.

## Notes ##

If you select an image size or frame rate that is not compatible with your current video input source the "Capture Log" at the bottom of the view will list the compatible image capture formats.

If you are using a "Facetime HD Camera" as the video source you should select "1280x720" as the frame size, and "30.000000" frames per second as your capture settings.


## FFMPEG Command Prompt Based Video Capture Reference Docs ##

You can check the ffmpeg docs for more details on how the MacOS AV Foundation based capture workflow works from the command prompt:

https://ffmpeg.org/ffmpeg-devices.html


You can generate a ffmpeg list of supported AV Foundation video capture sources in a terminal window using:

# Generate an FFMPEG Video Input List:
ffmpeg -f avfoundation -list_devices true -i "" 2>&1 | /usr/local/bin/bbedit

# Result:
[AVFoundation input device @ 0x7fbc99e00320] AVFoundation video devices:
[AVFoundation input device @ 0x7fbc99e00320] [0] Cisco VTCamera3
[AVFoundation input device @ 0x7fbc99e00320] [1] Cisco VTCamera3 #2
[AVFoundation input device @ 0x7fbc99e00320] [2] FaceTime HD Camera
[AVFoundation input device @ 0x7fbc99e00320] [3] Capture screen 0
[AVFoundation input device @ 0x7fbc99e00320] [4] Capture screen 1
[AVFoundation input device @ 0x7fbc99e00320] AVFoundation audio devices:
[AVFoundation input device @ 0x7fbc99e00320] [0] Scarlett 2i2 USB
[AVFoundation input device @ 0x7fbc99e00320] [1] Cisco VTCamera3
[AVFoundation input device @ 0x7fbc99e00320] [2] Built-in Microphone
[AVFoundation input device @ 0x7fbc99e00320] [3] Cisco VTCamera3


You can use a terminal window with ffmpeg + AV Foundation to capture a still frame from a video source in using:

/usr/local/bin/ffmpeg -y -f avfoundation -framerate 30.000000 -video_size 1280x720 -pixel_format uyvy422 -vsync 2 -i "default" -f image2 -vcodec mjpeg -vframes 1 -qscale:v 2 $HOME/Desktop/Snapshot.0001.jpg 2>&1

]]

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

-- Where should the frame captures be stored
local outputDirectory = comp:MapPath('Temp:/KartaVR/')
-- local outputDirectory = comp:MapPath('Temp:/Fusion/')
-- local outputDirectory = comp:MapPath('Comp:/Captures/')

-- What type of image should be saved to disk 
local outputImageFormat = '.jpg'

-- Starting framegrab image sequence frame number
local imageNumber = 1

-- ----------------------------------------------------------------------------
-- Display the extra debugging verbosity detail in the console log
-- printStatus = true
printStatus = false

-- Track if the image was found
local err = false

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

if platform == 'Windows' or platform == 'Linux' then
	print('[Warning] This script only runs on MacOS because it uses the AV Foundation library for video capture which does not exist on Linx and Windows.')
	return
end

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Find out if we are running in Fusion 8 or 9
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Check if Fusion Standalone or the Resolve Fusion page is active
host = fusion:MapPath('Fusion:/')
if string.lower(host):match('resolve') then
	hostSW = 'Resolve'
else
	hostSW = 'Fusion'
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
	
	-- Check if the folder exists and create it if required
	if not bmd.direxists(dir) then
		bmd.createdir(dir)
		print('[Created Folder] ' .. dir .. '\n')
	end
	
	-- Open the folder
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


-- Add a loader node to the composite based upon the current frame name
-- Example: AddSnapshotLoader('SnapshotLoader', filename)
function AddSnapshotLoader(nodeName, filename)
	-- Disable the file browser dialog
	AutoClipBrowse = fusion:GetPrefs('Global.UserInterface.AutoClipBrowse')
	fusion:SetPrefs('Global.UserInterface.AutoClipBrowse', false)

	-- Add a new loader node at the default coordinates in the Flow
	local snapshotLoader = composition:AddTool('Loader', -32768, -32768)

	-- Re-enable the file browser dialog
	fusion:SetPrefs('Global.UserInterface.AutoClipBrowse', AutoClipBrowse)

	-- Rename the loader node
	snapshotLoader:SetAttrs({TOOLS_Name = nodeName, TOOLB_NameSet = true})
	
	-- Update the loader's clip filename
	snapshotLoader.Clip[TIME_UNDEFINED] = filename
	snapshotLoader.GlobalStart = 1
	snapshotLoader.GlobalEnd = imageNumber
	
	-- Update the timeline render and global ranges
	comp:SetAttrs({COMPN_RenderStart = 1})
	comp:SetAttrs({COMPN_RenderEnd = imageNumber})
	
	comp:SetAttrs({COMPN_GlobalStart = 1})
	comp:SetAttrs({COMPN_GlobalEnd = imageNumber-1})
	
	-- Enable HiQ mode
	comp:SetAttrs{COMPB_HiQ = true}
	
	-- Display the Loader node in the Viewer 1 window
	comp:GetPreviewList().Left:ViewOn(snapshotLoader, 1)
	
	-- Move the timeline playhead to the current snapshot frame number
	comp.CurrentTime = imageNumber - 1
end


-- Convert a filepath to an HTML image tag
-- Example: html = html .. addImage('Temp:/Fusion/Screenshot.0001.jpg')
function addImage(Imagename)
	return '<img style="padding:70px;" src="' .. comp:MapPath(Imagename) .. '" />\n'
end


-- Check the ffmpeg video device list
-- Example: VideoDeviceList()
function VideoDeviceList()
	-- Create a new empty table to hold the list of video capture devices
	videoDevicesTable = {}
	
	-- Create a new table to hold the list of frame sizes
	videoResolutionTable = {}
	videoResolutionTable[1] = {id = 1, resolution = '3840x2160'}
	videoResolutionTable[2] = {id = 1, resolution = '1920x1280'}
	videoResolutionTable[3] = {id = 1, resolution = '1920x1080'}
	videoResolutionTable[4] = {id = 1, resolution = '1600x1200'}
	videoResolutionTable[5] = {id = 2, resolution = '1280x720'}
	videoResolutionTable[6] = {id = 3, resolution = '960x720'}
	videoResolutionTable[7] = {id = 4, resolution = '800x600'}
	videoResolutionTable[8] = {id = 5, resolution = '640x480'}
	videoResolutionTable[9] = {id = 6, resolution = '320x240'}
	videoResolutionTable[10] = {id = 7, resolution = '160x120'}
	
	-- Create a new table to hold the list of frame rates
	videoFrameRateTable = {}
	videoFrameRateTable[1] = {id = 1, fps = '30.000000'}
	videoFrameRateTable[2] = {id = 2, fps = '25.000000'}
	videoFrameRateTable[3] = {id = 3, fps = '20.000000'}
	videoFrameRateTable[4] = {id = 4, fps = '10.000000'}
	videoFrameRateTable[5] = {id = 5, fps = '5.000000'}
	videoFrameRateTable[6] = {id = 6, fps = '1.000000'}

	-- Create a new table to hold the list of pixel formats
	videoPixelFormat = {}
	videoPixelFormat[1] = {id = 1, format = 'uyvy422'}
	videoPixelFormat[2] = {id = 2, format = 'yuyv422'}
	videoPixelFormat[3] = {id = 3, format = 'nv12'}
	videoPixelFormat[4] = {id = 4, format = '0rgb'}
	videoPixelFormat[5] = {id = 5, format = 'bgr0'}
	
	-- Create a new table to hold the list of media types
	videoMediaType = {}
	videoMediaType[1] = {id = 1, format = 'JPEG Image'}
	videoMediaType[2] = {id = 1, format = 'PNG Image'}
	videoMediaType[3] = {id = 1, format = 'TIFF Image'}
	videoMediaType[4] = {id = 1, format = 'MP4 H.264 Movie'}
	videoMediaType[5] = {id = 1, format = 'MP4 H.265 Movie'}
	videoMediaType[6] = {id = 1, format = 'MOV H.264 Movie'}
	videoMediaType[7] = {id = 1, format = 'MOV ProRes 422 Movie'}

	local options = ''
	if platform == "Windows" then
		-- Running on Windows
		options = options .. ' ' .. ''
	elseif platform == 'Mac' then
		-- Running on Mac
		options = options .. ' ' .. ' -f avfoundation -list_devices true -i "" 2>&1'
	else
		--Linux
		options = options .. ' ' .. ''
	end

	-- Scan the ffmpeg terminal output line by line
	local handler = io.popen(ffmpegProgram .. ' ' .. options)
	local i = 1
	
	-- Add a 'disabled' video device
	videoDevicesTable[i] = {id = i, device = 'Disabled'}
	i = i + 1
	
	-- Add a 'default' video device
	videoDevicesTable[i] = {id = i, device = 'Default'}
	i = i + 1
	
	-- Scan the io.popen output for the remaining video devices
	for line in handler:lines() do
		-- [AVFoundation input device @ 0x7fbc99e00320] [0] Cisco VTCamera3
		searchString = '%[%d%].*$'
		rawResult = string.match(line, searchString)
		if rawResult ~= nil then
			-- print(rawResult)
			-- Example: [0] Cisco VTCamera3
			
			-- Trim off the ID Code trailing square bracket
			searchString = '%].*$'
			device = string.match(rawResult, searchString):sub(3)
			-- print(device)
			-- Example: Cisco VTCamera3
			
			-- Add a new entry to the table
			videoDevicesTable[i] = {id = i, device = device}
			-- Example: videoDevicesTable[1] = {id = 1, device = 'Cisco VTCamera3'}
			
			-- Increment the device counter
			i = i + 1
		end
	end
	
	-- Add the video input device entries to the ComboControl menu
	for i = 1, table.getn(videoDevicesTable) do
		itm.VideoDevicesCombo1:AddItem(videoDevicesTable[i].device)
		-- itm.VideoDevicesCombo2:AddItem(videoDevicesTable[i].device)
		-- itm.VideoDevicesCombo3:AddItem(videoDevicesTable[i].device)
		-- itm.VideoDevicesCombo4:AddItem(videoDevicesTable[i].device)
		-- itm.VideoDevicesCombo5:AddItem(videoDevicesTable[i].device)
		-- itm.VideoDevicesCombo6:AddItem(videoDevicesTable[i].device)
		-- itm.VideoDevicesCombo7:AddItem(videoDevicesTable[i].device)
		-- itm.VideoDevicesCombo8:AddItem(videoDevicesTable[i].device)
	end
	
	-- Add the video resolution entries to the ComboControl menu
	for i = 1, table.getn(videoResolutionTable) do
		itm.VideoResolutionCombo:AddItem(videoResolutionTable[i].resolution)
	end
	
	-- Add the video frame rates entries to the ComboControl menu
	for i = 1, table.getn(videoFrameRateTable) do
		itm.VideoFrameRateCombo:AddItem(videoFrameRateTable[i].fps)
	end
	
	-- Add the video format entries to the ComboControl menu
	for i = 1, table.getn(videoPixelFormat) do
		itm.VideoPixelFormatCombo:AddItem(videoPixelFormat[i].format)
	end
	
	-- Add the media type entries to the ComboControl menu
	for i = 1, table.getn(videoMediaType) do
		itm.MediaTypeCombo:AddItem(videoMediaType[i].format)
	end

	-- Pre-select some default options 
	
	-- Capture Preset Option 1
	-- Select a 1280x720 video resolution
	itm.VideoResolutionCombo.CurrentIndex = 4
	-- Select a 30 fps frame rate
	itm.VideoFrameRateCombo.CurrentIndex = 0
	-- Select the "Default" device
	itm.VideoDevicesCombo1.CurrentText = 'Default'
	-- Select the "uyvy422" video format
	itm.VideoPixelFormatCombo.CurrentText = 'uyvy422'
	-- Select the "JPEG" media type
	itm.MediaTypeCombo.CurrentText = 'JPEG Image'
	
	-- Capture Preset Option 2
	-- Select a 1600x1200 video resolution
	-- itm.VideoResolutionCombo.CurrentIndex = 1
	-- Select a 10 fps frame rate
	-- itm.VideoFrameRateCombo.CurrentIndex = 3
	-- Select the "Cisco VTCamera3" device
	-- itm.VideoDevicesCombo1.CurrentText = 'Cisco VTCamera3'
	-- itm.VideoDevicesCombo2.CurrentText = 'Cisco VTCamera3 #2'
	-- itm.VideoDevicesCombo3.CurrentText = 'Cisco VTCamera3 #3'
	-- itm.VideoDevicesCombo4.CurrentText = 'Cisco VTCamera3 #4'
	-- Select the "uyvy422" video format
	-- itm.VideoPixelFormatCombo.CurrentText = 'uyvy422'
	-- Select the "JPEG" media type
	-- itm.MediaTypeCombo.CurrentText = 'JPEG Image'
end


-- Generate the snapshot filename
-- Example: filename, tokenFilename = FrameFilename('Snapshot')
function FrameFilename(filenamePrefix)

	-- How many digits of frame padding?
	framePadding = 4
	paddedImageNumber = string.format('%0' .. framePadding .. 'd', imageNumber)
	
	local filename = ''
	local tokenFilename = ''
	
	-- Capture mode
	if math.floor(DurationFrames) >= 2 then
		-- Multi-frame capture
		
		-- Generate the filenames
		filename = filenamePrefix .. '_session_' .. paddedImageNumber .. '.0001' .. outputImageFormat
		-- Screenshot.0001.jpg
		tokenFilename = filenamePrefix ..'_session_' .. paddedImageNumber .. '.' .. '%0' .. framePadding .. 'd' .. outputImageFormat
		-- Screenshot.%04d.jpg
	else
		-- Single-frame capture
		
		-- Generate the filenames
		filename = filenamePrefix .. '.' .. paddedImageNumber .. outputImageFormat
		-- Screenshot.0001.jpg
		tokenFilename = filenamePrefix .. '.' .. '%0' .. framePadding .. 'd' .. outputImageFormat
		-- Screenshot.%04d.jpg
	end
	
	return filename, tokenFilename
end


-- Get the Snapshot filepath and verify the snapshot filename is unique
-- Example: filename, tokenFilename, startframe = CheckFilename()
function CheckFilename()

	-- Generate the filename that is saved to disk
	snapshotFilenamePrefix, snapshotTokenFilenamePrefix = FrameFilename(FilenamePrefix)
	local snapshotFilename = outputDirectory .. snapshotFilenamePrefix
	-- Temp:/Fusion/Screenshot.0001.jpg
	local snapshotTokenFilename = outputDirectory .. snapshotTokenFilenamePrefix
	-- Temp:/Fusion/Screenshot.%04d.jpg

	-- Ensure the outputFilename is unique to avoid overwriting images
	while eyeon.fileexists(snapshotFilename) do
		-- An existing image was found so increment the frame number
		imageNumber = imageNumber + 1
		
		-- Grab the next filename
		snapshotFilenamePrefix, snapshotTokenFilenamePrefix = FrameFilename(FilenamePrefix)
		snapshotFilename = outputDirectory .. snapshotFilenamePrefix
		-- Temp:/Fusion/Screenshot.0001.jpg
		snapshotTokenFilename = outputDirectory .. snapshotTokenFilenamePrefix
		-- Temp:/Fusion/Screenshot.%04d.jpg
	end
	
	return snapshotFilename, snapshotTokenFilename, imageNumber
end


-- Use ffmpeg to capture a still image
-- Example: FrameCapture('screenshot')
function FrameCapture(outputFilenamePrefix)
	-- Create the temporary output folder
	if platform == 'Windows' then
		os.execute('mkdir "' .. outputDirectory .. '"')
	else
	-- Mac and Linux
		os.execute('mkdir -p "' .. outputDirectory .. '"')
	end
	print('[Output Folder] ' .. outputDirectory)
	
	-- ffmpeg Video Source
	if itm.VideoDevicesCombo1.CurrentText == 'Disabled' then
		result = '[Capture Skipped] [Video Input] [1] ' .. itm.VideoDevicesCombo1.CurrentText
		-- Add the result to the ffmpeg log results TextEdit field
		itm.Result.PlainText = result
		print(result)
		return 
	elseif itm.VideoDevicesCombo1.CurrentText == 'Default' then
		videoInputName = 'default'
	else
		-- videoInputName = 'Cisco VTCamera3'
		videoInputName = itm.VideoDevicesCombo1.CurrentText
	end

	-- ffmpeg capture video resolution
	videoSize = itm.VideoResolutionCombo.CurrentText
	-- videoSize = '1600x1200'
		
	-- ffmpeg capture frame rate
	frameRate = itm.VideoFrameRateCombo.CurrentText
	-- frameRate = '5.000000'
	
	-- ffmpeg capture pixel format
	pixelFormat = itm.VideoPixelFormatCombo.CurrentText
	-- pixelFormat = 'uyvy422'
	
	-- output image compression quality (2 = very good quality)
	quality = 2

	-- Generate the filename that is saved to disk
	outputFilename, tokenFilename, startFrame = CheckFilename()
	-- Temp:/KartaVR/Screenshot.0001.jpg
	
	-- Update the label to list the captured frame name
	-- itm.ImageFilepathText.Text = FrameFilename(outputFilenamePrefix)
	itm.ImageFilepathText.Text = outputFilename

	local options = ''
	if platform == 'Windows' then
		-- Running on Windows
		options = options .. ' ' .. ''
	elseif platform == 'Mac' then
		-- Running on Mac
		
		
		-- FFmpeg sequence handling docs:
		-- https://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/image_sequence#Filename_numbering
		
		-- This snippet skips defining the pixel format
		-- options = options .. ' ' .. ' -y -f avfoundation -framerate ' .. frameRate .. ' -video_size ' .. videoSize .. ' -vsync 2 ' .. ' -i "' .. videoInputName .. '" -f image2 -vcodec mjpeg -vframes ' .. DurationFrames .. ' -qscale:v ' .. quality .. ' ""' .. tokenFilename .. '"" 2>&1'
		
		-- This snippet has the video format defined
		options = options .. ' ' .. ' -y -f avfoundation -framerate ' .. frameRate .. ' -video_size ' .. videoSize .. ' -pixel_format ' .. pixelFormat .. ' -vsync 2 ' .. ' -i "' .. videoInputName .. '" -f image2 -vcodec mjpeg -vframes ' .. DurationFrames .. ' -qscale:v ' .. quality .. ' "' .. tokenFilename .. '" 2>&1'
	else
		-- Running on Linux
		options = options .. ' ' .. ''
	end
	
	-- Capture a single frame using ffmpeg from the terminal
	local command = ffmpegProgram .. ' ' .. options
	print('[Launch Command] ' .. command)
	local handler = io.popen(command)
	local response = handler:read('*a')
	
	-- Add the result to the ffmpeg log results TextEdit field
	itm.Result.PlainText = command .. '\n' .. tostring(response)
	print(itm.Result.PlainText)
	
	itm.SnapshotWin.WindowTitle = 'Video Snapshot for Fusion'
	
	-- Increment the image number
	imageNumber = imageNumber + 1
end


-- Load the default settings from the Fusion prefs
FilenamePrefix = getPreferenceData('VideoSnapshot.FilenamePrefix', 'Snapshot', printStatus)

DurationFrames = getPreferenceData('VideoSnapshot.DurationFrames', tonumber(1), printStatus)

-- Where is ffmpeg installed on your MacOS system?
defaultFFmpegProgram = comp:MapPath('Reactor:/Deploy/Bin/ffmpeg/bin/ffmpeg')
-- defaultFFmpegProgram = '/usr/local/bin/ffmpeg'
-- defaultFFmpegProgram = 'ffmpeg'

ffmpegProgram = '"' .. getPreferenceData('KartaVR.SendMedia.FFmpegFile', defaultFFmpegProgram, printStatus) .. '"'

-- Get the Snapshot filepath and verify the snapshot filename is unique
filename, tokenFilename, startFrame = CheckFilename()

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 1200,350
win = disp:AddWindow({
	ID = 'SnapshotWin',
	TargetID = 'SnapshotWin',
	WindowTitle = 'Video Snapshot for Fusion',
	Geometry = {200, 200, width, height},
	Composition = comp,
	
	ui:VGroup{
		ID = 'root',
		-- Add your GUI elements here:
		
		-- Video Devices Combo Controls
		-- ui:HGroup{
			-- Weight = 0,
			-- ui:Label{ID = 'VideoDevicesLabel', Text = 'Select your video inputs:'},
			
			-- Video input list
			-- ui:ComboBox{ID = 'VideoDevicesCombo1'},
			-- ui:ComboBox{ID = 'VideoDevicesCombo2'},
			-- ui:ComboBox{ID = 'VideoDevicesCombo3'},
			-- ui:ComboBox{ID = 'VideoDevicesCombo4'},
			-- ui:ComboBox{ID = 'VideoDevicesCombo5'},
			-- ui:ComboBox{ID = 'VideoDevicesCombo6'},
			-- ui:ComboBox{ID = 'VideoDevicesCombo7'},
			-- ui:ComboBox{ID = 'VideoDevicesCombo8'},
		-- },
		
		-- Video Capture Settings
		ui:HGroup{
			Weight = 0,
			-- Video input list
			ui:Label{ID = 'VideoDevicesLabel', Text = 'Select your video inputs:'},
			ui:ComboBox{ID = 'VideoDevicesCombo1'},
			
			-- Media Type List
			ui:Label{ID = 'MediaTypeText', Text = 'Media Type: ', Weight = 0},
			ui:ComboBox{ID = 'MediaTypeCombo'},
			
			-- Duration
			ui:Label{ID = 'DurationLabel', Text = 'Capture Duration:', Weight = 0},
			ui:LineEdit{ID = 'DurationText', PlaceholderText = 'Frames', Text = tostring(DurationFrames), Weight = 0.20, MinimumSize = {40, 24}},
			
			-- Image Resolution list
			ui:Label{ID = 'ResolutionText', Text = 'Resolution: ', Weight = 0},
			ui:ComboBox{ID = 'VideoResolutionCombo'},
			
			-- Frame Rate list
			ui:Label{ID = 'FPSText', Text = 'FPS: ', Weight = 0},
			ui:ComboBox{ID = 'VideoFrameRateCombo'},
			
			-- Pixel Format list
			ui:Label{ID = 'PixelFormatText', Text = 'Format: ', Weight = 0},
			ui:ComboBox{ID = 'VideoPixelFormatCombo'},
		},
		
		-- Frame Saving Settings
		ui:HGroup{
			Weight = 0,
			
			-- Filename Prefix
			ui:Label{ID = 'FilenamePrefixLabel', Text = 'Image Prefix:', Weight = 0},
			ui:LineEdit{ID = 'FilenamePrefixText', PlaceholderText = 'Enter a filename prefix.', Text = FilenamePrefix, Weight = 1.5, MinimumSize = {250, 24}},
			ui:HGap(0, 2),
			
			-- Buttons
			ui:Button{ID = 'CaptureImageButton', Text = 'Capture Image'},
			ui:Button{ID = 'ShowOutputFolderButton', Text = 'Show Output Folder'},
			ui:Button{ID = 'AddLoaderButton', Text = 'Add Loader Node'},
		},
		
		-- Saved image filename
		ui:HGroup{
			Weight = 0,
			ui:Label{ID = 'SavedImageText', Text = 'Last Saved Image: ', Weight = 0},
			ui:Label{ID = 'ImageFilepathText', Text = filename, Weight = 1},
		},
		
		-- JPEG/PNG based image preview
		-- ui:HGroup{
		--	 Weight = 0.5,
		--	 ui:TextEdit{ID = 'HTMLPreview', ReadOnly = true},
		-- },
		
		-- FFmpeg results log
		ui:VGroup{
			ID = 'ResultGroup',
			Weight = 0.25,
			--Visible = false,
			
			-- ui:VGap(10), -- fixed 10 pixels gap
			ui:Label{ID = 'LogLabel', Text = 'Capture Log:', Weight = 0},
			ui:TextEdit{ID='Result', Text = '', ReadOnly = true}
		},
	},
})

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.SnapshotWin.Close(ev)
	disp:ExitLoop()
end

-- The filename prefix text was changed
function win.On.FilenamePrefixText.TextChanged(ev)
	setPreferenceData('VideoSnapshot.FilenamePrefix', tostring(itm.FilenamePrefixText.Text), printStatus)
	FilenamePrefix = tostring(itm.FilenamePrefixText.Text)
end

-- The Capture Duration text was changed
function win.On.DurationText.TextChanged(ev)
	setPreferenceData('VideoSnapshot.DurationFrames', tonumber(itm.DurationText.Text), printStatus)
	DurationFrames = tonumber(itm.DurationText.Text)
	print('[Capture Duration] ' .. DurationFrames)
end

-- The "Capture Image" button was pressed
function win.On.CaptureImageButton.Clicked(ev)
	-- Use ffmpeg to capture a still image
	FrameCapture(FilenamePrefix)
end

-- The "Show Output Folder" button was pressed
function win.On.ShowOutputFolderButton.Clicked(ev)
	openDirectory(outputDirectory)
end

-- The "Show Captured Image" button was pressed
function win.On.AddLoaderButton.Clicked(ev)
	-- Add a loader node to the composite based upon the current frame name
	AddSnapshotLoader('SnapshotLoader', itm.ImageFilepathText.Text)
	
	-- Update the HTML based JPEG/PNG image preview
	-- itm.HTMLPreview.HTML = addImage(itm.ImageFilepathText.Text)
	-- print('[HTML Preview] ', itm.HTMLPreview.HTML)
end

-- The VideoDevicesCombo# ComboControls were updated
function win.On.VideoPixelFormatCombo.CurrentIndexChanged(ev)
	print('[Pixel Format] ' .. itm.VideoPixelFormatCombo.CurrentText)
end


function win.On.VideoDevicesCombo1.CurrentIndexChanged(ev)
	print('[Video Input] [1] ' .. itm.VideoDevicesCombo1.CurrentText .. ' @ ' .. itm.VideoResolutionCombo.CurrentText)
end

--[[--
function win.On.VideoDevicesCombo2.CurrentIndexChanged(ev)
	print('[Video Input] [2] ' .. itm.VideoDevicesCombo2.CurrentText .. ' @ ' .. itm.VideoResolutionCombo.CurrentText)
end

function win.On.VideoDevicesCombo3.CurrentIndexChanged(ev)
	print('[Video Input] [3] ' .. itm.VideoDevicesCombo3.CurrentText .. ' @ ' .. itm.VideoResolutionCombo.CurrentText)
end

function win.On.VideoDevicesCombo4.CurrentIndexChanged(ev)
	print('[Video Input] [4] ' .. itm.VideoDevicesCombo4.CurrentText .. ' @ ' .. itm.VideoResolutionCombo.CurrentText)
end

function win.On.VideoDevicesCombo5.CurrentIndexChanged(ev)
	print('[Video Input] [5] ' .. itm.VideoDevicesCombo5.CurrentText .. ' @ ' .. itm.VideoResolutionCombo.CurrentText)
end

function win.On.VideoDevicesCombo6.CurrentIndexChanged(ev)
	print('[Video Input] [6] ' .. itm.VideoDevicesCombo6.CurrentText .. ' @ ' .. itm.VideoResolutionCombo.CurrentText)
end

function win.On.VideoDevicesCombo7.CurrentIndexChanged(ev)
	print('[Video Input] [7] ' .. itm.VideoDevicesCombo7.CurrentText .. ' @ ' .. itm.VideoResolutionCombo.CurrentText)
end

function win.On.VideoDevicesCombo8.CurrentIndexChanged(ev)
	print('[Video Input] [8] ' .. itm.VideoDevicesCombo8.CurrentText .. ' @ ' .. itm.VideoResolutionCombo.CurrentText)
end
--]]--

-- Check the ffmpeg video device list
VideoDeviceList()

win:Show()

-- Adjust the colors of the ffmpeg Results area on Fusion 9+
if fu_major_version >= 9 then
	bgcol = {R=0.125, G=0.125, B=0.125, A=1}
	itm.Result.BackgroundColor = bgcol
	itm.Result:SetPaletteColor('All', 'Base', bgcol)
else
	print('[Warning] You should really be running Fusion 9!')
end

-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the Atomizer window instead of closing the foreground composite.
app:AddConfig('SnapshotWin', {
	Target {
		ID = 'SnapshotWin',
	},
	
	Hotkeys {
		Target = 'SnapshotWin',
		Defaults = true,
	
		CONTROL_W = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
		CONTROL_F4 = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
	},
})

disp:RunLoop()
win:Hide()
