--[[--
----------------------------------------------------------------------------
Generate UV Pass in PTGui v4.0 for Fusion - 2018-12-25
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The Generate UV Pass in PTGui script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that will use Imagemagick and PTGui Pro to create a collection of UV Pass maps that can be used in Fusion to quickly and efficiently warp and stitch multi-camera rig panoramic 360 degree imagery.

How to use the Script:

Step 1. Start Fusion and open a new comp. Then run the "Script > KartaVR > Stitching > Generate UV Pass in PTGui" menu item.

Step 2. In the Generate UV Pass in PTGui dialog window you need to select a PTGui .pts file using the "PTGui Project File" text field. After customizing the settings like the image width and height controls you can click the "OK" button to generate your UV Pass maps. The images are rendered to the same folder as your original PTGui .pts file.

Script GUI Controls:

The "PTGui Project File" text field and file browser button allow you to select a PTGui .pts file from your hard disk. This is the file that will be used to generate the UV pass maps in PTGui Pro.

The "Projection" menu item allows you to switch the panoramic format that will be output by PTGui when the UV Pass maps are generated. This will automatically override the default panoramic image projection that is defined in the .pts file. The menu options are "Circular Fisheye", Cylindrical", "Equirectangular", "Rectilinear", and "Stereographic".

The "Horizontal FOV" control allows you to set the field of view value for the panoramic output. The Horizontal FOV value combined with the "Pano Width" setting are the primary controls for adjusting the field of view of the generated panorama. 

Note: The vertical FOV value (and therefore the panorama's aspect ratio) is controlled by adjusting the "Pano Height" setting in relation to the current "Pano Width" value. To get a 2:1 aspect ratio 360x180 degree LatLong output for example, you could have the Horizontal FOV set to 360, and the Pano Width set to 3840, and the Pano Height set to 1920.

The "Pano Width" control is used to define the horizontal width of the final PTGui rendered panoramic output.

The "Pano Height" control is used to define the vertical width of the final PTGui rendered panoramic output. This control also adjusts the aspect ratio of the rendered field of view for the panorama.

The "Pano Format" control allows you to customize the image format used by PTGui Pro to render out the 16 bit per channel integer format UV Pass map image. The menu options are "TIFF", "Photoshop PSD", and "Photoshop PSB".

The "UV Pass Width" control allows you to specify the horizontal resolution of the base UV map rectangular gradient image that is fed into PTGui in place of the original multi-camera panoramic rig images.

The "UV Pass Height" control allows you to specify the vertical resolution of the base UV map rectangular gradient image that is fed into PTGui in place of the original multi-camera panoramic rig images.

Note: The UV Pass template image should ideally have the "UV Pass Width" and "UV Pass Height" settings adjusted to preserve the same aspect ratio as your original photos, but can be scaled larger by a factor of 2x, 3x, 4x, etc... if you need to preserve the maximum detail possible during the uv remapping stage.

The "Image Format" control allows you to customize the image format used by UV map rectangular gradient image when the 16 bit per channel integer format image is generated. The menu options are "TIFF" and "PNG".

The "Compression" control allows you to choose if you want to save the UV Pass images with no compression, the RLE/Packbits compression format, or the LZW compression format. Generally speaking, the LZW option works the best at shrinking the file size while still preserving the image detail. The menu options are "None", "RLE", and "LZW". Note: The PSD image format only supports the None and RLE compression modes.

The "Include Masks" checkbox control allows you to enable or disable the custom PTGui masking that is applied to the imagery. Removing the masking makes it possible to resize the input imagery connected to a PTGui file.

The "Oversample the UV Pass Map" checkbox control allows you to quickly adjust the rendered image resolution on the UV Pass rectangular gradient image. When the checkbox is enabled the UV Pass rectangular gradient image will be rendered at 2x the specified "UV Pass Width" and "UV Pass Height" resolution.

The "Start View Numbering on 1" control allows you to adjust the camera view numbering of the PTGui rendered UV Pass map. If the checkbox is enabled the starting camera vis number will be "1". If the checkbox is disabled the starting view number will be "0".

The "Batch Render in PTGui" checkbox control lets you decide how the .pts file is processed after it is edited and updated by the "Generate UV Pass in PTGui" script. If the checkbox is enabled then the .pts script will be rendered automatically in PTGui using a batch rendering command and the generated images will be automatically renamed. If the checkbox is disabled then the .pts file will be loaded visually in the PTGui program where you can further adjust the settings before you manually launch a panoramic rendering.

The "OK" button will start processing the PTGui Project File that was specified in the script GUI and generate a new copy of the .pts file named `<project name>_uvpass.pts`. This file is saved to the same folder as the original .pts file.

The "Cancel" button will close the script GUI and stop the script.



----------------------------------------------------------------------------

Currently Disabled GUI control:

The "Skip Batch Alignment" checkbox control allows you to disable the PTGui option for running the alignment command when a batch rendering is done. This is useful if you have only one source image loaded in the PTGui .pts file and are attempting to render a UV Pass map that performs a basic panoramic remapping operation without any control points present in the image.

--]]--

-- --------------------------------------------------------
-- --------------------------------------------------------
-- --------------------------------------------------------

printStatus = true

-- Track if the image was found
local err = false

-- Global variable to track how many images were found in the PTGui project file
totalFrames = 0

-- Find out if we are running Fusion 6, 7, or 8
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


-- Open the PTGui .pts file and update the control point locations based upon the UV pass map image resolution vs the original coordinates
-- Example: controlPointRegexFile('/panorama.pts', 1920, 1080)
function controlPointRegexFile(inFilepath, imageWidth, imageHeight)
	-- Note: The control point line entries "n1" and "N2" are the values for the source and destination images that the x/y and X/Y control points are referring to on a line like this: c n1 N2 x1919 y1 X3839 Y1 t0
	
	-- Trimmed pts filename without the directory path
	ptsJustFilename = eyeon.getfilename(inFilepath)
	
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	os.execute('mkdir "' .. outputDirectory ..'"')
	
	-- Save a copy of the .pts file being edited in the $TEMP/KartaVR/ folder
	tempFile = outputDirectory .. ptsJustFilename .. '.temp'
	-- print('[Temp File] ' .. tempFile)
	
	-- Open up the file pointer for the output textfile
	outFile, err = io.open(tempFile,'w')
	if err then 
		print('[Error Opening File for Writing]')
		return
	end

	-- #-imgfile 2048 1360 "input-01.0000.JPG"
	searchString = '#%-imgfile%s.*"'
	resolution = ''
	
	-- Scan through the input textfile line by line
	imageCounter = 0
	lineCounter = 0
	for oneLine in io.lines(inFilepath) do
		-- Check if we have found a match with the searchString
		if oneLine:match(searchString) then
			-- Track the number of edits done
			imageCounter = imageCounter + 1
			
			resolution = string.match(oneLine, ' %d+ %d+', 9)
			if resolution ~= nil then
				print('[Image ' ..imageCounter .. ' Resolution] ' .. resolution)
				-- [Image 1 Resolution] 2048 1360
			end
		end
	end
	
	-- Track the resolution of the last image found in the PTGui file for the control point scaling effect
	if resolution ~= nil then
		print('[Last Image Resolution] ' .. resolution)
		
		-- Extract the width and height values into a table
		res = {}
		resolution:gsub('%d+', function(i) table.insert(res, i) end)
		
		-- List what we got in the table
		-- dump(res)
		
		sourceWidth = res[1]
		sourceHeight = res[2]
		print('[Extracted Resolution] ' .. sourceWidth .. 'x' .. sourceHeight)
		
		-- 3840 / 1920 = 2
		xScaleFactor = imageWidth / sourceWidth
		yScaleFactor = imageHeight / sourceHeight
		print('[Scale X] ' .. xScaleFactor .. ' [Scale Y] ' .. yScaleFactor)
	else
		print('[No images found in PTS File]')
		return 0
	end
	
	-- -------------------------------------
	-- Process the control points list for the resized image resolution:
	-- Example: c n1 N2 x1914 y5 X1917 Y2 t0
	searchString = 'c n'
	
	-- Scan through the input textfile line by line
	controlPointCounter = 0
	lineCounter = 0
	for oneLine in io.lines(inFilepath) do
		
 -- Check if we have found a match with the searchString
		if oneLine:match(searchString) then
			-- Track the number of edits done
			controlPointCounter = controlPointCounter + 1
			
			-- print('[Match ' .. counter .. '] ' .. oneLine)
			-- Example: [Match 4] c n1 N2 x6 y1073 X6 Y1072 t0
			
			-- Extract the control point values into a table
			controlPoints = {}
			oneLine:gsub('%w+', function(i) table.insert(controlPoints, i) end)
			
			if controlPoints ~= nil then
				-- List what we got in the table
				-- dump(controlPoints)
				--table: 0x037dc3c0
				--	1 = c
				--	2 = n1
				--	3 = N2
				--	4 = x6
				--	5 = y1073
				--	6 = X6
				--	7 = Y1072
				--	8 = t0
				
				-- Extract the leading letters (X, y, X, y) from the table entries to make it possible to do the scaling math on the entries
				for i=4,7,1 do
					controlPoints[i] = string.sub(controlPoints[i], 2)
				end
				
				-- Transform just the control point X & Y locations in the table entries
				
				-- Transformed x point
				controlPoints[4] = 'x' .. math.ceil(controlPoints[4] * xScaleFactor)
				-- Transformed y point
				controlPoints[5] = 'y' .. math.ceil(controlPoints[5] * yScaleFactor)
				
				-- Transformed X point
				controlPoints[6] = 'X' .. math.ceil(controlPoints[6] * xScaleFactor)
				-- Transformed Y point
				controlPoints[7] = 'Y' .. math.ceil(controlPoints[7] * yScaleFactor)
				
				-- List what is in the current table
				-- dump(controlPoints)
				
				-- Rebuild the current line string
				oneNewLine = controlPoints[1] .. ' '
				for i=2,8,1 do
					oneNewLine = oneNewLine .. controlPoints[i] .. ' '
				end
				
				print('[Src CP ' .. controlPointCounter .. '] ' .. oneLine .. ' [Dest CP ' .. controlPointCounter .. '] ' .. oneNewLine .. '\n')
				
				-- Push the updated control point entry back into the input line variable
				oneLine = oneNewLine
			end
		end
		
		-- Track the progress through the file
		lineCounter = lineCounter + 1
		-- print('[' .. lineCounter .. '] ' .. oneLine)
		
		-- Write the line entry to the output file
		if platform == 'Windows' then
			-- Add a newline character
			outFile:write(oneLine,'\n')
		else
			-- Mac and Linux
			outFile:write(oneLine,'\n')
			
			-- Skip adding the newline character
			-- outFile:write(oneLine)
		end
	end
	
	-- print('[End of File] ' .. lineCounter)
	
	-- Close the file pointer on our input and output textfiles
	outFile:close()
	
	print('[Copy PTS File] [From] ' .. tempFile .. ' [To] ' .. inFilepath)
	
	-- Check if Fusion Standalone or the Resolve Fusion page is active
	host = fusion:MapPath('Fusion:/')
	if string.lower(host):match('resolve') then
		hostOS = 'Resolve'
	
		if platform == 'Windows' then
			command = 'copy /Y "' .. tempFile .. '" "' .. inFilepath .. '" '
		else
			-- Mac / Linux
			command = 'cp "' .. tempFile .. '" "' .. inFilepath .. '" '
		end
	
		print('[Copy PTS File Command] ' .. command)
		os.execute(command)
	else
		hostOS = 'Fusion'
	
		-- Copy the temp file back into the orignal .pts document
		-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8/9 "bmd.scriptlib" libraries
		eyeon.copyfile(tempFile, inFilepath)
	end
	
	-- Return a total of how many times a control point string match was found
	return controlPointCounter
end


-- Open a file and perform a regular expressions based find & replace
function regexFile(inFilepath, searchString, replaceString)
	print('[' .. inFilepath .. '] [Find] ' .. searchString .. ' [Replace] ' .. replaceString)
	
	-- Trimmed pts filename without the directory path
	ptsJustFilename = eyeon.getfilename(inFilepath)
	
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	os.execute('mkdir "' .. outputDirectory..'"')
	
	-- Save a copy of the .pts file being edited in the $TEMP/KartaVR/ folder
	tempFile = outputDirectory .. ptsJustFilename .. '.temp'
	-- print('[Temp File] ' .. tempFile)
	
	-- Open up the file pointer for the output textfile
	outFile, err = io.open(tempFile,'w')
	if err then 
		print('[Error Opening File for Writing]')
		return
	end
	
	-- Scan through the input textfile line by line
	counter = 0
	lineCounter = 0
	for oneLine in io.lines(inFilepath) do
		-- Check if we have found a match with the searchString
		if oneLine:match(searchString) then
			-- Track the number of edits done
			counter = counter + 1
			
			-- Perform the regular expressions based line edit
			oneLine = oneLine:gsub(searchString, replaceString)
			
			-- Debug print out the line number and text we are editing
			-- print('[' .. counter .. '][Matched] ' .. oneLine .. ' [Search] ' .. searchString .. ' [Replace] ' .. replaceString)
		end
		
		-- Track the progress through the file
		lineCounter = lineCounter + 1
		-- print('[' .. lineCounter .. '] ' .. oneLine)
	
		-- Write the line entry to the output file
		if platform == 'Windows' then
			-- Add a newline character
			outFile:write(oneLine,'\n')
		else
			-- Mac and Linux
			outFile:write(oneLine,'\n')
			
			-- Skip adding the newline character
			-- outFile:write(oneLine)
		end
	end
	
	-- print('[End of File] ' .. lineCounter)
	-- Close the file pointer on our input and output textfiles
	outFile:close()
	
	print('[Copy PTS File] [From] ' .. tempFile .. ' [To] ' .. inFilepath)
	
	-- Check if Fusion Standalone or the Resolve Fusion page is active
	host = fusion:MapPath('Fusion:/')
	if string.lower(host):match('resolve') then
		hostOS = 'Resolve'
	
		if platform == 'Windows' then
			command = 'copy /Y "' .. tempFile .. '" "' .. inFilepath .. '" '
		else
			-- Mac / Linux
			command = 'cp "' .. tempFile .. '" "' .. inFilepath .. '" '
		end
	
		print('[Copy PTS File Command] ' .. command)
		os.execute(command)
	else
		hostOS = 'Fusion'
	
		-- Copy the temp file back into the orignal .pts document
		-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8/9 "bmd.scriptlib" libraries
		eyeon.copyfile(tempFile, inFilepath)
	end
	
	-- Return a total of how many times a string match was found
	return counter
 end


-- Use Imagemagick to create the base UV Map template image
function createImagemagickUVMapTemplate(imageWidth, imageHeight, oversampleMap, imageFormat, compress)
	command = nil
	
	-- Check if oversampling is enabled
	if oversampleMap == 1 then
		imageWidth = imageWidth * 2
		imageHeight = imageHeight * 2
	end
	
	imageFormatExt = ''
	if imageFormat == 0 then
		imageFormatExt = '.tif'
	elseif imageFormat == 1 then
		imageFormatExt = '.png'
	-- elseif imageFormat == 2 then
	--	imageFormatExt = '.psd'
	else
		-- Fallback mode if there are a wrong number of items in the imageFormat dialog field
		imageFormatExt = '.tif'
	end
	
	-- Choose if the uv pass map template gradient image name is starting on frame "0000" or frame "0001"
	-- frameNumber = ''
	--if frameOne == 0 then
	frameNumber = '.0000'
	--else
	-- frameNumber = '.0001'
	--end
	
	-- Bits Per Channel
	colorDepth = ' -depth 16 -type TrueColorMatte '

	-- Image Compression Settings
	compressionMode = ''
	if compress == 0 then
		-- compressionMode = ''
		-- compressionMode = ' +compress '
		compressionMode = ' -compress NONE '
	elseif compress == 1 then
		-- RLE is known as the PackBits codec in TIFF images
		compressionMode = ' -compress RLE '
	elseif compress == 2 then
		compressionMode = ' -compress LZW '
	end
	
	-- Image DPI Setting
	dpi = ' -density 72 -units pixelsperinch '
	
	-- Parenthesis
	openParen = ''
	closeParen = ''
	if platform == 'Windows' then
		openParen = ' ( '
		closeParen = ' ) '
	elseif platform == 'Mac' then
		openParen = ' \\( '
		closeParen = ' \\) '
	elseif platform == 'Linux' then
		openParen = ' \\( '
		closeParen = ' \\) '
	else
		openParen = ' \\( '
		closeParen = ' \\) '
	end
	
	-- The rendered UV Pass image name (Example: uvpass_1920x1080.0001.tif)
	outputFilename = 'uvpass_' .. imageWidth .. 'x' .. imageHeight .. frameNumber .. imageFormatExt
	-- outputFilename = 'uvpass_' .. imageWidth .. 'x' .. imageHeight .. imageFormatExt
	
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	os.execute('mkdir "' .. outputDirectory..'"')
	
	-- Redirect the output from the terminal to a log file
	outputLog = outputDirectory .. 'imagemagickUVPassOutputLog.txt'
	logCommand = ''
	if platform == 'Windows' then
		logCommand = ' ' .. '2>&1 | "' .. app:MapPath('Reactor:/Deploy/Bin/wintee/bin/wtee.exe') .. '" -a' .. ' "' .. outputLog.. '" '
	elseif platform == 'Mac' then
		logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
	elseif platform == 'Linux' then
		logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
	end
	
	-- The final output filepath for the generated UV Pass image
	localFilepath = outputDirectory .. outputFilename
	print('[UV Pass Template Image] ' .. localFilepath)
	
	-- Generate a red / horizontal axis gradient channel
	imagemagickCommandRed = openParen .. openParen .. colorDepth .. ' -size ' .. imageHeight .. 'x' .. imageWidth .. ' gradient:red-black ' .. closeParen .. ' -rotate 90 ' .. closeParen .. ' ' 
	
	-- Generate a green / vertical axis gradient channel
	imagemagickCommandGreen = openParen .. colorDepth .. ' -size ' .. imageWidth .. 'x' .. imageHeight .. ' gradient:white-black ' .. closeParen .. ' ' 
	
	-- Merge the red & green gradient channel UV pass images together
	imagemagickCommand = imagemagickCommandRed .. imagemagickCommandGreen .. ' -compose CopyGreen -composite ' .. compressionMode .. dpi .. ' "' .. localFilepath .. '" ' .. logCommand
	
	-- Open Imagemagick
	if platform == 'Windows' then
		-- Running on Windows
		defaultImagemagickProgram = app:MapPath('Reactor:/Deploy/Bin/imagemagick/bin/imconvert.exe')
		imagemagickProgram = getPreferenceData('KartaVR.SendMedia.ImagemagickFile', defaultImagemagickProgram, printStatus)
		command = 'start "" "' .. imagemagickProgram .. '" ' .. imagemagickCommand
		
		print('[Imagemagick Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
			-- ****** The Default KartaVR "Cactus Lab" provided ImageMagick tool should be enabled by default:
			defaultImagemagickProgram = '/opt/ImageMagick/bin/convert'
			
			-- Mac Ports Compiled/Official site downloaded ImageMagick:
			-- defaultImagemagickProgram = '/opt/local/bin/convert'
			
			-- Manual compiled ImageMagick:
			-- defaultImagemagickProgram = '/usr/local/bin/convert'
		
		imagemagickProgram = string.gsub(comp:MapPath(getPreferenceData('KartaVR.SendMedia.ImagemagickFile', defaultImagemagickProgram, printStatus)), '[/]$', '')
		command = '"' .. imagemagickProgram .. ' ' .. imagemagickCommand
		
		print('[Imagemagick Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		defaultImagemagickProgram = '/usr/bin/convert'
		
		imagemagickProgram =  .. getPreferenceData('KartaVR.SendMedia.ImagemagickFile', defaultImagemagickProgram, printStatus)
		command = '"' .. imagemagickProgram .. '" ' .. imagemagickCommand
		
		print('[Imagemagick Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
	
	return localFilepath
end


-- Edit a copy of the PTGui file and turn it into a UV pass map tuned version
function editPTGuiProjectFile(ptguiFile, img, imageWidth, imageHeight, mask, oversampleMap, imageFormat, compress, panoWidth, panoHeight, panoImageFormat, panoHorizontalFOV, batchProcess, skipBatchAlign)

	-- Newly edited .pts filename
	pts = eyeon.trimExtension(ptguiFile) .. '_uvpass.pts'
	
	-- .pts file directory
	ptsDir = dirname(ptguiFile)
	
	-- Trimmed img filename without the directory path
	imgJustFilename = eyeon.getfilename(img)
	
	-- Copied img filename with the .pts directory path added
	imgInPtsFolder = ptsDir .. imgJustFilename
	
	-- Check if the oversampling image resolution checkbox was enabled in the dialog.
	if oversampleMap == 1 then
		imageWidth = imageWidth * 2
		imageHeight = imageHeight * 2
	end
	
	-- Save a copy of the UV pass edited PTGui .pts file
	if platform == 'Windows' then
		-- Running on Windows
		
		
		-- Check if Fusion Standalone or the Resolve Fusion page is active
		host = fusion:MapPath('Fusion:/')
		if string.lower(host):match('resolve') then
			hostOS = 'Resolve'
			
			-- Make a copy of the .pts file
			print('[Copy PTS File] [From] ' .. ptguiFile .. ' [To] ' .. pts)
			command = 'copy /Y "' .. ptguiFile .. '" "' .. pts .. '" '
			print('[Copy PTS File Command] ', command)
			os.execute(command)
			
			-- Copy the uv pass map template image to the same folder as the pts file
			print('[Copy UV Pass Image] [From]' .. img .. ' [To] ' .. imgInPtsFolder)
			command = 'copy /Y "' .. img .. '" "' .. imgInPtsFolder .. '" '
			print('[Copy UV Pass Image Command] ', command)
			os.execute(command) 
		else
			hostOS = 'Fusion'
			
			-- Make a copy of the .pts file
			print('[Copy PTS File] [From] ' .. ptguiFile .. ' [To] ' .. pts)
			-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8 "bmd.scriptlib" libraries
			eyeon.copyfile(ptguiFile, pts)
			
			-- Copy the uv pass map template image to the same folder as the pts file
			print('[Copy UV Pass Image] [From]' .. img .. ' [To] ' .. imgInPtsFolder)
			-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8/9 "bmd.scriptlib" libraries
			eyeon.copyfile(img, imgInPtsFolder)
		end
	elseif platform == 'Mac' then
		-- Running on Mac
		
		
		-- Check if Fusion Standalone or the Resolve Fusion page is active
		host = fusion:MapPath('Fusion:/')
		if string.lower(host):match('resolve') then
			hostOS = 'Resolve'
			
			-- Make a copy of the .pts file
			print('[Copy PTS File] [From] ' .. ptguiFile .. ' [To] ' .. pts)
			command = 'cp "' .. ptguiFile .. '" "' .. pts .. '" '
			print('[Copy PTS File Command] ', command)
			os.execute(command)
			
			-- Copy the uv pass map template image to the same folder as the pts file
			print('[Copy UV Pass Image] [From] ' .. img .. ' [To] ' .. imgInPtsFolder)
			command = 'cp "' .. img .. '" "' .. imgInPtsFolder .. '" '
			print('[Copy UV Pass Image Command] ', command)
			os.execute(command)
		else
			hostOS = 'Fusion'
			
			-- Make a copy of the .pts file
			print('[Copy PTS File] [From] ' .. ptguiFile .. ' [To] ' .. pts)
			-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8 "bmd.scriptlib" libraries
			eyeon.copyfile(ptguiFile, pts)
			
			-- Copy the uv pass map template image to the same folder as the pts file
			print('[Copy UV Pass Image] [From] ' .. img .. ' [To] ' .. imgInPtsFolder)
			-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8 "bmd.scriptlib" libraries
			eyeon.copyfile(img, imgInPtsFolder)
		end

	elseif platform == 'Linux' then
		-- Running on Linux
		print('PTGui is not available for Linux yet.')
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
	
	print('[Editing PTGui Project UV Pass File] ' .. pts)
	
	-- ----------------------------------------------------
	-- ----------------------------------------------------
	
	-- Open the PTS file and perform a regular expressions based find & replace
	-- # PTGui Output Settings
	
	-- PTGui panoramic image format
	panoImageFormatMagick = ''
	panoImageFrameExt = ''
	if panoImageFormat == 0 then
		-- TIFF
		panoImageFormatMagick = 'TIFF_m'
		panoImageFrameExt = 'tif'
	elseif panoImageFormat == 1 then
		-- PSD
		panoImageFormatMagick = 'PSD_nomask'
		panoImageFrameExt = 'psd'
	elseif panoImageFormat == 2 then
		-- PSB (Photoshop Large Document)
		panoImageFormatMagick = 'PSB_nomask'
		panoImageFrameExt = 'psb'
	else
		-- Fallback mode if there are a wrong number of items in the Pano Format dialog field
		panoImageFormatMagick = 'TIFF_m'
		panoImageFrameExt = 'tif'
	end
	
	ptguiHorizontalFOV = ''

	-- PTGui panoramic image projection
	ptguiPanoProjection = ''
	if panoProjection == 0 then
		-- Circular Fisheye
		ptguiPanoProjection = 'fcircular'
		
		-- Limit Max Horizontal FOV
		if panoHorizontalFOV > 360 then
			panoHorizontalFOV = 360
		end
		
		ptguiHorizontalFOV = 'v' .. panoHorizontalFOV
	elseif ptguiPanoProjection == 1 then
		-- Cylindrical
		ptguiPanoProjection = 'f1'
		
		-- Limit Max Horizontal FOV
		if panoHorizontalFOV > 360 then
			panoHorizontalFOV = 360
		end
		
		ptguiHorizontalFOV = 'v' .. panoHorizontalFOV
	elseif panoProjection == 2 then
		-- Equirectangular
		ptguiPanoProjection = 'f2'
		
		-- Limit Max Horizontal FOV
		if panoHorizontalFOV > 360 then
			panoHorizontalFOV = 360
		end
		
		ptguiHorizontalFOV = 'v' .. panoHorizontalFOV
	elseif panoProjection == 3 then
		-- Rectilinear
		ptguiPanoProjection = 'f0'
		
		-- Limit Max Horizontal FOV
		if panoHorizontalFOV > 160 then
			panoHorizontalFOV = 160
		end
		
		ptguiHorizontalFOV = 'v' .. panoHorizontalFOV
	elseif panoProjection == 4 then
		-- Stereographic
		ptguiPanoProjection = 'fstereographic' 
		
		-- Limit Max Horizontal FOV
		if panoHorizontalFOV > 320 then
			panoHorizontalFOV = 320
		end
		
		ptguiHorizontalFOV = 'v' .. panoHorizontalFOV
	else
		-- Equirectangular Fallback mode if there are a wrong number of items in the Pano Projection dialog field
		ptguiPanoProjection = 'f2'
		
		-- Limit Max Horizontal FOV
		if panoHorizontalFOV > 360 then
			panoHorizontalFOV = 360
		end
		
		ptguiHorizontalFOV = 'v' .. panoHorizontalFOV
	end
	
	-- p w3840 h1920 f2 v360 u0 n"TIFF_m"
	searchString = 'p w.*'
	replaceString ='p w' .. panoWidth ..' h' .. panoHeight ..' ' .. ptguiPanoProjection .. ' ' .. ptguiHorizontalFOV .. ' u0 n"' .. panoImageFormatMagick .. '"'
	regexFile(pts, searchString, replaceString)
	
	-- #-tiffparameters 16bit lzw alpha_assoc
	searchString = '#%-tiffparameters%s.*'
	
	-- Image Compression Settings
	if compress == 0 then
		-- None
		replaceString = '#-tiffparameters 16bit none alpha_assoc'
	elseif compress == 1 then
		-- RLE is known as the PackBits codec in TIFF images
		replaceString = '#-tiffparameters 16bit packbits alpha_assoc'
	elseif compress == 2 then
		-- LZW
		replaceString = '#-tiffparameters 16bit lzw alpha_assoc'
	end
	
	regexFile(pts, searchString, replaceString)
	
	-- #-psdparameters 16bit packbits layered
	searchString = '#%-psdparameters%s.*'
	
	-- Image Compression Settings
	if compress == 0 then
		-- None
		replaceString = '#-psdparameters 16bit none layered'
	elseif compress == 1 then
		-- RLE is known as the PackBits codec in PSD images
		replaceString = '#-psdparameters 16bit packbits layered'
	elseif compress == 2 then
		-- LZW (not available so fall back to using RLE/packbits)
		replaceString = '#-psdparameters 16bit packbits layered'
	end
	
	regexFile(pts, searchString, replaceString)
	
	-- Check if the Include Masks checkbox was enabled in the dialog.
	if mask == 0 then
		-- Removing the line #-sourcemask clears out any custom PTGui masking. This makes it possible to resize the input imagery connected to a PTGui file that had masking information present in the document.
		searchString = '#%-sourcemask.*'
		replaceString = ''
		regexFile(pts, searchString, replaceString)
	end
	
	-- Removing the line #-simpleproject turns a basic tab pts file into an advanced tab project
	searchString = '#%-simpleproject.*'
	replaceString = ''
	regexFile(pts, searchString, replaceString)
	
	-- # ptGui project file
	searchString = '# ptGui project file'
	replaceString ='# ptGui project file\n# Generated by the KartaVR'
	regexFile(pts, searchString, replaceString)
	
	-- The final rendered panoramic image name #-outputfile /panorama_uvpass..tif
	searchString = '#%-outputfile.*'
	
	-- Note: By adding two dots to the end of the file name like "..tif" this will cause the PTGui frame numbering system to output a set of images in the foramt <name>.####.<ext> like:
	-- /panorama_uvpass.0000.tif /panorama_uvpass.0001.tif	/panorama_uvpass.0002.tif	 /panorama_uvpass.0003.tif
	replaceString ='#-outputfile ' ..eyeon.trimExtension(ptguiFile) .. '_uvpass..' .. panoImageFrameExt
	regexFile(pts, searchString, replaceString)
	
	-- #-pathseparator /
	-- Note: Windows uses "\" for path separators and Mac uses "/" for path separators
	if platform == 'Windows' then
		searchString = '#%-pathseparator%s.*'
		replaceString ='#-pathseparator \\'
		regexFile(pts, searchString, replaceString)
	else
		searchString = '#%-pathseparator%s.*'
		replaceString ='#-pathseparator /'
		regexFile(pts, searchString, replaceString)
	end
	
	-- Decide if the PTGui batch rendering needs to have image alignment applied or not
	-- This "skipBatchAlign" mode has to be disabled in the GUI if you have only one input image and therefore no control points to align in the PTS file
	-- #-batchsettings_align 0
	if skipBatchAlign == 1 then
		-- Turn off control point alignment during at PTGui batch process
		searchString = '#%-batchsettings_align%s.*'
		replaceString ='#-batchsettings_align 0'
		regexFile(pts, searchString, replaceString)
	else
		-- Turn on control point alignment during at PTGui batch process
		searchString = '#%-batchsettings_align%s.*'
		replaceString ='#-batchsettings_align 1'
		regexFile(pts, searchString, replaceString)
	end
	
	-- #-hdrmethod truehdr
	searchString = '#%-hdrmethod%s%g*'
	replaceString = '#-hdrmethod truehdr'
	regexFile(pts, searchString, replaceString)
	
	-- #-exrparameters withalpha
	searchString = '#%-exrparameters%s%g*'
	replaceString = '#-exrparameters withalpha'
	regexFile(pts, searchString, replaceString)
	
	-- #-hdrenabled
	searchString = '#%-hdroutputhdrblended%s%g*'
	-- replaceString = '#-hdrenabled'
	-- Clear this entry out
	replaceString = ''
	regexFile(pts, searchString, replaceString)
	
	-- #-hdroutputhdrlayers
	replaceString = '#-hdroutputhdrlayers'
	-- searchString = '#%-hdroutputtonemapped'
	replaceString = ''
	-- replaceString = '#-hdroutputhdrlayers'
	regexFile(pts, searchString, replaceString)
	
	-- #-hdrfileformat openexr
	searchString = '#%-hdrfileformat%s%g*'
	replaceString = '#-hdrfileformat openexr'
	regexFile(pts, searchString, replaceString)
	
	-- #-hdrmethod truehdr
	searchString = '#%-hdrmethod%s%g*'
	replaceString = '#-hdrmethod truehdr'
	regexFile(pts, searchString, replaceString)
	
	-- #-tonemapv2settings truehdr
	searchString = '#%-tonemapv2settings%s.*'
	-- Todo - Test the alternate color setting:
	-- replaceString = '#-tonemapv2settings PTGTM 1 0.7058 0 0 0 1 2 0 0 0'
	-- replaceString = '#-tonemapv2settings PTGTM 1 0.5 20 20 0 0 2 1 0.15 0'
	replaceString = '#-tonemapv2settings PTGTM 1 0.5 0 0 0 1 2 0 0 0'
	regexFile(pts, searchString, replaceString)
	
	-- #-vignettingparams
	searchString = '#%-vignettingparams%s.*'
	replaceString = '#-vignettingparams'
	regexFile(pts, searchString, replaceString)
	
	-- #-wbexposure 0 0 0
	searchString = '#%-wbexposure%s.*'
	replaceString = '#-wbexposure 0 0 0'
	regexFile(pts, searchString, replaceString)
	
	-- #-pmoptexposuremode disabled
	searchString = '#%-pmoptexposuremode%s%g*'
	replaceString = '#-pmoptexposuremode disabled'
	regexFile(pts, searchString, replaceString)
	
	-- #-pmoptvignettingmode disabled
	searchString = '#%-pmoptvignettingmode%s%g*'
	replaceString = '#-pmoptvignettingmode disabled'
	regexFile(pts, searchString, replaceString)
	
	-- #-pmoptcameracurvemode default
	searchString = '#%-pmoptcameracurvemode%s%g*'
	replaceString = '#-pmoptcameracurvemode default'
	regexFile(pts, searchString, replaceString)
	
	-- #-interpolator nearestneighbour
	searchString = '#%-interpolator%s%g*'
	replaceString = '#-interpolator nearestneighbour'
	regexFile(pts, searchString, replaceString)
	
	-- -------------------------------------------------
	-- -------------------------------------------------
	
	-- PTGui Image / Control Point Entry Lines
	-- Open the PTGui .pts file and update the control point locations based upon the UV pass map image resolution vs the original coordinates
	controlPointRegexFile(pts, imageWidth, imageHeight)
	
	-- Generate the updated image entry line
	-- -------------------------------------
	-- #-imgfile 4096 2,720 "uvpass_3840x1920.0000.tif"
	searchString = '#%-imgfile%s.*"'
	replaceString = '#-imgfile ' .. imageWidth .. ' ' .. imageHeight ..' "' .. imgJustFilename .. '"'
	
	-- Update the global variable "totalFrames" to track the total number of images found in the PTS file
	totalFrames = regexFile(pts, searchString, replaceString)
	print('[Total Images Found in PTS File] ' .. totalFrames)
	
	-- #-metadata -1 0.001 800 0000-00-00T00:00:00 4*32 0 -1 -1 -1 * * * linear -1 * T * 13100773143573272
	searchString = '#%-metadata%s.*'
	replaceString = '#-metadata -1 0.001 800 0000-00-00T00:00:00 4*32 0 -1 -1 -1 * * * linear -1 * T * 13100773143573272'
	regexFile(pts, searchString, replaceString)
	
	-- #-exposureparams 0 0 0 0
	searchString = '#%-exposureparams%s.*'
	replaceString = '#-exposureparams 0 0 0 0'
	regexFile(pts, searchString, replaceString)
	
	-- -------------------------------------------------
	-- -------------------------------------------------
	
	-- Todo: Check the PTS Control Points X and Y coordinates and see if it is a required step to adjust them to match the new image width and height dimensions
	-- # Control points:
	-- c n2 N3 x1297 y632 X1637 Y179 t0
	
	print('[Generated PTGui Project File] ' .. pts)
	return pts
end


-- Open a file in PTGui for editing
function ptguiStitcher(ptsFileName, batchProcess)
	-- Viewer Variables
	viewerProgram = nil
	command = nil
	
	-- Open the Viewer tool
	if platform == 'Windows' then
		-- Running on Windows
		defaultViewerProgram = 'C:\\Program Files\\PTGui\\PTGui.exe'
		viewerProgram = comp:MapPath(getPreferenceData('KartaVR.SendMedia.PTGuiFile', defaultViewerProgram, printStatus))
		
		command = ''
		-- Should PTGui be run as a batch render process
		if batchProcess == 1 then
			-- Batch render process the pts file with no gui shown
			command = 'start "" "' .. viewerProgram .. '" -batch -x "' .. ptsFileName .. '"'
		else
			-- Open the pts file in PTGui and show the gui
			command = 'start "" "' .. viewerProgram .. '" "' .. ptsFileName .. '"'
		end
		
		print('[PTGui Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		defaultViewerProgram = '/Applications/PTGui Pro.app'
		viewerProgram = string.gsub(comp:MapPath(getPreferenceData('KartaVR.SendMedia.PTGuiFile', defaultViewerProgram, printStatus)), '[/]$', '')
		
		command = ''
		-- Should PTGui be run as a batch render process
		if batchProcess == 1 then
			-- Batch render process the pts file with no gui shown
			command = 'open -a "' .. viewerProgram .. '" -n -W --args -batch -x "' .. ptsFileName .. '"'
		else
			-- Open the pts file in PTGui and show the gui
			command = 'open -a "' .. viewerProgram .. '" --args "' .. ptsFileName .. '"'
		end
		
		print('[PTGui Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		print('PTGui is not available for Linux yet.')
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


-- Play a KartaVR "audio" folder based wave audio file using a native Mac/Windows/Linux method:
-- Example: PlayWaveAudio('sound.wav')
-- or if you want to see debugging text use:
-- Example: PlayWaveAudio('sound.wav', true)
function PlayWaveAudio(filename, status)
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


-- Rename the batch render generated UV pass images
function renameUVMapImages(ptguiFile, batchProcess, panoImageFormat, startViewNumberingOnOne, startOnFrameOne)
	-- Check if the UV pass images were rendered automatically to disk using the "Batch Render in PTGui" Checkbox in the dialog window
	if batchProcess == 1 then
		print('[Preparing to rename the ' .. totalFrames .. ' PTGui batch rendered UV pass images.]')
		
		-- PTGui panoramic image format
		panoImageFrameExt = ''
		if panoImageFormat == 0 then
			-- TIFF
			panoImageFrameExt = 'tif'
		elseif panoImageFormat == 1 then
			-- PSD
			panoImageFrameExt = 'psd'
		elseif panoImageFormat == 2 then
			-- PSB (Photoshop Large Document)
			panoImageFrameExt = 'psb'
		else
			print('[Renamer Fallingback to default tiff format')
			-- Fallback mode if there are a wrong number of items in the Pano Format dialog field
			panoImageFrameExt = 'tif'
		end
				 
		frame = 0
		-- Rename the images
		while ( frame < totalFrames) do
			-- Add a dummy frame padding group of numbers on the end of the PTGui images to make Fusion happy and not load the images as a single image sequence
			-- Example: Turn the image named "panorama_uvpass.0001.tif" into "panorama_uvpass_0001.0000.tif"
			oldImage = eyeon.trimExtension(ptguiFile) .. '_uvpass.' .. string.format('%04d', frame) .. '.' .. panoImageFrameExt
			
			-- Add the Fusion dummy frame padding to the end of the images
			dummyFrames = '000' .. startOnFrameOne
			newImage = eyeon.trimExtension(ptguiFile) .. '_uvpass_' .. string.format('%04d', frame + startViewNumberingOnOne) .. '.' .. dummyFrames .. '.' .. panoImageFrameExt
			-- newImage = eyeon.trimExtension(ptguiFile) .. '_uvpass_' .. string.format("%04d", frame) .. '.0000.' .. panoImageFrameExt

			-- if platform == 'Windows' then
				-- command = 'copy /Y "' .. oldImage .. '" "' .. newImage .. '" '
				-- -- command = 'move /Y "' .. oldImage .. '" "' .. newImage .. '" '
			-- else
				-- -- Mac / Linux
				-- command = 'cp "' .. oldImage .. '" "' .. newImage .. '" '
			-- end

			-- print('[Copy UV Pass File Command] ' .. command)
			-- os.execute(command)
			-- print('[Rename Image ' .. frame .. '] [From Filename] ' .. oldImage .. ' [To Filename] ' .. newImage)
			
			renameResult = os.rename(oldImage, newImage)
			if renameResult ~= nil then
				print('[Rename Image ' .. frame .. '] [From Filename] ' .. oldImage .. ' [To Filename] ' .. newImage)
			else
				print('[Rename Image failed - Running this script a 2nd time will fix the issue]' .. ' [From Filename] ' .. oldImage .. ' [To Filename] ' .. newImage)
			end
			
			-- Increment to the next frame in the collection of images generated by the PTGui UV Pass individual layer output mode
			frame = frame + 1
		end
		 
		 -- Note: This is the end of the batchProcess == 1 section
	else
		print('[Skipping the image rename task as PTGui batch rendering was disabled.]')
	end
end


-- Play a sound effect
function CompletedSound()
	soundEffect = getPreferenceData('KartaVR.SendMedia.SoundEffect', 1, printStatus)
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
end

-- ------------------------------------
-- Main
-- ------------------------------------

-- Main Code
function Main()
	print('[Generate UV Pass in PTGui]')
	print ('Generate UV Pass in PTGui is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)
	
	-- Check if Fusion is running
	if not fusion then
		print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
	end
	
	-- Lock the comp flow area
	comp:Lock()
	
	-- Show the "Generate UV Pass in PTGui" dialog window
	-- Note: The AskUser dialog settings are covered on page 63 of the Fusion Scripting Guide
	compPath = dirname(comp:GetAttrs().COMPS_FileName)
	compPrefs = comp:GetPrefs('Comp.FrameFormat')
	width = compPrefs.Width
	height = compPrefs.Height
	
	-- Check if the comp hasn't been saved yet and then handle the comp image dimensions being reported as zero
	if width < 2 then
		width = 3840
	end
	
	if height < 2 then
		height = 1920
	end
	
	-- Panorama Width defaults to a 2:1 ratio of height value
	panoHeight = height
	panoWidth = panoHeight * 2
	
	print('[Comp Image Size Defaults] ' .. width .. 'x' .. height)
	
	-- ------------------------------------
	-- Load the comp specific preferences
	-- ------------------------------------
	
	-- Share this preference with the PTGui Project Importer Script
	-- PTGui Project File - use the comp path as the default starting value if the preference doesn't exist yet
	ptguiFile = comp:MapPath(getPreferenceData('KartaVR.PTGuiImporter.File', compPath, printStatus))
	
	-- Image Properties
	imageFormat = getPreferenceData('KartaVR.GenerateUVPass.ImageFormat', 0, printStatus)
	
	width = getPreferenceData('KartaVR.GenerateUVPass.Width', width, printStatus)
	height = getPreferenceData('KartaVR.GenerateUVPass.Height', height, printStatus)
	compress = getPreferenceData('KartaVR.GenerateUVPass.Compression', 2, printStatus)
	mask = getPreferenceData('KartaVR.GenerateUVPass.Mask', 0, printStatus)
	oversample = getPreferenceData('KartaVR.GenerateUVPass.Oversample', 0, printStatus)
	startOnFrameOne = getPreferenceData('KartaVR.GenerateUVPass.StartOnFrameOne', 0, printStatus)
	
	startViewNumberingOnOne = getPreferenceData('KartaVR.GenerateUVPass.StartViewNumberingOnOne', 1, printStatus)
	
	panoImageFormat = getPreferenceData('KartaVR.GenerateUVPass.PanoImageFormat', 0, printStatus)
	panoWidth = getPreferenceData('KartaVR.GenerateUVPass.PanoWidth', panoWidth, printStatus)
	panoHeight = getPreferenceData('KartaVR.GenerateUVPass.PanoHeight', panoHeight, printStatus)
	
	-- Image Projection - Default = 2 (Equirectangular)
	panoProjection = getPreferenceData('KartaVR.GenerateUVPass.PanoProjection', 2, printStatus)
	
	panoHorizontalFOV = getPreferenceData('KartaVR.GenerateUVPass.PanoHorizontalFOV', 360, printStatus)
	
	-- Disable this attribute for now as PTGui can't do any improvements on the featureless UV pass gradient
	-- Possibly it might be a good idea to to a pre-pass alignment and save on a copy of the original .pts first
	--skipBatchAlign = getPreferenceData('KartaVR.GenerateUVPass.SkipBatchAlign', 0, printStatus)
	skipBatchAlign = 1
	
	-- Choose if we are going to run the job in the background or just open the new .pts in PTGui's visual editor
	batchProcess = getPreferenceData('KartaVR.GenerateUVPass.BatchProcess', 1, printStatus)
	
	
	msg = 'This script requires a copy of PTGui Pro to be installed in order to generate the 16 bit per channel UV pass warping image output.'

	-- Image format list
	formatList = {'TIFF', 'PNG'}
	
	-- Note: PSD is not supported as an input format for PTGui
	--formatList = {'TIFF', 'PNG', 'Photoshop PSD'}
	
	-- Image compression list
	compressionList = {'None', 'RLE', 'LZW'}

	-- PTgui panorama image format list
	panoImageFormatList = {'TIFF', 'Photoshop PSD', 'Photoshop PSB'}

	-- PTgui panorama projetion format list
	panoProjectionList = {'Circular Fisheye', 'Cylindrical', 'Equirectangular', 'Rectilinear', 'Stereographic'}

	d = {}
	d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg}
	d[2] = {'File', Name = 'PTGui Project File', 'FileBrowse', Default = ptguiFile}
	d[3] = {'PanoProjection', Name = 'Projection', 'Dropdown', Default = panoProjection, Options = panoProjectionList }
	d[4] = {'PanoHorizontalFOV', Name = 'Horizontal FOV', 'Screw', Default = panoHorizontalFOV, Min = 0, Max = 360} 
	d[5] = {'PanoWidth', Name = 'Pano Width', 'Slider', Default = panoWidth, Integer = true, Min = 1, Max = 16384}
	d[6] = {'PanoHeight', Name = 'Pano Height', 'Slider', Default = panoHeight, Integer = true, Min = 1, Max = 16384}
	d[7] = {'PanoImageFormat', Name = 'Pano Format', 'Dropdown', Default = panoImageFormat, Options = panoImageFormatList }
	d[8] = {'Width', Name = 'UV Pass Width', 'Slider', Default = width, Integer = true, Min = 1, Max = 16384}
	d[9] = {'Height', Name = 'UV Pass Height', 'Slider', Default = height, Integer = true, Min = 1, Max = 16384}
	d[10] = {'ImageFormat', Name = 'Image Format', 'Dropdown', Default = imageFormat, Options = formatList }
	d[11] = {'Compression', Name = 'Compression', 'Dropdown', Default = compress, Options = compressionList }
	d[12] = {'Mask', Name = 'Include Masks', 'Checkbox', Default = mask, NumAcross = 2}
	d[13] = {'Oversample', Name = 'Oversample the UV Pass Map', 'Checkbox', Default = oversample, NumAcross = 2}
	d[14] = {'StartOnFrameOne', Name = 'Start on Frame 1', 'Checkbox', Default = startOnFrameOne, NumAcross = 2}
	d[15] = {'StartViewNumberingOnOne', Name = 'Start View Numbering on 1', 'Checkbox', Default = startViewNumberingOnOne, NumAcross = 2}
	d[16] = {'BatchProcess', Name = 'Batch Render in PTGui', 'Checkbox', Default = batchProcess, NumAcross = 2}
	-- d[16] = {'SkipBatchAlign', Name = 'Skip Batch Alignment', 'Checkbox', Default = skipBatchAlign, NumAcross = 2}
	
	dialog = comp:AskUser('Generate UV Pass in PTGui', d)
	if dialog == nil then
		print('You cancelled the dialog!')
		err = true
		
		-- Unlock the comp flow area
		comp:Unlock()
		
		return
	else
		-- Debug - List the output from the AskUser dialog window
		-- dump(dialog)
		
		-- Share this preference with the PTGui Project Importer Script
		ptguiFile = comp:MapPath(dialog.File)
		setPreferenceData('KartaVR.PTGuiImporter.File', ptguiFile, printStatus)
		
		imageFormat = dialog.ImageFormat
		setPreferenceData('KartaVR.GenerateUVPass.ImageFormat', imageFormat, printStatus)
		
		width = dialog.Width
		setPreferenceData('KartaVR.GenerateUVPass.Width', width, printStatus)
		
		height = dialog.Height
		setPreferenceData('KartaVR.GenerateUVPass.Height', height, printStatus)
		
		compress = dialog.Compression
		setPreferenceData('KartaVR.GenerateUVPass.Compression', compress, printStatus)
		
		mask = dialog.Mask
		setPreferenceData('KartaVR.GenerateUVPass.Mask', mask, printStatus)
		
		oversample = dialog.Oversample
		setPreferenceData('KartaVR.GenerateUVPass.Oversample', oversample, printStatus)
		
		startViewNumberingOnOne = dialog.StartViewNumberingOnOne
		setPreferenceData('KartaVR.GenerateUVPass.StartViewNumberingOnOne', startViewNumberingOnOne, printStatus)
		
		startOnFrameOne = dialog.StartOnFrameOne
		setPreferenceData('KartaVR.GenerateUVPass.StartOnFrameOne', startOnFrameOne, printStatus)
		
		panoImageFormat = dialog.PanoImageFormat
		setPreferenceData('KartaVR.GenerateUVPass.PanoImageFormat', panoImageFormat, printStatus)
		
		panoWidth = dialog.PanoWidth
		setPreferenceData('KartaVR.GenerateUVPass.PanoWidth', panoWidth, printStatus)
		
		panoHeight = dialog.PanoHeight
		setPreferenceData('KartaVR.GenerateUVPass.PanoHeight', panoHeight, printStatus)
		
		panoProjection = dialog.PanoProjection
		setPreferenceData('KartaVR.GenerateUVPass.PanoProjection', panoProjection, printStatus)
		
		panoHorizontalFOV = dialog.PanoHorizontalFOV
		setPreferenceData('KartaVR.GenerateUVPass.PanoHorizontalFOV', panoHorizontalFOV, printStatus)
		
		--skipBatchAlign = dialog.SkipBatchAlign
		setPreferenceData('KartaVR.GenerateUVPass.SkipBatchAlign', skipBatchAlign, printStatus)
		
		batchProcess = dialog.BatchProcess
		setPreferenceData('KartaVR.GenerateUVPass.BatchProcess', batchProcess, printStatus)
		
		print('[UV Pass Size] ' .. width .. 'x' .. height)
		print('[Image Format] ' .. imageFormat)
		print('[Oversample UV Pass] ' .. oversample)
		print('[Start on Frame 1] ' .. startOnFrameOne)
		print('[Start View Numbering on 1] ' .. startViewNumberingOnOne)
		
		print('[Pano Horizontal FOV] ' .. panoHorizontalFOV)
		print('[Pano Projection] ' .. panoProjection)
		print('[Pano Size] ' .. panoWidth .. 'x' .. panoHeight)
		print('[Pano Image Format] ' .. panoImageFormat)
		
		print('[Skip Batch Alignment Stage in PTGui] ' .. skipBatchAlign)
		print('[Batch Render in PTGui] ' .. batchProcess)
	end
	
	-- Todo: Add a sanity check to make sure the PTGui file actually exists on disk
	print('[PTGui Project File] ' .. dialog.File)
	
	-- Check if the PTGui filename ends with the .pts file extension
	searchString = 'pts$'
	if ptguiFile:match(searchString) ~= nil then
	--ptguiFileExtension = eyeon.getextension(ptguiFile)
	--if ptguiFileExtension == 'pts' then
		
		print('[A PTGui project file was selected and it has the .pts file extension.]')
	else
		print('[A PTGui project file was not selected.]')
		
		-- Unlock the comp flow area
		comp:Unlock()
		
		return
	end

	-- Use Imagemagick to create the base UV Map template image
	img = createImagemagickUVMapTemplate(width, height, oversample, imageFormat, compress)
	print('[Generated UV Pass Image] ' .. img) 
	
	-- Edit a copy of the PTGui file and turn it into a UV pass map tuned version
	pts = editPTGuiProjectFile(ptguiFile, img, width, height, mask, oversample, imageFormat, compress, panoWidth, panoHeight, panoImageFormat, panoHorizontalFOV, batchProcess, skipBatchAlign)
	
	-- Open a file in PTGui for editing
	ptguiStitcher(pts, batchProcess)
	
	-- Rename the batch render generated UV pass images
	renameUVMapImages(ptguiFile, batchProcess, panoImageFormat, startViewNumberingOnOne, startOnFrameOne)
	
	-- Report if the Fusion HiQ mode is enabled
	if comp:GetAttrs().COMPB_HiQ == true then
		print('[HiQ] The Fusion high quality mode is enabled so the stitching previews will look crisp.')
	else
		print('[HiQ] The Fusion high quality mode was activated so the stitching previews will look crisp. This was done by turning on the "HiQ" button in the Fusion timeline for crisper previews.')
		comp:SetAttrs{COMPB_HiQ = true}
	end
	
	-- Unlock the comp flow area
	comp:Unlock()
	
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
