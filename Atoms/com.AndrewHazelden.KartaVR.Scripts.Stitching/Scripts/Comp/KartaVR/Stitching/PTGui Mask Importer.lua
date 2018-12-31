--[[--
----------------------------------------------------------------------------
PTGui Mask Importer v4.0 for Fusion - 2018-12-25
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
Overview:

The PTGui Mask Importer script is a module from [KartaVR](http://www.andrewhazelden.com/blog/downloads/kartavr/) that will export and save the .png image format masking data from a PTGui .pts project file.

How to use the Script:

Step 1. Start Fusion and open a new comp. Then run the "Script > KartaVR > Stitching > PTGui Mask Importer" menu item.

Step 2. In the PTGui Mask Importer dialog window you need to select a PTGui .pts file using the "PTGui Project File" text field. After customizing the settings you can click the "OK" button to export each of the masks. The mask images are saved to the same folder as your original PTGui .pts file.

--]]--

-- --------------------------------------------------------
-- --------------------------------------------------------
-- --------------------------------------------------------

-- Display the extra debugging verbosity detail in the console log
-- printStatus = true
printStatus = false

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


-- Check if a directory exists
-- Example: directoryExists('/Users/Andrew/Desktop/')
function directoryExists(mediaDirName)
	if mediaDirName == nil then
		-- print('[Directory Variable is Empty] ', mediaDirName)
		return false
	else
		if fu_major_version >= 8 then
			-- The script is running on Fusion 8+ so we will use the fileexists command
			if eyeon.fileexists(mediaDirName) then
				return true
			else
				-- print('[Directory Missing] ', mediaDirName)
				return false
			end
		else
			-- The script is running on Fusion 6/7 so we will use the direxists command
			if eyeon.direxists(mediaDirName) then
				return true
			else
				-- print('[Directory Missing] ', mediaDirName)
				return false
			end
		end
	end
end


-- Open a folder window up using your desktop file browser
function openDirectory(mediaDirName)
	dir = dirname(mediaDirName)
	
	-- Double check that the folder actually exists before trying to open it
	if directoryExists(dir) == true then
		command = ''
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
	
		-- Fallback native OS copy for Resolve
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
 

-- Extract the Masks
function sourcemaskRegex(ptguiFile, framePadding, startOnFrameOne)
	mask = {}

	-- Newly edited .pts filename with the extension swapped and the directory removed
	ptsName = eyeon.getfilename(eyeon.trimExtension(ptguiFile) .. '_temp.pts')

	-- .pts file directory
	ptsDir = dirname(ptguiFile)
	
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	os.execute('mkdir "' .. outputDirectory ..'"')
	
	-- Save a copy of the .pts file being edited in the $TEMP/KartaVR/ folder
	pts = outputDirectory .. ptsName
	print('[Temp File] ' .. pts)
	
	-- Save a copy of the edited PTGui .pts file
	if platform == 'Windows' then
		-- Running on Windows
		
		print('[Copy PTS File] [From] ' .. ptguiFile .. ' [To] ' .. pts)
		
		-- Make a copy of the .pts file
		-- Check if Fusion Standalone or the Resolve Fusion page is active
		host = fusion:MapPath('Fusion:/')
		if string.lower(host):match('resolve') then
			hostOS = 'Resolve'
			
			command = 'copy /Y "' .. ptguiFile .. '" "' .. pts .. '" '
			print('[Copy PTS File Command] ', command)
			os.execute(command)
		else
			hostOS = 'Fusion'
			
			-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8/9 "bmd.scriptlib" libraries
			eyeon.copyfile(ptguiFile, pts)
		end
	elseif platform == 'Mac' then
		-- Running on Mac
		
		print('[Copy PTS File] [From] ' .. ptguiFile .. ' [To] ' .. pts)
		
		-- Check if Fusion Standalone or the Resolve Fusion page is active
		host = fusion:MapPath('Fusion:/')
		if string.lower(host):match('resolve') then
			hostOS = 'Resolve'
			
			command = 'cp "' .. ptguiFile .. '" "' .. pts .. '" '
			print('[Copy PTS File Command] ', command)
			os.execute(command)
		else
			hostOS = 'Fusion'
			
			-- Make a copy of the .pts file
			-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8/9 "bmd.scriptlib" libraries
			eyeon.copyfile(ptguiFile, pts)
		end
	elseif platform == 'Linux' then
		-- Running on Linux
		
		print('[Copy PTS File] [From] ' .. ptguiFile .. ' [To] ' .. pts)
		
		-- Check if Fusion Standalone or the Resolve Fusion page is active
		host = fusion:MapPath('Fusion:/')
		if string.lower(host):match('resolve') then
			hostOS = 'Resolve'
			
			command = 'cp "' .. ptguiFile .. '" "' .. pts .. '" '
			print('[Copy PTS File Command] ', command)
			os.execute(command)
		else
			hostOS = 'Fusion'
			
			-- Make a copy of the .pts file
			-- Perform a file copy using the Fusion 7 "eyeon.scriptlib" or Fusion 8/9 "bmd.scriptlib" libraries
			eyeon.copyfile(ptguiFile, pts)
		end
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
	
	-- Open up the file pointer for the input textfile
	-- outFile, err = io.open(pts,'w')
	-- if err then 
	-- 	print("[Error Opening File for Writing]")
	-- 	return
	-- end
	
	-- #-sourcemask
	searchString = '#%-sourcemask.*'
	
	-- Scan through the input textfile line by line
	maskCounter = 0
	lineCounter = 0
	for oneLine in io.lines(ptguiFile) do
		-- Check if we have found a match with the searchString
		if oneLine:match(searchString) then
			-- Open up the file pointer for the input textfile
			base64Filename = outputDirectory .. 'mask.' .. maskCounter .. '.txt'
			base64OutFile, err = io.open(base64Filename,'w')
			if err then 
				print('[Error Opening File for Writing] ' .. base64Filename)
				return
			else
				print('[Writing Mask] ' .. base64Filename)
			end
			
			-- Perform the regular expressions based line edit
			searchStringText = '#%-sourcemask '
			replaceStringText = ''
			oneLineOut = oneLine:gsub(searchStringText, replaceStringText)
			
			-- Write the base64 encoded mask to disk
			base64OutFile:write(oneLineOut,'\n')
			
			-- Close the file pointer on our output textfile
			base64OutFile:close()
			
			maskFrameNumber = string.format('%0' .. framePadding .. 'd', maskCounter+startOnFrameOne)
			
			-- Generate the output png image filename
			-- pngOutFilename = outputDirectory .. 'mask.' .. maskCounter .. '.png'
			pngOutFilename = eyeon.trimExtension(ptguiFile) .. '_mask_' .. maskFrameNumber .. frameExtensionNumber .. '.png'
			
			-- Redirect the output from the terminal to a log file
			outputLog = outputDirectory .. 'base64Decoder.txt'
			logCommand = ''
			if platform == 'Windows' then
				logCommand = ' ' .. '2>&1 | "' .. app:MapPath('Reactor:/Deploy/Bin/wintee/bin/wtee.exe') .. '" -a' .. ' "' .. outputLog.. '" '
			elseif platform == 'Mac' then
				logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
			elseif platform == 'Linux' then
				logCommand = ' ' .. '2>&1 | tee -a' .. ' "' .. outputLog.. '" '
			end
			
			-- Use the base64 terminal utility to decode the PNG formatted mask images
			command = ''
			if platform == 'Windows' then
				defaultbase64Program =  comp:MapPath('Reactor:/Deploy/Bin/cygwin/bin/base64.exe')
				-- This line assumes the KartaVR Cygwin "bin" folder is in the system %PATH% environment variable.
				-- defaultbase64Program = 'C:\\Program Files\\KartaVR\\tools\\cygwin\\bin\\base64.exe'
				base64Program = getPreferenceData('KartaVR.SendMedia.base64File', defaultbase64Program, printStatus)
				command = '"' .. base64Program .. '" -d -i "' .. base64Filename .. '" > "' .. pngOutFilename .. '" ' .. logCommand
				
				print('[base64 Command] ', command)
				os.execute(command)
			else
				base64Program = 'base64'
				command = base64Program .. ' -D -i "' .. base64Filename .. '" -o "' .. pngOutFilename .. '" ' --.. logCommand
				-- command = base64Program .. ' -D -i "' .. base64Filename .. '" -o "' .. pngOutFilename .. '" ' .. logCommand
				
				print('[base64 Command] ', command)
				os.execute(command)
			end
			
			
			-- Track the number of edits done
			maskCounter = maskCounter + 1
			
			if printStatus == 1 or printStatus == true then
				print('[Mask ' .. maskCounter .. '] ' .. oneLine)
			end
			
			-- Add a new mask to the table
			mask[maskCounter] = {id = cropCounter, pngFilename1 = pngOutFilename, base64Filename2 = base64Filename, lineNumber3 = lineCounter}
		end
		
		-- Track the progress through the file
		lineCounter = lineCounter + 1
	end
	
	print('[End of File] ' .. lineCounter)
	
	-- List the mask table contents
	-- if printStatus == 1 or printStatus == true then
		print('[Mask Table]')
		dump(mask)
	-- end
	
	-- Return a total of how many masks were found
	return maskCounter
end


-- Copy text to the operating system's clipboard
-- Example: CopyToClipboard('Hello World!')
function CopyToClipboard(textString)
	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	outputDirectory = comp:MapPath('Temp:\\KartaVR\\')
	clipboardTempFile = outputDirectory .. 'maskClipboardText.txt'

	-- Create the temp folder if required
	os.execute('mkdir "' .. outputDirectory..'"')

	-- Open up the file pointer for the output textfile
	outClipFile, err = io.open(clipboardTempFile,'w')
	if err then 
		print("[Error Opening Clipboard Temporary File for Writing]")
		return
	end
	
	outClipFile:write(textString,'\n')
	
	-- Close the file pointer on the output textfile
	outClipFile:close()
	
	if platform == 'Windows' then
		-- The Windows copy to clipboard command is "clip"
		command = 'clip < "' .. clipboardTempFile .. '"'
	elseif platform == 'Mac' then
		-- The Mac copy to clipboard command is "pbcopy"
		command = 'pbcopy < "' .. clipboardTempFile .. '"'
	elseif platform == 'Linux' then
		-- The Linux copy to clipboard command is "xclip"
		-- This requires a custom xclip tool install on Linux:
		
		-- Debian/Ubuntu:
		-- sudo apt-get install xclip
		
		-- Redhat/Centos/Fedora:
		-- yum install xclip
		command = 'cat "' .. clipboardTempFile .. '" | xclip -selection clipboard &'
	end
	
	if printStatus == 1 or printStatus == true then
		print('[Copy Text to Clipboard Command] ' .. command)
		print('[Clipboard] ' .. textString)
	end
	os.execute(command)
end

-- Add an extra loader node to the comp
function CreateLoaderNodes(nodeNumber, booleanName, loaderName, loaderFilename, loaderFormat, nodeOriginXPos, nodeOriginYPos, align)
	-- loaderFormat holds a value like 'TiffFormat'
	-- default node starting X/Y Pos = 605, 214.5
	
	-- Node spacing per row/column
	nodeXOffset = 110
	nodeYOffset = 33.5
	
	-- Node Transforms
	if align == 'left' then
		-- Position the loader node by calculating the node index # that is being added
		loaderXPos = nodeOriginXPos
		loaderYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- The boolean node goes to the left of the loader
		boolNodeXPos = loaderXPos - nodeXOffset
		boolNodeYPos = loaderYPos
	elseif align == 'right' then
		-- Position the loader node by calculating the node index # that is being added
		loaderXPos = nodeOriginXPos
		loaderYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- The boolean node goes to the right of the loader
		boolNodeXPos = loaderXPos + nodeXOffset
		boolNodeYPos = loaderYPos
	elseif align == 'upwards' then
		-- Position the loader node by calculating the node index # that is being added
		loaderXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		loaderYPos = nodeOriginYPos
	
		-- The boolean node goes to the above of the loader
		boolNodeXPos = loaderXPos
		boolNodeYPos = loaderYPos - nodeYOffset
	elseif align == 'downwards' then
		-- Position the loader node by calculating the node index # that is being added
		loaderXPos = nodeOriginXPos + (nodeXOffset * nodeNumber)
		loaderYPos = nodeOriginYPos
		
		-- The boolean node goes to the below of the loader
		boolNodeXPos = loaderXPos
		boolNodeYPos = loaderYPos + nodeYOffset
	else
		-- Position the loader node by calculating the node index # that is being added
		loaderXPos = nodeOriginXPos
		loaderYPos = nodeOriginYPos + (nodeYOffset * nodeNumber)
		
		-- boolean node goes to the right of the loader
		boolNodeXPos = loaderXPos + nodeXOffset
		boolNodeYPos = loaderYPos
	end
	
	
	nodeString = ''
	
	-- Escape the backwards path slashes on Windows
	if platform == 'Windows' then
		loaderFilename = loaderFilename:gsub('\\', '\\\\')
	end
	
	-- Add a Loader node
	nodeString = nodeString .. '\t\t' .. loaderName .. ' = Loader {\n'
	nodeString = nodeString .. '\t\t\tClips = {\n'
	nodeString = nodeString .. '\t\t\t\tClip {\n'
	nodeString = nodeString .. '\t\t\t\t\tID = "Clip1",\n'
	nodeString = nodeString .. '\t\t\t\t\tFilename = "' .. loaderFilename .. '",\n'
	nodeString = nodeString .. '\t\t\t\t\tFormatID = "' .. loaderFormat .. '",\n'
	
	-- Does the final frame padding start on frame 1 or frame 0?
	nodeString = nodeString .. '\t\t\t\t\tStartFrame = ' .. frameExtensionFusionStartFrame .. ',\n'
	
	nodeString = nodeString .. '\t\t\t\t\tLengthSetManually = true,\n'
	nodeString = nodeString .. '\t\t\t\t\tTrimIn = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tTrimOut = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tExtendFirst = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tExtendLast = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tLoop = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tAspectMode = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tDepth = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tTimeCode = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tGlobalStart = 0,\n'
	nodeString = nodeString .. '\t\t\t\t\tGlobalEnd = 0\n'
	nodeString = nodeString .. '\t\t\t}\n'
	nodeString = nodeString .. '\t\t},\n'
	nodeString = nodeString .. '\t\tCtrlWZoom = false,\n'
	nodeString = nodeString .. '\t\tInputs = {\n'
	nodeString = nodeString .. '\t\t\tMissingFrames = Input { Value = 1, },\n'
	nodeString = nodeString .. '\t\t\t["Gamut.SLogVersion"] = Input { Value = FuID { "SLog2" }, },\n'
	nodeString = nodeString .. '\t\t},\n'
	
	nodeString = nodeString .. '\t\t\tViewInfo = OperatorInfo { Pos = { ' .. loaderXPos .. ', ' .. loaderYPos .. ' } },\n'
	nodeString = nodeString .. '\t\t},\n'
	
	-- Add a Channel Boolean Node
	nodeString = nodeString .. '\t\t' .. booleanName .. ' = ChannelBoolean {\n'
	nodeString = nodeString .. '\t\t\tCtrlWZoom = false,\n'
	nodeString = nodeString .. '\t\t\tNameSet = true,\n'
	nodeString = nodeString .. '\t\t\tInputs = {\n'
	nodeString = nodeString .. '\t\t\t\tToAlpha = Input { Value = 13, },\n'
	nodeString = nodeString .. '\t\t\t\tBackground = Input {\n'
	nodeString = nodeString .. '\t\t\t\t\tSourceOp = "' .. loaderName .. '",\n'
	nodeString = nodeString .. '\t\t\t\t\tSource = "Output",\n'
	nodeString = nodeString .. '\t\t\t\t},\n'
	nodeString = nodeString .. '\t\t\t},\n'
	nodeString = nodeString .. '\t\tViewInfo = OperatorInfo { Pos = { ' .. boolNodeXPos .. ', ' .. boolNodeYPos .. ' } },\n'
	nodeString = nodeString .. '\t\t},\n' -- optional trailing comma
	
	return nodeString
end
	
-- Create the new mask image nodes and channel booleans for the comp
function AddMaskNodes()
	-- Check the Node Layout aka. "Build Direction" setting
	if nodeDirection == 0 then
		-- Skip Adding Nodes
		return
	elseif nodeDirection == 1 then
		-- Build Nodes Left
		nodeAlignment = 'left'
	elseif nodeDirection == 2 then
		-- Build Nodes Right
		nodeAlignment = 'right'
	elseif nodeDirection == 3 then
		-- Build Nodes Upwards
		nodeAlignment = 'upwards'
	elseif nodeDirection == 4 then
		-- Build Nodes Downwards
		nodeAlignment = 'downwards'
	else
		-- Fallback default of Build Nodes Downwards
		nodeAlignment = 'downwards'
	end
	
	print('[Node Layout / Build Direction] ' .. nodeAlignment)
	
	-- Node Positions - read from the Fusion cursor / last node position in the future.
	nodeX = 605
	nodeY = 346
	
	-- The loader node media basefolder
	-- Todo: Double check there is a trailing folder slash in the filepath!!
	-- mediaBaseFolder = ptsFolder
	
	-- -----------------------------------------
	-- Create the block of loader node elements
	-- -----------------------------------------
	
	-- Open the Fusion comp tags
	loaderNodes = '{\n'
	loaderNodes = loaderNodes .. '\tTools = ordered() {\n'
	
	-- Loop through loading each of the mask images
	-- Total Mask Loader Node Count = Total Nodes -
	totalNodes = maskCounter - 1
	
	-- Track the current node for the placement in the scene and the node name
	for nodeNumber = 0, totalNodes do
		maskFrameNumber = string.format('%0' .. framePadding .. 'd', nodeNumber+startOnFrameOne)
		
		-- Generate the current mask image filename assuming no mask number frame padding
		mediaClipName = eyeon.trimExtension(ptguiFile) .. '_mask_' .. maskFrameNumber .. frameExtensionNumber .. '.png'
		
		if eyeon.fileexists(mediaClipName) then
			-- Try finding the mask image with no padding first
			print('[Media File Found] ' .. mediaClipName)
		end
		
		nodeLoaderName = 'MaskLoader' .. nodeNumber
		nodeBooleanName = 'MaskChannelBoolean' .. nodeNumber
		
		if err == true then
			-- Skipping the loader node as the media is missing
			print('[Skipping Loader Node] ' .. nodeLoaderName .. ' [Media] ' .. mediaClipName)
		else
			-- Add the newest loader node
			print('[Adding Loader Node] ' .. nodeLoaderName .. ' [Media] ' .. mediaClipName)
			loaderNodes = loaderNodes .. CreateLoaderNodes(nodeNumber, nodeBooleanName, nodeLoaderName, mediaClipName, imageFormatFusion, nodeX, nodeY, nodeAlignment)
		end
	end
	
	
	-- Close the Fusion comp tags
	loaderNodes = loaderNodes .. '\t}\n}'
	
	print('[Creating Loader Nodes]')
	-- print(loaderNodes)
	
	-- Add the new loader nodes to the system clipboard buffer
	print('[Copying Loader Nodes to Clipboard]')
	CopyToClipboard(loaderNodes)
end

-- ------------------------------------
-- Main
-- ------------------------------------

print ('PTGui Mask Importer is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

-- Check if Fusion is running
if not fusion then
	print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
end

-- Lock the comp flow area
comp:Lock()

-- Search for the line #-sourcemask that holds the custom PTGui masking information
--searchString = '#%-sourcemask.*'
--replaceString = ''
--regexFile(pts, searchString, replaceString)


-- Show the "PTGui Mask Importer" dialog window
-- Note: The AskUser dialog settings are covered on page 63 of the Fusion Scripting Guide
compPath = dirname(comp:GetAttrs().COMPS_FileName)
compPrefs = comp:GetPrefs("Comp.FrameFormat")

-- ------------------------------------
-- Load the comp specific preferences
-- ------------------------------------

-- Share this text field with the PTGui Project Importer Script
-- PTGui Project File - use the comp path as the default starting value if the preference doesn't exist yet
ptguiFile = comp:MapPath(getPreferenceData('KartaVR.PTGuiImporter.File', compPath, printStatus))
nodeDirection = getPreferenceData('KartaVR.PTGuiMaskImporter.NodeDirection', 2, printStatus)
frameExtension = getPreferenceData('KartaVR.PTGuiMaskImporter.FrameExtension', 1, printStatus)
framePadding = getPreferenceData('KartaVR.PTGuiMaskImporter.FramePadding', 4, printStatus)
startOnFrameOne = getPreferenceData('KartaVR.PTGuiMaskImporter.StartOnFrameOne', 1, printStatus)
openOutputFolder = getPreferenceData('KartaVR.PTGuiMaskImporter.OpenOutputFolder', 1, printStatus)

-- Node Build Direction
nodeDirectionList = {'Skip Adding Nodes', 'Build Nodes Left', 'Build Nodes Right', 'Build Nodes Upwards', 'Build Nodes Downwards'}

-- Frame Extension List
frameExtensionList = {'<prefix>_mask_#.ext', '<prefix>_mask_#.0000.ext', '<prefix>_mask_#.0001.ext'}

msg = 'This script will extract panoramic masking PNG images from a PTGui .pts project file.'

d = {}
d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 3, Wrap = true, Default = msg}
d[2] = {'File', Name = 'PTGui Project File', 'FileBrowse', Default = ptguiFile}
d[3] = {'NodeDirection', Name = 'Node Layout', 'Dropdown', Default = nodeDirection, Options = nodeDirectionList}
d[4] = {'FrameExtension', Name = 'Frame Ext.', 'Dropdown', Default = frameExtension, Options = frameExtensionList}
d[5] = {'FramePadding', Name = 'Frame Padding', 'Slider', Default = framePadding, Integer = true, Min = 0, Max = 8}
d[6] = {'StartOnFrameOne', Name = 'Mask Numbering Starts on 1', 'Checkbox', Default = startOnFrameOne, NumAcross = 2}
d[7] = {'OpenOutputFolder', Name = 'Open Output Folder', 'Checkbox', Default = openOutputFolder, NumAcross = 1}

dialog = comp:AskUser('PTGui Mask Importer', d)
if dialog == nil then
	print('You cancelled the dialog!')
	err = true
	
	-- Unlock the comp flow area
	comp:Unlock()
	return
else
	-- Debug - List the output from the AskUser dialog window
	-- dump(dialog)
	
	-- Share this text field with the PTGui Project Importer Script
	ptguiFile = comp:MapPath(dialog.File)
	setPreferenceData('KartaVR.PTGuiImporter.File', ptguiFile, printStatus)
	
	nodeDirection = dialog.NodeDirection
	setPreferenceData('KartaVR.PTGuiMaskImporter.NodeDirection', nodeDirection, printStatus)
	
	frameExtension = dialog.FrameExtension
	setPreferenceData('KartaVR.PTGuiMaskImporter.FrameExtension', frameExtension, printStatus)
	
	framePadding = dialog.FramePadding
	setPreferenceData('KartaVR.PTGuiMaskImporter.FramePadding', framePadding, printStatus)
	
	startOnFrameOne = dialog.StartOnFrameOne
	setPreferenceData('KartaVR.PTGuiMaskImporter.StartOnFrameOne', startOnFrameOne, printStatus)
	
	openOutputFolder = dialog.OpenOutputFolder
	setPreferenceData('KartaVR.PTGuiMaskImporter.OpenOutputFolder', openOutputFolder, printStatus)
	
	print('[Frame Padding] ' .. framePadding)
	print('[Start View Numbering on 1] ' .. startOnFrameOne)
	print('[Open Output Folder] ' .. openOutputFolder)
end


-- Todo: Add a sanity check to make sure the PTGui file actually exists on disk
print('[PTGui Project File] ' .. dialog.File)

-- Check if the PTGui filename ends with the .pts file extension
searchString = 'pts$'
if ptguiFile:match(searchString) ~= nil then
-- ptguiFileExtension = eyeon.getextension(ptguiFile)
-- if ptguiFileExtension == 'pts' then
	
	print('[A PTGui project file was selected and it has the .pts file extension.]')
	
	-- The PTGui .pts project file is missing
	if eyeon.fileexists(ptguiFile) == false then
		print('[The PTGui project file you selected is missing]')
		
		-- Unlock the comp flow area
		comp:Unlock()
		
		return
	end
else
	print('[A PTGui project file was not selected.]')
	
	-- Unlock the comp flow area
	comp:Unlock()
	
	return
end

-- PTGui project file directory
ptsFolder = dirname(ptguiFile)

-- The mask image final sequence frame numbers
-- This starts on either none, frame 0000, or frame 0001
frameExtensionNumber = ''
if frameExtension == 0 then
 -- None (skip adding a frame extension number)
	frameExtensionNumber = ''
	frameExtensionFusionStartFrame = 0
elseif frameExtension == 1 then
	-- Start the image sequence on frame 0
	frameExtensionNumber = '.0000'
	frameExtensionFusionStartFrame = 0
else
	-- Start the image sequence on frame 1
	frameExtensionNumber = '.0001'
	frameExtensionFusionStartFrame = 1
end

-- Hard code the PTGui mask image format to PNG
imageFormat = 3

-- Select the image file format
if imageFormat == 0 then
	imageFormatExt = 'tif'
	imageFormatFusion = 'TiffFormat'
elseif imageFormat == 1 then
	imageFormatExt = 'tga'
	imageFormatFusion = 'TargaFormat'
elseif imageFormat == 2 then
	imageFormatExt = 'bmp'
	imageFormatFusion = 'BMPFormat'
elseif imageFormat == 3 then
	imageFormatExt = 'png'
	imageFormatFusion = 'PNGFormat'
elseif imageFormat == 4 then
	imageFormatExt = 'jpg'
	imageFormatFusion = 'JpegFormat'
else
	-- Fallback option
	imageFormatExt = 'tif'
	imageFormatFusion = 'TiffFormat'
end

-- Extract the Masks
msk = sourcemaskRegex(ptguiFile, framePadding, startOnFrameOne)
print('[Masks Found] ' .. msk)

-- Create the new mask image nodes and channel booleans for the comp
AddMaskNodes()

-- Unlock the comp flow area
comp:Unlock()


-- Open the PTGui .pts folder as an Explorer/Finder/Nautilus folder view
if openOutputFolder == 1 then
	if fu_major_version >= 8 then
		-- The script is running on Fusion 8+ so we will use the fileexists command
		if eyeon.fileexists(ptsFolder) then
			openDirectory(ptsFolder)
		else
			print('[Output Directory Missing] ', ptsFolder)
			err = true
		end
	else
		-- The script is running on Fusion 6/7 so we will use the direxists command
		if eyeon.direxists(ptsFolder) then
			openDirectory(ptsFolder)
		else
			print('[Output Directory Missing] ', ptsFolder)
			err = true
		end
	end
end


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
